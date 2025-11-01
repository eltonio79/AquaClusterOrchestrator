# Agent 03: Cleanup Agent

**Role**: Automated cleanup of old data and maintenance tasks  
**Priority**: Medium  
**Status**: Ready for implementation

---

## Mission

Automatically clean up old generated data, archive experiment results, and maintain disk space by removing outdated files.

---

## Responsibilities

1. **Archive Old Experiments**
   - Move experiment results older than threshold (e.g., 30 days) to archive
   - Preserve recent results and best_params.json files
   - Maintain archive structure

2. **Clean Old Logs**
   - Move processed logs to `logs/processed/` archive
   - Remove very old logs (>90 days)
   - Keep active logs untouched

3. **Clean Temporary Files**
   - Remove old temporary wrapper scripts from temp directory
   - Clean orphaned lock files
   - Remove empty directories

4. **Generate Cleanup Reports**
   - Log all cleanup actions
   - Report disk space freed
   - Track cleanup history

---

## Implementation Guide

### Core Script: `scripts/cleanup_agent.ps1`

```powershell
# Pseudo-code structure:
1. Check data/output/experiments/ for old files
2. Archive experiments older than threshold
3. Clean old logs from active folder
4. Remove temporary wrapper scripts
5. Clean orphaned lock files
6. Generate cleanup report
7. Log all actions
```

### Key Functions Needed

- `Archive-OldExperiments` - Move old experiments to archive
- `Clean-OldLogs` - Archive or remove old log files
- `Remove-TempFiles` - Clean temporary directory
- `Clean-OrphanedLocks` - Remove stale lock files
- `Generate-CleanupReport` - Create cleanup summary

### Logging

- Create markdown log: `data/output/logs/cleanup/cleanup_YYYYMMDD_HHMMSS.md`
- Log format:
  ```markdown
  # Cleanup Agent Log
  - Started: [timestamp]
  
  ## Actions
  - Archived: [count] experiments older than [days]
  - Moved: [count] log files to processed/
  - Removed: [count] temporary files
  - Freed: [size] disk space
  ```

---

## Configuration

### Cleanup Thresholds
- **Experiments**: Archive after 30 days, remove after 90 days
- **Logs**: Move to processed/ after 7 days, remove after 90 days
- **Temp files**: Remove after 1 day
- **Lock files**: Remove if process not running

### Preservation Rules
- **Always preserve**: `*_best_params.json` files
- **Always preserve**: `optimization_summary.md`
- **Always preserve**: Active logs and current run manifests
- **Never remove**: Recent results (< 7 days)

---

## Integration Points

- **Uses**: `scripts/cleanup_experiments.ps1` (existing)
- **Uses**: `scripts/cleanup_agent_logs.ps1` (existing)
- **Reads**: `data/output/experiments/`
- **Reads**: `data/output/logs/active/`
- **Writes**: Archive to `data/output/experiments/archive/`
- **Writes**: Logs to `data/output/logs/cleanup/`

---

## Error Handling

- **Permission errors**: Log and skip, don't fail
- **Locked files**: Skip and retry later
- **Missing directories**: Create as needed
- **Disk space issues**: Report warning

---

## Success Criteria

✅ Archives old experiments automatically  
✅ Cleans old logs without affecting active monitoring  
✅ Removes temporary files regularly  
✅ Generates cleanup reports  
✅ Preserves important files  

---

## Usage

```powershell
# Run cleanup (dry-run)
.\scripts\cleanup_agent.ps1 -WhatIf

# Run cleanup
.\scripts\cleanup_agent.ps1

# Custom thresholds
.\scripts\cleanup_agent.ps1 -ExperimentDays 30 -LogDays 7
```

---

## Schedule Recommendations

- **Frequency**: Daily or weekly
- **Best time**: Low activity periods (e.g., night)
- **Can be automated**: Via Windows Task Scheduler or cron

---

## Notes

- Always use `-WhatIf` first to preview actions
- Be conservative with deletion thresholds
- Preserve all best_params.json files regardless of age
- Maintain archive structure for future reference

---

**Status**: Ready for implementation  
**Priority**: Medium - Maintains system hygiene automatically

---

## Instructions for Agent

**Follow these guidelines when implementing this agent:**

1. **Read First**: 
   - `tasks/agents/AGENT_GUIDELINES.md` - Universal guidelines for all agents
   - `scripts/cleanup_generated_data.ps1` - Existing cleanup script
   - `scripts/cleanup_experiments.ps1` - Existing experiment cleanup
   - `scripts/cleanup_agent_logs.ps1` - Existing log cleanup

2. **Implementation Requirements**:
   - **PRESERVE** important files: `*_best_params.json`, `optimization_summary.md`
   - Use `-WhatIf` flag for dry-run testing
   - Archive before deleting (move to archive folder)
   - Check file ages before archiving/deleting
   - Clean temporary wrapper scripts from temp directory
   - Remove orphaned lock files (verify process not running)

3. **Testing**:
   - **ALWAYS** test with `-WhatIf` first
   - Verify important files are preserved
   - Test with actual old files
   - Verify archive structure is maintained

4. **Deployment**:
   - Run on schedule (daily or weekly)
   - Use conservative thresholds initially
   - Monitor cleanup reports for issues
   - Can be triggered manually if needed

5. **Follow Patterns**:
   - Use existing cleanup scripts as reference
   - Follow archive-before-delete pattern
   - Preserve critical files pattern

**CRITICAL**: Never delete `*_best_params.json` files or `optimization_summary.md`!

**See `tasks/agents/AGENT_GUIDELINES.md` for complete guidelines.**

