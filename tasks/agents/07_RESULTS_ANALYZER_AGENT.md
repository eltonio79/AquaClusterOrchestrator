# Agent 07: Results Analyzer Agent

**Role**: Analyze results, generate insights, and create summary reports  
**Priority**: Low  
**Status**: Ready for implementation

---

## Mission

Analyze pipeline results, compare runs, identify trends, generate insights, and create comprehensive analysis reports.

---

## Responsibilities

1. **Result Analysis**
   - Analyze cluster statistics across runs
   - Identify patterns and trends
   - Calculate aggregate metrics
   - Detect anomalies

2. **Trend Detection**
   - Track cluster count trends over time
   - Monitor quality metric changes
   - Identify improving or degrading rules
   - Compare optimization effectiveness

3. **Insight Generation**
   - Suggest parameter improvements
   - Identify best-performing configurations
   - Highlight rules needing attention
   - Generate recommendations

4. **Report Creation**
   - Create comprehensive analysis reports
   - Generate visualizations (charts, graphs)
   - Create executive summaries
   - Export analysis data

---

## Implementation Guide

### Core Script: `scripts/results_analyzer_agent.ps1`

```powershell
# Pseudo-code structure:
1. Load all run manifests from data/output/config/active/
2. Extract metrics from each run
3. Aggregate statistics:
   a. Total clusters per rule over time
   b. Average cluster sizes
   c. Quality scores
   d. Processing times
4. Detect trends:
   a. Increasing/decreasing cluster counts
   b. Quality improvements
   c. Performance changes
5. Generate insights and recommendations
6. Create analysis report with charts
```

### Key Functions Needed

- `Load-AllRuns` - Load all run manifests
- `Extract-Metrics` - Extract statistics from runs
- `Analyze-Trends` - Detect patterns over time
- `Generate-Insights` - Create recommendations
- `Create-Charts` - Generate visualizations (can use Python)
- `Generate-AnalysisReport` - Create comprehensive report

### Logging

- Create markdown log: `data/output/logs/analysis/analyzer_YYYYMMDD_HHMMSS.md`
- Log format:
  ```markdown
  # Results Analyzer Agent Log
  - Started: [timestamp]
  
  ## Analysis
  - [timestamp] Analyzed [count] runs
  - [timestamp] Detected [count] trends
  - [timestamp] Generated [count] insights
  
  ## Trends
  - [rule_name]: [trend] ([change])
  - [rule_name]: [trend] ([change])
  ```

---

## Configuration

### Analysis Scope
- **Time range**: Last 7/30/90 days or all runs
- **Rules**: All rules or specific rules
- **Metrics**: Cluster count, quality scores, processing time

### Trend Detection
- **Threshold**: Significant change >10%
- **Minimum runs**: At least 3 runs for trend detection
- **Direction**: Increasing, decreasing, stable

### Report Generation
- **Frequency**: Daily, weekly, or on demand
- **Format**: Markdown with embedded charts
- **Include**: Trends, insights, recommendations, raw data

---

## Integration Points

- **Reads**: `data/output/config/active/run_manifest_*.json`
- **Reads**: `data/output/results/` (result files)
- **Reads**: `data/output/experiments/` (optimization results)
- **Uses**: `scripts/compare_runs.py` (comparison logic)
- **Writes**: Analysis reports to `data/output/analysis/`
- **Writes**: Charts to `data/output/analysis/charts/`

---

## Error Handling

- **Missing data**: Skip and log warning
- **Invalid data**: Validate before analysis
- **Analysis errors**: Log error, continue with available data
- **Chart generation failures**: Fall back to tables

---

## Success Criteria

✅ Analyzes all available runs  
✅ Detects trends accurately  
✅ Generates meaningful insights  
✅ Creates comprehensive reports  
✅ Provides actionable recommendations  

---

## Usage

```powershell
# Run analysis
.\scripts\results_analyzer_agent.ps1

# Analyze specific time range
.\scripts\results_analyzer_agent.ps1 -Days 30

# Analyze specific rules
.\scripts\results_analyzer_agent.ps1 -Rules depth_change_analysis,depth_worst_increase

# Generate charts
.\scripts\results_analyzer_agent.ps1 -GenerateCharts
```

---

## Analysis Report Format

```markdown
# Results Analysis Report
- Generated: [timestamp]
- Analyzed Runs: [count]
- Time Range: [start] to [end]

## Executive Summary
- Total rules processed: [count]
- Average clusters per run: [number]
- Quality trend: [improving|stable|degrading]

## Trends by Rule
### depth_change_analysis
- Cluster count: [trend] ([change])
- Quality score: [trend] ([change])
- Status: [healthy|needs_attention]

## Insights
- [Rule X] shows significant improvement after optimization
- [Rule Y] needs parameter tuning
- [Rule Z] consistently produces good results

## Recommendations
- Consider re-optimizing [rule_name] with adjusted parameters
- [Rule_name] parameters are well-tuned, maintain current settings
```

---

## Notes

- Can use Python for advanced analysis (pandas, matplotlib)
- Integrate with optimization results for effectiveness analysis
- Generate charts showing trends over time
- Provide actionable recommendations based on analysis

---

**Status**: Ready for implementation  
**Priority**: Low - Provides insights and analytics

---

## Instructions for Agent

**Follow these guidelines when implementing this agent:**

1. **Read First**: 
   - `tasks/agents/AGENT_GUIDELINES.md` - Universal guidelines for all agents
   - `scripts/compare_runs.py` - Comparison logic
   - `scripts/optimizer.py` - Optimization metrics logic

2. **Implementation Requirements**:
   - Load all run manifests from `data/output/config/active/`
   - Extract and aggregate metrics from all runs
   - Detect trends using statistical analysis
   - Generate insights and recommendations
   - Create visualizations (can use Python with matplotlib)
   - Generate comprehensive analysis reports in Markdown

3. **Testing**:
   - Test with actual run data
   - Verify trend detection works correctly
   - Test insight generation logic
   - Verify report generation
   - Test visualization creation

4. **Deployment**:
   - Run on schedule (daily or weekly)
   - Can be triggered manually for specific analysis
   - Generate reports in `data/output/analysis/`
   - Export charts to `data/output/analysis/charts/`

5. **Follow Patterns**:
   - Use comparison logic from `compare_runs.py`
   - Use aggregation patterns from optimizer
   - Follow reporting format from other agents

**See `tasks/agents/AGENT_GUIDELINES.md` for complete guidelines.**

