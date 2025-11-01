#!/usr/bin/env python3
"""
Pipeline Runner - Main orchestrator for the cluster analysis pipeline.

Reads rule files, triggers Ruby raster export, processes rasters with Python,
generates visualizations and exports results.
"""

import os
import sys
import subprocess
import logging
import time
from datetime import datetime
from typing import Dict, List, Any, Optional
import json
import argparse

from rule_parser import RuleParser, RuleConfig
from cluster_processor import ClusterProcessor
from visualizer import RasterVisualizer, VisualizationConfig
from exporter import CombinedExporter
from verify_pipeline_results import PipelineVerifier
from crash_recovery import CrashRecovery, SafeErrorLogger


class PipelineRunner:
    """Main orchestrator for the cluster analysis pipeline."""
    
    def __init__(self, 
                 scripts_dir: str = "scripts",
                 data_dir: str = "data/output",
                 icm_exchange_path: str = "output/ICM_Release.x64/ICMExchange.exe",
                 run_simulations: bool = False,
                 monitor_mode: bool = False,
                 disable_git: bool = False):
        self.scripts_dir = scripts_dir
        self.data_dir = data_dir
        self.icm_exchange_path = icm_exchange_path
        self.run_simulations = run_simulations
        self.monitor_mode = monitor_mode
        self.disable_git = disable_git
        
        # Determine project root - parent directory of scripts_dir
        # If scripts_dir is relative, resolve from current working directory
        scripts_abs = os.path.abspath(scripts_dir)
        self.project_root = os.path.dirname(scripts_abs) if os.path.basename(scripts_abs) == 'scripts' else os.path.abspath('.')
        
        # Initialize components
        self.rule_parser = RuleParser(scripts_dir)
        self.cluster_processor = ClusterProcessor(data_dir)
        self.visualizer = RasterVisualizer(os.path.join(data_dir, "viz"))
        self.exporter = CombinedExporter(os.path.join(data_dir, "results"))
        self.verifier = PipelineVerifier(data_dir)
        
        # Set up logging
        self.logger = self._setup_logging()

        # Markdown log setup - use active folder for running pipelines
        logs_dir = os.path.join(self.data_dir, "logs", "active")
        os.makedirs(logs_dir, exist_ok=True)
        self.md_log_path = os.path.join(logs_dir, f"pipeline_run_{datetime.now().strftime('%Y%m%d_%H%M%S')}.md")
        self._md_init()
        
        # Results tracking
        self.results = []
        self.run_manifest = {
            'start_time': None,
            'end_time': None,
            'rules_processed': [],
            'errors': [],
            'statistics': {}
        }
    
    def _setup_logging(self) -> logging.Logger:
        """Set up logging for the pipeline."""
        log_dir = os.path.join(self.data_dir, "logs", "active")
        os.makedirs(log_dir, exist_ok=True)
        
        # Create logger
        logger = logging.getLogger('pipeline')
        logger.setLevel(logging.INFO)
        
        # Create formatter
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        
        # File handler
        log_file = os.path.join(log_dir, f"pipeline_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log")
        file_handler = logging.FileHandler(log_file)
        file_handler.setFormatter(formatter)
        logger.addHandler(file_handler)
        
        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        logger.addHandler(console_handler)
        
        return logger

    def _md_write(self, text: str) -> None:
        try:
            with open(self.md_log_path, 'a', encoding='utf-8') as f:
                f.write(text + "\n")
        except Exception as e:
            self.logger.debug(f"Failed to write MD log: {e}")

    def _md_init(self) -> None:
        self._md_write(f"# Cluster Analysis Pipeline Run")
        self._md_write("")

        # Load pipeline config for naming
        self._cfg = {}
        try:
            cfg_path = os.path.join(self.scripts_dir, 'pipeline_config.json')
            if os.path.exists(cfg_path):
                with open(cfg_path, 'r', encoding='utf-8-sig') as f:
                    self._cfg = json.load(f)
        except Exception as e:
            self.logger.warning(f"Could not load pipeline_config.json for naming: {e}")
    def _database_name(self) -> str:
        mp = self._cfg.get('model_path') or ''
        try:
            base = os.path.splitext(os.path.basename(mp))[0]
            return base or 'database'
        except Exception:
            return 'database'

    def _group_name(self) -> str:
        name = (self._cfg.get('source_group_name') or self._cfg.get('clusters_group_name') or '').strip()
        if name:
            return name
        return self._ensure_ungrouped_group()

    def _ensure_ungrouped_group(self) -> str:
        """Ensure an Ungrouped_XX folder exists for models with no group, per database.
        Picks the next available Ungrouped_01, Ungrouped_02, ... under data/output/<db>.
        """
        db = self._database_name()
        db_root = os.path.join(self.data_dir, db)
        os.makedirs(db_root, exist_ok=True)
        prefix = 'Ungrouped_'
        existing = set()
        try:
            for entry in os.listdir(db_root):
                p = os.path.join(db_root, entry)
                if os.path.isdir(p) and entry.startswith(prefix):
                    existing.add(entry)
        except Exception:
            pass
        idx = 1
        while True:
            candidate = f"{prefix}{idx:02d}"
            if candidate not in existing:
                try:
                    os.makedirs(os.path.join(db_root, candidate), exist_ok=True)
                except Exception:
                    # Best-effort creation; even if it fails, return the name
                    pass
                return candidate
            idx += 1

    def _run_name_for_sim(self, sim_id: int) -> str:
        # If we don't have the run name, fall back to sim_<id>
        return f"sim_{sim_id}"

    def _structured_root(self, sim_id: Optional[int] = None) -> str:
        parts = [self.data_dir, self._database_name(), self._group_name()]
        if sim_id is not None:
            parts.append(self._run_name_for_sim(sim_id))
        return os.path.join(*parts)
        self._md_write(f"- Start: {datetime.now().isoformat()}")
        self._md_write(f"- Data dir: `{self.data_dir}`")
        self._md_write(f"- Scripts dir: `{self.scripts_dir}`")
        self._md_write(f"- Run simulations: {self.run_simulations}")
        self._md_write("")
    
    def run_ruby_export(self, sim_id: int, attributes: List[str], output_dir: str) -> bool:
        """Run Ruby script to export rasters via ICMExchange."""
        try:
            # Prepare command with absolute script path and default cwd
            script_path = os.path.abspath(os.path.join(self.scripts_dir, "export_rasters.rb"))
            cmd = [
                self.icm_exchange_path,
                script_path,
                str(sim_id),
                output_dir,
                ','.join(attributes)
            ]
            self.logger.info(f"Running Ruby export: {' '.join(cmd)}")
            
            result = subprocess.run(
                cmd,
                cwd=self.project_root,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                self.logger.info("Ruby export completed successfully")
                self.logger.info(f"Export output: {result.stdout}")
                return True
            else:
                self.logger.error(f"Ruby export failed with return code {result.returncode}")
                self.logger.error(f"Error output: {result.stderr}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error running Ruby export: {e}")
            return False
    
    def run_results_csv_export(self, sim_id: int, output_dir: str, selection_json: Optional[str] = None) -> bool:
        """Run Ruby script to export simulation results to CSV via ICMExchange."""
        try:
            script_path = os.path.abspath(os.path.join(self.scripts_dir, "export_results_csv.rb"))
            cmd = [self.icm_exchange_path, script_path, str(sim_id), output_dir]
            if selection_json:
                cmd.append(selection_json)
            self.logger.info(f"Running CSV export: {' '.join(cmd)}")
            result = subprocess.run(cmd, cwd=self.project_root, capture_output=True, text=True)
            if result.returncode == 0:
                if result.stdout.strip():
                    self.logger.info(result.stdout)
                return True
            else:
                self.logger.error(f"CSV export failed: rc={result.returncode}\n{result.stderr}")
                return False
        except Exception as e:
            self.logger.error(f"Error running CSV export: {e}")
            return False

    def run_ruby_script(self, script_name: str, *args) -> bool:
        """Run a Ruby script via ICMExchange."""
        try:
            script_path = os.path.abspath(os.path.join(self.scripts_dir, script_name))
            cmd = [self.icm_exchange_path, script_path] + list(args)
            self.logger.info(f"Running Ruby script: {' '.join(cmd)}")
            
            result = subprocess.run(
                cmd,
                cwd=self.project_root,
                capture_output=True,
                text=True
            )
            
            if result.returncode == 0:
                self.logger.info("Ruby script completed successfully")
                if result.stdout.strip():
                    self.logger.info(f"Output: {result.stdout}")
                return True
            else:
                self.logger.error(f"Ruby script failed with return code {result.returncode}")
                self.logger.error(f"Error output: {result.stderr}")
                return False
                
        except Exception as e:
            self.logger.error(f"Error running Ruby script: {e}")
            return False
    
    def maybe_setup_cluster_network(self) -> bool:
        """Copy source network to Clusters group if needed and not already exists."""
        if not self.run_simulations:
            return True
        
        self.logger.info("Setting up cluster network copy...")
        self._md_write("\n### Cluster Network Setup")
        
        # Load config for group/network names
        try:
            cfg_path = os.path.join(self.scripts_dir, 'pipeline_config.json')
            with open(cfg_path, 'r', encoding='utf-8-sig') as f:
                cfg = json.load(f)
                src_group = cfg.get('source_group_name', '2D Demo - 2d rain')
                src_net = cfg.get('source_network_name', '5k')
                dest_group = cfg.get('clusters_group_name', 'Clusters')
        except Exception as e:
            self.logger.error(f"Could not load config: {e}")
            return False
        
        # Copy network to Clusters group
        success = self.run_ruby_script(
            'copy_network_to_group_by_name.rb',
            src_group,
            src_net,
            dest_group
        )
        
        if success:
            self._md_write(f"- Copied network '{src_group}>{src_net}' to '{dest_group}'")
        else:
            self._md_write("- Network copy failed or already exists")
        
        return success
    
    def maybe_run_simulations(self) -> Optional[int]:
        """Create/copy and launch simulation runs if enabled. Returns Run ID or None."""
        if not self.run_simulations:
            self.logger.info("Simulation runs disabled, skipping")
            return None
        
        self.logger.info("Creating and launching simulation runs...")
        self._md_write("\n### Simulation Runs")
        
        # Load config
        try:
            cfg_path = os.path.join(self.scripts_dir, 'pipeline_config.json')
            with open(cfg_path, 'r', encoding='utf-8-sig') as f:
                cfg = json.load(f)
                src_group = cfg.get('source_group_name', '2D Demo - 2d rain')
                dest_group = cfg.get('clusters_group_name', 'Clusters')
        except Exception as e:
            self.logger.error(f"Could not load config: {e}")
            return None
        
        # For now, we need the source Run name - this would come from user input or config
        # For initial implementation, we'll skip this step and log that manual input is needed
        self.logger.warning("Automatic simulation runs require source Run name")
        self._md_write("- Automatic simulation runs not yet fully implemented")
        self._md_write("- Requires manual setup: create Run in Clusters group via UI or Ruby script")
        
        return None
    
    def process_rule(self, rule_config: RuleConfig, export_rasters: bool = True) -> Optional[Dict[str, Any]]:
        """Process a single rule configuration."""
        self.logger.info(f"Processing rule: {rule_config.name}")
        self._md_write(f"\n## Rule: `{rule_config.name}` ({rule_config.analysis_type.value})")
        
        try:
            # Export rasters if needed
            if export_rasters:
                # Determine which simulations to export
                if rule_config.analysis_type.value == "comparison":
                    sim_ids = [rule_config.baseline_id or 1, rule_config.candidate_id or 2]
                else:
                    sim_ids = [rule_config.baseline_id or 1]
                
                # Export rasters for each simulation
                # Use raster/db/grupa/run/sim_<id> structure (instead of data_dir/db/grupa/run/rasters)
                for sim_id in sim_ids:
                    # Build raster path: raster/db/grupa/run/sim_<id>
                    # Note: _run_name_for_sim already returns sim_<id>, so we use it directly
                    run_name = self._run_name_for_sim(sim_id)
                    raster_parts = ["raster", self._database_name(), self._group_name(), run_name]
                    output_dir = os.path.join(self.data_dir, *raster_parts)
                    os.makedirs(output_dir, exist_ok=True)
                    
                    success = self.run_ruby_export(sim_id, rule_config.attributes, output_dir)
                    if not success:
                        self.logger.error(f"Failed to export rasters for simulation {sim_id}")
                        self._md_write(f"- Export failed for simulation {sim_id}")
                        return None
                    else:
                        self._md_write(f"- Exported rasters for simulation {sim_id} → `{output_dir}`")
            
            # Optionally export CSV results (2D/1D) for downstream analytics
            try:
                cfg_path = os.path.join(self.scripts_dir, 'pipeline_config.json')
                export_csv = False
                csv_selection = None
                if os.path.exists(cfg_path):
                    with open(cfg_path, 'r', encoding='utf-8-sig') as f:
                        cfg = json.load(f)
                        export_csv = cfg.get('export_csv', False)
                        sel = cfg.get('csv_selection', None)
                        if sel is not None:
                            csv_selection = json.dumps(sel)
                if export_csv:
                    for sim_id in ( [rule_config.baseline_id or 1] if rule_config.analysis_type.value != 'comparison' else [rule_config.baseline_id or 1, rule_config.candidate_id or 2] ):
                        csv_dir = os.path.join(self.data_dir, "experiments", "csv", f"sim_{sim_id}")
                        os.makedirs(csv_dir, exist_ok=True)
                        if self.run_results_csv_export(sim_id, csv_dir, csv_selection):
                            self._md_write(f"- Exported CSV results for simulation {sim_id} → `{csv_dir}`")
                        else:
                            self._md_write(f"- CSV export failed for simulation {sim_id}")
            except Exception as e:
                self.logger.warning(f"CSV export step skipped due to error: {e}")

            # Re-point outputs to structured layout per first sim (or None)
            target_sim = (sim_ids[0] if 'sim_ids' in locals() and sim_ids else None)
            structured_root = self._structured_root(target_sim)
            self.visualizer = RasterVisualizer(os.path.join(structured_root, "viz"))
            self.exporter = CombinedExporter(os.path.join(structured_root, "results"))

            # Process the rule
            result = self.cluster_processor.process_rule(rule_config)
            self.results.append(result)
            self._md_write(f"- Clusters: {len(result.clusters)}")
            
            # Create visualizations
            viz_config = VisualizationConfig()
            viz_paths = {
                'overlay': self.visualizer.create_cluster_overlay(result, viz_config),
                'heatmap': self.visualizer.create_heatmap(result, viz_config),
                'difference': self.visualizer.create_difference_map(result, viz_config),
                'animation': self.visualizer.create_animation(result, viz_config)
            }
            self._md_write("- Visualizations:")
            for k, v in viz_paths.items():
                if v:
                    self._md_write(f"  - {k}: `{v}`")
            
            # Export results
            exported_files = self.exporter.export_all(result, viz_paths)
            if exported_files:
                self._md_write("- Exports:")
                for p in exported_files:
                    self._md_write(f"  - `{p}`")
            
            # Track results
            rule_result = {
                'rule_name': rule_config.name,
                'analysis_type': rule_config.analysis_type.value,
                'clusters_count': len(result.clusters),
                'statistics': result.statistics,
                'exported_files': exported_files,
                'visualization_paths': viz_paths,
                'processing_time': time.time()
            }
            
            # Run verification
            self.logger.info(f"Verifying output for rule: {rule_config.name}")
            try:
                rule_config_dict = {
                    'outputs': rule_config.outputs.__dict__ if hasattr(rule_config.outputs, '__dict__') else rule_config.outputs
                }
                verification_result, verification_log = self.verifier.verify_and_log(
                    rule_config.name,
                    rule_config_dict,
                    os.path.join(self.data_dir, "logs", "active")
                )
                
                # Add verification status to rule result
                rule_result['verification'] = {
                    'status': verification_result.get('overall_status', 'unknown'),
                    'passed_checks': verification_result.get('summary', {}).get('passed_checks', 0),
                    'total_checks': verification_result.get('summary', {}).get('total_checks', 0),
                    'log_file': verification_log
                }
                
                verification_status = verification_result.get('overall_status', 'unknown')
                if verification_status == 'passed':
                    self._md_write("- Verification: ✅ passed")
                elif verification_status == 'partial':
                    self._md_write("- Verification: ⚠️ partial")
                else:
                    self._md_write("- Verification: ❌ failed")
                    self.logger.warning(f"Verification failed for rule: {rule_config.name}")
                    # Add to manifest errors but don't fail the rule
                    self.run_manifest['errors'].append(f"Verification failed for rule {rule_config.name}: see {verification_log}")
                
                self._md_write(f"- Verification log: `{verification_log}`")
                
            except Exception as e:
                self.logger.warning(f"Error during verification: {e}")
                rule_result['verification'] = {
                    'status': 'error',
                    'error': str(e)
                }
                self._md_write(f"- Verification: ❌ error ({e})")
            
            self.run_manifest['rules_processed'].append(rule_result)
            
            self.logger.info(f"Successfully processed rule: {rule_config.name}")
            self._md_write("- Status: success")
            return rule_result
            
        except Exception as e:
            error_msg = f"Error processing rule {rule_config.name}: {e}"
            self.logger.error(error_msg)
            self.run_manifest['errors'].append(error_msg)
            self._md_write(f"- Status: failed\n- Error: {e}")
            return None
    
    def run_pipeline(self, rule_names: Optional[List[str]] = None, export_rasters: bool = True) -> Dict[str, Any]:
        """Run the complete pipeline for specified rules."""
        self.logger.info("Starting cluster analysis pipeline")
        self.run_manifest['start_time'] = datetime.now().isoformat()
        
        try:
            # Setup cluster network if simulations are enabled
            if self.run_simulations:
                if not self.maybe_setup_cluster_network():
                    self.logger.warning("Failed to setup cluster network, continuing anyway")
            
            # Parse all rules
            all_rules = self.rule_parser.parse_all_rules()
            
            if not all_rules:
                self.logger.warning("No rules found to process")
                return self.run_manifest
            
            # Filter rules if specified
            if rule_names:
                rules_to_process = [r for r in all_rules if r.name in rule_names]
                if not rules_to_process:
                    self.logger.warning(f"No rules found matching names: {rule_names}")
                    return self.run_manifest
            else:
                rules_to_process = all_rules
            
            self.logger.info(f"Processing {len(rules_to_process)} rules")
            
            # Process each rule
            successful_rules = 0
            for rule_config in rules_to_process:
                result = self.process_rule(rule_config, export_rasters)
                if result:
                    successful_rules += 1
                
                # If simulations are enabled, attempt to run them (currently placeholder)
                if self.run_simulations and result:
                    self.maybe_run_simulations()
            
            # Generate summary report
            if self.results:
                summary_report_path = self.exporter.create_summary_report(self.results)
                self.run_manifest['summary_report'] = summary_report_path
                self._md_write(f"\n### Summary Report\n- `{summary_report_path}`")
            
            # Finalize manifest
            self.run_manifest['end_time'] = datetime.now().isoformat()
            self.run_manifest['statistics'] = {
                'total_rules': len(rules_to_process),
                'successful_rules': successful_rules,
                'failed_rules': len(rules_to_process) - successful_rules,
                'total_clusters': sum(len(r.clusters) for r in self.results)
            }
            
            # Save manifest - use config/active folder for active runs
            config_dir = os.path.join(self.data_dir, "config", "active")
            os.makedirs(config_dir, exist_ok=True)
            manifest_path = os.path.join(config_dir, f"run_manifest_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
            with open(manifest_path, 'w', encoding='utf-8') as f:
                json.dump(self.run_manifest, f, indent=2)
            
            self.logger.info(f"Pipeline completed successfully. Processed {successful_rules}/{len(rules_to_process)} rules")
            self.logger.info(f"Run manifest saved: {manifest_path}")
            self._md_write("\n---")
            self._md_write("### Run Statistics")
            stats = self.run_manifest['statistics']
            self._md_write(f"- Rules: {stats.get('successful_rules',0)}/{stats.get('total_rules',0)}")
            self._md_write(f"- Total clusters: {stats.get('total_clusters',0)}")
            if self.run_manifest['errors']:
                self._md_write("- Errors:")
                for err in self.run_manifest['errors']:
                    self._md_write(f"  - {err}")
            self._md_write(f"\nLog file: `{self.md_log_path}`")
            
            return self.run_manifest
            
        except Exception as e:
            self.logger.error(f"Pipeline failed: {e}")
            self.run_manifest['end_time'] = datetime.now().isoformat()
            self.run_manifest['errors'].append(str(e))
            raise
    
    def run_single_rule(self, rule_name: str, export_rasters: bool = True) -> Optional[Dict[str, Any]]:
        """Run pipeline for a single rule."""
        rule_config = self.rule_parser.get_rule_by_name(rule_name)
        if not rule_config:
            self.logger.error(f"Rule not found: {rule_name}")
            return None
        
        return self.process_rule(rule_config, export_rasters)
    
    def list_available_rules(self) -> List[str]:
        """List all available rule names."""
        rules = self.rule_parser.parse_all_rules()
        return [rule.name for rule in rules]


def main():
    """Main entry point for the pipeline."""
    parser = argparse.ArgumentParser(description='Cluster Analysis Pipeline')
    parser.add_argument('--rules', nargs='+', help='Specific rules to process')
    parser.add_argument('--no-export', action='store_true', help='Skip raster export step')
    parser.add_argument('--list-rules', action='store_true', help='List available rules')
    parser.add_argument('--scripts-dir', default='scripts', help='Scripts directory')
    parser.add_argument('--data-dir', default='data/output', help='Data output directory')
    parser.add_argument('--icm-exchange', default='output/ICM_Release.x64/ICMExchange.exe', 
                       help='Path to ICMExchange executable')
    parser.add_argument('--run-simulations', action='store_true',
                       help='Enable automatic simulation runs (default: disabled)')
    parser.add_argument('--monitor-mode', action='store_true',
                       help='Enable monitor/agent mode to wait for incoming data')
    parser.add_argument('--disable-git', action='store_true',
                       help='Disable any git-related operations (demo mode)')
    parser.add_argument('--model-path', type=str,
                       help='Path to .icmm model file (bypasses waiting for model)')
    parser.add_argument('--skip-model-wait', action='store_true',
                       help='Skip waiting for model in standalone folder')
    
    args = parser.parse_args()
    
    # Load config if available to override defaults
    run_sims = args.run_simulations
    try:
        cfg_path = os.path.join(args.scripts_dir, 'pipeline_config.json')
        if os.path.exists(cfg_path):
            with open(cfg_path, 'r', encoding='utf-8-sig') as f:
                cfg = json.load(f)
                if not args.run_simulations:
                    run_sims = cfg.get('run_simulations', False)
                if not args.monitor_mode:
                    args.monitor_mode = cfg.get('monitor_mode', False)
                if not args.disable_git:
                    args.disable_git = cfg.get('disable_git', False)
                # Update model_path if provided via argument
                if args.model_path:
                    cfg['model_path'] = args.model_path
                    # Save updated config
                    with open(cfg_path, 'w', encoding='utf-8-sig') as f:
                        json.dump(cfg, f, indent=2, ensure_ascii=False)
    except Exception as e:
        logging.warning(f"Could not load config: {e}")
    
    # Initialize pipeline runner
    runner = PipelineRunner(
        scripts_dir=args.scripts_dir,
        data_dir=args.data_dir,
        icm_exchange_path=args.icm_exchange,
        run_simulations=run_sims,
        monitor_mode=args.monitor_mode,
        disable_git=args.disable_git
    )
    
    try:
        if args.list_rules:
            # List available rules
            rules = runner.list_available_rules()
            print("Available rules:")
            for rule in rules:
                print(f"  - {rule}")
        else:
            # Run pipeline
            export_rasters = not args.no_export
            if args.monitor_mode:
                # Simple polling monitor: wait for new rasters then process existing data
                print("Monitor mode: waiting for incoming rasters (.tif) ... Press Ctrl+C to exit.")
                last_seen = 0
                try:
                    while True:
                        newest = 0
                        for root, _, files in os.walk(os.path.join(args.data_dir, 'rasters')):
                            for fn in files:
                                if fn.endswith('.tif'):
                                    ts = os.path.getmtime(os.path.join(root, fn))
                                    newest = max(newest, ts)
                        if newest > last_seen:
                            last_seen = newest
                            manifest = runner.run_pipeline(args.rules, export_rasters=False)
                            print("Processed after new rasters arrival.")
                        time.sleep(5)
                except KeyboardInterrupt:
                    print("Exiting monitor mode.")
                    return
            else:
                manifest = runner.run_pipeline(args.rules, export_rasters)
            
            print("\nPipeline Results:")
            print(f"  Rules processed: {manifest['statistics']['successful_rules']}/{manifest['statistics']['total_rules']}")
            print(f"  Total clusters: {manifest['statistics']['total_clusters']}")
            
            if manifest['errors']:
                print(f"  Errors: {len(manifest['errors'])}")
                for error in manifest['errors']:
                    print(f"    - {error}")
            
            if manifest.get('summary_report'):
                print(f"  Summary report: {manifest['summary_report']}")
    
    except KeyboardInterrupt:
        print("\n\nInterrupted by user. Progress saved.")
        sys.exit(130)
    
    except Exception as e:
        error_logger = SafeErrorLogger()
        error_logger.log_crash('pipeline_runner_main',
                             f"{type(e).__name__}: {str(e)}",
                             {'args': str(vars(args)) if 'args' in locals() else 'unknown'})
        print(f"Pipeline failed: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()
