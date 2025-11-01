#!/usr/bin/env python3
"""
Validation script for optimized rules.

Runs pipeline for each optimized rule, validates quality metrics,
compares with previous results, and generates a validation report.
"""

import os
import json
import logging
import subprocess
from datetime import datetime
from typing import Dict, List, Any, Optional
from pathlib import Path

from pipeline_runner import PipelineRunner
from rule_parser import RuleParser
from compare_runs import RunComparator
from verify_pipeline_results import PipelineVerifier
from crash_recovery import CrashRecovery, SafeErrorLogger, safe_execute
import sys


class OptimizedRuleValidator:
    """Validates optimized rules by running pipeline and comparing results."""
    
    def __init__(self, 
                 scripts_dir: str = "scripts",
                 data_dir: str = "data/output"):
        self.scripts_dir = scripts_dir
        self.data_dir = data_dir
        self.experiments_dir = os.path.join(data_dir, "experiments")
        self.rule_parser = RuleParser(scripts_dir)
        self.comparator = RunComparator(data_dir)
        self.verifier = PipelineVerifier(data_dir)
        self.logger = logging.getLogger(__name__)
        
        os.makedirs(self.experiments_dir, exist_ok=True)
    
    def load_best_params(self, rule_name: str) -> Optional[Dict[str, Any]]:
        """Load best parameters from optimization results."""
        best_params_file = os.path.join(self.experiments_dir, f"{rule_name}_best_params.json")
        
        if not os.path.exists(best_params_file):
            # Try to find any optimization results file
            pattern = f"{rule_name}_optimization_*.json"
            result_files = list(Path(self.experiments_dir).glob(pattern))
            if result_files:
                # Use most recent one
                result_files.sort(key=lambda x: x.stat().st_mtime, reverse=True)
                result_file = result_files[0]
                with open(result_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    return data.get('best_parameters', {})
            return None
        
        try:
            with open(best_params_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                return data.get('best_parameters', {})
        except Exception as e:
            self.logger.error(f"Error loading best params for {rule_name}: {e}")
            return None
    
    def find_previous_run_manifest(self, rule_name: str) -> Optional[str]:
        """Find the most recent run manifest that includes this rule."""
        config_dir = os.path.join(self.data_dir, "config", "active")
        processed_dir = os.path.join(self.data_dir, "config", "processed")
        
        manifest_files = []
        
        # Check active directory
        if os.path.exists(config_dir):
            manifest_files.extend(Path(config_dir).glob("run_manifest_*.json"))
        
        # Check processed directory
        if os.path.exists(processed_dir):
            manifest_files.extend(Path(processed_dir).glob("run_manifest_*.json"))
        
        # Sort by modification time (most recent first)
        manifest_files.sort(key=lambda x: x.stat().st_mtime, reverse=True)
        
        # Find manifest that contains this rule
        for manifest_file in manifest_files:
            try:
                with open(manifest_file, 'r', encoding='utf-8') as f:
                    manifest = json.load(f)
                    rules_processed = manifest.get('rules_processed', [])
                    for rule_result in rules_processed:
                        if rule_result.get('rule_name') == rule_name:
                            return str(manifest_file)
            except Exception as e:
                self.logger.warning(f"Error reading manifest {manifest_file}: {e}")
                continue
        
        return None
    
    def validate_single_rule(self, rule_name: str, export_rasters: bool = False) -> Dict[str, Any]:
        """
        Validate a single optimized rule.
        
        Args:
            rule_name: Name of the rule to validate
            export_rasters: Whether to export rasters (can skip if already done)
            
        Returns:
            Dictionary with validation results
        """
        self.logger.info(f"Validating rule: {rule_name}")
        
        validation_result = {
            'rule_name': rule_name,
            'timestamp': datetime.now().isoformat(),
            'status': 'unknown',
            'optimization_params_loaded': False,
            'pipeline_run_successful': False,
            'quality_check_passed': False,
            'comparison_with_previous': None,
            'issues': [],
            'recommendations': []
        }
        
        # Load best parameters
        best_params = self.load_best_params(rule_name)
        if not best_params:
            validation_result['status'] = 'error'
            validation_result['issues'].append(f"Could not load optimization results for {rule_name}")
            self.logger.warning(f"No optimization results found for {rule_name}")
            return validation_result
        
        validation_result['optimization_params_loaded'] = True
        
        # Check if rule JSON was updated with optimized parameters
        rule_json_path = os.path.join(self.scripts_dir, f"{rule_name}.json")
        if not os.path.exists(rule_json_path):
            validation_result['issues'].append(f"Rule JSON file not found: {rule_json_path}")
            validation_result['status'] = 'error'
            return validation_result
        
        try:
            # Run pipeline for this rule
            self.logger.info(f"Running pipeline for rule: {rule_name}")
            runner = PipelineRunner(
                scripts_dir=self.scripts_dir,
                data_dir=self.data_dir,
                run_simulations=False,  # Don't run simulations during validation
                disable_git=True  # Don't commit during validation
            )
            
            # Run single rule
            rule_result = runner.run_single_rule(rule_name, export_rasters=export_rasters)
            
            if rule_result:
                validation_result['pipeline_run_successful'] = True
                validation_result['pipeline_result'] = {
                    'clusters_count': rule_result.get('clusters_count', 0),
                    'statistics': rule_result.get('statistics', {}),
                    'verification': rule_result.get('verification', {})
                }
                
                # Check quality metrics
                verification = rule_result.get('verification', {})
                verification_status = verification.get('status', 'unknown')
                
                if verification_status == 'passed':
                    validation_result['quality_check_passed'] = True
                elif verification_status == 'partial':
                    validation_result['quality_check_passed'] = False
                    validation_result['issues'].append("Quality check partially passed")
                else:
                    validation_result['quality_check_passed'] = False
                    validation_result['issues'].append(f"Quality check failed: {verification_status}")
                
                # Compare with previous run if available
                previous_manifest = self.find_previous_run_manifest(rule_name)
                if previous_manifest:
                    self.logger.info(f"Found previous run manifest: {previous_manifest}")
                    
                    # Get current manifest (from pipeline runner)
                    current_manifest_path = runner.run_manifest.get('_manifest_path')
                    if not current_manifest_path:
                        # Try to find the most recent manifest
                        config_dir = os.path.join(self.data_dir, "config", "active")
                        if os.path.exists(config_dir):
                            manifest_files = sorted(
                                Path(config_dir).glob("run_manifest_*.json"),
                                key=lambda x: x.stat().st_mtime,
                                reverse=True
                            )
                            if manifest_files:
                                current_manifest_path = str(manifest_files[0])
                    
                    if current_manifest_path and os.path.exists(current_manifest_path):
                        try:
                            comparison = self.comparator.compare_run_manifests(
                                previous_manifest,
                                current_manifest_path
                            )
                            validation_result['comparison_with_previous'] = {
                                'improvement_scores': comparison.improvement_scores,
                                'recommendations': comparison.recommendations,
                                'metrics_comparison': comparison.metrics_comparison
                            }
                            
                            # Check if there's improvement
                            overall_improvement = comparison.improvement_scores.get('overall_improvement', 0.0)
                            if overall_improvement < -0.1:  # Regression threshold
                                validation_result['issues'].append(f"Regression detected: composite score decreased by {abs(overall_improvement):.4f}")
                                validation_result['status'] = 'regression'
                            elif overall_improvement > 0.1:  # Improvement threshold
                                validation_result['recommendations'].append(f"Improvement detected: composite score increased by {overall_improvement:.4f}")
                                if validation_result['status'] == 'unknown':
                                    validation_result['status'] = 'improved'
                            
                        except Exception as e:
                            self.logger.warning(f"Error comparing with previous run: {e}")
                            validation_result['issues'].append(f"Could not compare with previous run: {e}")
                    
                    else:
                        validation_result['issues'].append("Could not find current run manifest for comparison")
                
                # Determine final status
                if validation_result['status'] == 'unknown':
                    if validation_result['quality_check_passed']:
                        validation_result['status'] = 'passed'
                    else:
                        validation_result['status'] = 'failed'
                
            else:
                validation_result['pipeline_run_successful'] = False
                validation_result['status'] = 'failed'
                validation_result['issues'].append("Pipeline run failed")
                
        except Exception as e:
            self.logger.error(f"Error validating rule {rule_name}: {e}")
            validation_result['status'] = 'error'
            validation_result['issues'].append(f"Error during validation: {str(e)}")
        
        return validation_result
    
    def validate_all_optimized_rules(self, export_rasters: bool = False) -> Dict[str, Any]:
        """
        Validate all optimized rules.
        
        Args:
            export_rasters: Whether to export rasters (can skip if already done)
            
        Returns:
            Dictionary with validation results for all rules
        """
        self.logger.info("Starting validation of all optimized rules")
        
        # Find all optimization result files
        optimization_files = list(Path(self.experiments_dir).glob("*_best_params.json"))
        
        rule_names = set()
        for file in optimization_files:
            rule_name = file.stem.replace('_best_params', '')
            rule_names.add(rule_name)
        
        if not rule_names:
            self.logger.warning("No optimization results found")
            return {
                'timestamp': datetime.now().isoformat(),
                'total_rules': 0,
                'validated_rules': {},
                'summary': {
                    'passed': 0,
                    'failed': 0,
                    'regression': 0,
                    'errors': 0
                }
            }
        
        validation_results = {}
        for rule_name in sorted(rule_names):
            try:
                result = self.validate_single_rule(rule_name, export_rasters=export_rasters)
                validation_results[rule_name] = result
            except Exception as e:
                self.logger.error(f"Error validating rule {rule_name}: {e}")
                validation_results[rule_name] = {
                    'rule_name': rule_name,
                    'status': 'error',
                    'issues': [f"Validation error: {str(e)}"]
                }
        
        # Generate summary
        summary = {
            'passed': sum(1 for r in validation_results.values() if r.get('status') == 'passed'),
            'failed': sum(1 for r in validation_results.values() if r.get('status') == 'failed'),
            'regression': sum(1 for r in validation_results.values() if r.get('status') == 'regression'),
            'improved': sum(1 for r in validation_results.values() if r.get('status') == 'improved'),
            'errors': sum(1 for r in validation_results.values() if r.get('status') == 'error')
        }
        
        return {
            'timestamp': datetime.now().isoformat(),
            'total_rules': len(validation_results),
            'validated_rules': validation_results,
            'summary': summary
        }
    
    def generate_validation_report(self, validation_results: Dict[str, Any]) -> str:
        """Generate a markdown validation report."""
        report_file = os.path.join(self.experiments_dir, "validation_report.md")
        
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(f"# Validation Report for Optimized Rules\n\n")
            f.write(f"Generated: {timestamp}\n\n")
            
            summary = validation_results.get('summary', {})
            total_rules = validation_results.get('total_rules', 0)
            
            f.write(f"## Summary\n\n")
            f.write(f"- **Total rules validated:** {total_rules}\n")
            f.write(f"- **✅ Passed:** {summary.get('passed', 0)}\n")
            f.write(f"- **⚠️ Improved:** {summary.get('improved', 0)}\n")
            f.write(f"- **❌ Failed:** {summary.get('failed', 0)}\n")
            f.write(f"- **📉 Regression:** {summary.get('regression', 0)}\n")
            f.write(f"- **⚠️ Errors:** {summary.get('errors', 0)}\n\n")
            
            # Comparison table
            f.write(f"## Validation Results by Rule\n\n")
            f.write(f"| Rule Name | Status | Quality Check | Comparison | Issues |\n")
            f.write(f"|-----------|--------|--------------|------------|-------|\n")
            
            for rule_name, result in sorted(validation_results.get('validated_rules', {}).items()):
                status = result.get('status', 'unknown')
                status_emoji = {
                    'passed': '✅',
                    'improved': '✅',
                    'failed': '❌',
                    'regression': '📉',
                    'error': '⚠️',
                    'unknown': '❓'
                }.get(status, '❓')
                
                quality_check = '✅' if result.get('quality_check_passed', False) else '❌'
                
                comparison = result.get('comparison_with_previous')
                if comparison:
                    improvement = comparison.get('improvement_scores', {}).get('overall_improvement', 0.0)
                    if improvement > 0.1:
                        comp_str = f"+{improvement:.3f}"
                    elif improvement < -0.1:
                        comp_str = f"{improvement:.3f} (regression)"
                    else:
                        comp_str = "≈"
                else:
                    comp_str = "N/A"
                
                issues_count = len(result.get('issues', []))
                issues_str = str(issues_count) if issues_count > 0 else "None"
                
                f.write(f"| {rule_name} | {status_emoji} {status} | {quality_check} | {comp_str} | {issues_str} |\n")
            
            f.write(f"\n")
            
            # Detailed results
            f.write(f"## Detailed Results\n\n")
            
            for rule_name, result in sorted(validation_results.get('validated_rules', {}).items()):
                f.write(f"### {rule_name}\n\n")
                f.write(f"**Status:** {result.get('status', 'unknown')}\n")
                f.write(f"**Pipeline Run:** {'✅' if result.get('pipeline_run_successful', False) else '❌'}\n")
                f.write(f"**Quality Check:** {'✅ Passed' if result.get('quality_check_passed', False) else '❌ Failed'}\n\n")
                
                # Pipeline result metrics
                pipeline_result = result.get('pipeline_result', {})
                if pipeline_result:
                    f.write(f"#### Pipeline Metrics\n\n")
                    f.write(f"- Clusters: {pipeline_result.get('clusters_count', 0)}\n")
                    stats = pipeline_result.get('statistics', {})
                    if stats:
                        f.write(f"- Total area: {stats.get('total_area', 0.0):.2f}\n")
                        f.write(f"- Mean value: {stats.get('mean_value', 0.0):.4f}\n")
                    f.write(f"\n")
                
                # Comparison with previous
                comparison = result.get('comparison_with_previous')
                if comparison:
                    f.write(f"#### Comparison with Previous Run\n\n")
                    metrics = comparison.get('metrics_comparison', {})
                    if metrics:
                        f.write(f"| Metric | Change |\n")
                        f.write(f"|--------|-------|\n")
                        for metric_name, metric_data in metrics.items():
                            if isinstance(metric_data, dict):
                                change = metric_data.get('change', 0.0)
                                change_str = f"+{change:.4f}" if change >= 0 else f"{change:.4f}"
                                f.write(f"| {metric_name} | {change_str} |\n")
                    
                    recommendations = comparison.get('recommendations', [])
                    if recommendations:
                        f.write(f"\n**Recommendations:**\n")
                        for rec in recommendations:
                            f.write(f"- {rec}\n")
                    f.write(f"\n")
                
                # Issues
                issues = result.get('issues', [])
                if issues:
                    f.write(f"#### Issues\n\n")
                    for issue in issues:
                        f.write(f"- ⚠️ {issue}\n")
                    f.write(f"\n")
                
                # Recommendations
                recommendations = result.get('recommendations', [])
                if recommendations:
                    f.write(f"#### Recommendations\n\n")
                    for rec in recommendations:
                        f.write(f"- {rec}\n")
                    f.write(f"\n")
                
                f.write(f"---\n\n")
            
            # Rules requiring manual review
            f.write(f"## Rules Requiring Manual Review\n\n")
            manual_review = []
            for rule_name, result in validation_results.get('validated_rules', {}).items():
                status = result.get('status', 'unknown')
                if status in ['regression', 'failed', 'error']:
                    manual_review.append({
                        'rule': rule_name,
                        'status': status,
                        'issues': result.get('issues', [])
                    })
            
            if manual_review:
                for item in manual_review:
                    f.write(f"### {item['rule']}\n\n")
                    f.write(f"**Status:** {item['status']}\n\n")
                    f.write(f"**Issues:**\n")
                    for issue in item['issues']:
                        f.write(f"- {issue}\n")
                    f.write(f"\n")
            else:
                f.write(f"None - all rules validated successfully! ✅\n\n")
        
        self.logger.info(f"Generated validation report: {report_file}")
        return report_file


def main():
    """Main validation function."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Validate Optimized Rules')
    parser.add_argument('--rule', help='Specific rule to validate')
    parser.add_argument('--all-rules', action='store_true', help='Validate all optimized rules')
    parser.add_argument('--scripts-dir', default='scripts', help='Scripts directory')
    parser.add_argument('--data-dir', default='data/output', help='Data output directory')
    parser.add_argument('--export-rasters', action='store_true', help='Export rasters during validation')
    
    args = parser.parse_args()
    
    # Set up logging
    logging.basicConfig(level=logging.INFO)
    
    # Initialize validator
    validator = OptimizedRuleValidator(args.scripts_dir, args.data_dir)
    crash_recovery = CrashRecovery()
    error_logger = SafeErrorLogger()
    
    try:
        if args.all_rules:
            # Validate all rules with crash protection
            def run_validation():
                return validator.validate_all_optimized_rules(export_rasters=args.export_rasters)
            
            try:
                validation_results = safe_execute('validator_all_rules', run_validation,
                                                 crash_recovery=crash_recovery,
                                                 error_logger=error_logger)
            except Exception as e:
                error_logger.log_crash('validator_all_rules',
                                     f"{type(e).__name__}: {str(e)}",
                                     {'traceback': str(e)})
                raise
            
            # Generate report
            report_file = validator.generate_validation_report(validation_results)
            
            print(f"\nValidation Summary:")
            summary = validation_results.get('summary', {})
            print(f"  Total: {validation_results.get('total_rules', 0)}")
            print(f"  [OK] Passed: {summary.get('passed', 0)}")
            print(f"  [OK] Improved: {summary.get('improved', 0)}")
            print(f"  [X] Failed: {summary.get('failed', 0)}")
            print(f"  [DOWN] Regression: {summary.get('regression', 0)}")
            print(f"  [!] Errors: {summary.get('errors', 0)}")
            print(f"\nReport: {report_file}")
        
        elif args.rule:
            # Validate single rule with crash protection
            def run_single_validation():
                return validator.validate_single_rule(args.rule, export_rasters=args.export_rasters)
            
            try:
                result = safe_execute(f'validator_{args.rule}', run_single_validation,
                                    crash_recovery=crash_recovery,
                                    error_logger=error_logger)
            except Exception as e:
                error_logger.log_crash(f'validator_{args.rule}',
                                     f"{type(e).__name__}: {str(e)}",
                                     {'rule': args.rule})
                raise
            
            print(f"\nValidation Result for {args.rule}:")
            print(f"  Status: {result.get('status', 'unknown')}")
            print(f"  Quality Check: {'[OK]' if result.get('quality_check_passed', False) else '[X]'}")
            
            issues = result.get('issues', [])
            if issues:
                print(f"  Issues:")
                for issue in issues:
                    print(f"    - {issue}")
        
        else:
            print("Please specify --rule <rule_name> or --all-rules")
    
    except KeyboardInterrupt:
        print("\n\nInterrupted by user. Progress saved.")
        sys.exit(130)
    
    except Exception as e:
        error_msg = f"Validation failed: {e}"
        print(error_msg)
        error_logger.log_crash('validator_main',
                             f"{type(e).__name__}: {str(e)}",
                             {'args': str(vars(args))})
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    main()

