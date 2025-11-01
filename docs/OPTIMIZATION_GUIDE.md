# Parameter Optimization Guide

This guide explains how to use the automated parameter optimization system for cluster analysis rules.

## Overview

The optimization system automatically tests multiple parameter combinations for each rule, evaluates quality metrics, and identifies the best parameters based on composite quality scores.

## Quick Start

### 1. Optimize All Rules

```bash
python scripts/optimizer.py --all-rules
```

This will:
- Test parameter combinations for all rules
- Save best parameters to `data/output/experiments/<rule_name>_best_params.json`
- Update rule JSON files with optimized parameters
- Generate `data/output/experiments/optimization_summary.md`

### 2. Validate Optimized Rules

```bash
python scripts/validate_optimized_rules.py --all-rules
```

This will:
- Run pipeline for each optimized rule
- Validate quality metrics
- Compare with previous runs
- Generate `data/output/experiments/validation_report.md`

## Workflow

### Step 1: Optimization

Run the optimizer to find best parameters:

```bash
python scripts/optimizer.py --all-rules
```

**What happens:**
1. Parser loads all `.rul` and `.json` rule files
2. For each rule, generates parameter combinations:
   - **K-means**: Different k values (3, 4, 5, 6, 7, 8, 10)
   - **Thresholds**: Different threshold values (0.005, 0.01, 0.02, 0.05, 0.1, 0.2)
   - **Algorithms**: kmeans, connected_components, dbscan
   - **Min sizes**: Different minimum cluster sizes (25, 50, 75, 100, 150, 200)
3. Runs experiments for each combination
4. Computes quality metrics:
   - Composite score (weighted combination)
   - Cluster cohesion
   - Cluster separation
   - Silhouette score (when applicable)
5. Identifies best parameters based on composite score
6. Saves results and updates rule JSON files

**Output:**
- `data/output/experiments/<rule_name>_optimization_<timestamp>.json` - Full experiment results
- `data/output/experiments/<rule_name>_best_params.json` - Best parameters
- `data/output/experiments/optimization_summary.md` - Summary report

### Step 2: Validation

Validate the optimized parameters:

```bash
python scripts/validate_optimized_rules.py --all-rules
```

**What happens:**
1. Loads best parameters from optimization results
2. Runs pipeline for each optimized rule
3. Verifies output quality:
   - Checks if required files exist
   - Validates quality metrics meet thresholds
   - Verifies GeoJSON and CSV exports
4. Compares with previous runs (if available):
   - Computes improvement scores
   - Identifies regressions
   - Generates recommendations
5. Generates validation report

**Output:**
- `data/output/experiments/validation_report.md` - Validation report with:
  - Summary table comparing all rules
  - Detailed results for each rule
  - List of rules requiring manual review
  - Recommendations for improvement

### Step 3: Automatic Verification

The pipeline automatically verifies results after each rule execution:

**What happens:**
1. After processing each rule, `pipeline_runner.py` calls `verify_pipeline_results.py`
2. Verification checks:
   - Directory structure exists
   - Required output files exist (visualizations, GeoJSON, CSV)
   - Quality metrics meet thresholds
   - GeoJSON files are valid
   - CSV files are readable
3. Generates verification log

**Output:**
- `data/output/logs/active/verification_<rule_name>_<timestamp>.md` - Verification log

## Parameter Combinations

### Comparison Analysis

For comparison analysis rules, the optimizer tests:
- **K values**: 3, 4, 5, 6, 7, 8, 10
- **Thresholds**: 0.005, 0.01, 0.02, 0.05, 0.1, 0.2
- **Algorithms**: kmeans, connected_components

### Threshold Analysis

For threshold analysis rules:
- **Thresholds**: 0.005, 0.01, 0.02, 0.05, 0.1, 0.2
- **Min sizes**: 25, 50, 75, 100, 150, 200
- **Algorithm**: connected_components

### Hazard Analysis

For hazard analysis rules:
- **K values**: 3, 4, 5, 6, 7, 8, 10
- **Hazard thresholds**: 0.005, 0.01, 0.02, 0.05, 0.1, 0.2
- **Algorithm**: kmeans

## Quality Metrics

### Composite Score

Weighted combination of multiple metrics:
- Higher is better
- Combines cohesion and separation
- Default threshold: 0.3

### Cluster Cohesion

Measures how tightly packed cluster members are:
- Higher is better
- Default threshold: 0.2

### Cluster Separation

Measures how well clusters are separated:
- Higher is better
- Used in composite score calculation

### Silhouette Score

Measures cluster quality (when applicable):
- Range: -1 to 1
- Higher is better
- Used for k-means optimization

## Best Parameters Structure

Best parameters are saved in `data/output/experiments/<rule_name>_best_params.json`:

```json
{
  "rule_name": "depth_change_analysis",
  "timestamp": "2024-01-01T12:00:00",
  "best_parameters": {
    "clustering": {
      "method": "kmeans",
      "k": 6,
      "max_iter": 300,
      "random_seed": 42
    },
    "thresholds": {
      "min_cluster_area": 150.0
    }
  },
  "best_metrics": {
    "composite_score": 0.75,
    "cohesion": 0.65,
    "separation": 0.85
  },
  "experiment_id": "depth_change_analysis_042",
  "improvement_over_default": {
    "composite_score_improvement": 0.15,
    "relative_improvement": 25.0
  }
}
```

## Rule JSON Updates

Optimized parameters are automatically merged into rule JSON files:

```json
{
  "clustering": {
    "method": "kmeans",
    "k": 6,              // Updated from optimizer
    "max_iter": 300,
    "random_seed": 42
  },
  "thresholds": {
    "min_cluster_area": 150.0  // Updated from optimizer
  }
}
```

**Note:** Only clustering and thresholds sections are updated. Other configuration (attributes, visualization, outputs) remains unchanged.

## Validation Report Structure

The validation report includes:

1. **Summary**: Overall statistics (passed/failed/regression counts)
2. **Comparison Table**: Quick overview of all rules
3. **Detailed Results**: For each rule:
   - Pipeline metrics (clusters, area, mean value)
   - Comparison with previous run
   - Quality check status
   - Issues and recommendations
4. **Manual Review List**: Rules requiring attention

## Troubleshooting

### Optimization Takes Too Long

Reduce parameter space in `scripts/optimizer.py`:

```python
opt_params = OptimizationParams(
    k_values=[4, 6, 8],  # Fewer k values
    threshold_values=[0.01, 0.05, 0.1],  # Fewer thresholds
    min_size_values=[50, 100, 150]  # Fewer min sizes
)
```

### No Improvement Found

If optimization doesn't improve results:
1. Check if default parameters are already optimal
2. Expand parameter space
3. Review quality metrics thresholds
4. Check for data quality issues

### Validation Fails

If validation fails:
1. Check if pipeline runs successfully
2. Verify output files are generated
3. Review quality metric thresholds in `verify_pipeline_results.py`
4. Check for missing previous run data for comparison

### Rule JSON Not Updated

If rule JSON files aren't updated:
1. Check file permissions
2. Verify rule JSON file exists
3. Review optimizer logs for errors
4. Manually update if needed

## Advanced Usage

### Custom Optimization Parameters

Create custom optimization parameters:

```python
from optimizer import OptimizationParams, PipelineOptimizer

opt_params = OptimizationParams(
    k_values=[3, 5, 7, 9, 11],
    min_size_values=[30, 60, 90, 120],
    threshold_values=[0.01, 0.02, 0.05],
    algorithms=['kmeans', 'dbscan']
)

optimizer = PipelineOptimizer('scripts', 'data/output')
results = optimizer.optimize_all_rules(opt_params)
```

### Single Rule Optimization

Optimize a specific rule:

```bash
python scripts/optimizer.py --rule depth_change_analysis
```

### Validation Without Export

Validate without exporting rasters (use existing data):

```bash
python scripts/validate_optimized_rules.py --all-rules
# Rasters are not exported by default
```

To export rasters during validation:

```bash
python scripts/validate_optimized_rules.py --all-rules --export-rasters
```

## Best Practices

1. **Run optimization before validation**: Ensure best parameters are found first
2. **Review optimization summary**: Check if improvements are significant
3. **Validate after optimization**: Verify optimized parameters work correctly
4. **Archive old results**: Use `cleanup_experiments.ps1` to archive old optimization results
5. **Track iterations**: Use git tags to track optimization iterations
6. **Manual review**: Always review rules marked for manual review in validation report

## Next Steps

After optimization and validation:

1. **Review results**: Check optimization and validation reports
2. **Manual adjustments**: Fine-tune parameters if needed
3. **Git commit**: Commit optimized parameters with tag
4. **Production use**: Use optimized parameters in production pipeline
5. **Iterative improvement**: Repeat optimization cycle as needed

