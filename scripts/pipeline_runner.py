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


class PipelineRunner:
    """Main orchestrator for the cluster analysis pipeline."""
    
    def __init__(self, 
                 scripts_dir: str = "scripts",
                 data_dir: str = "data/output",
                 icm_exchange_path: str = "output/ICM_Release.x64/ICMExchange.exe"):
        self.scripts_dir = scripts_dir
        self.data_dir = data_dir
        self.icm_exchange_path = icm_exchange_path
        
        # Initialize components
        self.rule_parser = RuleParser(scripts_dir)
        self.cluster_processor = ClusterProcessor(data_dir)
        self.visualizer = RasterVisualizer(os.path.join(data_dir, "viz"))
        self.exporter = CombinedExporter(os.path.join(data_dir, "results"))
        
        # Set up logging
        self.logger = self._setup_logging()
        
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
        log_dir = os.path.join(self.data_dir, "logs")
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
    
    def run_ruby_export(self, sim_id: int, attributes: List[str], output_dir: str) -> bool:
        """Run Ruby script to export rasters via ICMExchange."""
        try:
            # Prepare command
            cmd = [
                self.icm_exchange_path,
                os.path.join(self.scripts_dir, "export_rasters.rb"),
                str(sim_id),
                output_dir,
                ','.join(attributes)
            ]
            
            self.logger.info(f"Running Ruby export: {' '.join(cmd)}")
            
            # Run command
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                cwd=os.path.dirname(os.path.abspath(self.scripts_dir))
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
    
    def process_rule(self, rule_config: RuleConfig, export_rasters: bool = True) -> Optional[Dict[str, Any]]:
        """Process a single rule configuration."""
        self.logger.info(f"Processing rule: {rule_config.name}")
        
        try:
            # Export rasters if needed
            if export_rasters:
                # Determine which simulations to export
                if rule_config.analysis_type.value == "comparison":
                    sim_ids = [rule_config.baseline_id or 1, rule_config.candidate_id or 2]
                else:
                    sim_ids = [rule_config.baseline_id or 1]
                
                # Export rasters for each simulation
                for sim_id in sim_ids:
                    output_dir = os.path.join(self.data_dir, "rasters", f"sim_{sim_id}")
                    os.makedirs(output_dir, exist_ok=True)
                    
                    success = self.run_ruby_export(sim_id, rule_config.attributes, output_dir)
                    if not success:
                        self.logger.error(f"Failed to export rasters for simulation {sim_id}")
                        return None
            
            # Process the rule
            result = self.cluster_processor.process_rule(rule_config)
            self.results.append(result)
            
            # Create visualizations
            viz_config = VisualizationConfig()
            viz_paths = {
                'overlay': self.visualizer.create_cluster_overlay(result, viz_config),
                'heatmap': self.visualizer.create_heatmap(result, viz_config),
                'difference': self.visualizer.create_difference_map(result, viz_config),
                'animation': self.visualizer.create_animation(result, viz_config)
            }
            
            # Export results
            exported_files = self.exporter.export_all(result, viz_paths)
            
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
            
            self.run_manifest['rules_processed'].append(rule_result)
            
            self.logger.info(f"Successfully processed rule: {rule_config.name}")
            return rule_result
            
        except Exception as e:
            error_msg = f"Error processing rule {rule_config.name}: {e}"
            self.logger.error(error_msg)
            self.run_manifest['errors'].append(error_msg)
            return None
    
    def run_pipeline(self, rule_names: Optional[List[str]] = None, export_rasters: bool = True) -> Dict[str, Any]:
        """Run the complete pipeline for specified rules."""
        self.logger.info("Starting cluster analysis pipeline")
        self.run_manifest['start_time'] = datetime.now().isoformat()
        
        try:
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
            
            # Generate summary report
            if self.results:
                summary_report_path = self.exporter.create_summary_report(self.results)
                self.run_manifest['summary_report'] = summary_report_path
            
            # Finalize manifest
            self.run_manifest['end_time'] = datetime.now().isoformat()
            self.run_manifest['statistics'] = {
                'total_rules': len(rules_to_process),
                'successful_rules': successful_rules,
                'failed_rules': len(rules_to_process) - successful_rules,
                'total_clusters': sum(len(r.clusters) for r in self.results)
            }
            
            # Save manifest
            manifest_path = os.path.join(self.data_dir, f"run_manifest_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json")
            with open(manifest_path, 'w', encoding='utf-8') as f:
                json.dump(self.run_manifest, f, indent=2)
            
            self.logger.info(f"Pipeline completed successfully. Processed {successful_rules}/{len(rules_to_process)} rules")
            self.logger.info(f"Run manifest saved: {manifest_path}")
            
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
    
    args = parser.parse_args()
    
    # Initialize pipeline runner
    runner = PipelineRunner(
        scripts_dir=args.scripts_dir,
        data_dir=args.data_dir,
        icm_exchange_path=args.icm_exchange
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
    
    except Exception as e:
        print(f"Pipeline failed: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
