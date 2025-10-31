#!/usr/bin/env python3
"""
Cluster Processor for 2D Raster Analysis

Main analysis engine that reads exported GeoTIFF rasters, performs clustering analysis,
and generates cluster polygons with metrics based on rule configurations.
"""

import os
import numpy as np
import rasterio
from rasterio.features import shapes
from shapely.geometry import shape, Point, Polygon
from shapely.ops import unary_union
from sklearn.cluster import KMeans, DBSCAN
from sklearn.preprocessing import StandardScaler
from scipy import ndimage
from scipy.ndimage import label
import json
import logging
from typing import Dict, List, Tuple, Any, Optional
from dataclasses import dataclass, asdict
from rule_parser import RuleConfig, AnalysisType


@dataclass
class ClusterMetrics:
    """Metrics for a single cluster."""
    cluster_id: int
    area: float
    centroid: Tuple[float, float]
    mean_value: float
    max_value: float
    min_value: float
    std_value: float
    pixel_count: int
    polygon: Dict[str, Any]  # GeoJSON-like polygon


@dataclass
class AnalysisResult:
    """Result of a clustering analysis."""
    rule_name: str
    analysis_type: str
    clusters: List[ClusterMetrics]
    raster_info: Dict[str, Any]
    processing_params: Dict[str, Any]
    statistics: Dict[str, Any]


class RasterProcessor:
    """Handles raster I/O and basic processing."""
    
    def __init__(self, data_dir: str = "data/output"):
        self.data_dir = data_dir
        self.logger = logging.getLogger(__name__)
    
    def load_raster(self, filepath: str) -> Tuple[np.ndarray, Dict[str, Any]]:
        """Load a GeoTIFF raster and return data and metadata."""
        try:
            with rasterio.open(filepath) as src:
                data = src.read(1)  # Read first band
                meta = {
                    'transform': src.transform,
                    'crs': src.crs,
                    'width': src.width,
                    'height': src.height,
                    'bounds': src.bounds,
                    'nodata': src.nodata
                }
                return data, meta
        except Exception as e:
            self.logger.error(f"Error loading raster {filepath}: {e}")
            raise
    
    def save_raster(self, data: np.ndarray, filepath: str, meta: Dict[str, Any]) -> None:
        """Save data as a GeoTIFF raster."""
        try:
            with rasterio.open(
                filepath,
                'w',
                driver='GTiff',
                height=data.shape[0],
                width=data.shape[1],
                count=1,
                dtype=data.dtype,
                crs=meta.get('crs'),
                transform=meta.get('transform')
            ) as dst:
                dst.write(data, 1)
                if meta.get('nodata') is not None:
                    dst.nodata = meta['nodata']
        except Exception as e:
            self.logger.error(f"Error saving raster {filepath}: {e}")
            raise
    
    def get_raster_files(self, sim_id: int, attributes: List[str]) -> Dict[str, str]:
        """Get paths to raster files for a simulation and attributes."""
        raster_dir = os.path.join(self.data_dir, "rasters", f"sim_{sim_id}")
        files = {}
        
        if not os.path.exists(raster_dir):
            raise FileNotFoundError(f"Raster directory not found: {raster_dir}")
        
        for attr in attributes:
            # Look for files matching the attribute pattern
            pattern = f"{attr}_*.tif"
            import glob
            matches = glob.glob(os.path.join(raster_dir, pattern))
            if matches:
                files[attr] = matches[0]  # Take the first match
            else:
                self.logger.warning(f"No raster file found for attribute {attr}")
        
        return files


class ClusterAnalyzer:
    """Performs clustering analysis on raster data."""
    
    def __init__(self):
        self.logger = logging.getLogger(__name__)
    
    def compute_delta(self, baseline_data: np.ndarray, candidate_data: np.ndarray) -> np.ndarray:
        """Compute the difference between baseline and candidate rasters."""
        # Handle nodata values
        mask = (baseline_data != -9999) & (candidate_data != -9999)
        delta = np.zeros_like(baseline_data)
        delta[mask] = candidate_data[mask] - baseline_data[mask]
        delta[~mask] = -9999  # Set nodata
        return delta
    
    def compute_hazard_index(self, depth_data: np.ndarray, speed_data: np.ndarray) -> np.ndarray:
        """Compute hazard index as depth × speed."""
        mask = (depth_data != -9999) & (speed_data != -9999)
        hazard = np.zeros_like(depth_data)
        hazard[mask] = depth_data[mask] * speed_data[mask]
        hazard[~mask] = -9999
        return hazard
    
    def apply_threshold(self, data: np.ndarray, threshold: float, nodata: float = -9999) -> np.ndarray:
        """Apply threshold to create binary mask."""
        mask = data > threshold
        result = np.zeros_like(data)
        result[mask] = 1
        result[data == nodata] = nodata
        return result
    
    def connected_components_clustering(self, binary_data: np.ndarray, min_size: int = 50) -> np.ndarray:
        """Perform connected components clustering on binary data."""
        # Remove nodata values for clustering
        mask = binary_data != -9999
        working_data = binary_data.copy()
        working_data[~mask] = 0
        
        # Perform connected components analysis
        labeled_array, num_features = label(working_data)
        
        # Remove small clusters
        for cluster_id in range(1, num_features + 1):
            cluster_mask = labeled_array == cluster_id
            cluster_size = np.sum(cluster_mask)
            if cluster_size < min_size:
                labeled_array[cluster_mask] = 0
        
        # Restore nodata values
        labeled_array[~mask] = -9999
        
        return labeled_array
    
    def kmeans_clustering(self, data: np.ndarray, k: int, max_iter: int = 300, 
                         random_seed: int = 42) -> np.ndarray:
        """Perform k-means clustering on raster data."""
        # Prepare data for clustering
        valid_mask = data != -9999
        valid_data = data[valid_mask].reshape(-1, 1)
        
        if len(valid_data) == 0:
            return np.full_like(data, -9999)
        
        # Standardize data
        scaler = StandardScaler()
        scaled_data = scaler.fit_transform(valid_data)
        
        # Perform k-means clustering
        kmeans = KMeans(n_clusters=k, max_iter=max_iter, random_state=random_seed, n_init=10)
        cluster_labels = kmeans.fit_predict(scaled_data)
        
        # Create result array
        result = np.full_like(data, -9999)
        result[valid_mask] = cluster_labels
        
        return result
    
    def extract_cluster_polygons(self, cluster_data: np.ndarray, original_data: np.ndarray, 
                                meta: Dict[str, Any]) -> List[ClusterMetrics]:
        """Extract cluster polygons and compute metrics."""
        clusters = []
        
        # Get unique cluster IDs (excluding nodata)
        unique_clusters = np.unique(cluster_data[cluster_data != -9999])
        
        for cluster_id in unique_clusters:
            if cluster_id == 0:  # Skip background
                continue
                
            # Create binary mask for this cluster
            cluster_mask = cluster_data == cluster_id
            
            # Get values within this cluster
            cluster_values = original_data[cluster_mask]
            
            if len(cluster_values) == 0:
                continue
            
            # Compute basic metrics
            area = np.sum(cluster_mask) * abs(meta['transform'][0]) * abs(meta['transform'][4])
            pixel_count = np.sum(cluster_mask)
            
            # Compute centroid
            y_indices, x_indices = np.where(cluster_mask)
            centroid_y = np.mean(y_indices)
            centroid_x = np.mean(x_indices)
            
            # Transform to real coordinates
            transform = meta['transform']
            centroid_lon = transform.c + centroid_x * transform.a + centroid_y * transform.b
            centroid_lat = transform.f + centroid_x * transform.d + centroid_y * transform.e
            
            # Compute value statistics
            mean_value = np.mean(cluster_values)
            max_value = np.max(cluster_values)
            min_value = np.min(cluster_values)
            std_value = np.std(cluster_values)
            
            # Extract polygon
            try:
                # Use rasterio to extract shapes
                cluster_data_single = (cluster_data == cluster_id).astype(np.uint8)
                shapes_result = list(shapes(cluster_data_single, mask=cluster_mask, transform=transform))
                
                if shapes_result:
                    # Take the largest polygon
                    polygons = [shape(geom) for geom, value in shapes_result if value == 1]
                    if polygons:
                        # Simplify and get the largest polygon
                        largest_polygon = max(polygons, key=lambda p: p.area)
                        
                        # Convert to GeoJSON format
                        polygon_geojson = {
                            "type": "Polygon",
                            "coordinates": [list(largest_polygon.exterior.coords)]
                        }
                    else:
                        polygon_geojson = None
                else:
                    polygon_geojson = None
                    
            except Exception as e:
                self.logger.warning(f"Error extracting polygon for cluster {cluster_id}: {e}")
                polygon_geojson = None
            
            cluster_metrics = ClusterMetrics(
                cluster_id=int(cluster_id),
                area=float(area),
                centroid=(float(centroid_lon), float(centroid_lat)),
                mean_value=float(mean_value),
                max_value=float(max_value),
                min_value=float(min_value),
                std_value=float(std_value),
                pixel_count=int(pixel_count),
                polygon=polygon_geojson
            )
            
            clusters.append(cluster_metrics)
        
        return clusters


class ClusterProcessor:
    """Main processor that orchestrates the clustering analysis."""
    
    def __init__(self, data_dir: str = "data/output"):
        self.data_dir = data_dir
        self.raster_processor = RasterProcessor(data_dir)
        self.cluster_analyzer = ClusterAnalyzer()
        self.logger = logging.getLogger(__name__)
    
    def process_rule(self, rule_config: RuleConfig) -> AnalysisResult:
        """Process a single rule configuration."""
        self.logger.info(f"Processing rule: {rule_config.name} ({rule_config.analysis_type.value})")
        
        try:
            # Load raster data
            raster_files = self._load_rasters_for_rule(rule_config)
            
            # Perform analysis based on type
            if rule_config.analysis_type == AnalysisType.COMPARISON:
                result = self._process_comparison(rule_config, raster_files)
            elif rule_config.analysis_type == AnalysisType.THRESHOLD:
                result = self._process_threshold(rule_config, raster_files)
            elif rule_config.analysis_type == AnalysisType.HAZARD:
                result = self._process_hazard(rule_config, raster_files)
            elif rule_config.analysis_type == AnalysisType.VOLUME:
                result = self._process_volume(rule_config, raster_files)
            elif rule_config.analysis_type == AnalysisType.RANKING:
                result = self._process_ranking(rule_config, raster_files)
            else:
                raise ValueError(f"Unknown analysis type: {rule_config.analysis_type}")
            
            # Compute overall statistics
            result.statistics = self._compute_statistics(result.clusters)
            
            self.logger.info(f"Processed {len(result.clusters)} clusters for rule {rule_config.name}")
            return result
            
        except Exception as e:
            self.logger.error(f"Error processing rule {rule_config.name}: {e}")
            raise
    
    def _load_rasters_for_rule(self, rule_config: RuleConfig) -> Dict[str, Tuple[np.ndarray, Dict[str, Any]]]:
        """Load raster data for a rule configuration."""
        raster_files = {}
        
        # Determine which simulations to load
        if rule_config.analysis_type == AnalysisType.COMPARISON:
            if rule_config.baseline_id and rule_config.candidate_id:
                sim_ids = [rule_config.baseline_id, rule_config.candidate_id]
            else:
                # Default to sim 1 and 2
                sim_ids = [1, 2]
        else:
            # Use baseline_id or default to sim 1
            sim_id = rule_config.baseline_id or 1
            sim_ids = [sim_id]
        
        # Load rasters for each simulation
        for sim_id in sim_ids:
            try:
                files = self.raster_processor.get_raster_files(sim_id, rule_config.attributes)
                for attr, filepath in files.items():
                    data, meta = self.raster_processor.load_raster(filepath)
                    key = f"sim_{sim_id}_{attr}"
                    raster_files[key] = (data, meta)
            except FileNotFoundError as e:
                self.logger.warning(f"Could not load rasters for sim {sim_id}: {e}")
        
        return raster_files
    
    def _process_comparison(self, rule_config: RuleConfig, raster_files: Dict[str, Tuple[np.ndarray, Dict[str, Any]]]) -> AnalysisResult:
        """Process comparison analysis (baseline vs candidate)."""
        # Find baseline and candidate data
        baseline_data = None
        candidate_data = None
        meta = None
        
        for key, (data, raster_meta) in raster_files.items():
            if "sim_1_" in key or f"sim_{rule_config.baseline_id}_" in key:
                baseline_data = data
                meta = raster_meta
            elif "sim_2_" in key or f"sim_{rule_config.candidate_id}_" in key:
                candidate_data = data
        
        if baseline_data is None or candidate_data is None:
            raise ValueError("Could not find both baseline and candidate data")
        
        # Compute delta
        delta = self.cluster_analyzer.compute_delta(baseline_data, candidate_data)
        
        # Apply threshold if specified
        threshold = rule_config.thresholds.get('change_threshold', 0.01)
        binary_delta = self.cluster_analyzer.apply_threshold(delta, threshold)
        
        # Perform clustering
        clustering_params = rule_config.clustering
        if clustering_params.get('method') == 'connected_components':
            cluster_data = self.cluster_analyzer.connected_components_clustering(
                binary_delta, clustering_params.get('min_size', 50)
            )
        else:
            # Default to k-means
            k = clustering_params.get('k', 5)
            cluster_data = self.cluster_analyzer.kmeans_clustering(delta, k)
        
        # Extract clusters
        clusters = self.cluster_analyzer.extract_cluster_polygons(cluster_data, delta, meta)
        
        return AnalysisResult(
            rule_name=rule_config.name,
            analysis_type="comparison",
            clusters=clusters,
            raster_info=meta,
            processing_params=rule_config.clustering,
            statistics={}
        )
    
    def _process_threshold(self, rule_config: RuleConfig, raster_files: Dict[str, Tuple[np.ndarray, Dict[str, Any]]]) -> AnalysisResult:
        """Process threshold analysis."""
        # Get the main attribute data
        main_data = None
        meta = None
        
        for key, (data, raster_meta) in raster_files.items():
            if rule_config.attributes[0].lower() in key.lower():
                main_data = data
                meta = raster_meta
                break
        
        if main_data is None:
            raise ValueError("Could not find data for threshold analysis")
        
        # Apply threshold
        threshold = rule_config.thresholds.get('depth_threshold', 0.5)
        binary_data = self.cluster_analyzer.apply_threshold(main_data, threshold)
        
        # Perform clustering
        clustering_params = rule_config.clustering
        if clustering_params.get('method') == 'connected_components':
            cluster_data = self.cluster_analyzer.connected_components_clustering(
                binary_data, clustering_params.get('min_size', 50)
            )
        else:
            # Default to connected components for threshold analysis
            cluster_data = self.cluster_analyzer.connected_components_clustering(binary_data, 50)
        
        # Extract clusters
        clusters = self.cluster_analyzer.extract_cluster_polygons(cluster_data, main_data, meta)
        
        return AnalysisResult(
            rule_name=rule_config.name,
            analysis_type="threshold",
            clusters=clusters,
            raster_info=meta,
            processing_params=rule_config.clustering,
            statistics={}
        )
    
    def _process_hazard(self, rule_config: RuleConfig, raster_files: Dict[str, Tuple[np.ndarray, Dict[str, Any]]]) -> AnalysisResult:
        """Process hazard analysis (depth × speed)."""
        # Get depth and speed data
        depth_data = None
        speed_data = None
        meta = None
        
        for key, (data, raster_meta) in raster_files.items():
            if 'depth' in key.lower():
                depth_data = data
                meta = raster_meta
            elif 'speed' in key.lower():
                speed_data = data
        
        if depth_data is None or speed_data is None:
            raise ValueError("Could not find both depth and speed data for hazard analysis")
        
        # Compute hazard index
        hazard_data = self.cluster_analyzer.compute_hazard_index(depth_data, speed_data)
        
        # Apply threshold
        threshold = rule_config.thresholds.get('hazard_threshold', 1.0)
        binary_hazard = self.cluster_analyzer.apply_threshold(hazard_data, threshold)
        
        # Perform clustering
        clustering_params = rule_config.clustering
        if clustering_params.get('method') == 'kmeans':
            k = clustering_params.get('k', 4)
            cluster_data = self.cluster_analyzer.kmeans_clustering(hazard_data, k)
        else:
            cluster_data = self.cluster_analyzer.connected_components_clustering(binary_hazard, 50)
        
        # Extract clusters
        clusters = self.cluster_analyzer.extract_cluster_polygons(cluster_data, hazard_data, meta)
        
        return AnalysisResult(
            rule_name=rule_config.name,
            analysis_type="hazard",
            clusters=clusters,
            raster_info=meta,
            processing_params=rule_config.clustering,
            statistics={}
        )
    
    def _process_volume(self, rule_config: RuleConfig, raster_files: Dict[str, Tuple[np.ndarray, Dict[str, Any]]]) -> AnalysisResult:
        """Process volume analysis."""
        # Similar to threshold but focus on volume calculations
        return self._process_threshold(rule_config, raster_files)
    
    def _process_ranking(self, rule_config: RuleConfig, raster_files: Dict[str, Tuple[np.ndarray, Dict[str, Any]]]) -> AnalysisResult:
        """Process ranking analysis."""
        # Similar to comparison but rank clusters by metrics
        result = self._process_comparison(rule_config, raster_files)
        
        # Sort clusters by max_value (worst increase)
        result.clusters.sort(key=lambda c: c.max_value, reverse=True)
        
        return result
    
    def _compute_statistics(self, clusters: List[ClusterMetrics]) -> Dict[str, Any]:
        """Compute overall statistics for clusters."""
        if not clusters:
            return {}
        
        areas = [c.area for c in clusters]
        mean_values = [c.mean_value for c in clusters]
        max_values = [c.max_value for c in clusters]
        
        return {
            'total_clusters': len(clusters),
            'total_area': sum(areas),
            'mean_cluster_area': np.mean(areas),
            'std_cluster_area': np.std(areas),
            'mean_cluster_value': np.mean(mean_values),
            'std_cluster_value': np.std(mean_values),
            'max_cluster_value': max(max_values),
            'min_cluster_value': min(max_values)
        }


def main():
    """Test the cluster processor."""
    from rule_parser import RuleParser
    
    # Set up logging
    logging.basicConfig(level=logging.INFO)
    
    # Parse rules
    parser = RuleParser()
    rules = parser.parse_all_rules()
    
    if not rules:
        print("No rules found to process")
        return
    
    # Process first rule as test
    processor = ClusterProcessor()
    try:
        result = processor.process_rule(rules[0])
        print(f"Processed rule: {result.rule_name}")
        print(f"Found {len(result.clusters)} clusters")
        print(f"Statistics: {result.statistics}")
    except Exception as e:
        print(f"Error processing rule: {e}")


if __name__ == "__main__":
    main()
