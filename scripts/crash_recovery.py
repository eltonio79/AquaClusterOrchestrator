#!/usr/bin/env python3
"""
Crash recovery and state management utilities.

Provides state saving/loading, progress tracking, and crash recovery
mechanisms to prevent data loss and enable resume after crashes.
"""

import os
import json
import logging
from datetime import datetime
from typing import Dict, Any, Optional
from pathlib import Path


class CrashRecovery:
    """Manages crash recovery state and progress tracking."""
    
    def __init__(self, state_dir: str = "data/output/.state"):
        self.state_dir = Path(state_dir)
        self.state_dir.mkdir(parents=True, exist_ok=True)
        self.logger = logging.getLogger(__name__)
    
    def save_state(self, 
                   operation: str,
                   state_data: Dict[str, Any],
                   metadata: Optional[Dict[str, Any]] = None) -> str:
        """
        Save operation state to disk.
        
        Args:
            operation: Operation identifier (e.g., 'optimizer', 'validator')
            state_data: State data to save
            metadata: Optional metadata (timestamp, etc.)
            
        Returns:
            Path to saved state file
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        state_file = self.state_dir / f"{operation}_{timestamp}.json"
        
        state = {
            'operation': operation,
            'timestamp': timestamp,
            'state': state_data,
            'metadata': metadata or {}
        }
        
        try:
            with open(state_file, 'w', encoding='utf-8') as f:
                json.dump(state, f, indent=2, ensure_ascii=False)
            
            # Also save as latest
            latest_file = self.state_dir / f"{operation}_latest.json"
            with open(latest_file, 'w', encoding='utf-8') as f:
                json.dump(state, f, indent=2, ensure_ascii=False)
            
            self.logger.debug(f"Saved state: {state_file}")
            return str(state_file)
        except Exception as e:
            self.logger.error(f"Failed to save state: {e}")
            raise
    
    def load_latest_state(self, operation: str) -> Optional[Dict[str, Any]]:
        """
        Load latest saved state for an operation.
        
        Args:
            operation: Operation identifier
            
        Returns:
            State dictionary or None if not found
        """
        latest_file = self.state_dir / f"{operation}_latest.json"
        
        if not latest_file.exists():
            return None
        
        try:
            with open(latest_file, 'r', encoding='utf-8') as f:
                state = json.load(f)
            self.logger.debug(f"Loaded state: {latest_file}")
            return state
        except Exception as e:
            self.logger.warning(f"Failed to load state: {e}")
            return None
    
    def save_progress(self,
                     operation: str,
                     completed_items: list,
                     current_item: Optional[str] = None,
                     errors: Optional[list] = None) -> None:
        """
        Save progress for long-running operations.
        
        Args:
            operation: Operation identifier
            completed_items: List of completed items
            current_item: Currently processing item
            errors: List of errors encountered
        """
        progress = {
            'completed': completed_items,
            'current': current_item,
            'errors': errors or [],
            'total_completed': len(completed_items),
            'last_updated': datetime.now().isoformat()
        }
        
        progress_file = self.state_dir / f"{operation}_progress.json"
        try:
            with open(progress_file, 'w', encoding='utf-8') as f:
                json.dump(progress, f, indent=2, ensure_ascii=False)
        except Exception as e:
            self.logger.error(f"Failed to save progress: {e}")
    
    def load_progress(self, operation: str) -> Optional[Dict[str, Any]]:
        """Load saved progress for an operation."""
        progress_file = self.state_dir / f"{operation}_progress.json"
        
        if not progress_file.exists():
            return None
        
        try:
            with open(progress_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception as e:
            self.logger.warning(f"Failed to load progress: {e}")
            return None
    
    def clear_state(self, operation: str) -> None:
        """Clear saved state and progress for an operation."""
        latest_file = self.state_dir / f"{operation}_latest.json"
        progress_file = self.state_dir / f"{operation}_progress.json"
        
        for file in [latest_file, progress_file]:
            if file.exists():
                try:
                    file.unlink()
                    self.logger.debug(f"Cleared state: {file}")
                except Exception as e:
                    self.logger.warning(f"Failed to clear state {file}: {e}")


class SafeErrorLogger:
    """Safe error logging that persists to disk even on crashes."""
    
    def __init__(self, log_dir: str = "data/output/logs"):
        self.log_dir = Path(log_dir)
        self.log_dir.mkdir(parents=True, exist_ok=True)
        self.error_log = self.log_dir / "crash_errors.log"
    
    def log_error(self, 
                  operation: str,
                  error: Exception,
                  context: Optional[Dict[str, Any]] = None) -> None:
        """Log error to persistent file."""
        error_entry = {
            'timestamp': datetime.now().isoformat(),
            'operation': operation,
            'error_type': type(error).__name__,
            'error_message': str(error),
            'context': context or {}
        }
        
        try:
            with open(self.error_log, 'a', encoding='utf-8') as f:
                f.write(json.dumps(error_entry, ensure_ascii=False) + "\n")
        except Exception:
            # If even logging fails, try to write to a simple text file
            try:
                with open(self.log_dir / "crash_errors_simple.txt", 'a', encoding='utf-8') as f:
                    f.write(f"{datetime.now()}: {operation}: {error}\n")
            except Exception:
                pass  # Last resort - can't log anything
    
    def log_crash(self,
                  operation: str,
                  traceback_str: str,
                  context: Optional[Dict[str, Any]] = None) -> None:
        """Log crash with full traceback."""
        crash_entry = {
            'timestamp': datetime.now().isoformat(),
            'operation': operation,
            'type': 'crash',
            'traceback': traceback_str,
            'context': context or {}
        }
        
        crash_log = self.log_dir / "crashes.log"
        try:
            with open(crash_log, 'a', encoding='utf-8') as f:
                f.write(json.dumps(crash_entry, ensure_ascii=False) + "\n")
                f.write("\n" + "="*80 + "\n\n")
        except Exception:
            pass  # Can't log crash either


def safe_execute(operation: str,
                 func,
                 *args,
                 crash_recovery: Optional[CrashRecovery] = None,
                 error_logger: Optional[SafeErrorLogger] = None,
                 **kwargs) -> Any:
    """
    Execute function with crash protection.
    
    Args:
        operation: Operation identifier
        func: Function to execute
        *args, **kwargs: Arguments to pass to function
        crash_recovery: Optional CrashRecovery instance
        error_logger: Optional SafeErrorLogger instance
        
    Returns:
        Function result or None on failure
    """
    if crash_recovery is None:
        crash_recovery = CrashRecovery()
    if error_logger is None:
        error_logger = SafeErrorLogger()
    
    try:
        # Save state before execution
        state_data = {
            'operation': operation,
            'args': str(args),
            'kwargs': str(kwargs),
            'started': datetime.now().isoformat()
        }
        crash_recovery.save_state(operation, state_data)
        
        # Execute function
        result = func(*args, **kwargs)
        
        # Clear state on success
        crash_recovery.clear_state(operation)
        
        return result
    
    except KeyboardInterrupt:
        error_logger.log_error(operation, 
                             Exception("Interrupted by user"),
                             {'type': 'KeyboardInterrupt'})
        raise
    
    except Exception as e:
        import traceback
        tb_str = traceback.format_exc()
        
        error_logger.log_crash(operation, tb_str, {
            'args': str(args),
            'kwargs': str(kwargs)
        })
        
        # Save error state
        if crash_recovery:
            error_state = {
                'operation': operation,
                'error': str(e),
                'error_type': type(e).__name__,
                'traceback': tb_str
            }
            crash_recovery.save_state(f"{operation}_error", error_state)
        
        raise

