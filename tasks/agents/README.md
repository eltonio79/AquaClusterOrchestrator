# Agent Instructions Directory

This directory contains detailed instructions for specialized monitoring and automation agents.

## Available Agents

1. **01_RASTER_MONITOR_AGENT.md** - Monitors for new raster files and triggers pipeline
2. **02_EXPERIMENT_MONITOR_AGENT.md** - Monitors optimization results and triggers validation
3. **03_CLEANUP_AGENT.md** - Automated cleanup and maintenance
4. **04_VALIDATION_AGENT.md** - Automated validation and quality assurance
5. **05_GIT_TRACKING_AGENT.md** - Automated Git commit tracking
6. **06_HEALTH_CHECK_AGENT.md** - System health monitoring
7. **07_RESULTS_ANALYZER_AGENT.md** - Results analysis and insights

## How to Use These Instructions

Each agent instruction file contains:
- **Mission**: What the agent should do
- **Responsibilities**: Detailed task breakdown
- **Implementation Guide**: How to implement the agent
- **Configuration**: Settings and parameters
- **Integration Points**: How it connects with existing system
- **Success Criteria**: How to know it's working correctly

## Starting an Agent

### Using the Startup Script

Use `scripts/start_agent.ps1` to start agents:

**Delegation Mode** (default - when agent not implemented):
```powershell
.\scripts\start_agent.ps1 -AgentName "raster_monitor" -Instructions "Implement and start the raster monitor agent"
```

**Direct Execution Mode** (when agent script exists):
```powershell
.\scripts\start_agent.ps1 -AgentName "raster_monitor" -Direct
```

### Manual Start

1. Read the agent's instruction file
2. Review integration points with existing scripts
3. Implement the core script following the guide
4. Test thoroughly before deploying
5. Monitor logs for proper operation

## Agent Coordination

Agents can work independently or coordinate:
- **Raster Monitor** → Triggers **Pipeline** → **Validation Agent** validates
- **Experiment Monitor** → Triggers **Validation Agent**
- **Cleanup Agent** → Works independently on schedule
- **Health Check Agent** → Monitors all other agents
- **Git Tracking Agent** → Commits after successful runs
- **Results Analyzer** → Analyzes results from all agents

## Priority Guidelines

- **High Priority**: Raster Monitor (automates core workflow)
- **Medium Priority**: Experiment Monitor, Cleanup, Validation, Health Check
- **Low Priority**: Git Tracking, Results Analyzer

## Implementation Notes

- All agents should use `Start-Process` for background tasks (not `Start-Job`)
- Include crash recovery for Python-based agents
- Log all activities to markdown files in `data/output/logs/[agent_name]/`
- Follow existing code patterns from core scripts
- Test individually before running multiple agents

## Agent Instruction Files Status

**Files in `tasks/agents/*.md` are COMMITTED to Git** - They are reference material, not active task files.

**Default behavior**: These files are NOT automatically processed by agents unless:
- Explicitly mentioned in chat
- Agent assigned to role via `.cursor/rules/`
- Referenced in a task file (`tasks/*.json`)

See `tasks/agents/GIT_WORKFLOW.md` for details about Git workflow and task system vs delegation system.

## Agent Status Tracking

Track agent implementation status:
- ✅ Implemented and tested
- 🔄 In progress
- ⏳ Ready for implementation
- ❌ Not implemented

---

**See individual agent files for detailed instructions.**

---

## Agent Status and Monitoring

### Status System

Agent status is tracked in `data/output/config/agent_status.json`:
- **Update status**: `.\scripts\update_agent_status.ps1 -AgentName "raster_monitor" -Status "running" -Pid 12345`
- **Query status**: `.\scripts\update_agent_status.ps1 -AgentName "raster_monitor" -GetStatus`
- **List available**: `.\scripts\update_agent_status.ps1 -ListAvailable`

### Monitoring Dashboard

Open `data/output/agent_monitor.html` in a web browser to view:
- Agent status with green/red indicators
- Task status with progress indicators
- Available agents counter
- Log viewer (select agent to view logs)
- Auto-refresh every 5 seconds

**Note**: The dashboard reads from `data/output/config/agent_status.json` and requires agents to update their status using `update_agent_status.ps1`.

