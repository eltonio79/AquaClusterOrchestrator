# Exchange script: Delete all polygons (hw_polygon) from the target network
# Usage:
#   ICMExchange.exe scripts/delete_polygons.rb

require 'json'

def read_config_model_path
  begin
    cfg_path = File.join('data', 'input', 'config', 'pipeline_config.json')
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

begin
  # Parse args: [model_path] [network_id]
  model_path = nil
  network_id = nil
  acc = []
  ARGV.each do |t|
    acc << t
    candidate = acc.join(' ')
    if File.exist?(candidate)
      model_path = candidate
      break
    end
  end
  tail = ARGV.drop(acc.length)
  network_id = (tail[0] && tail[0] != '') ? tail[0].to_i : nil
  model_path ||= read_config_model_path || 'models/standalone/Raster 2d Export/Raster_2d_Export.icmm'
  db = WSApplication.open(model_path)

  # Find a specific or first openable network
  network_mo = nil
  if network_id
    begin
      network_mo = db.model_object_from_type_and_id('Model Network', network_id)
    rescue
      network_mo = nil
    end
  end
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
  removed = 0
  net.transaction_begin
  begin
    net.row_objects('hw_polygon').each do |ro|
      ro.delete
      removed += 1
    end
    net.transaction_commit
    puts "Deleted polygons: #{removed}"
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


