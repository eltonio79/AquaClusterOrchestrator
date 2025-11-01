# Scripts Reference Guide

## Overview

This document describes the purpose, functionality, and dependencies of all scripts in the `scripts/` directory.

---

## Python Scripts

### Core Pipeline Scripts

#### `pipeline_runner.py`
**Purpose**: Main orchestrator for the cluster analysis pipeline  
**Dependencies**: 
- `rule_parser.py` - Parses rule configuration files
- `cluster_processor.py` - Processes raster data and performs clustering
- `visualizer.py` - Generates visualizations
- `exporter.py` - Exports results
- `verify_pipeline_results.py` - Validates output quality
- `crash_recovery.py` - Handles crash recovery and error logging

**Functionality**:
- Reads rule files from `scripts/*.rul` or `scripts/*.json`
- Orchestrates the complete analysis workflow
- Calls Ruby scripts for raster export via ICMExchange
- Processes rasters with Python clustering algorithms
- Generates visualizations and exports results
- Logs operations to markdown files

**Usage**:
```bash
python scripts/pipeline_runner.py [--rules RULE1 RULE2] [--no-export] [--model-path PATH]
```

---

#### `rule_parser.py`
**Purpose**: Parses natural language rule descriptions and converts them to `RuleConfig` objects  
**Dependencies**: None (core module)

**Functionality**:
- Parses `.rul` files with natural language rules
- Parses `.json` files with structured rule configurations
- Converts rules to `RuleConfig` dataclass objects
- Supports analysis types: threshold, comparison, hazard, volume
- Extracts clustering parameters, visualization settings, output paths

**Usage**: Imported by `pipeline_runner.py`, `optimizer.py`, `validate_optimized_rules.py`

---

#### `cluster_processor.py`
**Purpose**: Processes raster data and performs cluster analysis  
**Dependencies**:
- `rule_parser.py` - For `RuleConfig` objects
- NumPy, GDAL, scikit-learn - External libraries

**Functionality**:
- Loads and processes raster files (GeoTIFF)
- Implements clustering algorithms: KMeans, DBSCAN, Connected Components
- Handles different analysis types: threshold, comparison, hazard, volume
- Finds raster files in multiple directory structures
- Creates cluster masks and computes statistics
- Returns `AnalysisResult` objects

**Key Classes**:
- `RasterProcessor` - Raster I/O operations
- `ClusterProcessor` - Main clustering logic
- `ClusterQualityMetrics` - Quality scoring

**Usage**: Imported by `pipeline_runner.py`, `optimizer.py`, `validate_optimized_rules.py`

---

#### `visualizer.py`
**Purpose**: Generates visualizations of cluster analysis results  
**Dependencies**:
- `cluster_processor.py` - For `AnalysisResult` objects
- Matplotlib, NumPy - External libraries

**Functionality**:
- Creates cluster overlay visualizations
- Generates heatmaps and difference maps
- Creates animated GIFs showing temporal changes
- Customizes colors and styling based on `VisualizationConfig`
- Saves PNG and GIF files

**Key Classes**:
- `RasterVisualizer` - Main visualization logic
- `VisualizationConfig` - Configuration dataclass

**Usage**: Imported by `pipeline_runner.py`

---

#### `exporter.py`
**Purpose**: Exports cluster analysis results to various formats  
**Dependencies**:
- `cluster_processor.py` - For `AnalysisResult` objects
- GeoJSON, CSV libraries

**Functionality**:
- Exports clusters to GeoJSON format
- Creates CSV files with cluster summaries and statistics
- Generates markdown reports
- Creates summary reports across multiple rules

**Key Classes**:
- `CombinedExporter` - Main export functionality

**Usage**: Imported by `pipeline_runner.py`

---

### Optimization and Validation Scripts

#### `optimizer.py`
**Purpose**: Systematically optimizes clustering parameters for rules  
**Dependencies**:
- `rule_parser.py` - Loads rule configurations
- `cluster_processor.py` - Runs experiments with different parameters
- `pipeline_runner.py` - For `PipelineRunner` class (if needed)
- `crash_recovery.py` - Crash protection

**Functionality**:
- Generates parameter combinations (k, min_size, thresholds, algorithms)
- Runs experiments with varying parameters
- Computes quality metrics (silhouette, cohesion, separation)
- Finds best parameters based on composite score
- Saves optimization results to JSON files
- Updates rule JSON files with optimized parameters

**Key Classes**:
- `PipelineOptimizer` - Main optimization logic
- `ParameterOptimizer` - Parameter space exploration
- `ClusterQualityMetrics` - Quality computation

**Usage**:
```bash
python scripts/optimizer.py --all-rules
python scripts/optimizer.py --rule depth_change_analysis
```

---

#### `validate_optimized_rules.py`
**Purpose**: Validates optimized rules by running pipeline and comparing results  
**Dependencies**:
- `pipeline_runner.py` - Runs pipeline with optimized parameters
- `rule_parser.py` - Loads rule configurations
- `compare_runs.py` - Compares results with previous runs
- `verify_pipeline_results.py` - Validates output quality
- `crash_recovery.py` - Crash protection

**Functionality**:
- Loads best parameters from optimization results
- Runs pipeline for each optimized rule
- Validates quality metrics
- Compares results with previous runs (if available)
- Generates validation report in Markdown

**Key Classes**:
- `OptimizedRuleValidator` - Main validation logic

**Usage**:
```bash
python scripts/validate_optimized_rules.py --all-rules
python scripts/validate_optimized_rules.py --rule depth_change_analysis
```

---

#### `compare_runs.py`
**Purpose**: Compares results from different pipeline runs  
**Dependencies**: JSON files from previous runs

**Functionality**:
- Loads run manifests from `data/output/config/active/`
- Compares metrics between runs
- Detects improvements or regressions
- Generates comparison reports

**Key Classes**:
- `RunComparator` - Comparison logic

**Usage**: Imported by `validate_optimized_rules.py`

---

#### `verify_pipeline_results.py`
**Purpose**: Automatically verifies pipeline output quality  
**Dependencies**: Output files from pipeline runs

**Functionality**:
- Checks for existence of output files (rasters, clusters, viz, reports)
- Verifies basic metrics (e.g., non-zero cluster count)
- Validates file formats and structure
- Generates verification logs

**Key Classes**:
- `PipelineVerifier` - Verification logic

**Usage**: Imported by `pipeline_runner.py`, `validate_optimized_rules.py`

---

### Utility Scripts

#### `crash_recovery.py`
**Purpose**: Provides crash recovery and state management utilities  
**Dependencies**: None (standalone utility)

**Functionality**:
- Saves operation state to disk before execution
- Tracks progress for long-running operations
- Logs errors and crashes to persistent files
- Provides `safe_execute()` wrapper for protected execution

**Key Classes**:
- `CrashRecovery` - State management
- `SafeErrorLogger` - Persistent error logging

**Usage**: Imported by `pipeline_runner.py`, `optimizer.py`, `validate_optimized_rules.py`

---

#### `processed_results_tracker.py`
**Purpose**: Tracks which results have been processed  
**Dependencies**: None

**Functionality**:
- Maintains a registry of processed results
- Prevents duplicate processing
- Tracks processing timestamps

**Usage**: May be used by pipeline for deduplication

---

#### `demo_pipeline.py`
**Purpose**: Demonstration and testing script  
**Dependencies**: All core modules

**Functionality**:
- Shows example usage of pipeline components
- Demonstrates different analysis types
- Provides example configurations

**Usage**:
```bash
python scripts/demo_pipeline.py
```

---

#### `test_pipeline.py`
**Purpose**: Unit tests for pipeline components  
**Dependencies**: All core modules

**Functionality**:
- Tests rule parsing
- Tests directory structure creation
- Validates configuration loading

**Usage**:
```bash
python scripts/test_pipeline.py
```

---

## PowerShell Scripts

### Pipeline Execution Scripts

#### `run_pipeline.ps1`
**Purpose**: Main PowerShell wrapper for pipeline execution  
**Dependencies**: Python pipeline scripts

**Functionality**:
- Checks prerequisites (Python, packages, ICMExchange)
- Sets up virtual environment if needed
- Builds command arguments
- Runs `pipeline_runner.py` with proper parameters

**Usage**:
```powershell
.\scripts\run_pipeline.ps1 [-Rules RULE1,RULE2] [-NoExport] [-ScriptsDir DIR] [-DataDir DIR]
```

---

#### `run_pipeline_background.ps1`
**Purpose**: Runs pipeline in background using `Start-Process` (not `Start-Job`)  
**Dependencies**: Python pipeline scripts

**Functionality**:
- Runs pipeline as separate process (non-blocking)
- Handles model path detection or waiting
- Creates wrapper script with proper argument escaping
- Uses `cmd.exe` to handle paths with spaces
- Logs to markdown files in `data/output/logs/active/`
- Returns immediately to prevent agent connection issues

**Usage**:
```powershell
.\scripts\run_pipeline_background.ps1 [-ModelPath PATH] [-SkipModelWait] [-Rules RULE1,RULE2]
```

---

#### `run_pipeline_interactive.ps1`
**Purpose**: Interactive version with user prompts  
**Dependencies**: Python pipeline scripts

**Functionality**:
- Prompts user for rules to process
- Interactive configuration
- User-friendly error messages

**Usage**:
```powershell
.\scripts\run_pipeline_interactive.ps1
```

---

### Model Management Scripts

#### `copy_model_to_standalone.ps1`
**Purpose**: Copies complete model project (not just `.icmm` file) to `models/standalone/`  
**Dependencies**: None

**Functionality**:
- Copies entire model directory structure
- Handles folder cleanup if needed
- Ensures all model files are available for testing

**Usage**:
```powershell
.\scripts\copy_model_to_standalone.ps1 -ModelPath "PATH\TO\MODEL.icmm" [-CleanExisting]
```

---

### Cleanup Scripts

#### `cleanup_generated_data.ps1`
**Purpose**: Cleans up generated outputs (rasters, viz, results, experiments, clusters, csv)  
**Dependencies**: None

**Functionality**:
- Removes files under `data/output` (except logs)
- Removes files under `data/input`
- Preserves log files

**Usage**:
```powershell
.\scripts\cleanup_generated_data.ps1 [-Yes]
```

---

#### `cleanup_experiments.ps1`
**Purpose**: Archives old experiment results  
**Dependencies**: None

**Functionality**:
- Identifies experiment result files older than threshold (e.g., 30 days)
- Moves them to archive subfolder within `data/output/experiments/`

**Usage**:
```powershell
.\scripts\cleanup_experiments.ps1
```

---

#### `cleanup_agent_logs.ps1`
**Purpose**: Centralized log cleanup and lock management  
**Dependencies**: None

**Functionality**:
- Removes stale monitor lock files
- Moves completed logs (`agent_run_*.md`, `pipeline_run_*.log`) to `logs/processed/`
- Checks if processes are still running before removing locks

**Usage**: Called by `monitor_most_recent_agents_markdown_log.ps1`, `manage_agents.ps1`

---

### Agent Management Scripts

#### `manage_agents.ps1`
**Purpose**: Manages agent processes and logs  
**Dependencies**: `cleanup_agent_logs.ps1`

**Functionality**:
- Lists active agents
- Starts/stops agents
- Cleans up locks and logs

**Usage**:
```powershell
.\scripts\manage_agents.ps1 [--list] [--stop-all]
```

---

#### `monitor_most_recent_agents_markdown_log.ps1`
**Purpose**: Monitors most recent agent markdown logs  
**Dependencies**: `cleanup_agent_logs.ps1`

**Functionality**:
- Watches for new log files
- Displays recent activity
- Calls cleanup before monitoring

**Usage**:
```powershell
.\scripts\monitor_most_recent_agents_markdown_log.ps1
```

---

#### `stop_monitor_agents.ps1`
**Purpose**: Stops agent monitoring processes  
**Dependencies**: None

**Functionality**:
- Finds and stops monitor processes
- Cleans up lock files

**Usage**:
```powershell
.\scripts\stop_monitor_agents.ps1
```

---

#### `test_monitor.ps1`
**Purpose**: Tests monitor functionality  
**Dependencies**: None

**Functionality**:
- Tests log file detection
- Tests cleanup operations

**Usage**:
```powershell
.\scripts\test_monitor.ps1
```

---

### Task Delegation Scripts

#### `delegate_task_to_agent.ps1`
**Purpose**: Creates task files for other agents  
**Dependencies**: None

**Functionality**:
- Creates JSON task files in `tasks/` directory
- Specifies task instructions, script paths, status
- Enables inter-agent communication

**Usage**:
```powershell
.\scripts\delegate_task_to_agent.ps1 -TaskName "NAME" -Instructions "TEXT" -ScriptPath "PATH"
```

---

### Utility Scripts

#### `safe_run.ps1`
**Purpose**: Safe wrapper for running scripts with error handling  
**Dependencies**: None

**Functionality**:
- Wraps script execution in try-catch
- Logs errors to files
- Prevents crashes from propagating

**Usage**: Imported by other PowerShell scripts

---

#### `setup_pipeline.ps1`
**Purpose**: Sets up pipeline environment  
**Dependencies**: None

**Functionality**:
- Checks Python installation
- Sets up virtual environment
- Installs dependencies

**Usage**:
```powershell
.\scripts\setup_pipeline.ps1
```

---

#### `commit_iteration.ps1`
**Purpose**: Git automation for iteration tracking  
**Dependencies**: Git

**Functionality**:
- Commits pipeline results to Git
- Tracks iteration metrics
- Creates commit messages with statistics

**Usage**:
```powershell
.\scripts\commit_iteration.ps1
```

---

#### `dir.bat` / `dir.ps1`
**Purpose**: Updates `paths.txt` file after file/folder add/remove/rename  
**Dependencies**: None

**Functionality**:
- Scans directory structure
- Updates `paths.txt` file
- Required after any file operations per repo hygiene rules

**Usage**:
```powershell
.\scripts\dir.bat
```

---

## Ruby Scripts

### Raster Export Scripts

#### `export_rasters.rb`
**Purpose**: Exports 2D raster results from ICM simulations  
**Dependencies**: ICMExchange, InfoWorks ICM database

**Functionality**:
- Opens ICM model via `WSApplication.open()`
- Exports raster data for specified simulation ID
- Exports multiple attributes (DEPTH2D, SPEED2D, ANGLE2D, etc.)
- Saves GeoTIFF files to specified output directory
- Supports structured output: `raster/<model>/<run>/sim_<id>/`

**Usage**: Called by `pipeline_runner.py` via ICMExchange:
```bash
ICMExchange.exe export_rasters.rb <sim_id> <output_dir> [attributes_csv] [model_path]
```

---

#### `export_results_csv.rb`
**Purpose**: Exports simulation results to CSV format  
**Dependencies**: ICMExchange, InfoWorks ICM database

**Functionality**:
- Exports result data for specified simulation
- Creates CSV files in output directory
- May be used for result comparison

**Usage**: Called by `pipeline_runner.py` via ICMExchange:
```bash
ICMExchange.exe export_results_csv.rb <sim_id> <output_dir>
```

---

### Model Management Scripts (Ruby)

#### `list_simulations.rb`
**Purpose**: Lists available simulations in the model  
**Dependencies**: ICMExchange

**Functionality**:
- Opens ICM model
- Lists all simulations with IDs and names
- Useful for debugging and model inspection

**Usage**: Called via ICMExchange

---

#### `clone_icmm_and_insert.rb`
**Purpose**: Clones ICM model and inserts network  
**Dependencies**: ICMExchange

**Functionality**:
- Creates model copy
- Inserts network data

**Usage**: Called via ICMExchange

---

#### `launch_run_by_id.rb`
**Purpose**: Launches simulation run by ID  
**Dependencies**: ICMExchange

**Functionality**:
- Finds simulation by ID
- Launches simulation

**Usage**: Called via ICMExchange

---

### Network Management Scripts (Ruby)

#### `copy_network_to_group.rb`
**Purpose**: Copies network to group  
**Dependencies**: ICMExchange

**Functionality**:
- Copies network objects to specified group

**Usage**: Called via ICMExchange

---

#### `copy_network_to_group_by_name.rb`
**Purpose**: Copies network to group by name  
**Dependencies**: ICMExchange

**Functionality**:
- Finds group by name
- Copies network to that group

**Usage**: Called via ICMExchange

---

#### `get_network_in_group.rb`
**Purpose**: Retrieves network in group  
**Dependencies**: ICMExchange

**Functionality**:
- Gets network objects from specified group

**Usage**: Called via ICMExchange

---

#### `list_groups_and_networks.rb`
**Purpose**: Lists groups and networks in model  
**Dependencies**: ICMExchange

**Functionality**:
- Lists all groups
- Lists networks in each group

**Usage**: Called via ICMExchange

---

#### `list_model_objects.rb`
**Purpose**: Lists model objects  
**Dependencies**: ICMExchange

**Functionality**:
- Lists various model objects (networks, simulations, etc.)

**Usage**: Called via ICMExchange

---

### Polygon Management Scripts (Ruby)

#### `create_test_polygon.rb`
**Purpose**: Creates test polygon in model  
**Dependencies**: ICMExchange

**Functionality**:
- Creates polygon geometry
- Adds to model

**Usage**: Called via ICMExchange

---

#### `create_polygons_from_geojson.rb`
**Purpose**: Creates polygons from GeoJSON file  
**Dependencies**: ICMExchange

**Functionality**:
- Reads GeoJSON file
- Creates polygons in model from GeoJSON features

**Usage**: Called via ICMExchange

---

#### `insert_test_polygon.rb`
**Purpose**: Inserts test polygon  
**Dependencies**: ICMExchange

**Functionality**:
- Inserts polygon into model

**Usage**: Called via ICMExchange

---

#### `delete_polygons.rb`
**Purpose**: Deletes polygons from model  
**Dependencies**: ICMExchange

**Functionality**:
- Removes polygons from model

**Usage**: Called via ICMExchange

---

## Configuration Files

### Rule Files

#### `*.rul` files
**Purpose**: Natural language rule descriptions  
**Format**: Markdown-like with natural language queries

**Example**: `depth_change_analysis.rul`
```markdown
# MCP-enabled rule
Find areas where depth increased significantly between simulation 1 and 2
```

**Usage**: Parsed by `rule_parser.py` to create `RuleConfig` objects

---

#### `*.json` files (Rule Configurations)
**Purpose**: Structured rule configurations with clustering parameters  
**Format**: JSON with analysis type, attributes, clustering, visualization settings

**Example**: `depth_change_analysis.json`
```json
{
  "analysis_type": "comparison",
  "attributes": ["DEPTH2D"],
  "clustering": {
    "method": "kmeans",
    "k": 5,
    "min_cluster_size": 100
  }
}
```

**Usage**: Loaded by `rule_parser.py`, updated by `optimizer.py`

---

#### `pipeline_config.json`
**Purpose**: Global pipeline configuration  
**Format**: JSON with paths and settings

**Contains**:
- `model_path` - Path to ICM model file
- `run_simulations` - Whether to run simulations
- `monitor_mode` - Monitor mode flag
- `disable_git` - Disable Git integration

**Usage**: Loaded by `pipeline_runner.py`, `export_rasters.rb`

---

## Data Flow and Dependencies

### Typical Workflow

1. **User/Agent** → `run_pipeline_background.ps1`
   - Provides model path
   - Starts background process

2. **run_pipeline_background.ps1** → `pipeline_runner.py`
   - Escapes arguments properly
   - Uses `cmd.exe` for path handling

3. **pipeline_runner.py** → `rule_parser.py`
   - Loads rule configurations
   - Creates `RuleConfig` objects

4. **pipeline_runner.py** → `export_rasters.rb` (via ICMExchange)
   - Exports raster data from ICM model
   - Saves GeoTIFF files

5. **pipeline_runner.py** → `cluster_processor.py`
   - Loads raster files
   - Performs clustering analysis
   - Returns `AnalysisResult`

6. **pipeline_runner.py** → `visualizer.py`
   - Creates visualizations
   - Generates PNG/GIF files

7. **pipeline_runner.py** → `exporter.py`
   - Exports results to GeoJSON, CSV, Markdown

8. **pipeline_runner.py** → `verify_pipeline_results.py`
   - Validates output quality
   - Generates verification logs

### Optimization Workflow

1. **optimizer.py** → `rule_parser.py`
   - Loads rule configurations

2. **optimizer.py** → `cluster_processor.py`
   - Runs experiments with different parameters

3. **optimizer.py** → Saves results
   - Saves best parameters to JSON
   - Updates rule JSON files

4. **validate_optimized_rules.py** → `optimizer.py` (for best params)
   - Loads optimized parameters

5. **validate_optimized_rules.py** → `pipeline_runner.py`
   - Runs pipeline with optimized parameters

6. **validate_optimized_rules.py** → `compare_runs.py`
   - Compares with previous runs

---

## Key Dependencies Summary

### Python Module Dependencies
```
pipeline_runner.py
├── rule_parser.py
├── cluster_processor.py
├── visualizer.py
├── exporter.py
├── verify_pipeline_results.py
└── crash_recovery.py

optimizer.py
├── rule_parser.py
├── cluster_processor.py
└── crash_recovery.py

validate_optimized_rules.py
├── pipeline_runner.py
├── rule_parser.py
├── compare_runs.py
├── verify_pipeline_results.py
└── crash_recovery.py
```

### External Dependencies
- **ICMExchange.exe**: Required for Ruby script execution
- **Python 3.8+**: Required for all Python scripts
- **Libraries**: NumPy, GDAL, scikit-learn, Matplotlib, GeoJSON
- **InfoWorks ICM**: Required for raster export and model access

### File Structure Dependencies
- **Rule files**: `scripts/*.rul` or `scripts/*.json`
- **Models**: `models/standalone/<model_name>/`
- **Rasters**: `data/output/raster/<model>/<run>/sim_<id>/`
- **Results**: `data/output/<model>/<run>/results/<rule_name>/`
- **Logs**: `data/output/logs/active/` and `logs/processed/`

---

## Notes

- All PowerShell scripts use `Start-Process` instead of `Start-Job` for background tasks to prevent connection issues
- All Python scripts include crash recovery via `crash_recovery.py`
- Raster directory structure supports both `model/run/sim_X` and `db/group/run/sim_X` patterns
- Logs are automatically cleaned up by `cleanup_agent_logs.ps1`
- Optimization results are saved to `data/output/experiments/` and update rule JSON files

