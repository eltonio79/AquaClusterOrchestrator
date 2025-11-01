# Agent 01: Raster Monitor Agent

**Role**: Monitor for new raster files and automatically trigger pipeline processing  
**Priority**: High  
**Status**: Ready for implementation

---

## Mission

Monitor the `data/output/raster/` directory for new `.tif` files. When new rasters are detected, automatically trigger the pipeline to process them with current rules.

---

## Responsibilities

1. **Monitor Raster Directory**
   - Watch `data/output/raster/` recursively for new `.tif` files
   - Detect when new files appear (by timestamp or file system events)
   - Track already processed files to avoid duplicates

2. **Trigger Pipeline**
   - When new rasters detected, call `run_pipeline_background.ps1`
   - Use `--no-export` flag (rasters already exist)
   - Process all rules or specified rules

3. **Log Activity**
   - Log detected files to `data/output/logs/monitors/raster_monitor_*.md`
   - Record triggered pipeline runs
   - Track processing status

---

## Implementation Guide

### Core Script: `scripts/monitor_rasters.ps1`

```powershell
# Pseudo-code structure:
1. Initialize monitoring on data/output/raster/
2. Track last known newest file timestamp
3. Loop:
   a. Scan for .tif files newer than last known
   b. If found:
      - Log detection
      - Extract model/run info from path
      - Trigger pipeline with --no-export
      - Update last known timestamp
   c. Sleep 30 seconds
4. Handle errors gracefully
```

### Key Functions Needed

- `Get-NewRasters` - Find new raster files since last check
- `ExtractModelInfo` - Parse raster path to extract model/run information
- `TriggerPipeline` - Call `run_pipeline_background.ps1` with appropriate flags
- `UpdateLastCheck` - Save timestamp of latest processed file

### Logging

- Create markdown log: `data/output/logs/monitors/raster_monitor_YYYYMMDD_HHMMSS.md`
- Log format:
  ```markdown
  # Raster Monitor Agent Log
  - Started: [timestamp]
  - Monitoring: data/output/raster/
  
  ## Detections
  - [timestamp] Detected new rasters in [path]
  - [timestamp] Triggered pipeline for [model]/[run]
  ```

---

## Configuration

### Monitor Interval
- **Default**: Check every 30 seconds
- **Configurable**: Via parameter or config file

### Trigger Conditions
- **New files detected**: Any new `.tif` file
- **Threshold**: Minimum 10 files to avoid false triggers
- **Pattern matching**: Can filter by model/run patterns

### Pipeline Options
- Use `--no-export` flag (rasters already exist)
- Process all rules or specific rules
- Respect existing pipeline runs (don't start if one is running)

---

## Integration Points

- **Uses**: `scripts/run_pipeline_background.ps1`
- **Reads**: `scripts/pipeline_config.json`
- **Writes**: Logs to `data/output/logs/monitors/`
- **Monitors**: `data/output/raster/` directory

---

## Error Handling

- **File system errors**: Log and retry
- **Pipeline start failures**: Log error, continue monitoring
- **Duplicate detection**: Skip already processed files
- **Lock files**: Check if pipeline already running

---

## Success Criteria

✅ Detects new rasters within 30 seconds  
✅ Triggers pipeline automatically  
✅ Logs all activity clearly  
✅ Doesn't interfere with manual pipeline runs  
✅ Handles errors gracefully  

---

## Usage

```powershell
# Start monitor
.\scripts\monitor_rasters.ps1

# With custom interval
.\scripts\monitor_rasters.ps1 -Interval 60

# With specific rules
.\scripts\monitor_rasters.ps1 -Rules depth_change_analysis,depth_worst_increase
```

---

## Notes

- Use file system watcher or polling (simpler: polling every 30s)
- Track processed files by timestamp or by keeping a registry
- Don't trigger if a pipeline is already running (check lock files)
- Can be extended to watch specific model/run combinations

---

**Status**: Ready for implementation  
**Priority**: High - Automates pipeline triggering from raster detection

---

## Instructions for Agent

**Follow these guidelines when implementing this agent:**

1. **Read First**: 
   - `tasks/agents/AGENT_GUIDELINES.md` - Universal guidelines for all agents
   - `docs/SCRIPTS_REFERENCE.md` - Script reference for integration points
   - `scripts/run_pipeline_background.ps1` - Reference implementation for background processes

2. **Implementation Requirements**:
   - Use `Start-Process` (NOT `Start-Job`) for all background tasks
   - Implement error handling for file system operations
   - Log all activities to markdown files in `data/output/logs/monitors/`
   - Track processed files to avoid duplicates (use JSON registry)
   - Check for existing pipeline runs before triggering new ones

3. **Testing**:
   - Test with actual raster files in `data/output/raster/`
   - Verify pipeline is triggered correctly
   - Verify logs are created properly
   - Test error handling (missing directories, permission errors)

4. **Deployment**:
   - Run as background process using `Start-Process`
   - Monitor logs for proper operation
   - Don't interfere with manual pipeline runs

5. **Follow Patterns**:
   - Use existing `run_pipeline_background.ps1` as reference
   - Follow logging format from `monitor_most_recent_agents_markdown_log.ps1`
   - Use cleanup pattern from `cleanup_agent_logs.ps1` for lock files

**See `tasks/agents/AGENT_GUIDELINES.md` for complete guidelines.**

