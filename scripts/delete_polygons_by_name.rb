require 'json'

def read_config_model_path
  begin
    base = File.dirname(__FILE__)
    cfg_path = File.join(base, 'data', 'input', 'config', 'pipeline_config.json')
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

def find_group(db, name)
  begin
    g = db.model_object ">MODG~#{name}"
    return g if g
  rescue
  end
  groups = db.model_object_collection('Model Group')
  return nil if groups.nil?
  i = 0
  while i < groups.length
    g = groups[i]
    return g if g && g.name == name
    i += 1
  end
  nil
end

def find_network_in_group(group, network_name)
  kids = group.children || []
  kids.each do |c|
    return c if c.type == 'Model Network' && c.name.downcase == network_name.downcase
  end
  nil
end

begin
  toks = ARGV.dup
  # Some environments inject a leading 'ADSK' token
  toks.shift if toks[0] == 'ADSK'
  if toks.length < 2
    puts 'Usage: delete_polygons_by_name.rb <group_name> <network_name>'
    exit 1
  end
  group_name = toks.shift
  network_name = toks.shift

  model_path = read_config_model_path
  if model_path.nil? || model_path.empty?
    model_path = 'C:/Users/brodowm/OneDrive - Autodesk/Documents/InfoWorks ICM/Standalone Databases/Raster 2d Export/Raster_2d_Export.icmm'
  end
  db = WSApplication.open(model_path)

  grp = find_group(db, group_name)
  raise "Group not found: #{group_name}" if grp.nil?
  net_mo = find_network_in_group(grp, network_name)
  raise "Network not found in group '#{group_name}': #{network_name}" if net_mo.nil?

  net = net_mo.open
  net.transaction_begin
  begin
    ros = net.row_objects('hw_polygon')
    count = 0
    ros.each do |ro|
      ro.delete
      count += 1
    end
    net.transaction_commit
    puts "Deleted polygons: #{count}"
  rescue => e
    net.transaction_rollback
    raise e
  ensure
    net.close if net
  end
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  exit 1
end


