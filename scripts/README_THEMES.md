# Cluster Polygon Themes and Layers

## Overview
This document explains how to configure polygon display settings for cluster analysis results in InfoWorks ICM.

## Background
GeoPlan Properties (including layer visibility and themes) are stored in `.iws` files, which are binary XML configuration files managed by ICM internally. The Ruby Exchange API does not provide methods to create or modify GeoPlan themes or layer configurations programmatically.

## Recommended Approach: Use Attributes

Instead of creating a custom layer (which is not supported via API), we recommend:

1. **Use the existing `hw_polygon` layer** - All cluster polygons are imported into this standard ICM layer
2. **Use attributes to distinguish clusters** - Each polygon has the following attributes:
   - `polygon_id` - Unique identifier
   - `cluster_id` - Cluster identifier
   - `rule` - Name of the rule that generated this cluster
   - `score` - Mean/max value within the cluster
   - `unit` - Unit of measurement
   - `value` - Value in the unit
   - `parent_polygon_id` - If part of a parent polygon (null otherwise)
   - `parent_cluster_id` - If part of a parent cluster (null otherwise)

3. **Create a theme based on attributes** - In the ICM UI:
   - Open the network with clusters
   - Go to GeoPlan Properties
   - Create a new theme for `hw_polygon` layer
   - Theme by `rule` or `score` attribute
   - Save the properties to preserve your theme

## Manual Theme Setup (UI)

### Using GeoPlan Properties

1. Open the network with imported clusters
2. Right-click on GeoPlan and select "Properties" (or press `P`)
3. In the Theme Order tab, locate `hw_polygon`
4. With `hw_polygon` selected, click "Add Theme" or create a new subtheme
5. Configure the theme:
   - **Theme by**: `rule` (to color by analysis type) or `score` (to color by value)
   - **Range type**: As appropriate for your data
   - **Colors**: Choose a palette
6. Click "OK" to apply
7. Optional: Save the GeoPlan Properties (`File > Save GeoPlan Properties`)

### Applying Saved Properties

If you've exported GeoPlan Properties to an `.iws` file, you can load them:

1. Open the network
2. Go to `File > Load GeoPlan Properties`
3. Select your `.iws` file
4. The theme will be applied

## Examples

### Theme by Rule Name
Create a theme that colors polygons by their `rule` attribute:
- **Field**: `rule` (string field)
- **Range**: Use unique values
- **Colors**: Assign different colors for each rule (e.g., depth_change_analysis = blue, hazard_about_one = red)

### Theme by Score
Create a graduated theme based on `score` values:
- **Field**: `score` (double/numeric field)  
- **Range**: Continuous or custom breaks
- **Colors**: Use a gradient palette (e.g., green to red)

## Alternative: Use Layer Groups

If you want to manage multiple polygon types separately:

1. Use a naming convention in `polygon_id` to distinguish types
2. Create selection filters based on the naming convention
3. The `hw_polygon` layer can display all polygons with different visual styles
4. Use the layer visibility toggle to show/hide polygon sets

## Notes

- The `hw_polygon` layer is always visible by default in ICM
- Themes can be saved with the network or exported as `.iws` files
- Themes are applied per network, not globally
- Polygons are stored as flat coordinate arrays in `boundary_array` field

## See Also

- `GeoPlanProp_X.iws` - Example GeoPlan Properties export
- `scripts/create_polygons_from_geojson.rb` - Polygon import script
- ICM User Guide section on GeoPlan Properties and Themes


