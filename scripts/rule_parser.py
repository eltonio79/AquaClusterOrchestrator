#!/usr/bin/env python3
"""
Rule Parser for Cluster Analysis Pipeline

Parses .rul files (natural language queries) and maps them to analysis functions.
Supports multiple rule types: comparison, threshold, hazard, volume, ranking.
"""

import re
import json
import os
from typing import Dict, List, Tuple, Any, Optional
from dataclasses import dataclass
from enum import Enum


class AnalysisType(Enum):
    """Types of analysis supported by the pipeline."""
    COMPARISON = "comparison"      # baseline vs candidate deltas
    THRESHOLD = "threshold"        # absolute value filtering
    HAZARD = "hazard"             # computed metrics (depth × speed)
    VOLUME = "volume"             # spatial integration
    RANKING = "ranking"           # ranking by metrics


@dataclass
class RuleConfig:
    """Configuration for a rule analysis."""
    name: str
    analysis_type: AnalysisType
    attributes: List[str]
    thresholds: Dict[str, float]
    clustering: Dict[str, Any]
    visualization: Dict[str, Any]
    outputs: Dict[str, Any]
    baseline_id: Optional[int] = None
    candidate_id: Optional[int] = None
    query_text: str = ""


class RuleParser:
    """Parses .rul files and maps them to analysis configurations."""
    
    def __init__(self, rules_dir: str = "scripts"):
        self.rules_dir = rules_dir
        self.patterns = {
            # Comparison patterns
            "depth_change": [
                r"depth.*change",
                r"how.*depth.*change",
                r"depth.*delta",
                r"change.*depth"
            ],
            "volume_change": [
                r"volume.*change",
                r"how.*volume.*change",
                r"volume.*delta"
            ],
            
            # Threshold patterns
            "high_depths": [
                r"depth.*>.*\d+\.?\d*",
                r"flood.*depth",
                r"high.*depth",
                r"depth.*exceed"
            ],
            "hazard_areas": [
                r"hazard.*\d+\.?\d*",
                r"depth.*speed",
                r"hazard.*rating"
            ],
            
            # Ranking patterns
            "worst_increase": [
                r"worst.*increase",
                r"highest.*increase",
                r"maximum.*increase"
            ],
            
            # Element filtering patterns
            "elements_filter": [
                r"elements.*increase.*\d+\.?\d*",
                r"elements.*delta.*\d+\.?\d*",
                r"show.*elements"
            ]
        }
    
    def parse_rule_file(self, rule_file: str) -> RuleConfig:
        """Parse a .rul file and return a RuleConfig object."""
        rule_path = os.path.join(self.rules_dir, rule_file)
        
        # Read the rule text
        with open(rule_path, 'r', encoding='utf-8') as f:
            rule_text = f.read().strip()
        
        # Extract the query text (skip comments)
        query_lines = []
        for line in rule_text.split('\n'):
            line = line.strip()
            if line and not line.startswith('#'):
                query_lines.append(line)
        query_text = ' '.join(query_lines)
        
        # Determine analysis type
        analysis_type = self._determine_analysis_type(query_text)
        
        # Load corresponding JSON config
        config_file = rule_file.replace('.rul', '.json')
        config_path = os.path.join(self.rules_dir, config_file)
        
        if os.path.exists(config_path):
            with open(config_path, 'r', encoding='utf-8') as f:
                config_data = json.load(f)
        else:
            # Create default config
            config_data = self._create_default_config(analysis_type)
        
        # Extract rule name from filename
        rule_name = os.path.splitext(rule_file)[0]
        
        # Create RuleConfig
        config = RuleConfig(
            name=rule_name,
            analysis_type=analysis_type,
            query_text=query_text,
            attributes=config_data.get('attributes', ['DEPTH2D', 'SPEED2D']),
            thresholds=config_data.get('thresholds', {}),
            clustering=config_data.get('clustering', {}),
            visualization=config_data.get('visualization', {}),
            outputs=config_data.get('outputs', {}),
            baseline_id=config_data.get('compare', {}).get('baseline_id'),
            candidate_id=config_data.get('compare', {}).get('candidate_id')
        )
        
        return config
    
    def _determine_analysis_type(self, query_text: str) -> AnalysisType:
        """Determine the analysis type based on the query text."""
        query_lower = query_text.lower()
        
        # Check patterns in order of specificity
        if any(re.search(pattern, query_lower) for pattern in self.patterns["depth_change"]):
            return AnalysisType.COMPARISON
        elif any(re.search(pattern, query_lower) for pattern in self.patterns["volume_change"]):
            return AnalysisType.VOLUME
        elif any(re.search(pattern, query_lower) for pattern in self.patterns["high_depths"]):
            return AnalysisType.THRESHOLD
        elif any(re.search(pattern, query_lower) for pattern in self.patterns["hazard_areas"]):
            return AnalysisType.HAZARD
        elif any(re.search(pattern, query_lower) for pattern in self.patterns["worst_increase"]):
            return AnalysisType.RANKING
        elif any(re.search(pattern, query_lower) for pattern in self.patterns["elements_filter"]):
            return AnalysisType.THRESHOLD
        else:
            # Default to threshold analysis
            return AnalysisType.THRESHOLD
    
    def _create_default_config(self, analysis_type: AnalysisType) -> Dict[str, Any]:
        """Create a default configuration for the analysis type."""
        defaults = {
            AnalysisType.COMPARISON: {
                "attributes": ["DEPTH2D", "SPEED2D"],
                "clustering": {
                    "method": "kmeans",
                    "k": 5,
                    "max_iter": 300,
                    "random_seed": 42
                },
                "thresholds": {
                    "min_cluster_area": 100.0,
                    "change_threshold": 0.01
                }
            },
            AnalysisType.THRESHOLD: {
                "attributes": ["DEPTH2D"],
                "clustering": {
                    "method": "connected_components",
                    "min_size": 50
                },
                "thresholds": {
                    "depth_threshold": 0.5
                }
            },
            AnalysisType.HAZARD: {
                "attributes": ["DEPTH2D", "SPEED2D"],
                "clustering": {
                    "method": "kmeans",
                    "k": 4,
                    "max_iter": 300
                },
                "thresholds": {
                    "hazard_threshold": 1.0
                }
            },
            AnalysisType.VOLUME: {
                "attributes": ["DEPTH2D"],
                "clustering": {
                    "method": "connected_components",
                    "min_size": 100
                },
                "thresholds": {
                    "min_cluster_area": 200.0
                }
            },
            AnalysisType.RANKING: {
                "attributes": ["DEPTH2D"],
                "clustering": {
                    "method": "kmeans",
                    "k": 6,
                    "max_iter": 300
                },
                "thresholds": {
                    "min_cluster_area": 150.0
                }
            }
        }
        
        base_config = defaults.get(analysis_type, defaults[AnalysisType.THRESHOLD])
        
        # Add common visualization and output settings
        base_config.update({
            "visualization": {
                "palette": "Spectral",
                "use_gradient": True,
                "draw_mesh": False,
                "center_only": True
            },
            "outputs": {
                "make_animation": True,
                "export_geojson": True,
                "export_shapefile": False
            }
        })
        
        return base_config
    
    def parse_all_rules(self) -> List[RuleConfig]:
        """Parse all .rul files in the rules directory."""
        rules = []
        
        if not os.path.exists(self.rules_dir):
            print(f"Warning: Rules directory {self.rules_dir} does not exist")
            return rules
        
        for filename in os.listdir(self.rules_dir):
            if filename.endswith('.rul'):
                try:
                    config = self.parse_rule_file(filename)
                    rules.append(config)
                    print(f"Parsed rule: {config.name} -> {config.analysis_type.value}")
                except Exception as e:
                    print(f"Error parsing rule {filename}: {e}")
        
        return rules
    
    def get_rule_by_name(self, rule_name: str) -> Optional[RuleConfig]:
        """Get a specific rule by name."""
        rule_file = f"{rule_name}.rul"
        rule_path = os.path.join(self.rules_dir, rule_file)
        
        if os.path.exists(rule_path):
            return self.parse_rule_file(rule_file)
        return None


def main():
    """Test the rule parser."""
    parser = RuleParser()
    rules = parser.parse_all_rules()
    
    print(f"\nParsed {len(rules)} rules:")
    for rule in rules:
        print(f"  {rule.name}: {rule.analysis_type.value}")
        print(f"    Query: {rule.query_text}")
        print(f"    Attributes: {rule.attributes}")
        if rule.baseline_id and rule.candidate_id:
            print(f"    Comparison: {rule.baseline_id} vs {rule.candidate_id}")


if __name__ == "__main__":
    main()
