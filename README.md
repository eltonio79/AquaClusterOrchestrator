# Cluster Analysis Pipeline

An automated 2D cluster analysis and visualization pipeline for InfoWorks ICM simulation results. This pipeline processes raster exports from ICM simulations, performs clustering analysis based on natural language rules, and generates comprehensive visualizations and reports.

## Overview

The pipeline implements a complete workflow from raster export through clustering analysis to visualization and reporting, with support for iterative optimization and git-tracked experiments.

### Architecture

**Flow:** Ruby (ICMExchange) → Raster Export → Python (Analysis & Clustering) → Results & Visualization → Git Tracking

**Model:** `models/standalone/Medium 2D/Ruby_Hackathon_Medium_2D_Model.icmm`

## Features

- **Natural Language Rules**: Parse `.rul` files with natural language queries
- **Multiple Analysis Types**: Comparison, threshold, hazard, volume, and ranking analyses
- **Automated Clustering**: K-means, connected components, and DBSCAN algorithms
- **Rich Visualizations**: Cluster overlays, heatmaps, difference maps, and animations
- **Comprehensive Reports**: CSV exports, GeoJSON boundaries, and markdown reports
- **Parameter Optimization**: Automated parameter tuning with quality metrics
- **Git Integration**: Automatic commit tracking with structured messages
- **Iterative Improvement**: Support for multiple optimization iterations

## Installation

### Prerequisites

- Python 3.8+
- Ruby (bundled with ICMExchange)
- ICMExchange executable
- Git

### Python Dependencies

Install required Python packages:

```bash
pip install -r requirements.txt
```

Key dependencies:
- numpy, scipy, pandas (scientific computing)
- rasterio, shapely (geospatial processing)
- scikit-learn (machine learning)
- matplotlib, pillow, imageio (visualization)

## Usage

### Basic Pipeline Execution

Run the complete pipeline for all rules:

```powershell
.\scripts\run_pipeline.ps1
```

Run pipeline for specific rules:

```powershell
.\scripts\run_pipeline.ps1 -Rules depth_change_analysis,show_high_depths
```

List available rules:

```powershell
.\scripts\run_pipeline.ps1 -ListRules
```

Skip raster export (use existing data):

```powershell
.\scripts\run_pipeline.ps1 -NoExport
```

### Individual Components

#### Rule Parser

Parse and validate rule configurations:

```bash
python scripts/rule_parser.py
```

#### Pipeline Runner

Run pipeline with specific parameters:

```bash
python scripts/pipeline_runner.py --list-rules
python scripts/pipeline_runner.py --rules depth_change_analysis
```

#### Optimizer

Optimize clustering parameters:

```bash
python scripts/optimizer.py --rule depth_change_analysis
python scripts/optimizer.py --all-rules
```

#### Run Comparison

Compare results between iterations:

```bash
python scripts/compare_runs.py --manifest1 run1.json --manifest2 run2.json
```

### Git Integration

Commit iteration results:

```powershell
.\scripts\commit_iteration.ps1 -Message "Optimization iteration 1"
```

With tagging:

```powershell
.\scripts\commit_iteration.ps1 -Message "Best parameters found" -Tag
```

## Rule Configuration

### Rule Files (.rul)

Natural language queries that define the analysis:

```
# MCP-enabled rule
# Agents may collaborate via MCP to interpret/extend this rule.
How has the depth in my clusters changed?
```

### Configuration Files (.json)

JSON configurations that specify parameters:

```json
{
  "compare": {
    "baseline_id": 1,
    "candidate_id": 2
  },
  "attributes": [
    "DEPTH2D",
    "SPEED2D"
  ],
  "clustering": {
    "method": "kmeans",
    "k": 6,
    "max_iter": 300,
    "random_seed": 42
  },
  "thresholds": {
    "min_cluster_area": 150.0
  }
}
```

## Analysis Types

### Comparison Analysis
- **Purpose**: Compare baseline vs candidate simulation results
- **Output**: Delta maps showing areas of change
- **Example**: `depth_change_analysis.rul`

### Threshold Analysis
- **Purpose**: Identify areas exceeding specific thresholds
- **Output**: Binary masks and connected component clusters
- **Example**: `show_high_depths.rul`

### Hazard Analysis
- **Purpose**: Compute composite metrics (e.g., depth × speed)
- **Output**: Hazard index maps and risk clusters
- **Example**: `hazard_about_one.rul`

### Volume Analysis
- **Purpose**: Spatial integration and volume calculations
- **Output**: Volume change maps and integrated clusters
- **Example**: `volume_change_analysis.rul`

### Ranking Analysis
- **Purpose**: Rank clusters by severity or impact
- **Output**: Ranked cluster lists and priority maps
- **Example**: `depth_worst_increase.rul`

## Output Structure

```
data/output/
├── rasters/{sim_id}/{attribute}_{timestep}.tif
├── clusters/{rule_name}/clusters.{geojson,shp,csv}
├── viz/{rule_name}/{overlay_NNN.jpg, animation.gif}
├── results/{rule_name}/REPORT.md
├── experiments/run_{timestamp}.json
└── logs/pipeline_{timestamp}.log
```

## Optimization

The pipeline includes automated parameter optimization:

1. **Parameter Space Exploration**: Systematic testing of clustering parameters
2. **Quality Metrics**: Silhouette score, cohesion, separation metrics
3. **Best Parameter Identification**: Automatic selection of optimal configurations
4. **Iterative Refinement**: Multiple optimization cycles with improvement tracking

## Git Integration

The pipeline includes comprehensive git integration:

- **Automatic Commits**: Structured commit messages with metrics
- **Iteration Tracking**: Tag-based versioning of significant improvements
- **Selective Staging**: Only commits essential generated artifacts
- **Run Comparison**: Compare results between iterations

## Testing

Run basic functionality tests:

```bash
python scripts/test_pipeline.py
```

This tests:
- File structure completeness
- Directory creation
- Rule configuration validation
- Rule parsing functionality

## File Descriptions

### Core Components

- **`rule_parser.py`**: Parses `.rul` files and maps to analysis functions
- **`cluster_processor.py`**: Main analysis engine for clustering operations
- **`visualizer.py`**: Creates cluster overlays, heatmaps, and animations
- **`exporter.py`**: Exports results to CSV, GeoJSON, and markdown formats
- **`pipeline_runner.py`**: Main orchestrator for the complete pipeline
- **`optimizer.py`**: Parameter optimization and quality assessment
- **`compare_runs.py`**: Comparison between different pipeline runs

### Ruby Scripts

- **`export_rasters.rb`**: Exports rasters from ICM simulations
- **`list_simulations.rb`**: Lists available simulations in the model

### PowerShell Scripts

- **`run_pipeline.ps1`**: PowerShell wrapper for pipeline execution
- **`commit_iteration.ps1`**: Git automation for iteration tracking

## Examples

### Example 1: Basic Pipeline Run

```powershell
# Run all rules
.\scripts\run_pipeline.ps1

# Check results
ls data/output/results/
```

### Example 2: Parameter Optimization

```powershell
# Optimize specific rule
python scripts/optimizer.py --rule depth_change_analysis

# Check optimization results
ls data/output/experiments/
```

### Example 3: Git Tracking

```powershell
# Commit iteration with metrics
.\scripts\commit_iteration.ps1 -Message "Optimization iteration 1" -Tag

# View commit history
git log --oneline
```

## Troubleshooting

### Common Issues

1. **Python Dependencies**: Ensure all required packages are installed
2. **ICMExchange Path**: Verify the path to ICMExchange executable
3. **Model Access**: Ensure the Medium 2D model is accessible
4. **Permissions**: Check file system permissions for output directories

### Debugging

Enable detailed logging by setting log level in the pipeline scripts:

```python
logging.basicConfig(level=logging.DEBUG)
```

### Error Handling

The pipeline includes comprehensive error handling:
- Graceful failure with detailed error messages
- Automatic cleanup of temporary files
- Rollback capabilities for failed operations

## Contributing

1. Follow the existing code structure and patterns
2. Add comprehensive error handling
3. Include logging for debugging
4. Update tests when adding new features
5. Document new functionality in this README

## License

This pipeline is part of the Ruby Hackathon 2025 project and follows the project's licensing terms.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the logs in `data/output/logs/`
3. Run the test suite to verify basic functionality
4. Check git history for recent changes

