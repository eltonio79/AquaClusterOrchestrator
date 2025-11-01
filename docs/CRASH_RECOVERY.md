# Crash Recovery and Protection System

## Overview

This document describes the crash recovery and protection mechanisms implemented to prevent data loss and enable recovery after system crashes or interruptions.

## Components

### 1. Crash Recovery Module (`scripts/crash_recovery.py`)

Provides state management and crash recovery functionality:

- **State Saving**: Automatically saves operation state before execution
- **Progress Tracking**: Tracks completed items and current progress
- **Error Logging**: Persistent logging of errors and crashes
- **Safe Execution**: Wrapper function for protected execution

### 2. Safe Error Logger (`SafeErrorLogger`)

Persistent error logging that survives crashes:

- Logs errors to `data/output/logs/crash_errors.log`
- Logs full crashes to `data/output/logs/crashes.log`
- Uses JSON format for structured error data
- Falls back to simple text logging if JSON fails

### 3. Crash Recovery (`CrashRecovery`)

State management for operations:

- Saves state to `data/output/.state/`
- Creates timestamped state files
- Maintains `_latest.json` files for quick recovery
- Tracks progress in `_progress.json` files

## Integration

### Optimizer (`scripts/optimizer.py`)

- Saves progress before each rule optimization
- Logs errors for failed rules
- Tracks completed vs. failed rules
- Uses `safe_execute()` wrapper for crash protection

### Validator (`scripts/validate_optimized_rules.py`)

- Protects validation runs with crash recovery
- Logs validation errors separately
- Tracks validation progress

### Pipeline Runner (`scripts/pipeline_runner.py`)

- Logs crashes to persistent files
- Handles `KeyboardInterrupt` gracefully (exit code 130)
- Provides full traceback on failures

## Usage

### Automatic Protection

All major operations are automatically protected:

```python
from crash_recovery import CrashRecovery, SafeErrorLogger, safe_execute

# Automatic protection
result = safe_execute('operation_name', my_function, arg1, arg2)
```

### Manual State Management

```python
from crash_recovery import CrashRecovery

crash_recovery = CrashRecovery()

# Save state
crash_recovery.save_state('my_operation', {'data': 'value'})

# Load state
state = crash_recovery.load_latest_state('my_operation')

# Save progress
crash_recovery.save_progress('my_operation', 
                            completed_items=['item1', 'item2'],
                            current_item='item3')
```

## Recovery After Crash

### Check Error Logs

```bash
# View recent errors
cat data/output/logs/crash_errors.log

# View crashes
cat data/output/logs/crashes.log
```

### Check Saved State

```bash
# List saved states
ls data/output/.state/

# View latest state for an operation
cat data/output/.state/optimizer_latest.json

# View progress
cat data/output/.state/optimizer_progress.json
```

### Resume Operation

The system automatically saves progress, so you can:

1. Check what was completed: `cat data/output/.state/optimizer_progress.json`
2. Note which items had errors
3. Re-run the operation (it will skip completed items if implemented)

## Error Handling Best Practices

### Keyboard Interrupt (Ctrl+C)

- All scripts handle `KeyboardInterrupt` gracefully
- Exit code 130 indicates user interruption
- Progress is saved before exit

### Exceptions

- All exceptions are caught and logged
- Full tracebacks are saved to crash logs
- Scripts exit with code 1 on errors (except KeyboardInterrupt)

### Unicode Issues

- Replaced emoji characters with ASCII alternatives:
  - ✅ → `[OK]`
  - ❌ → `[X]`
  - ⚠️ → `[!]`
  - 📉 → `[DOWN]`

## File Locations

- **State files**: `data/output/.state/`
- **Error logs**: `data/output/logs/crash_errors.log`
- **Crash logs**: `data/output/logs/crashes.log`
- **Progress files**: `data/output/.state/{operation}_progress.json`

## Benefits

1. **No Data Loss**: State and progress saved automatically
2. **Debugging**: Full error traces saved for analysis
3. **Recovery**: Can identify what was completed before crash
4. **Resilience**: System continues operating even when individual operations fail
5. **Transparency**: All errors logged persistently

## Future Enhancements

- Automatic resume from saved state
- Progress continuation (skip completed items)
- State cleanup (remove old state files)
- Crash notification system

