#!/usr/bin/env python3
"""
Optimizer module for cluster analysis pipeline.

Runs experiments with varying cluster parameters, tests different algorithms,
and identifies best parameters per rule type.
"""

import os
import json
import numpy as np
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple
import logging
from dataclasses import dataclass, asdict
from sklearn.metrics import silhouette_score, calinski_harabasz_score, davies_bouldin_score
from sklearn.cluster import KMeans, DBSCAN
import itertools

from rule_parser import RuleParser, RuleConfig
from cluster_processor import ClusterProcessor, AnalysisResult
from pipeline_runner import PipelineRunner


@dataclass
class OptimizationParams:
    """Parameters for optimization experiments."""
    k_values: List[int] = None
    min_size_values: List[int] = None
    threshold_values: List[float] = None
    algorithms: List[str] = None
    
    def __post_init__(self):
        if self.k_values is None:
            self.k_values = [3, 4, 5, 6, 7, 8, 10]
        if self.min_size_values is None:
            self.min_size_values = [25, 50, 75, 100, 150, 200]
        if self.threshold_values is None:
            self.threshold_values = [0.005, 0.01, 0.02, 0.05, 0.1, 0.2]
        if self.algorithms is None:
            self.algorithms = ['kmeans', 'connected_components', 'dbscan']


@dataclass
class ExperimentResult:
    """Result of a single optimization experiment."""
    experiment_id: str
    rule_name: str
    parameters: Dict[str, Any]
    metrics: Dict[str, float]
    clusters_count: int
    total_area: float
    mean_cluster_value: float
    processing_time: float
    timestamp: str


class ClusterQualityMetrics:
    """Computes quality metrics for cluster analysis results."""
    
    def __init__(self):
        self.logger = logging.getLogger(__name__)
    
    def compute_silhouette_score(self, data: np.ndarray, labels: np.ndarray) -> float:
        """Compute silhouette score for clustering quality."""
        try:
            # Remove nodata values
            mask = data != -9999
            valid_data = data[mask].reshape(-1, 1)
            valid_labels = labels[mask]
            
            if len(np.unique(valid_labels)) < 2:
                return -1.0  # Cannot compute silhouette for single cluster
            
            score = silhouette_score(valid_data, valid_labels)
            return score
        except Exception as e:
            self.logger.warning(f"Could not compute silhouette score: {e}")
            return -1.0
    
    def compute_calinski_harabasz_score(self, data: np.ndarray, labels: np.ndarray) -> float:
        """Compute Calinski-Harabasz score for clustering quality."""
        try:
            # Remove nodata values
            mask = data != -9999
            valid_data = data[mask].reshape(-1, 1)
            valid_labels = labels[mask]
            
            if len(np.unique(valid_labels)) < 2:
                return 0.0  # Cannot compute CH score for single cluster
            
            score = calinski_harabasz_score(valid_data, valid_labels)
            return score
        except Exception as e:
            self.logger.warning(f"Could not compute Calinski-Harabasz score: {e}")
            return 0.0
    
    def compute_davies_bouldin_score(self, data: np.ndarray, labels: np.ndarray) -> float:
        """Compute Davies-Bouldin score for clustering quality."""
        try:
            # Remove nodata values
            mask = data != -9999
            valid_data = data[mask].reshape(-1, 1)
            valid_labels = labels[mask]
            
            if len(np.unique(valid_labels)) < 2:
                return float('inf')  # Cannot compute DB score for single cluster
            
            score = davies_bouldin_score(valid_data, valid_labels)
            return score
        except Exception as e:
            self.logger.warning(f"Could not compute Davies-Bouldin score: {e}")
            return float('inf')
    
    def compute_cluster_cohesion(self, clusters: List[Any]) -> float:
        """Compute cluster cohesion based on within-cluster variance."""
        if not clusters:
            return 0.0
        
        total_cohesion = 0.0
        for cluster in clusters:
            # Use std_value as a measure of cohesion (lower is better)
            cohesion = 1.0 / (1.0 + cluster.std_value)  # Convert to 0-1 scale
            total_cohesion += cohesion
        
        return total_cohesion / len(clusters)
    
    def compute_cluster_separation(self, clusters: List[Any]) -> float:
        """Compute cluster separation based on centroid distances."""
        if len(clusters) < 2:
            return 0.0
        
        total_distance = 0.0
        count = 0
        
        for i in range(len(clusters)):
            for j in range(i + 1, len(clusters)):
                # Compute Euclidean distance between centroids
                dist = np.sqrt(
                    (clusters[i].centroid[0] - clusters[j].centroid[0])**2 +
                    (clusters[i].centroid[1] - clusters[j].centroid[1])**2
                )
                total_distance += dist
                count += 1
        
        return total_distance / count if count > 0 else 0.0
    
    def compute_composite_score(self, result: AnalysisResult) -> float:
        """Compute a composite quality score for the clustering result."""
        try:
            # Extract data and labels from the result (this would need to be stored)
            # For now, use available metrics
            cohesion = self.compute_cluster_cohesion(result.clusters)
            separation = self.compute_cluster_separation(result.clusters)
            
            # Normalize separation (higher is better, but we want to scale it)
            normalized_separation = min(separation / 1000.0, 1.0)  # Assume max distance of 1000
            
            # Combine metrics (cohesion + separation)
            composite_score = (cohesion + normalized_separation) / 2.0
            
            return composite_score
        except Exception as e:
            self.logger.warning(f"Could not compute composite score: {e}")
            return 0.0


class ParameterOptimizer:
    """Optimizes clustering parameters through systematic experiments."""
    
    def __init__(self, 
                 data_dir: str = "data/output",
                 experiments_dir: str = "data/output/experiments"):
        self.data_dir = data_dir
        self.experiments_dir = experiments_dir
        self.cluster_processor = ClusterProcessor(data_dir)
        self.quality_metrics = ClusterQualityMetrics()
        self.logger = logging.getLogger(__name__)
        
        os.makedirs(experiments_dir, exist_ok=True)
    
    def generate_parameter_combinations(self, rule_config: RuleConfig, 
                                      opt_params: OptimizationParams) -> List[Dict[str, Any]]:
        """Generate all parameter combinations for optimization."""
        combinations = []
        
        # Base parameters
        base_params = {
            'attributes': rule_config.attributes,
            'baseline_id': rule_config.baseline_id,
            'candidate_id': rule_config.candidate_id
        }
        
        # Generate combinations based on analysis type
        if rule_config.analysis_type.value == "comparison":
            # For comparison analysis, vary k values and thresholds
            for k in opt_params.k_values:
                for threshold in opt_params.threshold_values:
                    for algorithm in opt_params.algorithms:
                        if algorithm == 'kmeans':
                            params = {
                                **base_params,
                                'clustering': {
                                    'method': 'kmeans',
                                    'k': k,
                                    'max_iter': 300,
                                    'random_seed': 42
                                },
                                'thresholds': {
                                    'change_threshold': threshold,
                                    'min_cluster_area': 100.0
                                }
                            }
                            combinations.append(params)
                        elif algorithm == 'connected_components':
                            params = {
                                **base_params,
                                'clustering': {
                                    'method': 'connected_components',
                                    'min_size': 50
                                },
                                'thresholds': {
                                    'change_threshold': threshold,
                                    'min_cluster_area': 100.0
                                }
                            }
                            combinations.append(params)
        
        elif rule_config.analysis_type.value == "threshold":
            # For threshold analysis, vary thresholds and min_size
            for threshold in opt_params.threshold_values:
                for min_size in opt_params.min_size_values:
                    params = {
                        **base_params,
                        'clustering': {
                            'method': 'connected_components',
                            'min_size': min_size
                        },
                        'thresholds': {
                            'depth_threshold': threshold
                        }
                    }
                    combinations.append(params)
        
        elif rule_config.analysis_type.value == "hazard":
            # For hazard analysis, vary k values and hazard thresholds
            for k in opt_params.k_values:
                for threshold in opt_params.threshold_values:
                    params = {
                        **base_params,
                        'clustering': {
                            'method': 'kmeans',
                            'k': k,
                            'max_iter': 300,
                            'random_seed': 42
                        },
                        'thresholds': {
                            'hazard_threshold': threshold
                        }
                    }
                    combinations.append(params)
        
        else:
            # Default combinations
            for k in opt_params.k_values:
                params = {
                    **base_params,
                    'clustering': {
                        'method': 'kmeans',
                        'k': k,
                        'max_iter': 300,
                        'random_seed': 42
                    },
                    'thresholds': rule_config.thresholds
                }
                combinations.append(params)
        
        return combinations
    
    def run_experiment(self, rule_config: RuleConfig, parameters: Dict[str, Any], 
                      experiment_id: str) -> ExperimentResult:
        """Run a single optimization experiment."""
        start_time = datetime.now()
        
        try:
            # Create original rule config with new parameters
            modified_config = RuleConfig(
                name=rule_config.name,
                analysis_type=rule_config.analysis_type,
                query_text=rule_config.query_text,
                attributes=parameters.get('attributes', rule_config.attributes),
                thresholds=parameters.get('thresholds', rule_config.thresholds),
                clustering=parameters.get('clustering', rule_config.clustering),
                visualization=rule_config.visualization,
                outputs=rule_config.outputs,
                baseline_id=parameters.get('baseline_id', rule_config.baseline_id),
                candidate_id=parameters.get('candidate_id', rule_config.candidate_id)
            )
            
            # Process the rule with modified parameters
            result = self.cluster_processor.process_rule(modified_config)
            
            # Compute quality metrics
            composite_score = self.quality_metrics.compute_composite_score(result)
            cohesion = self.quality_metrics.compute_cluster_cohesion(result.clusters)
            separation = self.quality_metrics.compute_cluster_separation(result.clusters)
            
            processing_time = (datetime.now() - start_time).total_seconds()
            
            experiment_result = ExperimentResult(
                experiment_id=experiment_id,
                rule_name=rule_config.name,
                parameters=parameters,
                metrics={
                    'composite_score': composite_score,
                    'cohesion': cohesion,
                    'separation': separation,
                    'silhouette_score': -1.0,  # Would need raw data
                    'calinski_harabasz_score': 0.0,  # Would need raw data
                    'davies_bouldin_score': float('inf')  # Would need raw data
                },
                clusters_count=len(result.clusters),
                total_area=result.statistics.get('total_area', 0.0),
                mean_cluster_value=result.statistics.get('mean_cluster_value', 0.0),
                processing_time=processing_time,
                timestamp=datetime.now().isoformat()
            )
            
            return experiment_result
            
        except Exception as e:
            self.logger.error(f"Error in experiment {experiment_id}: {e}")
            # Return a failed experiment result
            return ExperimentResult(
                experiment_id=experiment_id,
                rule_name=rule_config.name,
                parameters=parameters,
                metrics={'composite_score': 0.0, 'cohesion': 0.0, 'separation': 0.0},
                clusters_count=0,
                total_area=0.0,
                mean_cluster_value=0.0,
                processing_time=0.0,
                timestamp=datetime.now().isoformat()
            )
    
    def optimize_rule(self, rule_config: RuleConfig, 
                     opt_params: OptimizationParams) -> List[ExperimentResult]:
        """Optimize parameters for a single rule."""
        self.logger.info(f"Optimizing rule: {rule_config.name}")
        
        # Generate parameter combinations
        combinations = self.generate_parameter_combinations(rule_config, opt_params)
        self.logger.info(f"Generated {len(combinations)} parameter combinations")
        
        # Run experiments
        results = []
        for i, params in enumerate(combinations):
            experiment_id = f"{rule_config.name}_{i:03d}"
            self.logger.info(f"Running experiment {i+1}/{len(combinations)}: {experiment_id}")
            
            result = self.run_experiment(rule_config, params, experiment_id)
            results.append(result)
        
        return results
    
    def find_best_parameters(self, experiment_results: List[ExperimentResult]) -> Dict[str, Any]:
        """Find the best parameters from experiment results."""
        if not experiment_results:
            return {}
        
        # Sort by composite score (higher is better)
        sorted_results = sorted(experiment_results, 
                              key=lambda x: x.metrics.get('composite_score', 0.0), 
                              reverse=True)
        
        best_result = sorted_results[0]
        
        return {
            'best_parameters': best_result.parameters,
            'best_metrics': best_result.metrics,
            'experiment_id': best_result.experiment_id,
            'improvement_over_default': self._compute_improvement(experiment_results)
        }
    
    def _compute_improvement(self, results: List[ExperimentResult]) -> Dict[str, float]:
        """Compute improvement over default parameters."""
        if len(results) < 2:
            return {}
        
        # Assume first result is default
        default_result = results[0]
        best_result = max(results, key=lambda x: x.metrics.get('composite_score', 0.0))
        
        default_score = default_result.metrics.get('composite_score', 0.0)
        best_score = best_result.metrics.get('composite_score', 0.0)
        
        improvement = {
            'composite_score_improvement': best_score - default_score,
            'relative_improvement': (best_score - default_score) / max(default_score, 0.001) * 100
        }
        
        return improvement
    
    def save_experiment_results(self, results: List[ExperimentResult], rule_name: str) -> str:
        """Save experiment results to file."""
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        filename = f"{rule_name}_optimization_{timestamp}.json"
        filepath = os.path.join(self.experiments_dir, filename)
        
        # Convert results to serializable format
        serializable_results = []
        for result in results:
            serializable_results.append(asdict(result))
        
        experiment_data = {
            'rule_name': rule_name,
            'timestamp': timestamp,
            'total_experiments': len(results),
            'results': serializable_results,
            'best_parameters': self.find_best_parameters(results)
        }
        
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(experiment_data, f, indent=2)
        
        self.logger.info(f"Saved experiment results: {filepath}")
        return filepath


class PipelineOptimizer:
    """Main optimizer that orchestrates the optimization process."""
    
    def __init__(self, 
                 scripts_dir: str = "scripts",
                 data_dir: str = "data/output"):
        self.scripts_dir = scripts_dir
        self.data_dir = data_dir
        self.rule_parser = RuleParser(scripts_dir)
        self.parameter_optimizer = ParameterOptimizer(data_dir)
        self.logger = logging.getLogger(__name__)
    
    def optimize_all_rules(self, opt_params: OptimizationParams) -> Dict[str, Any]:
        """Optimize parameters for all rules."""
        self.logger.info("Starting optimization for all rules")
        
        # Parse all rules
        rules = self.rule_parser.parse_all_rules()
        if not rules:
            self.logger.warning("No rules found for optimization")
            return {}
        
        optimization_results = {}
        
        for rule_config in rules:
            try:
                self.logger.info(f"Optimizing rule: {rule_config.name}")
                
                # Run optimization
                experiment_results = self.parameter_optimizer.optimize_rule(rule_config, opt_params)
                
                # Find best parameters
                best_params = self.parameter_optimizer.find_best_parameters(experiment_results)
                
                # Save results
                results_file = self.parameter_optimizer.save_experiment_results(
                    experiment_results, rule_config.name
                )
                
                optimization_results[rule_config.name] = {
                    'best_parameters': best_params,
                    'total_experiments': len(experiment_results),
                    'results_file': results_file
                }
                
                self.logger.info(f"Completed optimization for rule: {rule_config.name}")
                
            except Exception as e:
                self.logger.error(f"Error optimizing rule {rule_config.name}: {e}")
                optimization_results[rule_config.name] = {
                    'error': str(e),
                    'best_parameters': {},
                    'total_experiments': 0
                }
        
        return optimization_results
    
    def optimize_single_rule(self, rule_name: str, opt_params: OptimizationParams) -> Dict[str, Any]:
        """Optimize parameters for a single rule."""
        rule_config = self.rule_parser.get_rule_by_name(rule_name)
        if not rule_config:
            self.logger.error(f"Rule not found: {rule_name}")
            return {}
        
        try:
            self.logger.info(f"Optimizing rule: {rule_name}")
            
            # Run optimization
            experiment_results = self.parameter_optimizer.optimize_rule(rule_config, opt_params)
            
            # Find best parameters
            best_params = self.parameter_optimizer.find_best_parameters(experiment_results)
            
            # Save results
            results_file = self.parameter_optimizer.save_experiment_results(
                experiment_results, rule_name
            )
            
            return {
                'rule_name': rule_name,
                'best_parameters': best_params,
                'total_experiments': len(experiment_results),
                'results_file': results_file
            }
            
        except Exception as e:
            self.logger.error(f"Error optimizing rule {rule_name}: {e}")
            return {'error': str(e)}


def main():
    """Test the optimizer."""
    import argparse
    
    parser = argparse.ArgumentParser(description='Cluster Analysis Optimizer')
    parser.add_argument('--rule', help='Specific rule to optimize')
    parser.add_argument('--all-rules', action='store_true', help='Optimize all rules')
    parser.add_argument('--scripts-dir', default='scripts', help='Scripts directory')
    parser.add_argument('--data-dir', default='data/output', help='Data output directory')
    
    args = parser.parse_args()
    
    # Set up logging
    logging.basicConfig(level=logging.INFO)
    
    # Initialize optimizer
    optimizer = PipelineOptimizer(args.scripts_dir, args.data_dir)
    
    # Set up optimization parameters
    opt_params = OptimizationParams()
    
    try:
        if args.all_rules:
            # Optimize all rules
            results = optimizer.optimize_all_rules(opt_params)
            print(f"Optimized {len(results)} rules")
            
            for rule_name, result in results.items():
                print(f"\n{rule_name}:")
                print(f"  Best parameters: {result.get('best_parameters', {})}")
                print(f"  Total experiments: {result.get('total_experiments', 0)}")
        
        elif args.rule:
            # Optimize single rule
            result = optimizer.optimize_single_rule(args.rule, opt_params)
            print(f"Optimization result for {args.rule}:")
            print(f"  Best parameters: {result.get('best_parameters', {})}")
            print(f"  Total experiments: {result.get('total_experiments', 0)}")
        
        else:
            print("Please specify --rule <rule_name> or --all-rules")
    
    except Exception as e:
        print(f"Optimization failed: {e}")


if __name__ == "__main__":
    main()
