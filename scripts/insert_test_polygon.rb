# Exchange script: Insert a test polygon directly into hw_polygon
# Usage:
#   ICMExchange.exe scripts/insert_test_polygon.rb [polygon_id] [model_path]

require 'json'

def read_config_model_path
  begin
    cfg_path = File.join('scripts', 'pipeline_config.json')
    if File.exist?(cfg_path)
      # Read bytes, strip UTF-8 BOM if present, then force UTF-8
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

# Robust argument handling (Exchange may pass script path unexpectedly and split on spaces)
polygon_id = 'cluster_test_1'
model_path = nil
network_id = nil

tokens = ARGV.dup
tokens.shift while tokens[0] && tokens[0].downcase.end_with?('.rb')

if tokens[0] && tokens[0] != ''
  polygon_id = tokens.shift
end

# Reconstruct model_path from remaining tokens until a valid file exists, otherwise fallback to config
acc = []
tokens.each do |t|
  acc << t
  candidate = acc.join(' ')
  if File.exist?(candidate)
    model_path = candidate
    tokens = tokens.drop(acc.length)
    break
  end
end
model_path ||= read_config_model_path || 'models/standalone/Raster 2d Export/Raster_2d_Export.icmm'

network_id = (tokens[0] && tokens[0] != '') ? tokens[0].to_i : nil

begin
  db = WSApplication.open(model_path)

  # Open specific Model Network if ID provided
  network_mo = nil
  if network_id
    begin
      network_mo = db.model_object_from_type_and_id('Model Network', network_id)
    rescue
      network_mo = nil
    end
  end
  # Otherwise find any openable network model object
  if network_mo.nil?
    %w[Model\ Network Geometry Collection\ Network River\ Network].each do |t|
      begin
        col = db.model_object_collection(t.gsub('\\',''))
        if col && col.length > 0
          mo = col.first
          if mo.respond_to?(:open)
            network_mo = mo
            break
          end
        end
      rescue
      end
    end
  end
  raise 'No model network found' if network_mo.nil?

  net = network_mo.open

  # Rectangle within known raster extents (meters). Adjust if needed for your model CRS.
  # Extents seen in raster export: X ~ 151124..152728, Y ~ 209487..211189
  x0 = 151300.0; y0 = 209700.0
  x1 = 151400.0; y1 = 209800.0
  coords = [
    x0, y0,
    x1, y0,
    x1, y1,
    x0, y1
  ]

  net.transaction_begin
  begin
    ro = net.new_row_object('hw_polygon')
    ro['polygon_id'] = polygon_id
    begin
      ro['boundary_array'] = coords
    rescue
      coords.each_slice(2) { |xy| ro['boundary_array'] << xy }
    end
    ro.write
    net.transaction_commit
    puts "Inserted polygon #{polygon_id} with #{coords.length/2} vertices."
  rescue => e
    net.transaction_rollback
    raise e
  ensure
    net.close if net
  end
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end


