# Agent 05: Git Tracking Agent

**Role**: Automated Git commit tracking and iteration management  
**Priority**: Low  
**Status**: Ready for implementation

---

## Mission

Automatically track pipeline iterations, commit results to Git with meaningful messages, and maintain iteration history.

---

## Responsibilities

1. **Track Pipeline Iterations**
   - Detect completed pipeline runs
   - Extract metrics and statistics
   - Prepare commit messages

2. **Automated Git Commits**
   - Commit results after successful pipeline runs
   - Create meaningful commit messages with metrics
   - Handle iteration numbering

3. **Iteration Management**
   - Track iteration numbers
   - Maintain iteration history
   - Link commits to iterations

4. **Branch Management**
   - Create feature branches for experiments
   - Merge successful optimizations
   - Maintain clean commit history

---

## Implementation Guide

### Core Script: `scripts/git_tracking_agent.ps1`

```powershell
# Pseudo-code structure:
1. Monitor for completed pipeline runs
2. Extract metrics from run manifest
3. Prepare commit message with metrics
4. Stage relevant files (results, not large rasters)
5. Commit with iteration number
6. Update iteration tracker
7. Log Git actions
```

### Key Functions Needed

- `Get-CompletedRuns` - Find completed pipeline runs
- `Extract-Metrics` - Get statistics from run manifest
- `Prepare-CommitMessage` - Create meaningful commit message
- `Stage-RelevantFiles` - Add results, configs, reports (skip rasters)
- `Commit-Iteration` - Commit with iteration tracking
- `Update-IterationTracker` - Maintain iteration count

### Logging

- Create markdown log: `data/output/logs/git/git_tracking_YYYYMMDD_HHMMSS.md`
- Log format:
  ```markdown
  # Git Tracking Agent Log
  - Started: [timestamp]
  
  ## Commits
  - [timestamp] Committed iteration #[number]: [description]
  - [timestamp] Metrics: [rules]/[clusters]
  - [timestamp] Branch: [branch_name]
  ```

---

## Configuration

### Commit Settings
- **Auto-commit**: On/off flag
- **Commit frequency**: After each run or batch
- **Files to include**: Results, reports, configs (not rasters)
- **Commit message format**: `Iteration #N: [description] - [metrics]`

### Iteration Tracking
- **Iteration number**: Sequential from last iteration
- **Storage**: `data/output/config/iterations.json`
- **Metadata**: Timestamp, rules, metrics, commit hash

### Branch Strategy
- **Main branch**: `master` for stable results
- **Feature branches**: `iteration/N` for experimental runs
- **Auto-merge**: Merge to master if quality passes

---

## Integration Points

- **Uses**: `scripts/commit_iteration.ps1` (existing)
- **Reads**: `data/output/config/active/run_manifest_*.json`
- **Reads**: `data/output/config/iterations.json` (iteration tracker)
- **Writes**: Git commits
- **Writes**: Logs to `data/output/logs/git/`

---

## Error Handling

- **Git errors**: Log and skip, don't block pipeline
- **Merge conflicts**: Log warning, manual resolution required
- **Large files**: Skip rasters, commit only essential results
- **No changes**: Skip commit if nothing to commit

---

## Success Criteria

✅ Commits results automatically after runs  
✅ Creates meaningful commit messages  
✅ Tracks iterations properly  
✅ Maintains clean Git history  
✅ Handles errors gracefully  

---

## Usage

```powershell
# Enable auto-tracking
.\scripts\git_tracking_agent.ps1 -AutoCommit

# Manual commit for specific run
.\scripts\git_tracking_agent.ps1 -RunId "20251101_182405" -Commit

# Track only, don't commit
.\scripts\git_tracking_agent.ps1 -TrackOnly
```

---

## Important Considerations

⚠️ **Don't commit large files** (rasters, temporary files)  
⚠️ **Respect .gitignore** settings  
⚠️ **Use meaningful messages** with metrics  
⚠️ **Can disable** if Git integration is not desired  

---

## Notes

- Integrate with `commit_iteration.ps1` if available
- Skip committing rasters (too large)
- Focus on results, reports, and configuration files
- Can be disabled if manual Git control is preferred

---

**Status**: Ready for implementation  
**Priority**: Low - Optional automation for Git workflow

---

## Instructions for Agent

**Follow these guidelines when implementing this agent:**

1. **Read First**: 
   - `tasks/agents/AGENT_GUIDELINES.md` - Universal guidelines for all agents
   - `scripts/commit_iteration.ps1` - Existing Git commit script
   - Git best practices (squash merge, meaningful messages)

2. **Implementation Requirements**:
   - **NEVER commit large files** (rasters, temporary files)
   - **Respect .gitignore** settings
   - Stage only: results, reports, configs (not rasters)
   - Create meaningful commit messages with metrics
   - Track iterations in `data/output/config/iterations.json`
   - Handle Git errors gracefully (don't block pipeline)

3. **Testing**:
   - Test with test repository first
   - Verify only relevant files are staged
   - Test commit message format
   - Verify iteration tracking works
   - Test error handling (Git not available, merge conflicts)

4. **Deployment**:
   - Can be enabled/disabled via config
   - Run after successful pipeline runs
   - Can be triggered manually if needed

5. **Follow Patterns**:
   - Use existing `commit_iteration.ps1` as reference
   - Follow commit message format from memory (squash-merge, single sentence)

**CRITICAL**: Never commit rasters or temporary files! Only commit essential results.

**See `tasks/agents/AGENT_GUIDELINES.md` for complete guidelines.**

