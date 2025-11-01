# Agent 02: Experiment Monitor Agent

**Role**: Monitor optimization experiments and trigger validation automatically  
**Priority**: Medium  
**Status**: Ready for implementation

---

## Mission

Monitor the `data/output/experiments/` directory for new optimization results. When optimization completes, automatically trigger validation of optimized rules.

---

## Responsibilities

1. **Monitor Experiment Directory**
   - Watch for new `*_best_params.json` files
   - Detect completed optimization runs
   - Track which optimizations have been validated

2. **Trigger Validation**
   - When optimization completes, call `validate_optimized_rules.py`
   - Validate only newly optimized rules
   - Generate comparison reports

3. **Track Optimization Status**
   - Maintain registry of optimized rules
   - Track validation status for each rule
   - Detect when all rules are optimized

---

## Implementation Guide

### Core Script: `scripts/monitor_experiments.ps1`

```powershell
# Pseudo-code structure:
1. Initialize monitoring on data/output/experiments/
2. Track known best_params.json files
3. Loop:
   a. Scan for new *_best_params.json files
   b. If found:
      - Extract rule name from filename
      - Check if already validated
      - Trigger validation for this rule
      - Mark as validated
   c. Check for optimization_summary.md updates
   d. Sleep 60 seconds
4. Handle errors gracefully
```

### Key Functions Needed

- `Get-NewOptimizations` - Find new best_params.json files
- `ExtractRuleName` - Parse filename to get rule name
- `IsValidated` - Check if rule has been validated
- `TriggerValidation` - Call `validate_optimized_rules.py`
- `UpdateValidationStatus` - Track validation completion

### Logging

- Create markdown log: `data/output/logs/monitors/experiment_monitor_YYYYMMDD_HHMMSS.md`
- Log format:
  ```markdown
  # Experiment Monitor Agent Log
  - Started: [timestamp]
  - Monitoring: data/output/experiments/
  
  ## Detections
  - [timestamp] Detected optimization: [rule_name]
  - [timestamp] Triggered validation for [rule_name]
  - [timestamp] Validation completed: [rule_name]
  ```

---

## Configuration

### Monitor Interval
- **Default**: Check every 60 seconds (optimizations take longer)
- **Configurable**: Via parameter

### Trigger Conditions
- **New best_params.json**: Rule optimized
- **Summary updated**: `optimization_summary.md` changed
- **All rules optimized**: Trigger full validation

### Validation Options
- Validate single rule or all optimized rules
- Compare with previous runs if available
- Generate detailed reports

---

## Integration Points

- **Uses**: `scripts/validate_optimized_rules.py`
- **Reads**: `data/output/experiments/*_best_params.json`
- **Reads**: `data/output/experiments/optimization_summary.md`
- **Writes**: Logs to `data/output/logs/monitors/`
- **Creates**: Validation status registry in `data/output/experiments/.validation_status.json`

---

## Error Handling

- **Missing files**: Skip and retry later
- **Validation failures**: Log error, don't block monitoring
- **Partial optimizations**: Wait for complete optimization
- **Concurrent validations**: Queue validation requests

---

## Success Criteria

✅ Detects new optimizations within 60 seconds  
✅ Triggers validation automatically  
✅ Tracks validation status  
✅ Generates comparison reports  
✅ Handles partial optimizations gracefully  

---

## Usage

```powershell
# Start monitor
.\scripts\monitor_experiments.ps1

# Validate immediately on detection
.\scripts\monitor_experiments.ps1 -AutoValidate

# Only monitor, don't trigger
.\scripts\monitor_experiments.ps1 -MonitorOnly
```

---

## Notes

- Monitor both `*_best_params.json` files and `optimization_summary.md`
- Can trigger validation per rule or wait for all rules
- Consider waiting for optimization to fully complete before validating
- Maintain validation registry to avoid duplicate validation

---

**Status**: Ready for implementation  
**Priority**: Medium - Automates validation after optimization

---

## Instructions for Agent

**Follow these guidelines when implementing this agent:**

1. **Read First**: 
   - `tasks/agents/AGENT_GUIDELINES.md` - Universal guidelines for all agents
   - `docs/SCRIPTS_REFERENCE.md` - Script reference for integration points
   - `scripts/validate_optimized_rules.py` - Reference for validation logic

2. **Implementation Requirements**:
   - Monitor `data/output/experiments/` for new `*_best_params.json` files
   - Track validation status to avoid duplicate validation
   - Use Python validation script via subprocess or direct import
   - Log all validation triggers and results
   - Wait for optimization to fully complete before validating

3. **Testing**:
   - Test with actual optimization results
   - Verify validation is triggered correctly
   - Verify validation status tracking works
   - Test error handling (missing files, validation failures)

4. **Deployment**:
   - Can run continuously or on schedule
   - Monitor logs for validation results
   - Coordinate with experiment cleanup (don't validate archived experiments)

5. **Follow Patterns**:
   - Use existing monitoring scripts as reference
   - Follow validation pattern from `validate_optimized_rules.py`
   - Use registry pattern for tracking processed items

**See `tasks/agents/AGENT_GUIDELINES.md` for complete guidelines.**

