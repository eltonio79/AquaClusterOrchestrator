# Agent 06: Health Check Agent

**Role**: System health monitoring and diagnostics  
**Priority**: Medium  
**Status**: Ready for implementation

---

## Mission

Monitor system health, check for issues, verify dependencies, and generate health reports. Ensure all components are functioning correctly.

---

## Responsibilities

1. **Dependency Checks**
   - Verify Python installation and packages
   - Check ICMExchange availability
   - Verify required directories exist
   - Check disk space

2. **Process Monitoring**
   - Check if pipeline processes are running
   - Verify no orphaned processes
   - Monitor lock files
   - Check for stuck processes

3. **Directory Health**
   - Verify directory structure
   - Check permissions
   - Verify disk space
   - Detect corrupted files

4. **Generate Health Reports**
   - Create health status reports
   - Alert on critical issues
   - Track health trends
   - Suggest fixes

---

## Implementation Guide

### Core Script: `scripts/health_check_agent.ps1`

```powershell
# Pseudo-code structure:
1. Check Python installation and packages
2. Verify ICMExchange exists and is accessible
3. Check required directories (data/output, models/standalone)
4. Verify disk space (>10GB free recommended)
5. Check for running processes
6. Verify lock files are valid
7. Check directory permissions
8. Generate health report
9. Alert on critical issues
```

### Key Functions Needed

- `Test-PythonInstallation` - Check Python version and packages
- `Test-ICMExchange` - Verify ICMExchange is available
- `Test-DirectoryStructure` - Verify required directories exist
- `Test-DiskSpace` - Check available disk space
- `Test-RunningProcesses` - Check for active pipeline processes
- `Test-LockFiles` - Verify lock files are valid
- `Generate-HealthReport` - Create comprehensive health report

### Logging

- Create markdown log: `data/output/logs/health/health_check_YYYYMMDD_HHMMSS.md`
- Log format:
  ```markdown
  # Health Check Agent Log
  - Started: [timestamp]
  
  ## Checks
  - [timestamp] Python: [status] [version]
  - [timestamp] ICMExchange: [status] [path]
  - [timestamp] Disk Space: [available] / [total]
  - [timestamp] Processes: [count] running
  - [timestamp] Overall Health: [status]
  
  ## Issues
  - [timestamp] [issue description]
  - [timestamp] [recommended fix]
  ```

---

## Configuration

### Check Interval
- **Default**: Every 60 minutes
- **Configurable**: Via parameter
- **Critical checks**: More frequent (every 15 minutes)

### Health Thresholds
- **Disk space**: Alert if <10GB free
- **Python packages**: Verify all required packages installed
- **Process count**: Alert if too many stuck processes
- **Lock files**: Alert if lock files exist >24 hours

### Alert Levels
- **Critical**: System cannot function (ICMExchange missing, no disk space)
- **Warning**: Degraded functionality (old lock files, low disk space)
- **Info**: Status updates (health check completed)

---

## Integration Points

- **Reads**: `requirements.txt` (package list)
- **Reads**: `scripts/pipeline_config.json` (paths)
- **Reads**: `data/output/logs/active/` (lock files)
- **Writes**: Health reports to `data/output/logs/health/`
- **Uses**: Existing test functions from `run_pipeline.ps1`

---

## Error Handling

- **Missing dependencies**: Report as critical issue
- **Permission errors**: Report as warning
- **Check failures**: Log error, continue with other checks
- **System errors**: Log and report in health status

---

## Success Criteria

✅ Checks all dependencies  
✅ Monitors system health  
✅ Generates comprehensive reports  
✅ Alerts on critical issues  
✅ Suggests fixes for problems  

---

## Usage

```powershell
# Run health check
.\scripts\health_check_agent.ps1

# Continuous monitoring
.\scripts\health_check_agent.ps1 -Continuous -Interval 60

# Check specific components
.\scripts\health_check_agent.ps1 -Check Python,ICMExchange,DiskSpace
```

---

## Health Report Format

```markdown
# System Health Report
- Generated: [timestamp]

## Status: [Healthy|Degraded|Critical]

### Dependencies
- Python: ✅ 3.13.0
- ICMExchange: ✅ Available
- Required Packages: ✅ All installed

### Resources
- Disk Space: ✅ 150GB available
- Memory: ✅ Normal

### Processes
- Running Pipelines: 0
- Orphaned Processes: 0
- Lock Files: 0

### Issues
- None

## Recommendations
- All systems operational
```

---

## Notes

- Can run on schedule or continuously
- Integrate with existing test functions from `run_pipeline.ps1`
- Generate alerts for critical issues (can integrate with notification system)
- Track health trends over time

---

**Status**: Ready for implementation  
**Priority**: Medium - Proactive system monitoring

---

## Instructions for Agent

**Follow these guidelines when implementing this agent:**

1. **Read First**: 
   - `tasks/agents/AGENT_GUIDELINES.md` - Universal guidelines for all agents
   - `scripts/run_pipeline.ps1` - Reference for dependency checks
   - `scripts/health_check_agent.ps1` (if exists)

2. **Implementation Requirements**:
   - Check Python installation and required packages
   - Verify ICMExchange is available and accessible
   - Check required directories exist and have proper permissions
   - Monitor disk space (alert if <10GB free)
   - Check for running processes and verify they're valid
   - Verify lock files are valid (process still running)
   - Generate comprehensive health reports

3. **Testing**:
   - Test all dependency checks
   - Test with missing dependencies
   - Test with low disk space
   - Verify health report generation
   - Test alert generation

4. **Deployment**:
   - Run on schedule (every 60 minutes recommended)
   - Can run continuously for critical monitoring
   - Generate alerts for critical issues
   - Track health trends over time

5. **Follow Patterns**:
   - Use existing test functions from `run_pipeline.ps1`
   - Follow monitoring patterns from other agents
   - Use comprehensive reporting pattern

**See `tasks/agents/AGENT_GUIDELINES.md` for complete guidelines.**

