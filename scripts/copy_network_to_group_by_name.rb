# Exchange script: Copy a Model Network found by Group Name and Network Name into a destination Model Group.
# Usage:
#   ICMExchange.exe scripts/copy_network_to_group_by_name.rb <group_name> <network_name> [dest_group_name]

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

def ensure_group(db, name)
  groups = db.model_object_collection('Model Group')
  if groups
    begin
      len = groups.length
      i = 0
      while i < len
        g = groups[i]
        return g if g && g.name == name
        i += 1
      end
    rescue
    end
  end
  db.new_model_object('Model Group', name)
end

def find_group(db, name)
  # Try direct path syntax first
  begin
    g = db.model_object ">MODG~#{name}"
    return g if g
  rescue
  end
  # Fallback: iterate collection
  begin
    groups = db.model_object_collection('Model Group')
    return nil if groups.nil?
    count = groups.length
    i = 0
    while i < count
      g = groups[i]
      return g if g && g.name == name
      i += 1
    end
  rescue
  end
  nil
end

def unique_name_in_group(group, base)
  names = []
  begin
    children = group.children
    names = children.map { |c| c.name } if children
  rescue
  end
  return base unless names.include?(base)
  i = 1
  while i < 1000
    cand = format('%s_v%03d', base, i)
    return cand unless names.include?(cand)
    i += 1
  end
  format('%s_v%s', base, Time.now.strftime('%H%M%S'))
end

begin
  if ARGV.length < 2
    puts 'Usage: copy_network_to_group_by_name.rb <group_name> <network_name> [dest_group_name]'
    exit 1
  end
  # Rebuild names from tail to avoid Exchange injecting leading tokens (e.g., "ADSK")
  toks = ARGV.dup
  dest_group_name = 'Clusters'
  if toks.length >= 3
    dest_group_name = toks.pop
  end
  network_name = toks.pop
  group_name = toks.join(' ')
  group_name = group_name.sub(/^ADSK\s+/,'') if group_name.start_with?('ADSK ')

  model_path = read_config_model_path || 'models/standalone/Raster 2d Export/Raster_2d_Export.icmm'
  db = WSApplication.open(model_path)

  src_group = find_group(db, group_name)
  raise "Source group not found: #{group_name}" if src_group.nil?

  src_net = nil
  children = src_group.children || []
  children.each do |c|
    if c.type == 'Model Network' && c.name.downcase == network_name.downcase
      src_net = c
      break
    end
  end
  raise "Network not found in group '#{group_name}': #{network_name}" if src_net.nil?

  dest_group = ensure_group(db, dest_group_name)
  raise 'Could not create/find destination group' if dest_group.nil?

  copied = dest_group.copy_here(src_net, false, true)
  raise 'Copy failed' if copied.nil?

  new_name = unique_name_in_group(dest_group, src_net.name)
  begin
    copied.name = new_name
  rescue
    copied.name = format('%s_v%s', src_net.name, Time.now.strftime('%H%M%S'))
  end

  puts "Copied '#{group_name}>#{network_name}' -> '#{dest_group_name}>#{copied.name}' (ID #{copied.id})"
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end


