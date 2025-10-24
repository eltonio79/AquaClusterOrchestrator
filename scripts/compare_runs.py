#!/usr/bin/env python3
"""
Compare Runs module for cluster analysis pipeline.

Compares clustering results between iterations, generates diff reports,
tracks improvement metrics, and suggests parameter refinements.
"""

import os
import json
import numpy as np
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple
import logging
from dataclasses import dataclass
import pandas as pd
from pathlib import Path


@dataclass
class RunComparison:
    """Comparison between two analysis runs."""
    run1_name: str
    run2_name: str
    rule_name: str
    metrics_comparison: Dict[str, Any]
    parameter_changes: Dict[str, Any]
    improvement_scores: Dict[str, float]
    recommendations: List[str]


class RunComparator:
    """Compares results between different pipeline runs."""
    
    def __init__(self, data_dir: str = "data/output"):
        self.data_dir = data_dir
        self.logger = logging.getLogger(__name__)
    
    def load_run_manifest(self, manifest_path: str) -> Dict[str, Any]:
        """Load a run manifest file."""
        try:
            with open(manifest_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            self.logger.error(f"Error loading manifest {manifest_path}: {e}")
            return {}
    
    def load_experiment_results(self, results_path: str) -> Dict[str, Any]:
        """Load experiment results file."""
        try:
            with open(results_path, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            self.logger.error(f"Error loading experiment results {results_path}: {e}")
            return {}
    
    def compare_run_manifests(self, manifest1_path: str, manifest2_path: str) -> RunComparison:
        """Compare two run manifests."""
        manifest1 = self.load_run_manifest(manifest1_path)
        manifest2 = self.load_run_manifest(manifest2_path)
        
        run1_name = os.path.basename(manifest1_path).replace('.json', '')
        run2_name = os.path.basename(manifest2_path).replace('.json', '')
        
        # Compare overall statistics
        stats1 = manifest1.get('statistics', {})
        stats2 = manifest2.get('statistics', {})
        
        metrics_comparison = {
            'total_rules': {
                'run1': stats1.get('total_rules', 0),
                'run2': stats2.get('total_rules', 0),
                'change': stats2.get('total_rules', 0) - stats1.get('total_rules', 0)
            },
            'successful_rules': {
                'run1': stats1.get('successful_rules', 0),
                'run2': stats2.get('successful_rules', 0),
                'change': stats2.get('successful_rules', 0) - stats1.get('successful_rules', 0)
            },
            'total_clusters': {
                'run1': stats1.get('total_clusters', 0),
                'run2': stats2.get('total_clusters', 0),
                'change': stats2.get('total_clusters', 0) - stats1.get('total_clusters', 0)
            }
        }
        
        # Compare individual rule results
        rules1 = {r['rule_name']: r for r in manifest1.get('rules_processed', [])}
        rules2 = {r['rule_name']: r for r in manifest2.get('rules_processed', [])}
        
        rule_comparisons = {}
        for rule_name in set(rules1.keys()) | set(rules2.keys()):
            rule1 = rules1.get(rule_name, {})
            rule2 = rules2.get(rule_name, {})
            
            rule_comparisons[rule_name] = {
                'clusters_count': {
                    'run1': rule1.get('clusters_count', 0),
                    'run2': rule2.get('clusters_count', 0),
                    'change': rule2.get('clusters_count', 0) - rule1.get('clusters_count', 0)
                },
                'total_area': {
                    'run1': rule1.get('statistics', {}).get('total_area', 0.0),
                    'run2': rule2.get('statistics', {}).get('total_area', 0.0),
                    'change': rule2.get('statistics', {}).get('total_area', 0.0) - rule1.get('statistics', {}).get('total_area', 0.0)
                }
            }
        
        # Calculate improvement scores
        improvement_scores = self._calculate_improvement_scores(metrics_comparison, rule_comparisons)
        
        # Generate recommendations
        recommendations = self._generate_recommendations(metrics_comparison, rule_comparisons, improvement_scores)
        
        return RunComparison(
            run1_name=run1_name,
            run2_name=run2_name,
            rule_name="all_rules",
            metrics_comparison=metrics_comparison,
            parameter_changes={},
            improvement_scores=improvement_scores,
            recommendations=recommendations
        )
    
    def compare_experiment_results(self, results1_path: str, results2_path: str) -> RunComparison:
        """Compare two experiment result files."""
        results1 = self.load_experiment_results(results1_path)
        results2 = self.load_experiment_results(results2_path)
        
        run1_name = os.path.basename(results1_path).replace('.json', '')
        run2_name = os.path.basename(results2_path).replace('.json', '')
        rule_name = results1.get('rule_name', 'unknown')
        
        # Compare best parameters
        best_params1 = results1.get('best_parameters', {}).get('best_parameters', {})
        best_params2 = results2.get('best_parameters', {}).get('best_parameters', {})
        
        parameter_changes = self._compare_parameters(best_params1, best_params2)
        
        # Compare metrics
        best_metrics1 = results1.get('best_parameters', {}).get('best_metrics', {})
        best_metrics2 = results2.get('best_parameters', {}).get('best_metrics', {})
        
        metrics_comparison = {
            'composite_score': {
                'run1': best_metrics1.get('composite_score', 0.0),
                'run2': best_metrics2.get('composite_score', 0.0),
                'change': best_metrics2.get('composite_score', 0.0) - best_metrics1.get('composite_score', 0.0)
            },
            'cohesion': {
                'run1': best_metrics1.get('cohesion', 0.0),
                'run2': best_metrics2.get('cohesion', 0.0),
                'change': best_metrics2.get('cohesion', 0.0) - best_metrics1.get('cohesion', 0.0)
            },
            'separation': {
                'run1': best_metrics1.get('separation', 0.0),
                'run2': best_metrics2.get('separation', 0.0),
                'change': best_metrics2.get('separation', 0.0) - best_metrics1.get('separation', 0.0)
            }
        }
        
        # Calculate improvement scores
        improvement_scores = {
            'overall_improvement': metrics_comparison['composite_score']['change'],
            'relative_improvement': self._calculate_relative_improvement(
                best_metrics1.get('composite_score', 0.0),
                best_metrics2.get('composite_score', 0.0)
            )
        }
        
        # Generate recommendations
        recommendations = self._generate_parameter_recommendations(parameter_changes, improvement_scores)
        
        return RunComparison(
            run1_name=run1_name,
            run2_name=run2_name,
            rule_name=rule_name,
            metrics_comparison=metrics_comparison,
            parameter_changes=parameter_changes,
            improvement_scores=improvement_scores,
            recommendations=recommendations
        )
    
    def _compare_parameters(self, params1: Dict[str, Any], params2: Dict[str, Any]) -> Dict[str, Any]:
        """Compare parameter changes between two runs."""
        changes = {}
        
        # Compare clustering parameters
        clustering1 = params1.get('clustering', {})
        clustering2 = params2.get('clustering', {})
        
        clustering_changes = {}
        for key in set(clustering1.keys()) | set(clustering2.keys()):
            val1 = clustering1.get(key)
            val2 = clustering2.get(key)
            if val1 != val2:
                clustering_changes[key] = {
                    'from': val1,
                    'to': val2,
                    'change': val2 - val1 if isinstance(val2, (int, float)) and isinstance(val1, (int, float)) else None
                }
        
        if clustering_changes:
            changes['clustering'] = clustering_changes
        
        # Compare thresholds
        thresholds1 = params1.get('thresholds', {})
        thresholds2 = params2.get('thresholds', {})
        
        threshold_changes = {}
        for key in set(thresholds1.keys()) | set(thresholds2.keys()):
            val1 = thresholds1.get(key)
            val2 = thresholds2.get(key)
            if val1 != val2:
                threshold_changes[key] = {
                    'from': val1,
                    'to': val2,
                    'change': val2 - val1 if isinstance(val2, (int, float)) and isinstance(val1, (int, float)) else None
                }
        
        if threshold_changes:
            changes['thresholds'] = threshold_changes
        
        return changes
    
    def _calculate_improvement_scores(self, metrics_comparison: Dict[str, Any], 
                                    rule_comparisons: Dict[str, Any]) -> Dict[str, float]:
        """Calculate improvement scores from comparisons."""
        scores = {}
        
        # Overall improvement score
        total_clusters_change = metrics_comparison['total_clusters']['change']
        successful_rules_change = metrics_comparison['successful_rules']['change']
        
        # Weighted improvement score
        scores['overall_improvement'] = (total_clusters_change * 0.7) + (successful_rules_change * 0.3)
        
        # Rule-specific improvements
        rule_improvements = []
        for rule_name, comparison in rule_comparisons.items():
            clusters_change = comparison['clusters_count']['change']
            area_change = comparison['total_area']['change']
            
            # Positive changes are improvements
            rule_improvement = (clusters_change * 0.6) + (area_change / 1000.0 * 0.4)
            rule_improvements.append(rule_improvement)
        
        scores['average_rule_improvement'] = np.mean(rule_improvements) if rule_improvements else 0.0
        
        return scores
    
    def _calculate_relative_improvement(self, old_value: float, new_value: float) -> float:
        """Calculate relative improvement percentage."""
        if old_value == 0:
            return 100.0 if new_value > 0 else 0.0
        return ((new_value - old_value) / abs(old_value)) * 100.0
    
    def _generate_recommendations(self, metrics_comparison: Dict[str, Any], 
                                rule_comparisons: Dict[str, Any],
                                improvement_scores: Dict[str, float]) -> List[str]:
        """Generate recommendations based on comparison results."""
        recommendations = []
        
        # Overall performance recommendations
        if improvement_scores['overall_improvement'] > 0:
            recommendations.append("Development shows positive improvement in clustering performance")
        elif improvement_scores['overall_improvement'] < -10:
            recommendations.append("Significant performance degradation detected - review recent changes")
        
        # Rule-specific recommendations
        for rule_name, comparison in rule_comparisons.items():
            clusters_change = comparison['clusters_count']['change']
            area_change = comparison['total_area']['change']
            
            if clusters_change < -5:
                recommendations.append(f"Rule '{rule_name}': Significant reduction in clusters detected - consider adjusting thresholds")
            elif clusters_change > 20:
                recommendations.append(f"Rule '{rule_name}': Large increase in clusters - consider increasing min_cluster_area")
            
            if area_change < -1000:
                recommendations.append(f"Rule '{rule_name}': Significant reduction in total cluster area - review parameter settings")
        
        # Success rate recommendations
        successful_change = metrics_comparison['successful_rules']['change']
        if successful_change < 0:
            recommendations.append("Decreased success rate - investigate failed rules and error logs")
        elif successful_change > 0:
            recommendations.append("Improved success rate - continue current approach")
        
        return recommendations
    
    def _generate_parameter_recommendations(self, parameter_changes: Dict[str, Any], 
                                          improvement_scores: Dict[str, float]) -> List[str]:
        """Generate parameter-specific recommendations."""
        recommendations = []
        
        # Parameter change recommendations
        if 'clustering' in parameter_changes:
            clustering_changes = parameter_changes['clustering']
            
            if 'k' in clustering_changes:
                k_change = clustering_changes['k']['change']
                if k_change > 0:
                    recommendations.append("Increased k value - monitor for over-clustering")
                elif k_change < 0:
                    recommendations.append("Decreased k value - monitor for under-clustering")
            
            if 'min_size' in clustering_changes:
                min_size_change = clustering_changes['min_size']['change']
                if min_size_change > 0:
                    recommendations.append("Increased min_size - expect fewer, larger clusters")
                elif min_size_change < 0:
                    recommendations.append("Decreased min_size - expect more, smaller clusters")
        
        if 'thresholds' in parameter_changes:
            threshold_changes = parameter_changes['thresholds']
            
            for threshold_name, change_info in threshold_changes.items():
                threshold_change = change_info.get('change', 0)
                if threshold_change > 0:
                    recommendations.append(f"Increased {threshold_name} threshold - expect fewer clusters above threshold")
                elif threshold_change < 0:
                    recommendations.append(f"Decreased {threshold_name} threshold - expect more clusters above threshold")
        
        # Improvement-based recommendations
        if improvement_scores['overall_improvement'] > 0.1:
            recommendations.append("Significant improvement detected - consider applying similar changes to other rules")
        elif improvement_scores['overall_improvement'] < -0.1:
            recommendations.append("Performance degradation - consider reverting recent parameter changes")
        
        return recommendations
    
    def save_comparison_report(self, comparison: RunComparison, output_path: str) -> None:
        """Save comparison report to file."""
        try:
            report_data = {
                'comparison_metadata': {
                    'run1_name': comparison.run1_name,
                    'run2_name': comparison.run2_name,
                    'rule_name': comparison.rule_name,
                    'comparison_date': datetime.now().isoformat()
                },
                'metrics_comparison': comparison.metrics_comparison,
                'parameter_changes': comparison.parameter_changes,
                'improvement_scores': comparison.improvement_scores,
                'recommendations': comparison.recommendations
            }
            
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(report_data, f, indent=2)
            
            self.logger.info(f"Saved comparison report: {output_path}")
            
        except Exception as e:
            self.logger.error(f"Error saving comparison report: {e}")
            raise


class RunAnalyzer:
    """Analyzes multiple runs and tracks trends."""
    
    def __init__(self, data_dir: str = "data/output"):
        self.data_dir = data_dir
        self.comparator = RunComparator(data_dir)
        self.logger = logging.getLogger(__name__)
    
    def analyze_run_trends(self, run_directory: str) -> Dict[str, Any]:
        """Analyze trends across multiple runs."""
        run_dir = Path(run_directory)
        
        if not run_dir.exists():
            self.logger.error(f"Run directory not found: {run_directory}")
            return {}
        
        # Find all manifest files
        manifest_files = list(run_dir.glob("run_manifest_*.json"))
        manifest_files.sort()
        
        if len(manifest_files) < 2:
            self.logger.warning("Need at least 2 runs to analyze trends")
            return {}
        
        # Compare consecutive runs
        comparisons = []
        for i in range(len(manifest_files) - 1):
            comparison = self.comparator.compare_run_manifests(
                str(manifest_files[i]),
                str(manifest_files[i + 1])
            )
            comparisons.append(comparison)
        
        # Analyze trends
        trends = self._analyze_trends(comparisons)
        
        return {
            'total_runs': len(manifest_files),
            'comparisons': [asdict(c) for c in comparisons],
            'trends': trends
        }
    
    def _analyze_trends(self, comparisons: List[RunComparison]) -> Dict[str, Any]:
        """Analyze trends from multiple comparisons."""
        trends = {
            'improvement_trend': [],
            'cluster_count_trend': [],
            'success_rate_trend': [],
            'overall_trend': 'stable'
        }
        
        for comparison in comparisons:
            trends['improvement_trend'].append(comparison.improvement_scores.get('overall_improvement', 0.0))
            
            total_clusters_change = comparison.metrics_comparison.get('total_clusters', {}).get('change', 0)
            trends['cluster_count_trend'].append(total_clusters_change)
            
            successful_rules_change = comparison.metrics_comparison.get('successful_rules', {}).get('change', 0)
            trends['success_rate_trend'].append(successful_rules_change)
        
        # Determine overall trend
        avg_improvement = np.mean(trends['improvement_trend'])
        if avg_improvement > 0.1:
            trends['overall_trend'] = 'improving'
        elif avg_improvement < -0.1:
            trends['overall_trend'] = 'declining'
        
        return trends


def main():
    """Test the run comparator."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Run Comparison Tool')
    parser.add_argument('--manifest1', help='First run manifest file')
    parser.add_argument('--manifest2', help='Second run manifest file')
    parser.add_argument('--results1', help='First experiment results file')
    parser.add_argument('--results2', help='Second experiment results file')
    parser.add_argument('--output', help='Output comparison report file')
    parser.add_argument('--analyze-trends', help='Analyze trends in run directory')
    
    args = parser.parse_args()
    
    # Set up logging
    logging.basicConfig(level=logging.INFO)
    
    comparator = RunComparator()
    
    try:
        if args.analyze_trends:
            analyzer = RunAnalyzer()
            trends = analyzer.analyze_run_trends(args.analyze_trends)
            print(f"Analyzed trends for {trends.get('total_runs', 0)} runs")
            print(f"Overall trend: {trends.get('trends', {}).get('overall_trend', 'unknown')}")
        
        elif args.manifest1 and args.manifest2:
            comparison = comparator.compare_run_manifests(args.manifest1, args.manifest2)
            print(f"Comparison between {comparison.run1_name} and {comparison.run2_name}")
            print(f"Improvement scores: {comparison.improvement_scores}")
            print(f"Recommendations: {comparison.recommendations}")
            
            if args.output:
                comparator.save_comparison_report(comparison, args.output)
        
        elif args.results1 and args.results2:
            comparison = comparator.compare_experiment_results(args.results1, args.results2)
            print(f"Experiment comparison for rule {comparison.rule_name}")
            print(f"Parameter changes: {comparison.parameter_changes}")
            print(f"Improvement scores: {comparison.improvement_scores}")
            print(f"Recommendations: {comparison.recommendations}")
            
            if args.output:
                comparator.save_comparison_report(comparison, args.output)
        
        else:
            print("Please specify comparison files or trend analysis directory")
    
    except Exception as e:
        print(f"Comparison failed: {e}")


if __name__ == "__main__":
    main()
