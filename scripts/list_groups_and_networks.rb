require 'json'

def read_config_model_path
  begin
    base = File.dirname(__FILE__)
    cfg_path = File.join(base, 'pipeline_config.json')
    if File.exist?(cfg_path)
      raw = File.open(cfg_path, 'rb') { |f| f.read }
      raw = raw.sub(/^\xEF\xBB\xBF/, '')
      cfg = JSON.parse(raw.force_encoding('UTF-8'))
      return cfg['model_path'] if cfg && cfg['model_path'] && !cfg['model_path'].empty?
    end
  rescue
  end
  nil
end

begin
  model_path = read_config_model_path
  if model_path.nil? || model_path.empty?
    # Rebuild from ARGV: skip any leading tokens until joined path exists
    acc = []
    ARGV.each do |t|
      acc << t
      candidate = acc.join(' ')
      if File.exist?(candidate)
        model_path = candidate
        break
      end
    end
  end
  if model_path.nil? || model_path.empty?
    model_path = 'C:/Users/brodowm/OneDrive - Autodesk/Documents/InfoWorks ICM/Standalone Databases/Raster 2d Export/Raster_2d_Export.icmm'
  end
  raise 'Provide model path or set scripts/pipeline_config.json' if model_path.nil? || model_path.empty?
  db = WSApplication.open(model_path)

  groups = db.model_object_collection('Model Group')
  len = groups ? groups.length : 0
  puts "Root Model Groups (#{len})"
  i = 0
  while i < len
    g = groups[i]
    puts "> #{g.name} (#{g.id}) - Model group"
    # children networks
    begin
      kids = g.children || []
      kids.each do |c|
        if c.type == 'Model Network'
          puts "  > #{g.name}>#{c.name} (#{c.id}) - Model network"
        end
      end
    rescue
    end
    i += 1
  end
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  exit 1
end


