#!/usr/bin/env python3
"""
Demo script for the cluster analysis pipeline.

This script demonstrates the basic functionality of the pipeline
without requiring actual simulation data or ICMExchange.
"""

import os
import sys
import json
from datetime import datetime
from rule_parser import RuleParser, AnalysisType


def demo_rule_parsing():
    """Demonstrate rule parsing functionality."""
    print("=== Rule Parsing Demo ===")
    
    parser = RuleParser()
    rules = parser.parse_all_rules()
    
    print(f"Found {len(rules)} rules:")
    for rule in rules:
        print(f"\nRule: {rule.name}")
        print(f"  Type: {rule.analysis_type.value}")
        print(f"  Query: {rule.query_text}")
        print(f"  Attributes: {rule.attributes}")
        
        if rule.baseline_id and rule.candidate_id:
            print(f"  Comparison: Simulation {rule.baseline_id} vs {rule.candidate_id}")
        
        # Show clustering parameters
        if rule.clustering:
            print(f"  Clustering: {rule.clustering}")
        
        # Show thresholds
        if rule.thresholds:
            print(f"  Thresholds: {rule.thresholds}")


def demo_analysis_types():
    """Demonstrate different analysis types."""
    print("\n=== Analysis Types Demo ===")
    
    analysis_types = {
        AnalysisType.COMPARISON: "Compare baseline vs candidate scenarios",
        AnalysisType.THRESHOLD: "Filter areas exceeding thresholds",
        AnalysisType.HAZARD: "Compute hazard indices (depth × speed)",
        AnalysisType.VOLUME: "Spatial integration and volume calculations",
        AnalysisType.RANKING: "Rank clusters by severity/impact"
    }
    
    for analysis_type, description in analysis_types.items():
        print(f"{analysis_type.value}: {description}")


def demo_output_structure():
    """Demonstrate expected output structure."""
    print("\n=== Output Structure Demo ===")
    
    output_structure = {
        "data/output/": {
            "rasters/": "Exported GeoTIFF raster files",
            "clusters/": "Cluster boundaries and metrics",
            "viz/": "Visualizations and animations",
            "results/": "Reports and summaries",
            "experiments/": "Optimization results",
            "logs/": "Pipeline execution logs"
        }
    }
    
    def print_structure(structure, indent=0):
        for key, value in structure.items():
            prefix = "  " * indent
            if isinstance(value, dict):
                print(f"{prefix}{key}")
                print_structure(value, indent + 1)
            else:
                print(f"{prefix}{key} - {value}")
    
    print_structure(output_structure)


def demo_rule_configuration():
    """Demonstrate rule configuration examples."""
    print("\n=== Rule Configuration Demo ===")
    
    # Example comparison rule
    comparison_config = {
        "name": "depth_change_analysis",
        "analysis_type": "comparison",
        "query": "How has the depth in my clusters changed?",
        "attributes": ["DEPTH2D", "SPEED2D"],
        "baseline_id": 1,
        "candidate_id": 2,
        "clustering": {
            "method": "kmeans",
            "k": 5,
            "max_iter": 300,
            "random_seed": 42
        },
        "thresholds": {
            "change_threshold": 0.01,
            "min_cluster_area": 100.0
        }
    }
    
    print("Example Comparison Rule Configuration:")
    print(json.dumps(comparison_config, indent=2))
    
    # Example threshold rule
    threshold_config = {
        "name": "show_high_depths",
        "analysis_type": "threshold",
        "query": "Show me all areas with a flood depth > 0.5m",
        "attributes": ["DEPTH2D"],
        "baseline_id": 1,
        "clustering": {
            "method": "connected_components",
            "min_size": 50
        },
        "thresholds": {
            "depth_threshold": 0.5
        }
    }
    
    print("\nExample Threshold Rule Configuration:")
    print(json.dumps(threshold_config, indent=2))


def demo_workflow():
    """Demonstrate the complete workflow."""
    print("\n=== Workflow Demo ===")
    
    workflow_steps = [
        "1. Parse rule files (.rul) and configurations (.json)",
        "2. Export rasters from ICM simulations using Ruby scripts",
        "3. Process rasters with Python clustering algorithms",
        "4. Generate cluster boundaries and compute metrics",
        "5. Create visualizations (overlays, heatmaps, animations)",
        "6. Export results (CSV, GeoJSON, markdown reports)",
        "7. Optimize parameters through iterative experiments",
        "8. Track improvements with git commits and tags"
    ]
    
    for step in workflow_steps:
        print(f"  {step}")


def demo_optimization():
    """Demonstrate optimization capabilities."""
    print("\n=== Optimization Demo ===")
    
    optimization_features = [
        "Parameter Space Exploration: Test different k values, thresholds, algorithms",
        "Quality Metrics: Silhouette score, cohesion, separation",
        "Best Parameter Selection: Automatic identification of optimal configurations",
        "Iterative Refinement: Multiple optimization cycles",
        "Improvement Tracking: Compare results between iterations",
        "Git Integration: Track optimization progress with commits"
    ]
    
    for feature in optimization_features:
        print(f"  • {feature}")


def demo_usage_examples():
    """Demonstrate usage examples."""
    print("\n=== Usage Examples ===")
    
    examples = [
        {
            "title": "Run Complete Pipeline",
            "command": "powershell .\\scripts\\run_pipeline.ps1",
            "description": "Process all rules with raster export"
        },
        {
            "title": "Run Specific Rules",
            "command": "powershell .\\scripts\\run_pipeline.ps1 -Rules depth_change_analysis,show_high_depths",
            "description": "Process only specified rules"
        },
        {
            "title": "Skip Raster Export",
            "command": "powershell .\\scripts\\run_pipeline.ps1 -NoExport",
            "description": "Use existing raster data"
        },
        {
            "title": "Optimize Parameters",
            "command": "python scripts/optimizer.py --rule depth_change_analysis",
            "description": "Optimize clustering parameters for specific rule"
        },
        {
            "title": "Commit Iteration",
            "command": "powershell .\\scripts\\commit_iteration.ps1 -Message 'Optimization iteration 1'",
            "description": "Track progress with git commits"
        }
    ]
    
    for example in examples:
        print(f"\n{example['title']}:")
        print(f"  Command: {example['command']}")
        print(f"  Description: {example['description']}")


def main():
    """Run the complete demo."""
    print("Cluster Analysis Pipeline - Demo")
    print("=" * 50)
    print(f"Demo run at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    try:
        demo_rule_parsing()
        demo_analysis_types()
        demo_output_structure()
        demo_rule_configuration()
        demo_workflow()
        demo_optimization()
        demo_usage_examples()
        
        print("\n" + "=" * 50)
        print("Demo completed successfully!")
        print("\nNext steps:")
        print("1. Install Python dependencies: pip install -r requirements.txt")
        print("2. Run basic tests: python scripts/test_pipeline.py")
        print("3. Execute pipeline: powershell .\\scripts\\run_pipeline.ps1")
        print("4. Check results in data/output/ directory")
        
    except Exception as e:
        print(f"\nDemo failed with error: {e}")
        return 1
    
    return 0


if __name__ == "__main__":
    exit(main())
