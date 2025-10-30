# Exchange script: Create hw_polygon features from a GeoJSON file (no ODIC)
# Usage:
#   ICMExchange.exe scripts/create_polygons_from_geojson.rb <geojson_path> [model_path] [table] [id_field]
# Defaults:
#   table: hw_polygon
#   id_field: cluster_id

require 'json'

def read_config_model_path
  begin
    cfg_path = File.join('scripts', 'pipeline_config.json')
    if File.exist?(cfg_path)
      raw = File.open(cfg_path, 'rb') { |f| f.read }
      raw = raw.sub(/^\xEF\xBB\xBF/, '')
      cfg = JSON.parse(raw.force_encoding('UTF-8'))
      return cfg['model_path'] if cfg && cfg['model_path'] && !cfg['model_path'].empty?
    end
  rescue => e
    puts "Warning: Could not read pipeline_config.json: #{e.message}"
  end
  nil
end

if ARGV.length < 1
  puts "Usage: create_polygons_from_geojson.rb <geojson_path> [model_path] [table] [id_field]"
  puts "Example: create_polygons_from_geojson.rb data/output/clusters/depth_change_analysis/clusters.geojson"
  exit 1
end

# Robust argument parsing to handle spaces passed via Exchange
args = ARGV.dup
# If Exchange prepends script path, it won't affect here; we just need a valid existing path reconstructed from args
geojson_path = nil
1.upto(args.length) do |i|
  candidate = args[0, i].join(' ')
  if File.exist?(candidate)
    geojson_path = candidate
    args = args[i..-1] || []
    break
  end
end

# Fallback to first token if not found
geojson_path ||= ARGV[0]

model_path   = (args[0] && args[0] != '') ? args[0] : (read_config_model_path || 'models/standalone/Medium 2D/Ruby_Hackathon_Medium_2D_Model.icmm')
table_name   = (args[1] && args[1] != '') ? args[1] : 'hw_polygon'
id_field     = (args[2] && args[2] != '') ? args[2] : 'cluster_id'

unless File.exist?(geojson_path)
  # Fallback: discover latest clusters.geojson (prefer hazard_about_one)
  base = File.join('data','output','results')
  candidates = Dir.glob(File.join(base, '**', '*clusters.geojson'))
  if candidates && !candidates.empty?
    preferred = candidates.select { |p| p.downcase.include?('hazard_about_one') }
    geojson_path = (preferred.first || candidates.sort_by { |p| File.mtime(p) }.last)
    puts "Auto-selected GeoJSON: #{geojson_path}"
  else
    puts "ERROR: GeoJSON not found: #{geojson_path}"
    exit 1
  end
end

begin
  data = JSON.parse(File.read(geojson_path))
rescue => e
  puts "ERROR: Failed to parse GeoJSON: #{e.class} — #{e.message}"
  exit 1
end

features = data['features'] || []
if features.empty?
  puts "No features found in GeoJSON. Nothing to import."
  exit 0
end

begin
  db = WSApplication.open(model_path)
  puts "Opened database: #{model_path}"

  # Prefer Clusters group network, fallback to first available
  network_mo = nil
  
  # Try Clusters group
  begin
    cfg = nil
    cfg_path = File.join('scripts', 'pipeline_config.json')
    if File.exist?(cfg_path)
      raw = File.open(cfg_path, 'rb') { |f| f.read }
      raw = raw.sub(/^\xEF\xBB\xBF/, '')
      cfg = JSON.parse(raw.force_encoding('UTF-8'))
    end
    
    groups = db.model_object_collection('Model Group')
    if groups && cfg
      clusters_grp = nil
      len = groups.length
      i = 0
      while i < len
        g = groups[i]
        if g && g.name == (cfg['clusters_group_name'] || 'Clusters')
          clusters_grp = g
          break
        end
        i += 1
      end
      
      if clusters_grp
        children = clusters_grp.children || []
        children.each do |c|
          if c.type == 'Model Network'
            network_mo = c
            break
          end
        end
      end
    end
  rescue => e
    puts "Note: Could not find Clusters group network: #{e.message}"
  end
  
  # Fallback to first model network
  if network_mo.nil?
    begin
      col = db.model_object_collection('Model Network')
      network_mo = col.first if col && col.length > 0
    rescue
    end
  end
  raise 'No model network found in database' if network_mo.nil?

  net = network_mo.open
  puts "Network opened: #{network_mo.name}"

  created = 0
  skipped = 0

  net.transaction_begin
  begin
    features.each_with_index do |f, idx|
      geom = f['geometry'] || {}
      props = f['properties'] || {}
      gtype = geom['type']
      coords = geom['coordinates']
      next if coords.nil?

      # Normalize to array of polygons (outer rings only)
      rings = []
      if gtype == 'Polygon'
        # coords = [ [ [x,y], [x,y], ... ] , [hole...], ...]
        outer = coords[0] || []
        rings << outer
      elsif gtype == 'MultiPolygon'
        # coords = [ [ [ [x,y],... ] , [hole...] ], ... ]
        coords.each do |poly|
          outer = (poly && poly[0]) || []
          rings << outer
        end
      else
        skipped += 1
        next
      end

      rings.each_with_index do |ring, ridx|
        flat = []
        ring.each do |pt|
          next unless pt && pt.length >= 2
          x = pt[0].to_f
          y = pt[1].to_f
          flat << x
          flat << y
        end
        # Require at least 3 vertices
        if flat.length < 6
          skipped += 1
          next
        end

        ro = net.new_row_object(table_name)
        # Extended attribute set from GeoJSON properties
        base_id = props[id_field] || props['id'] || ("cluster_" + (idx+1).to_s)
        pid = ridx == 0 ? base_id.to_s : (base_id.to_s + "_part" + ridx.to_s)
        if ro.respond_to?(:[]=)
          ro['polygon_id'] = pid
          ro['cluster_id'] = props['cluster_id'].to_s unless props['cluster_id'].nil?
          ro['rule'] = props['rule_name'].to_s unless props['rule_name'].nil?
          score_val = props['mean_value'] || props['score'] || props['max_value']
          ro['score'] = score_val.to_f unless score_val.nil?
          ro['unit'] = props['unit'].to_s unless props['unit'].nil?
          ro['value'] = props['mean_value'].to_f unless props['mean_value'].nil?
          ro['parent_polygon_id'] = props['parent_polygon_id'].to_s unless props['parent_polygon_id'].nil?
          ro['parent_cluster_id'] = props['parent_cluster_id'].to_s unless props['parent_cluster_id'].nil?
        end
        # geometry
        if ro.respond_to?(:boundary_array)
          # boundary_array is an array of doubles [x1,y1,x2,y2,...]
          # Some APIs allow push with << ; here assign outright if supported
          begin
            ro['boundary_array'] = flat
          rescue
            # fallback to appending pairs
            flat.each_slice(2) { |xy| ro['boundary_array'] << xy }
          end
        end
        ro.write
        created += 1
      end
    end

    net.transaction_commit
    puts "Created polygons: #{created}; skipped: #{skipped}"
  rescue => e
    net.transaction_rollback
    puts "ERROR: Import failed: #{e.class} — #{e.message}"
    puts e.backtrace.join("\n")
    exit 1
  ensure
    net.close if net
  end

rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end


