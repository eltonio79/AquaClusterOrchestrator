# Agent Guidelines - Universal Instructions for All Agents

**Date**: 2025-11-01  
**Purpose**: Universal guidelines and best practices for all automation agents

---

## General Principles

### 1. Follow Existing Patterns ✅
- **Always** check existing scripts for patterns before implementing new functionality
- **Reuse** existing functions and modules where possible
- **Mirror** code style and structure from core scripts
- **Reference** `docs/SCRIPTS_REFERENCE.md` for script details

### 2. Use Start-Process (Not Start-Job) ⚠️
- **CRITICAL**: All background tasks MUST use `Start-Process`
- **NEVER** use `Start-Job` (causes connection issues)
- **Example**: See `scripts/run_pipeline_background.ps1` for pattern
- **Reason**: Prevents agent crashes and connection problems

### 3. Implement Crash Recovery 🔒
- **All Python scripts** should import `crash_recovery.py`
- **Save state** before operations using `CrashRecovery`
- **Log errors** using `SafeErrorLogger`
- **Use** `safe_execute()` wrapper for protected execution
- **Example**: See `optimizer.py` for integration pattern

### 4. Log Everything 📝
- **Create markdown logs** in `data/output/logs/[agent_name]/`
- **Use descriptive names**: `agent_name_YYYYMMDD_HHMMSS.md`
- **Log all actions**: Detections, triggers, errors, completions
- **Include timestamps** for all log entries
- **Format**: Use markdown for readability

### 5. Handle Errors Gracefully 🛡️
- **Never crash** the agent on errors
- **Log errors** and continue with next task
- **Retry logic**: Implement retries for transient errors
- **Skip invalid data**: Don't fail on bad input, log and skip
- **Cleanup**: Always clean up resources even on errors

---

## Technical Requirements

### Working Directory
- **Always set working directory** to project root before executing commands
- **Use** `Set-Location` or `cd` to project root
- **Example**: `Set-Location 'C:\Users\brodowm\OneDrive - Autodesk\Shared\Dev\Git\AquaClusterOrchestrator'`

### Path Handling
- **Use absolute paths** for critical operations
- **Handle spaces** in paths properly (use quotes)
- **Test paths** before using them (`Test-Path`)
- **Resolve relative paths** to absolute before passing to subprocesses

### Process Management
- **Check for running processes** before starting new ones
- **Use lock files** to prevent concurrent execution
- **Clean up lock files** after completion
- **Monitor processes** to detect stuck jobs

### File Operations
- **Create directories** if they don't exist (`New-Item -ItemType Directory`)
- **Check permissions** before writing files
- **Use UTF-8 encoding** for all text files
- **Preserve important files** (best_params.json, summaries, etc.)

---

## Agent-Specific Patterns

### Monitoring Agents (01, 02, 04)
- **Polling interval**: Check every 30-60 seconds
- **Track processed items**: Avoid duplicate processing
- **Use file timestamps**: Compare modification times
- **Registry files**: Track processed items in JSON files

### Maintenance Agents (03)
- **Preserve important data**: Never delete best_params.json
- **Archive before delete**: Move to archive, don't delete immediately
- **Dry-run option**: Use `-WhatIf` to preview actions
- **Conservative thresholds**: Err on the side of caution

### Analysis Agents (05, 06, 07)
- **Load all relevant data**: Don't process incrementally
- **Generate comprehensive reports**: Include all insights
- **Create visualizations**: Charts and graphs are valuable
- **Export data**: Make analysis data available for review

---

## Code Quality Standards

### PowerShell Scripts
- **Use functions**: Break logic into reusable functions
- **Parameter validation**: Validate all input parameters
- **Error handling**: Try-catch blocks for all operations
- **Comments**: Document complex logic

### Python Scripts
- **Import crash_recovery**: Add crash protection
- **Type hints**: Use type annotations where helpful
- **Docstrings**: Document functions and classes
- **Error handling**: Try-except with logging

### Ruby Scripts
- **Error handling**: Rescue exceptions and log errors
- **Validate input**: Check arguments before processing
- **Close resources**: Always close files and connections

---

## Integration Guidelines

### With Pipeline Runner
- **Use** `--no-export` flag if rasters already exist
- **Specify rules** with `--rules` parameter
- **Monitor** via run manifests in `data/output/config/active/`
- **Check** log files for completion status

### With Existing Scripts
- **Reuse** existing cleanup scripts (`cleanup_agent_logs.ps1`, etc.)
- **Integrate** with existing monitoring scripts
- **Extend** existing functionality rather than duplicating
- **Follow** existing naming conventions

### With Configuration Files
- **Read** `scripts/pipeline_config.json` for paths
- **Respect** `pipeline_config.json` settings
- **Update** config only when necessary
- **Preserve** existing config values

---

## Logging Standards

### Log File Format
```markdown
# [Agent Name] Log
- Started: [timestamp]
- Monitoring: [directory/component]

## Actions
- [timestamp] [action description]
- [timestamp] [action description]

## Errors
- [timestamp] [error description]

## Summary
- Total actions: [count]
- Errors: [count]
- Completed: [timestamp]
```

### Log Locations
- **Monitor agents**: `data/output/logs/monitors/[agent_name]_*.md`
- **Cleanup agent**: `data/output/logs/cleanup/cleanup_*.md`
- **Validation agent**: `data/output/logs/validation/validation_*.md`
- **Git agent**: `data/output/logs/git/git_tracking_*.md`
- **Health agent**: `data/output/logs/health/health_check_*.md`
- **Analysis agent**: `data/output/logs/analysis/analyzer_*.md`

---

## Testing Guidelines

### Before Deployment
- **Test individually**: Run agent alone first
- **Test with real data**: Use actual files and directories
- **Test error conditions**: Simulate failures
- **Test concurrent execution**: Run multiple agents together

### Testing Checklist
- ✅ Agent starts correctly
- ✅ Agent detects target items
- ✅ Agent triggers appropriate actions
- ✅ Agent logs all activities
- ✅ Agent handles errors gracefully
- ✅ Agent cleans up after itself
- ✅ Agent doesn't interfere with manual operations

---

## Performance Considerations

### Efficiency
- **Avoid unnecessary scans**: Cache file listings
- **Batch operations**: Process multiple items together
- **Sleep intervals**: Use appropriate intervals (30-60s for monitors)
- **Resource usage**: Monitor CPU and memory

### Scalability
- **Handle large datasets**: Process incrementally if needed
- **Archive old data**: Don't accumulate unlimited data
- **Clean temp files**: Remove temporary files regularly
- **Monitor disk space**: Alert on low disk space

---

## Safety Guidelines

### Data Protection
- **Never delete**: best_params.json, optimization_summary.md
- **Preserve logs**: Archive instead of deleting
- **Backup before delete**: Archive important data
- **Test cleanup**: Use dry-run before actual cleanup

### Process Safety
- **Check locks**: Don't start if another process is running
- **Verify processes**: Check if process is still running before cleaning locks
- **Graceful shutdown**: Handle termination signals properly
- **Resource cleanup**: Always clean up resources

---

## Communication Between Agents

### Coordination
- **Lock files**: Use lock files to prevent conflicts
- **Status files**: Share status via JSON files in `data/output/config/`
- **Registry files**: Track processed items in shared registries
- **Avoid conflicts**: Don't modify same files concurrently

### File-Based Communication
- **Task files**: Use `tasks/` directory for task delegation
- **Status files**: Create status files in `data/output/config/`
- **Result files**: Share results via structured directories
- **Avoid direct IPC**: Use file-based communication for reliability

---

## Monitoring and Maintenance

### Agent Health
- **Log startup/shutdown**: Always log agent lifecycle
- **Track errors**: Count and report errors
- **Monitor performance**: Track processing times
- **Report status**: Generate status reports regularly

### Self-Monitoring
- **Check own health**: Agents should verify their own operation
- **Alert on issues**: Notify on critical problems
- **Recovery mechanisms**: Implement self-recovery where possible
- **Graceful degradation**: Continue with reduced functionality if needed

---

## Deployment Checklist

Before deploying an agent:
- ✅ Script implemented following patterns
- ✅ Crash recovery integrated (if Python)
- ✅ Error handling comprehensive
- ✅ Logging implemented
- ✅ Tested individually
- ✅ Tested with real data
- ✅ Tested error conditions
- ✅ Documentation updated
- ✅ Instructions reviewed

---

## Common Pitfalls to Avoid

### ⚠️ DON'T
- ❌ Use `Start-Job` (causes connection issues)
- ❌ Delete important files (best_params.json, summaries)
- ❌ Start processes without checking locks
- ❌ Ignore errors silently
- ❌ Hard-code paths (use config files)
- ❌ Skip crash recovery in Python scripts
- ❌ Create files in root directory
- ❌ Leave lock files after completion

### ✅ DO
- ✅ Use `Start-Process` for background tasks
- ✅ Preserve important data
- ✅ Check locks before starting
- ✅ Log all errors
- ✅ Use config files for paths
- ✅ Integrate crash recovery
- ✅ Use structured directories
- ✅ Clean up lock files

---

## Example Agent Implementation Template

```powershell
# Agent Template
param(
    [int]$Interval = 60,
    [switch]$DryRun
)

# Initialize
$projectRoot = "C:\Users\brodowm\OneDrive - Autodesk\Shared\Dev\Git\AquaClusterOrchestrator"
Set-Location $projectRoot

# Logging setup
$logDir = "data/output/logs/agents/agent_name"
New-Item -ItemType Directory -Force -Path $logDir | Out-Null
$logFile = Join-Path $logDir "agent_name_$(Get-Date -Format 'yyyyMMdd_HHmmss').md"

function Write-AgentLog {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[$timestamp] $Message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# Main loop
Write-AgentLog "Agent started"
try {
    while ($true) {
        # Agent logic here
        Write-AgentLog "Checking for new items..."
        
        # Perform checks and actions
        # ... agent-specific logic ...
        
        Start-Sleep -Seconds $Interval
    }
} catch {
    Write-AgentLog "Error: $($_.Exception.Message)"
} finally {
    Write-AgentLog "Agent stopped"
}
```

---

## Final Instructions for All Agents

### When Implementing
1. **Read** the specific agent instruction file first
2. **Review** existing similar scripts for patterns
3. **Follow** these guidelines strictly
4. **Test** thoroughly before deployment
5. **Monitor** logs after deployment

### When Operating
1. **Log everything** - All actions, errors, completions
2. **Handle errors gracefully** - Never crash the agent
3. **Respect locks** - Don't interfere with other processes
4. **Preserve data** - Never delete important files
5. **Clean up** - Remove temporary files and locks

### When Troubleshooting
1. **Check logs first** - Review agent logs for issues
2. **Verify dependencies** - Python, ICMExchange, directories
3. **Check permissions** - File system permissions
4. **Review code** - Check implementation against patterns
5. **Test incrementally** - Test individual functions first

---

## Success Criteria

An agent is successful when:
- ✅ Runs continuously without crashing
- ✅ Detects and processes items correctly
- ✅ Logs all activities clearly
- ✅ Handles errors gracefully
- ✅ Doesn't interfere with manual operations
- ✅ Maintains system health
- ✅ Follows all guidelines

---

## Questions or Issues?

- **Review**: `docs/SCRIPTS_REFERENCE.md` for script details
- **Check**: `temp/AGENT_HANDOFF.md` for continuation context
- **Read**: `docs/CRASH_RECOVERY.md` for crash recovery patterns
- **Reference**: Existing scripts for implementation examples

---

**Remember**: The goal is to automate tasks reliably, not to create more work. If in doubt, err on the side of caution and log more than less.

**Good luck with your agent implementations!** 🚀

