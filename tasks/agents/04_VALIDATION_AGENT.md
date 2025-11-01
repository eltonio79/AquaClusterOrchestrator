# Agent 04: Validation Agent

**Role**: Automated validation and quality assurance  
**Priority**: Medium  
**Status**: Ready for implementation

---

## Mission

Automatically validate pipeline outputs, verify quality metrics, and generate validation reports. Ensure all results meet quality standards.

---

## Responsibilities

1. **Validate Pipeline Outputs**
   - Run `verify_pipeline_results.py` after each pipeline run
   - Check for missing files, invalid formats, empty results
   - Verify cluster quality metrics

2. **Compare Run Results**
   - Use `compare_runs.py` to compare current run with previous
   - Detect improvements or regressions
   - Generate comparison reports

3. **Quality Thresholds**
   - Check if results meet minimum quality thresholds
   - Alert on quality degradation
   - Suggest parameter adjustments

4. **Generate Validation Reports**
   - Create comprehensive validation reports
   - Track quality trends over time
   - Highlight issues and improvements

---

## Implementation Guide

### Core Script: `scripts/validation_agent.ps1`

```powershell
# Pseudo-code structure:
1. Monitor for new run manifests in data/output/config/active/
2. When new run detected:
   a. Extract run information
   b. Run verify_pipeline_results.py for the run
   c. Compare with previous run (if available)
   d. Check quality thresholds
   e. Generate validation report
   f. Alert on quality issues
3. Log all validation actions
```

### Key Functions Needed

- `Get-NewRuns` - Detect new pipeline runs from manifests
- `Validate-Run` - Call verification for a run
- `Compare-Runs` - Compare with previous run
- `Check-QualityThresholds` - Verify quality metrics
- `Generate-ValidationReport` - Create validation summary

### Logging

- Create markdown log: `data/output/logs/validation/validation_YYYYMMDD_HHMMSS.md`
- Log format:
  ```markdown
  # Validation Agent Log
  - Started: [timestamp]
  
  ## Validations
  - [timestamp] Validated run: [run_id]
  - [timestamp] Quality check: [status]
  - [timestamp] Comparison with previous: [result]
  - [timestamp] Issues found: [count]
  ```

---

## Configuration

### Validation Triggers
- **New run manifest**: Validate immediately
- **Scheduled validation**: Daily validation of all runs
- **On demand**: Manual trigger for specific runs

### Quality Thresholds
- **Minimum clusters**: At least 1 cluster per rule
- **Cluster size**: Minimum cluster area threshold
- **File completeness**: All expected files present
- **Format validity**: Files are valid GeoJSON/CSV/etc.

### Comparison Settings
- **Compare with**: Most recent run or specific run
- **Track metrics**: Cluster count, area, quality scores
- **Regression threshold**: Alert if quality drops >10%

---

## Integration Points

- **Uses**: `scripts/verify_pipeline_results.py`
- **Uses**: `scripts/compare_runs.py`
- **Reads**: `data/output/config/active/run_manifest_*.json`
- **Reads**: `data/output/results/` (run outputs)
- **Writes**: Validation reports to `data/output/validation/`
- **Writes**: Logs to `data/output/logs/validation/`

---

## Error Handling

- **Missing runs**: Skip and log warning
- **Validation failures**: Log error, continue with next
- **Comparison errors**: Log and continue
- **Quality threshold violations**: Generate alerts

---

## Success Criteria

✅ Validates all pipeline runs automatically  
✅ Compares results with previous runs  
✅ Generates quality reports  
✅ Alerts on quality issues  
✅ Tracks quality trends over time  

---

## Usage

```powershell
# Monitor and auto-validate
.\scripts\validation_agent.ps1

# Validate specific run
.\scripts\validation_agent.ps1 -RunId "20251101_182405"

# Validate all recent runs
.\scripts\validation_agent.ps1 -AllRecent

# Quality check only
.\scripts\validation_agent.ps1 -QualityCheckOnly
```

---

## Notes

- Monitor `run_manifest_*.json` files for new runs
- Use verification logs to track validation history
- Can integrate with experiment monitor for optimization validation
- Consider setting up alerts for critical quality issues

---

**Status**: Ready for implementation  
**Priority**: Medium - Ensures quality automatically

---

## Instructions for Agent

**Follow these guidelines when implementing this agent:**

1. **Read First**: 
   - `tasks/agents/AGENT_GUIDELINES.md` - Universal guidelines for all agents
   - `scripts/verify_pipeline_results.py` - Verification logic
   - `scripts/compare_runs.py` - Comparison logic
   - `scripts/validate_optimized_rules.py` - Validation workflow

2. **Implementation Requirements**:
   - Monitor `data/output/config/active/` for new `run_manifest_*.json` files
   - Call verification scripts (Python) for each run
   - Compare with previous runs if available
   - Check quality thresholds and alert on violations
   - Generate comprehensive validation reports

3. **Testing**:
   - Test with actual pipeline runs
   - Verify verification scripts are called correctly
   - Test comparison functionality
   - Verify quality threshold checking
   - Test alert generation

4. **Deployment**:
   - Can run continuously or trigger after runs
   - Monitor logs for validation results
   - Generate alerts for quality issues (can integrate with notification system)

5. **Follow Patterns**:
   - Use existing verification scripts
   - Follow validation pattern from `validate_optimized_rules.py`
   - Use comparison logic from `compare_runs.py`

**See `tasks/agents/AGENT_GUIDELINES.md` for complete guidelines.**

