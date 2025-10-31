#!/usr/bin/env python3
"""
Visualization module for cluster analysis results.

Creates cluster overlays on base rasters, generates animations, and produces
heatmaps and difference maps.
"""

import os
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.colors import ListedColormap
import rasterio
from PIL import Image, ImageDraw
import imageio
from typing import Dict, List, Tuple, Any, Optional
import json
import logging
from dataclasses import dataclass
from cluster_processor import AnalysisResult, ClusterMetrics


@dataclass
class VisualizationConfig:
    """Configuration for visualization output."""
    palette: str = "Spectral"
    use_gradient: bool = True
    draw_mesh: bool = False
    center_only: bool = True
    output_size: Tuple[int, int] = (800, 600)
    dpi: int = 100
    animation_fps: int = 2
    overlay_alpha: float = 0.7


class RasterVisualizer:
    """Handles visualization of raster data and cluster overlays."""
    
    def __init__(self, output_dir: str = "data/output/viz"):
        self.output_dir = output_dir
        self.logger = logging.getLogger(__name__)
        os.makedirs(output_dir, exist_ok=True)
    
    def create_cluster_overlay(self, result: AnalysisResult, config: VisualizationConfig) -> str:
        """Create a cluster overlay visualization."""
        rule_name = result.rule_name
        viz_dir = os.path.join(self.output_dir, rule_name)
        os.makedirs(viz_dir, exist_ok=True)
        
        try:
            # Create figure
            fig, ax = plt.subplots(figsize=(config.output_size[0]/config.dpi, 
                                           config.output_size[1]/config.dpi), 
                                 dpi=config.dpi)
            
            # Load base raster if available
            base_raster_path = self._find_base_raster(rule_name)
            if base_raster_path:
                self._plot_base_raster(ax, base_raster_path, result.raster_info)
            
            # Plot clusters
            self._plot_clusters(ax, result.clusters, config)
            
            # Customize plot
            ax.set_title(f"Cluster Analysis: {rule_name}")
            ax.set_xlabel("Longitude")
            ax.set_ylabel("Latitude")
            ax.grid(True, alpha=0.3)
            
            # Save plot
            output_path = os.path.join(viz_dir, f"{rule_name}_overlay.png")
            plt.savefig(output_path, bbox_inches='tight', dpi=config.dpi)
            plt.close()
            
            self.logger.info(f"Created cluster overlay: {output_path}")
            return output_path
            
        except Exception as e:
            self.logger.error(f"Error creating cluster overlay: {e}")
            raise
    
    def create_heatmap(self, result: AnalysisResult, config: VisualizationConfig) -> str:
        """Create a heatmap visualization of cluster values."""
        rule_name = result.rule_name
        viz_dir = os.path.join(self.output_dir, rule_name)
        os.makedirs(viz_dir, exist_ok=True)
        
        try:
            fig, ax = plt.subplots(figsize=(config.output_size[0]/config.dpi, 
                                           config.output_size[1]/config.dpi), 
                                 dpi=config.dpi)
            
            # Create heatmap data
            if result.clusters:
                values = [c.mean_value for c in result.clusters]
                areas = [c.area for c in result.clusters]
                colors = plt.cm.get_cmap(config.palette)(np.linspace(0, 1, len(values)))
                
                # Create scatter plot with size based on area and color based on value
                x_coords = [c.centroid[0] for c in result.clusters]
                y_coords = [c.centroid[1] for c in result.clusters]
                
                scatter = ax.scatter(x_coords, y_coords, 
                                   s=[a/10 for a in areas],  # Scale area for visibility
                                   c=values,
                                   cmap=config.palette,
                                   alpha=0.7,
                                   edgecolors='black',
                                   linewidth=0.5)
                
                # Add colorbar
                cbar = plt.colorbar(scatter, ax=ax)
                cbar.set_label('Mean Value')
            
            ax.set_title(f"Cluster Heatmap: {rule_name}")
            ax.set_xlabel("Longitude")
            ax.set_ylabel("Latitude")
            ax.grid(True, alpha=0.3)
            
            # Save plot
            output_path = os.path.join(viz_dir, f"{rule_name}_heatmap.png")
            plt.savefig(output_path, bbox_inches='tight', dpi=config.dpi)
            plt.close()
            
            self.logger.info(f"Created heatmap: {output_path}")
            return output_path
            
        except Exception as e:
            self.logger.error(f"Error creating heatmap: {e}")
            raise
    
    def create_difference_map(self, result: AnalysisResult, config: VisualizationConfig) -> str:
        """Create a difference map showing changes."""
        rule_name = result.rule_name
        viz_dir = os.path.join(self.output_dir, rule_name)
        os.makedirs(viz_dir, exist_ok=True)
        
        try:
            fig, ax = plt.subplots(figsize=(config.output_size[0]/config.dpi, 
                                           config.output_size[1]/config.dpi), 
                                 dpi=config.dpi)
            
            # Create difference visualization
            if result.analysis_type == "comparison" and result.clusters:
                # Use cluster values to show differences
                values = [c.mean_value for c in result.clusters]
                areas = [c.area for c in result.clusters]
                
                # Create color map for positive/negative changes
                colors = ['red' if v > 0 else 'blue' for v in values]
                sizes = [a/10 for a in areas]
                
                x_coords = [c.centroid[0] for c in result.clusters]
                y_coords = [c.centroid[1] for c in result.clusters]
                
                scatter = ax.scatter(x_coords, y_coords, 
                                   s=sizes,
                                   c=colors,
                                   alpha=0.7,
                                   edgecolors='black',
                                   linewidth=0.5)
                
                # Add legend
                red_patch = patches.Patch(color='red', label='Increase')
                blue_patch = patches.Patch(color='blue', label='Decrease')
                ax.legend(handles=[red_patch, blue_patch])
            
            ax.set_title(f"Difference Map: {rule_name}")
            ax.set_xlabel("Longitude")
            ax.set_ylabel("Latitude")
            ax.grid(True, alpha=0.3)
            
            # Save plot
            output_path = os.path.join(viz_dir, f"{rule_name}_difference.png")
            plt.savefig(output_path, bbox_inches='tight', dpi=config.dpi)
            plt.close()
            
            self.logger.info(f"Created difference map: {output_path}")
            return output_path
            
        except Exception as e:
            self.logger.error(f"Error creating difference map: {e}")
            raise
    
    def create_animation(self, result: AnalysisResult, config: VisualizationConfig) -> str:
        """Create an animation showing cluster evolution."""
        rule_name = result.rule_name
        viz_dir = os.path.join(self.output_dir, rule_name)
        os.makedirs(viz_dir, exist_ok=True)
        
        try:
            # For now, create a simple animation by varying cluster visualization parameters
            frames = []
            
            # Create multiple frames with different visualization parameters
            for frame_idx in range(5):
                fig, ax = plt.subplots(figsize=(config.output_size[0]/config.dpi, 
                                               config.output_size[1]/config.dpi), 
                                     dpi=config.dpi)
                
                # Plot clusters with varying parameters
                if result.clusters:
                    alpha = 0.3 + (frame_idx * 0.1)
                    values = [c.mean_value for c in result.clusters]
                    areas = [c.area for c in result.clusters]
                    
                    x_coords = [c.centroid[0] for c in result.clusters]
                    y_coords = [c.centroid[1] for c in result.clusters]
                    
                    ax.scatter(x_coords, y_coords, 
                             s=[a/10 for a in areas],
                             c=values,
                             cmap=config.palette,
                             alpha=alpha,
                             edgecolors='black',
                             linewidth=0.5)
                
                ax.set_title(f"Cluster Animation Frame {frame_idx + 1}: {rule_name}")
                ax.set_xlabel("Longitude")
                ax.set_ylabel("Latitude")
                ax.grid(True, alpha=0.3)
                
                # Save frame
                frame_path = os.path.join(viz_dir, f"frame_{frame_idx:03d}.png")
                plt.savefig(frame_path, bbox_inches='tight', dpi=config.dpi)
                plt.close()
                
                frames.append(frame_path)
            
            # Create GIF animation
            gif_path = os.path.join(viz_dir, f"{rule_name}_animation.gif")
            with imageio.get_writer(gif_path, mode='I', fps=config.animation_fps) as writer:
                for frame_path in frames:
                    image = imageio.imread(frame_path)
                    writer.append_data(image)
            
            # Clean up frame files
            for frame_path in frames:
                os.remove(frame_path)
            
            self.logger.info(f"Created animation: {gif_path}")
            return gif_path
            
        except Exception as e:
            self.logger.error(f"Error creating animation: {e}")
            raise
    
    def _find_base_raster(self, rule_name: str) -> Optional[str]:
        """Find a base raster file for overlay visualization."""
        # Look for raster files in the data directory
        raster_dir = os.path.join("data/output/rasters")
        if not os.path.exists(raster_dir):
            return None
        
        # Look for any .tif file that might be suitable as base
        for root, dirs, files in os.walk(raster_dir):
            for file in files:
                if file.endswith('.tif'):
                    return os.path.join(root, file)
        
        return None
    
    def _plot_base_raster(self, ax, raster_path: str, raster_info: Dict[str, Any]) -> None:
        """Plot the base raster as background."""
        try:
            with rasterio.open(raster_path) as src:
                data = src.read(1)
                transform = src.transform
                
                # Plot raster as background
                im = ax.imshow(data, extent=[
                    transform.c, transform.c + transform.a * src.width,
                    transform.f + transform.e * src.height, transform.f
                ], cmap='gray', alpha=0.3)
                
        except Exception as e:
            self.logger.warning(f"Could not plot base raster: {e}")
    
    def _plot_clusters(self, ax, clusters: List[ClusterMetrics], config: VisualizationConfig) -> None:
        """Plot cluster polygons and centroids."""
        if not clusters:
            return
        
        # Plot cluster centroids
        x_coords = [c.centroid[0] for c in clusters]
        y_coords = [c.centroid[1] for c in clusters]
        values = [c.mean_value for c in clusters]
        areas = [c.area for c in clusters]
        
        scatter = ax.scatter(x_coords, y_coords, 
                           s=[a/10 for a in areas],
                           c=values,
                           cmap=config.palette,
                           alpha=config.overlay_alpha,
                           edgecolors='black',
                           linewidth=0.5)
        
        # Add cluster labels
        for i, cluster in enumerate(clusters):
            ax.annotate(f'{cluster.cluster_id}', 
                       cluster.centroid, 
                       ha='center', va='center',
                       fontsize=8, fontweight='bold',
                       color='white' if cluster.mean_value > np.median(values) else 'black')
        
        # Plot cluster polygons if available
        if config.draw_mesh:
            for cluster in clusters:
                if cluster.polygon:
                    try:
                        from shapely.geometry import shape
                        geom = shape(cluster.polygon)
                        x, y = geom.exterior.xy
                        ax.plot(x, y, 'k-', alpha=0.5, linewidth=1)
                    except Exception as e:
                        self.logger.warning(f"Could not plot cluster polygon: {e}")


class AnimationCreator:
    """Creates animations from multiple visualization frames."""
    
    def __init__(self, output_dir: str = "data/output/viz"):
        self.output_dir = output_dir
        self.logger = logging.getLogger(__name__)
    
    def create_comparison_animation(self, results: List[AnalysisResult], config: VisualizationConfig) -> str:
        """Create an animation comparing multiple analysis results."""
        try:
            # Create frames for each result
            frames = []
            for result in results:
                visualizer = RasterVisualizer(self.output_dir)
                overlay_path = visualizer.create_cluster_overlay(result, config)
                
                # Convert to frame
                frame = Image.open(overlay_path)
                frames.append(np.array(frame))
            
            # Create animation
            animation_path = os.path.join(self.output_dir, "comparison_animation.gif")
            with imageio.get_writer(animation_path, mode='I', fps=config.animation_fps) as writer:
                for frame in frames:
                    writer.append_data(frame)
            
            self.logger.info(f"Created comparison animation: {animation_path}")
            return animation_path
            
        except Exception as e:
            self.logger.error(f"Error creating comparison animation: {e}")
            raise


def main():
    """Test the visualizer."""
    from cluster_processor import ClusterProcessor, AnalysisResult
    from rule_parser import RuleParser
    
    # Set up logging
    logging.basicConfig(level=logging.INFO)
    
    # Parse rules and process one
    parser = RuleParser()
    rules = parser.parse_all_rules()
    
    if not rules:
        print("No rules found to visualize")
        return
    
    processor = ClusterProcessor()
    try:
        # Process first rule
        result = processor.process_rule(rules[0])
        
        # Create visualizations
        visualizer = RasterVisualizer()
        config = VisualizationConfig()
        
        overlay_path = visualizer.create_cluster_overlay(result, config)
        heatmap_path = visualizer.create_heatmap(result, config)
        difference_path = visualizer.create_difference_map(result, config)
        animation_path = visualizer.create_animation(result, config)
        
        print(f"Created visualizations:")
        print(f"  Overlay: {overlay_path}")
        print(f"  Heatmap: {heatmap_path}")
        print(f"  Difference: {difference_path}")
        print(f"  Animation: {animation_path}")
        
    except Exception as e:
        print(f"Error in visualization test: {e}")


if __name__ == "__main__":
    main()
