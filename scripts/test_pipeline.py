#!/usr/bin/env python3
"""
Simple test script for the cluster analysis pipeline.
Tests basic functionality without requiring all dependencies.
"""

import os
import sys
import json
from rule_parser import RuleParser


def test_rule_parsing():
    """Test rule parsing functionality."""
    print("=== Testing Rule Parsing ===")
    
    try:
        parser = RuleParser()
        rules = parser.parse_all_rules()
        
        print(f"Successfully parsed {len(rules)} rules:")
        for rule in rules:
            print(f"  - {rule.name}: {rule.analysis_type.value}")
            print(f"    Query: {rule.query_text}")
            print(f"    Attributes: {rule.attributes}")
            if rule.baseline_id and rule.candidate_id:
                print(f"    Comparison: {rule.baseline_id} vs {rule.candidate_id}")
            print()
        
        return True
    except Exception as e:
        print(f"Error testing rule parsing: {e}")
        return False


def test_file_structure():
    """Test that all required files exist."""
    print("=== Testing File Structure ===")
    
    required_files = [
        "scripts/rule_parser.py",
        "scripts/cluster_processor.py", 
        "scripts/visualizer.py",
        "scripts/exporter.py",
        "scripts/pipeline_runner.py",
        "scripts/optimizer.py",
        "scripts/compare_runs.py",
        "scripts/export_rasters.rb",
        "scripts/list_simulations.rb",
        "scripts/run_pipeline.ps1",
        "scripts/commit_iteration.ps1",
        "requirements.txt"
    ]
    
    missing_files = []
    for file_path in required_files:
        if not os.path.exists(file_path):
            missing_files.append(file_path)
    
    if missing_files:
        print(f"Missing files: {missing_files}")
        return False
    else:
        print("All required files present")
        return True


def test_rule_configs():
    """Test that rule configuration files are valid."""
    print("=== Testing Rule Configurations ===")
    
    try:
        # Check that all .rul files have corresponding .json files
        rules_dir = "data/input/rules"
        rul_files = [f for f in os.listdir(rules_dir) if f.endswith('.rul')]
        json_files = [f for f in os.listdir(rules_dir) if f.endswith('.json')]
        
        print(f"Found {len(rul_files)} .rul files")
        print(f"Found {len(json_files)} .json files")
        
        missing_json = []
        for rul_file in rul_files:
            json_file = rul_file.replace('.rul', '.json')
            if json_file not in json_files:
                missing_json.append(json_file)
        
        if missing_json:
            print(f"Missing JSON configs: {missing_json}")
            return False
        else:
            print("All rule files have corresponding JSON configs")
            return True
            
    except Exception as e:
        print(f"Error testing rule configs: {e}")
        return False


def test_directory_structure():
    """Test that required directories exist or can be created."""
    print("=== Testing Directory Structure ===")
    
    required_dirs = [
        "data/output",
        "data/output/rasters",
        "data/output/clusters", 
        "data/output/viz",
        "data/output/results",
        "data/output/logs",
        "data/output/experiments"
    ]
    
    try:
        for dir_path in required_dirs:
            if not os.path.exists(dir_path):
                os.makedirs(dir_path, exist_ok=True)
                print(f"Created directory: {dir_path}")
            else:
                print(f"Directory exists: {dir_path}")
        
        return True
    except Exception as e:
        print(f"Error creating directories: {e}")
        return False


def main():
    """Run all tests."""
    print("Cluster Analysis Pipeline - Basic Tests")
    print("=" * 50)
    
    tests = [
        ("File Structure", test_file_structure),
        ("Directory Structure", test_directory_structure), 
        ("Rule Configurations", test_rule_configs),
        ("Rule Parsing", test_rule_parsing)
    ]
    
    results = []
    for test_name, test_func in tests:
        print(f"\n{test_name} Test:")
        try:
            result = test_func()
            results.append((test_name, result))
            if result:
                print(f"PASS: {test_name} test passed")
            else:
                print(f"FAIL: {test_name} test failed")
        except Exception as e:
            print(f"ERROR: {test_name} test error: {e}")
            results.append((test_name, False))
    
    # Summary
    print("\n" + "=" * 50)
    print("Test Summary:")
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "PASS" if result else "FAIL"
        print(f"  {test_name}: {status}")
    
    print(f"\nOverall: {passed}/{total} tests passed")
    
    if passed == total:
        print("SUCCESS: All basic tests passed! Pipeline is ready for use.")
        return 0
    else:
        print("FAILURE: Some tests failed. Please fix issues before proceeding.")
        return 1


if __name__ == "__main__":
    exit(main())
