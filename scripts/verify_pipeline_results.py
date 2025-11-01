#!/usr/bin/env python3
"""
Pipeline Results Verification Module

Automatically verifies pipeline output quality after each rule execution.
Checks output files, quality metrics, directory structures, and generates verification logs.
"""

import os
import json
import logging
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple
from pathlib import Path


class VerificationResult:
    """Result of a verification check."""
    
    def __init__(self, check_name: str, passed: bool, message: str = "", details: Dict[str, Any] = None):
        self.check_name = check_name
        self.passed = passed
        self.message = message
        self.details = details or {}
        self.timestamp = datetime.now().isoformat()
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'check_name': self.check_name,
            'passed': self.passed,
            'message': self.message,
            'details': self.details,
            'timestamp': self.timestamp
        }


class PipelineVerifier:
    """Verifies pipeline output quality and completeness."""
    
    def __init__(self, data_dir: str = "data/output"):
        self.data_dir = data_dir
        self.logger = logging.getLogger(__name__)
        
        # Quality thresholds
        self.min_composite_score = 0.3
        self.min_cohesion = 0.2
        self.min_clusters = 1
        
        # Required output files
        self.required_files = {
            'visualization': ['*.png', '*.jpg'],
            'export_geojson': ['*.geojson'],
            'export_csv': ['*.csv'],
            'export_markdown': ['*.md']
        }
    
    def verify_rule_output(self, rule_name: str, rule_config: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Verify output for a specific rule.
        
        Args:
            rule_name: Name of the rule to verify
            rule_config: Optional rule configuration dict
            
        Returns:
            Dictionary with verification results
        """
        results_dir = os.path.join(self.data_dir, "results", rule_name)
        viz_dir = os.path.join(self.data_dir, "viz", rule_name)
        
        verification_results = {
            'rule_name': rule_name,
            'timestamp': datetime.now().isoformat(),
            'overall_status': 'unknown',
            'checks': [],
            'summary': {
                'total_checks': 0,
                'passed_checks': 0,
                'failed_checks': 0
            },
            'issues': []
        }
        
        checks = []
        
        # Check 1: Directory structure exists
        check1 = self._check_directory_structure(results_dir, viz_dir)
        checks.append(check1)
        
        # Check 2: Output files exist
        if rule_config and 'outputs' in rule_config:
            check2 = self._check_output_files(results_dir, viz_dir, rule_config['outputs'])
            checks.append(check2)
        else:
            check2 = self._check_output_files_basic(results_dir, viz_dir)
            checks.append(check2)
        
        # Check 3: Quality metrics meet thresholds
        check3 = self._check_quality_metrics(results_dir, rule_name)
        checks.append(check3)
        
        # Check 4: GeoJSON validity (if exists)
        check4 = self._check_geojson_validity(results_dir)
        checks.append(check4)
        
        # Check 5: CSV validity (if exists)
        check5 = self._check_csv_validity(results_dir)
        checks.append(check5)
        
        # Compile results
        verification_results['checks'] = [c.to_dict() for c in checks]
        verification_results['summary']['total_checks'] = len(checks)
        verification_results['summary']['passed_checks'] = sum(1 for c in checks if c.passed)
        verification_results['summary']['failed_checks'] = sum(1 for c in checks if not c.passed)
        
        # Determine overall status
        if verification_results['summary']['failed_checks'] == 0:
            verification_results['overall_status'] = 'passed'
        elif verification_results['summary']['passed_checks'] > 0:
            verification_results['overall_status'] = 'partial'
        else:
            verification_results['overall_status'] = 'failed'
        
        # Collect issues
        for check in checks:
            if not check.passed:
                verification_results['issues'].append({
                    'check': check.check_name,
                    'message': check.message,
                    'details': check.details
                })
        
        return verification_results
    
    def _check_directory_structure(self, results_dir: str, viz_dir: str) -> VerificationResult:
        """Check if required directory structure exists."""
        results_exist = os.path.exists(results_dir)
        viz_exist = os.path.exists(viz_dir)
        
        if results_exist and viz_exist:
            return VerificationResult(
                check_name='directory_structure',
                passed=True,
                message="Required directories exist",
                details={'results_dir': results_dir, 'viz_dir': viz_dir}
            )
        else:
            missing = []
            if not results_exist:
                missing.append('results_dir')
            if not viz_exist:
                missing.append('viz_dir')
            
            return VerificationResult(
                check_name='directory_structure',
                passed=False,
                message=f"Missing directories: {', '.join(missing)}",
                details={'missing': missing}
            )
    
    def _check_output_files_basic(self, results_dir: str, viz_dir: str) -> VerificationResult:
        """Check for basic output files without specific configuration."""
        found_files = []
        missing_expected = []
        
        # Check for common output files
        if os.path.exists(results_dir):
            for ext in ['*.geojson', '*.csv', '*.md']:
                files = list(Path(results_dir).glob(ext))
                if files:
                    found_files.extend([str(f) for f in files])
        
        if os.path.exists(viz_dir):
            for ext in ['*.png', '*.jpg']:
                files = list(Path(viz_dir).glob(ext))
                if files:
                    found_files.extend([str(f) for f in files])
        
        if found_files:
            return VerificationResult(
                check_name='output_files',
                passed=True,
                message=f"Found {len(found_files)} output file(s)",
                details={'found_files': found_files}
            )
        else:
            return VerificationResult(
                check_name='output_files',
                passed=False,
                message="No output files found",
                details={'results_dir': results_dir, 'viz_dir': viz_dir}
            )
    
    def _check_output_files(self, results_dir: str, viz_dir: str, outputs_config: Dict[str, Any]) -> VerificationResult:
        """Check for specific output files based on configuration."""
        found_files = []
        missing_files = []
        
        # Check visualization
        if outputs_config.get('make_animation') or outputs_config.get('make_overlay'):
            viz_files = []
            if os.path.exists(viz_dir):
                viz_files = list(Path(viz_dir).glob('*.png')) + list(Path(viz_dir).glob('*.jpg'))
            if viz_files:
                found_files.extend([str(f) for f in viz_files])
            else:
                missing_files.append('visualization')
        
        # Check GeoJSON export
        if outputs_config.get('export_geojson'):
            geojson_files = []
            if os.path.exists(results_dir):
                geojson_files = list(Path(results_dir).glob('*.geojson'))
            if geojson_files:
                found_files.extend([str(f) for f in geojson_files])
            else:
                missing_files.append('geojson_export')
        
        # Check CSV export
        if outputs_config.get('export_csv', True):  # Default to True
            csv_files = []
            if os.path.exists(results_dir):
                csv_files = list(Path(results_dir).glob('*.csv'))
            if csv_files:
                found_files.extend([str(f) for f in csv_files])
            else:
                missing_files.append('csv_export')
        
        if missing_files:
            return VerificationResult(
                check_name='output_files',
                passed=False,
                message=f"Missing expected output files: {', '.join(missing_files)}",
                details={'found_files': found_files, 'missing_files': missing_files}
            )
        else:
            return VerificationResult(
                check_name='output_files',
                passed=True,
                message=f"All expected output files found ({len(found_files)} files)",
                details={'found_files': found_files}
            )
    
    def _check_quality_metrics(self, results_dir: str, rule_name: str) -> VerificationResult:
        """Check if quality metrics meet minimum thresholds."""
        metrics_file = os.path.join(results_dir, f"{rule_name}_metrics.json")
        
        if not os.path.exists(metrics_file):
            # Try alternative locations
            for alt_file in ['metrics.json', 'quality_metrics.json', 'cluster_metrics.json']:
                alt_path = os.path.join(results_dir, alt_file)
                if os.path.exists(alt_path):
                    metrics_file = alt_path
                    break
        
        if not os.path.exists(metrics_file):
            return VerificationResult(
                check_name='quality_metrics',
                passed=False,
                message="Metrics file not found",
                details={'searched_locations': [results_dir]}
            )
        
        try:
            with open(metrics_file, 'r', encoding='utf-8') as f:
                metrics = json.load(f)
            
            issues = []
            warnings = []
            
            # Check composite score
            composite_score = metrics.get('composite_score', metrics.get('quality_score', 0.0))
            if composite_score < self.min_composite_score:
                issues.append(f"Composite score {composite_score:.4f} below threshold {self.min_composite_score}")
            
            # Check cohesion
            cohesion = metrics.get('cohesion', metrics.get('cluster_cohesion', 0.0))
            if cohesion < self.min_cohesion:
                warnings.append(f"Cohesion {cohesion:.4f} below recommended {self.min_cohesion}")
            
            # Check cluster count
            cluster_count = metrics.get('cluster_count', metrics.get('clusters', 0))
            if cluster_count < self.min_clusters:
                issues.append(f"Cluster count {cluster_count} below minimum {self.min_clusters}")
            
            # Check if all required metrics exist
            required_metrics = ['composite_score', 'cohesion', 'separation', 'cluster_count']
            missing_metrics = [m for m in required_metrics if m not in metrics]
            
            if issues:
                return VerificationResult(
                    check_name='quality_metrics',
                    passed=False,
                    message=f"Quality metrics below thresholds: {', '.join(issues)}",
                    details={
                        'metrics': metrics,
                        'issues': issues,
                        'warnings': warnings,
                        'missing_metrics': missing_metrics
                    }
                )
            else:
                return VerificationResult(
                    check_name='quality_metrics',
                    passed=True,
                    message="Quality metrics meet all thresholds",
                    details={
                        'metrics': metrics,
                        'warnings': warnings,
                        'missing_metrics': missing_metrics
                    }
                )
        
        except Exception as e:
            return VerificationResult(
                check_name='quality_metrics',
                passed=False,
                message=f"Error reading metrics file: {str(e)}",
                details={'metrics_file': metrics_file, 'error': str(e)}
            )
    
    def _check_geojson_validity(self, results_dir: str) -> VerificationResult:
        """Check if GeoJSON files are valid."""
        if not os.path.exists(results_dir):
            return VerificationResult(
                check_name='geojson_validity',
                passed=True,  # Pass if directory doesn't exist (no GeoJSON required)
                message="Results directory not found, skipping GeoJSON check"
            )
        
        geojson_files = list(Path(results_dir).glob('*.geojson'))
        
        if not geojson_files:
            return VerificationResult(
                check_name='geojson_validity',
                passed=True,  # Pass if no GeoJSON files (might be optional)
                message="No GeoJSON files found, skipping check"
            )
        
        invalid_files = []
        for geojson_file in geojson_files:
            try:
                with open(geojson_file, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                
                # Basic GeoJSON structure check
                if 'type' not in data:
                    invalid_files.append(str(geojson_file))
                elif data['type'] == 'FeatureCollection' and 'features' not in data:
                    invalid_files.append(str(geojson_file))
                elif data['type'] == 'Feature' and 'geometry' not in data:
                    invalid_files.append(str(geojson_file))
            
            except Exception as e:
                invalid_files.append(f"{geojson_file}: {str(e)}")
        
        if invalid_files:
            return VerificationResult(
                check_name='geojson_validity',
                passed=False,
                message=f"Invalid GeoJSON files: {', '.join(invalid_files)}",
                details={'invalid_files': invalid_files}
            )
        else:
            return VerificationResult(
                check_name='geojson_validity',
                passed=True,
                message=f"All {len(geojson_files)} GeoJSON file(s) are valid",
                details={'validated_files': [str(f) for f in geojson_files]}
            )
    
    def _check_csv_validity(self, results_dir: str) -> VerificationResult:
        """Check if CSV files are valid (basic structure check)."""
        if not os.path.exists(results_dir):
            return VerificationResult(
                check_name='csv_validity',
                passed=True,
                message="Results directory not found, skipping CSV check"
            )
        
        csv_files = list(Path(results_dir).glob('*.csv'))
        
        if not csv_files:
            return VerificationResult(
                check_name='csv_validity',
                passed=True,
                message="No CSV files found, skipping check"
            )
        
        invalid_files = []
        for csv_file in csv_files:
            try:
                # Basic check: file is readable and has at least one line
                with open(csv_file, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                    if len(lines) < 1:
                        invalid_files.append(f"{csv_file}: empty file")
            except Exception as e:
                invalid_files.append(f"{csv_file}: {str(e)}")
        
        if invalid_files:
            return VerificationResult(
                check_name='csv_validity',
                passed=False,
                message=f"Invalid CSV files: {', '.join(invalid_files)}",
                details={'invalid_files': invalid_files}
            )
        else:
            return VerificationResult(
                check_name='csv_validity',
                passed=True,
                message=f"All {len(csv_files)} CSV file(s) are valid",
                details={'validated_files': [str(csv_file) for csv_file in csv_files]}
            )
    
    def save_verification_log(self, verification_result: Dict[str, Any], log_dir: str = None) -> str:
        """Save verification result to a markdown log file."""
        if log_dir is None:
            log_dir = os.path.join(self.data_dir, "logs", "active")
        
        os.makedirs(log_dir, exist_ok=True)
        
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        rule_name = verification_result.get('rule_name', 'unknown')
        log_file = os.path.join(log_dir, f"verification_{rule_name}_{timestamp}.md")
        
        status_emoji = {
            'passed': '✅',
            'partial': '⚠️',
            'failed': '❌',
            'unknown': '❓'
        }
        
        status = verification_result.get('overall_status', 'unknown')
        emoji = status_emoji.get(status, '❓')
        
        with open(log_file, 'w', encoding='utf-8') as f:
            f.write(f"# Verification Report: {rule_name}\n\n")
            f.write(f"**Status:** {emoji} {status.upper()}\n")
            f.write(f"**Timestamp:** {verification_result.get('timestamp', 'N/A')}\n\n")
            
            summary = verification_result.get('summary', {})
            f.write(f"## Summary\n\n")
            f.write(f"- **Total checks:** {summary.get('total_checks', 0)}\n")
            f.write(f"- **Passed:** {summary.get('passed_checks', 0)}\n")
            f.write(f"- **Failed:** {summary.get('failed_checks', 0)}\n\n")
            
            # Detailed checks
            f.write(f"## Detailed Checks\n\n")
            for check in verification_result.get('checks', []):
                check_emoji = '✅' if check.get('passed', False) else '❌'
                f.write(f"### {check_emoji} {check.get('check_name', 'unknown')}\n\n")
                f.write(f"{check.get('message', 'N/A')}\n\n")
                
                if check.get('details'):
                    f.write(f"**Details:**\n")
                    details = check['details']
                    if isinstance(details, dict):
                        for key, value in details.items():
                            if key == 'found_files' and isinstance(value, list):
                                f.write(f"- Found files: {len(value)}\n")
                                for file_path in value[:5]:  # Show first 5
                                    f.write(f"  - `{file_path}`\n")
                                if len(value) > 5:
                                    f.write(f"  - ... and {len(value) - 5} more\n")
                            elif key == 'metrics' and isinstance(value, dict):
                                f.write(f"- Metrics:\n")
                                for mkey, mval in value.items():
                                    f.write(f"  - {mkey}: {mval}\n")
                            else:
                                f.write(f"- {key}: {value}\n")
                    f.write(f"\n")
            
            # Issues
            issues = verification_result.get('issues', [])
            if issues:
                f.write(f"## Issues\n\n")
                for issue in issues:
                    f.write(f"- **{issue.get('check', 'unknown')}:** {issue.get('message', 'N/A')}\n")
                f.write(f"\n")
        
        self.logger.info(f"Saved verification log: {log_file}")
        return log_file
    
    def verify_and_log(self, rule_name: str, rule_config: Dict[str, Any] = None, log_dir: str = None) -> Tuple[Dict[str, Any], str]:
        """Verify rule output and save log. Returns (verification_result, log_file_path)."""
        verification_result = self.verify_rule_output(rule_name, rule_config)
        log_file = self.save_verification_log(verification_result, log_dir)
        return verification_result, log_file


def main():
    """Test the verifier."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Pipeline Results Verifier')
    parser.add_argument('--rule', required=True, help='Rule name to verify')
    parser.add_argument('--data-dir', default='data/output', help='Data output directory')
    parser.add_argument('--config', help='Path to rule JSON config file')
    
    args = parser.parse_args()
    
    # Set up logging
    logging.basicConfig(level=logging.INFO)
    
    # Load rule config if provided
    rule_config = None
    if args.config and os.path.exists(args.config):
        with open(args.config, 'r', encoding='utf-8') as f:
            rule_config = json.load(f)
    
    # Initialize verifier
    verifier = PipelineVerifier(args.data_dir)
    
    # Verify
    verification_result, log_file = verifier.verify_and_log(args.rule, rule_config)
    
    # Print summary
    status = verification_result.get('overall_status', 'unknown')
    summary = verification_result.get('summary', {})
    
    print(f"\nVerification Status: {status.upper()}")
    print(f"Total checks: {summary.get('total_checks', 0)}")
    print(f"Passed: {summary.get('passed_checks', 0)}")
    print(f"Failed: {summary.get('failed_checks', 0)}")
    print(f"\nLog file: {log_file}")
    
    # Exit with appropriate code
    if status == 'failed':
        exit(1)
    elif status == 'partial':
        exit(2)
    else:
        exit(0)


if __name__ == "__main__":
    main()

