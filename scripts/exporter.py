#!/usr/bin/env python3
"""
Export module for cluster analysis results.

Writes GeoJSON/Shapefile cluster boundaries, creates CSV summary tables,
and generates markdown reports.
"""

import os
import json
import csv
from typing import Dict, List, Any, Optional
import logging
from dataclasses import asdict
from cluster_processor import AnalysisResult, ClusterMetrics
from datetime import datetime
import pandas as pd


class GeoJSONExporter:
    """Exports cluster data to GeoJSON format."""
    
    def __init__(self, output_dir: str = "data/output/results"):
        self.output_dir = output_dir
        self.logger = logging.getLogger(__name__)
    
    def export_clusters(self, result: AnalysisResult) -> str:
        """Export clusters to GeoJSON format."""
        rule_name = result.rule_name
        output_dir = os.path.join(self.output_dir, rule_name)
        os.makedirs(output_dir, exist_ok=True)
        
        try:
            # Create GeoJSON feature collection
            features = []
            
            for cluster in result.clusters:
                if cluster.polygon:
                    feature = {
                        "type": "Feature",
                        "properties": {
                            "cluster_id": cluster.cluster_id,
                            "area": cluster.area,
                            "mean_value": cluster.mean_value,
                            "max_value": cluster.max_value,
                            "min_value": cluster.min_value,
                            "std_value": cluster.std_value,
                            "pixel_count": cluster.pixel_count,
                            "centroid_lon": cluster.centroid[0],
                            "centroid_lat": cluster.centroid[1]
                        },
                        "geometry": cluster.polygon
                    }
                    features.append(feature)
            
            geojson_data = {
                "type": "FeatureCollection",
                "features": features,
                "properties": {
                    "rule_name": rule_name,
                    "analysis_type": result.analysis_type,
                    "total_clusters": len(result.clusters),
                    "created_at": datetime.now().isoformat(),
                    "statistics": result.statistics
                }
            }
            
            # Save to file
            output_path = os.path.join(output_dir, f"{rule_name}_clusters.geojson")
            with open(output_path, 'w', encoding='utf-8') as f:
                json.dump(geojson_data, f, indent=2)
            
            self.logger.info(f"Exported clusters to GeoJSON: {output_path}")
            return output_path
            
        except Exception as e:
            self.logger.error(f"Error exporting clusters to GeoJSON: {e}")
            raise


class CSVExporter:
    """Exports cluster data to CSV format."""
    
    def __init__(self, output_dir: str = "data/output/results"):
        self.output_dir = output_dir
        self.logger = logging.getLogger(__name__)
    
    def export_cluster_summary(self, result: AnalysisResult) -> str:
        """Export cluster summary to CSV format."""
        rule_name = result.rule_name
        output_dir = os.path.join(self.output_dir, rule_name)
        os.makedirs(output_dir, exist_ok=True)
        
        try:
            output_path = os.path.join(output_dir, f"{rule_name}_clusters.csv")
            
            with open(output_path, 'w', newline='', encoding='utf-8') as csvfile:
                fieldnames = [
                    'cluster_id', 'area', 'mean_value', 'max_value', 'min_value', 
                    'std_value', 'pixel_count', 'centroid_lon', 'centroid_lat'
                ]
                writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
                
                writer.writeheader()
                for cluster in result.clusters:
                    writer.writerow({
                        'cluster_id': cluster.cluster_id,
                        'area': cluster.area,
                        'mean_value': cluster.mean_value,
                        'max_value': cluster.max_value,
                        'min_value': cluster.min_value,
                        'std_value': cluster.std_value,
                        'pixel_count': cluster.pixel_count,
                        'centroid_lon': cluster.centroid[0],
                        'centroid_lat': cluster.centroid[1]
                    })
            
            self.logger.info(f"Exported cluster summary to CSV: {output_path}")
            return output_path
            
        except Exception as e:
            self.logger.error(f"Error exporting cluster summary to CSV: {e}")
            raise
    
    def export_statistics(self, result: AnalysisResult) -> str:
        """Export overall statistics to CSV format."""
        rule_name = result.rule_name
        output_dir = os.path.join(self.output_dir, rule_name)
        os.makedirs(output_dir, exist_ok=True)
        
        try:
            output_path = os.path.join(output_dir, f"{rule_name}_statistics.csv")
            
            with open(output_path, 'w', newline='', encoding='utf-8') as csvfile:
                writer = csv.writer(csvfile)
                
                writer.writerow(['Metric', 'Value'])
                writer.writerow(['rule_name', rule_name])
                writer.writerow(['analysis_type', result.analysis_type])
                writer.writerow(['created_at', datetime.now().isoformat()])
                
                for key, value in result.statistics.items():
                    writer.writerow([key, value])
            
            self.logger.info(f"Exported statistics to CSV: {output_path}")
            return output_path
            
        except Exception as e:
            self.logger.error(f"Error exporting statistics to CSV: {e}")
            raise


class ReportGenerator:
    """Generates markdown reports for analysis results."""
    
    def __init__(self, output_dir: str = "data/output/results"):
        self.output_dir = output_dir
        self.logger = logging.getLogger(__name__)
    
    def generate_report(self, result: AnalysisResult, viz_paths: Dict[str, str]) -> str:
        """Generate a markdown report for analysis results."""
        rule_name = result.rule_name
        output_dir = os.path.join(self.output_dir, rule_name)
        os.makedirs(output_dir, exist_ok=True)
        
        try:
            output_path = os.path.join(output_dir, "REPORT.md")
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(f"# Cluster Analysis Report: {rule_name}\n\n")
                
                # Metadata
                f.write("## Analysis Metadata\n\n")
                f.write(f"- **Rule Name**: {rule_name}\n")
                f.write(f"- **Analysis Type**: {result.analysis_type}\n")
                f.write(f"- **Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
                f.write(f"- **Total Clusters**: {len(result.clusters)}\n\n")
                
                # Statistics
                f.write("## Overall Statistics\n\n")
                f.write("| Metric | Value |\n")
                f.write("|--------|-------|\n")
                for key, value in result.statistics.items():
                    f.write(f"| {key} | {value} |\n")
                f.write("\n")
                
                # Processing parameters
                f.write("## Processing Parameters\n\n")
                f.write("```json\n")
                f.write(json.dumps(result.processing_params, indent=2))
                f.write("\n```\n\n")
                
                # Cluster details
                f.write("## Cluster Details\n\n")
                if result.clusters:
                    f.write("| ID | Area | Mean Value | Max Value | Min Value | Std Value | Pixel Count |\n")
                    f.write("|----|------|------------|-----------|-----------|-----------|-------------|\n")
                    
                    for cluster in result.clusters:
                        f.write(f"| {cluster.cluster_id} | {cluster.area:.2f} | "
                               f"{cluster.mean_value:.4f} | {cluster.max_value:.4f} | "
                               f"{cluster.min_value:.4f} | {cluster.std_value:.4f} | "
                               f"{cluster.pixel_count} |\n")
                    f.write("\n")
                else:
                    f.write("No clusters found.\n\n")
                
                # Visualizations
                f.write("## Visualizations\n\n")
                if viz_paths.get('overlay'):
                    f.write(f"### Cluster Overlay\n\n")
                    f.write(f"![Cluster Overlay]({os.path.basename(viz_paths['overlay'])})\n\n")
                
                if viz_paths.get('heatmap'):
                    f.write(f"### Cluster Heatmap\n\n")
                    f.write(f"![Cluster Heatmap]({os.path.basename(viz_paths['heatmap'])})\n\n")
                
                if viz_paths.get('difference'):
                    f.write(f"### Difference Map\n\n")
                    f.write(f"![Difference Map]({os.path.basename(viz_paths['difference'])})\n\n")
                
                if viz_paths.get('animation'):
                    f.write(f"### Animation\n\n")
                    f.write(f"![Animation]({os.path.basename(viz_paths['animation'])})\n\n")
                
                # Files
                f.write("## Generated Files\n\n")
                f.write("- `clusters.csv` - Cluster summary data\n")
                f.write("- `statistics.csv` - Overall statistics\n")
                f.write("- `clusters.geojson` - Cluster geometries (if available)\n")
                f.write("- `REPORT.md` - This report\n")
                
                if viz_paths.get('overlay'):
                    f.write(f"- `{os.path.basename(viz_paths['overlay'])}` - Cluster overlay visualization\n")
                if viz_paths.get('heatmap'):
                    f.write(f"- `{os.path.basename(viz_paths['heatmap'])}` - Cluster heatmap\n")
                if viz_paths.get('difference'):
                    f.write(f"- `{os.path.basename(viz_paths['difference'])}` - Difference map\n")
                if viz_paths.get('animation'):
                    f.write(f"- `{os.path.basename(viz_paths['animation'])}` - Animation\n")
                
                f.write("\n")
                
                # Analysis notes
                f.write("## Analysis Notes\n\n")
                f.write("This analysis was generated using the automated cluster analysis pipeline.\n")
                f.write("The results show areas of significant change or interest based on the specified criteria.\n")
                
                if result.analysis_type == "comparison":
                    f.write("\nThis is a comparison analysis showing differences between baseline and candidate scenarios.\n")
                elif result.analysis_type == "threshold":
                    f.write("\nThis is a threshold analysis identifying areas exceeding specified criteria.\n")
                elif result.analysis_type == "hazard":
                    f.write("\nThis is a hazard analysis combining depth and speed to identify risk areas.\n")
                elif result.analysis_type == "volume":
                    f.write("\nThis is a volume analysis focusing on spatial integration of values.\n")
                elif result.analysis_type == "ranking":
                    f.write("\nThis is a ranking analysis identifying the worst affected areas.\n")
            
            self.logger.info(f"Generated report: {output_path}")
            return output_path
            
        except Exception as e:
            self.logger.error(f"Error generating report: {e}")
            raise


class CombinedExporter:
    """Combines all export functionality."""
    
    def __init__(self, output_dir: str = "data/output/results"):
        self.output_dir = output_dir
        self.geojson_exporter = GeoJSONExporter(output_dir)
        self.csv_exporter = CSVExporter(output_dir)
        self.report_generator = ReportGenerator(output_dir)
        self.logger = logging.getLogger(__name__)
    
    def export_all(self, result: AnalysisResult, viz_paths: Dict[str, str]) -> Dict[str, str]:
        """Export all formats for a given analysis result."""
        exported_files = {}
        
        try:
            # Export GeoJSON
            geojson_path = self.geojson_exporter.export_clusters(result)
            exported_files['geojson'] = geojson_path
            
            # Export CSV files
            csv_summary_path = self.csv_exporter.export_cluster_summary(result)
            exported_files['csv_summary'] = csv_summary_path
            
            csv_stats_path = self.csv_exporter.export_statistics(result)
            exported_files['csv_statistics'] = csv_stats_path
            
            # Generate report
            report_path = self.report_generator.generate_report(result, viz_paths)
            exported_files['report'] = report_path
            
            self.logger.info(f"Exported all formats for rule: {result.rule_name}")
            return exported_files
            
        except Exception as e:
            self.logger.error(f"Error exporting all formats: {e}")
            raise
    
    def create_summary_report(self, results: List[AnalysisResult]) -> str:
        """Create a summary report for all analysis results."""
        try:
            output_path = os.path.join(self.output_dir, "SUMMARY_REPORT.md")
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write("# Cluster Analysis Summary Report\n\n")
                f.write(f"**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
                
                f.write(f"**Total Rules Processed**: {len(results)}\n\n")
                
                # Summary table
                f.write("## Analysis Summary\n\n")
                f.write("| Rule Name | Analysis Type | Clusters | Total Area | Mean Value |\n")
                f.write("|-----------|---------------|----------|------------|------------|\n")
                
                for result in results:
                    total_area = result.statistics.get('total_area', 0)
                    mean_value = result.statistics.get('mean_cluster_value', 0)
                    f.write(f"| {result.rule_name} | {result.analysis_type} | "
                           f"{len(result.clusters)} | {total_area:.2f} | {mean_value:.4f} |\n")
                
                f.write("\n")
                
                # Individual rule links
                f.write("## Individual Reports\n\n")
                for result in results:
                    f.write(f"- [{result.rule_name}]({result.rule_name}/REPORT.md)\n")
                
                f.write("\n")
                
                # Analysis types breakdown
                f.write("## Analysis Types\n\n")
                analysis_types = {}
                for result in results:
                    analysis_types[result.analysis_type] = analysis_types.get(result.analysis_type, 0) + 1
                
                for analysis_type, count in analysis_types.items():
                    f.write(f"- **{analysis_type}**: {count} rules\n")
                
                f.write("\n")
                
                # Notes
                f.write("## Notes\n\n")
                f.write("This summary report provides an overview of all cluster analysis results.\n")
                f.write("Refer to individual rule reports for detailed information.\n")
            
            self.logger.info(f"Created summary report: {output_path}")
            return output_path
            
        except Exception as e:
            self.logger.error(f"Error creating summary report: {e}")
            raise


def main():
    """Test the exporter."""
    from cluster_processor import ClusterProcessor
    from rule_parser import RuleParser
    from visualizer import RasterVisualizer, VisualizationConfig
    
    # Set up logging
    logging.basicConfig(level=logging.INFO)
    
    # Parse rules and process one
    parser = RuleParser()
    rules = parser.parse_all_rules()
    
    if not rules:
        print("No rules found to export")
        return
    
    processor = ClusterProcessor()
    try:
        # Process first rule
        result = processor.process_rule(rules[0])
        
        # Create visualizations
        visualizer = RasterVisualizer()
        config = VisualizationConfig()
        
        viz_paths = {
            'overlay': visualizer.create_cluster_overlay(result, config),
            'heatmap': visualizer.create_heatmap(result, config),
            'difference': visualizer.create_difference_map(result, config),
            'animation': visualizer.create_animation(result, config)
        }
        
        # Export all formats
        exporter = CombinedExporter()
        exported_files = exporter.export_all(result, viz_paths)
        
        print(f"Exported files:")
        for format_type, filepath in exported_files.items():
            print(f"  {format_type}: {filepath}")
        
    except Exception as e:
        print(f"Error in export test: {e}")


if __name__ == "__main__":
    main()
