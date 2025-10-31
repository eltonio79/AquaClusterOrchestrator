# Exchange script: Copy a Model Network to a destination Model Group (create if missing),
# keeping base name with incremented postfix (_v001, _v002, ...).
# Usage:
#   ICMExchange.exe scripts/copy_network_to_group.rb <source_network_id> [dest_group_name]

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
  rescue
  end
  nil
end

def ensure_group(db, name)
  # Try find existing root model group by name; if not, create
  begin
    # scripting path short-hand may be available, fall back to scan
    groups = db.model_object_collection('Model Group')
    grp = groups.find { |g| g.name == name }
    return grp unless grp.nil?
  rescue
  end
  return db.new_model_object('Model Group', name)
end

def unique_name_in_group(group, base)
  # Try base, then base_v001 ... base_v999
  existing = []
  begin
    children = group.children
    existing = children.map { |c| c.name } if children
  rescue
    # If children not available, we will attempt rename and catch
  end
  return base unless existing.include?(base)
  i = 1
  while i < 1000
    candidate = format('%s_v%03d', base, i)
    return candidate unless existing.include?(candidate)
    i += 1
  end
  format('%s_v%s', base, Time.now.strftime('%H%M%S'))
end

begin
  # Flexible args: either (<id> [group]) or (<model_path> <id> [group])
  tokens = ARGV.dup
  src_id = nil
  dest_group_name = 'Clusters'

  # Try path-first form
  acc = []
  model_path = nil
  tokens.each_with_index do |t, i|
    acc << t
    candidate = acc.join(' ')
    if File.exist?(candidate)
      model_path = candidate
      tokens = tokens.drop(i+1)
      break
    end
  end

  if model_path.nil?
    # No path found in args; expect id first
    raise 'Usage: copy_network_to_group.rb <source_network_id> [dest_group_name] or <model_path> <source_network_id> [dest_group_name]' if tokens.empty?
    src_id = tokens.shift.to_i
  else
    raise 'Missing network id' if tokens.empty?
    src_id = tokens.shift.to_i
  end
  dest_group_name = tokens.shift || 'Clusters'

  model_path ||= read_config_model_path || 'models/standalone/Raster 2d Export/Raster_2d_Export.icmm'
  db = WSApplication.open(model_path)

  src_net = db.model_object_from_type_and_id('Model Network', src_id)
  raise "Source Model Network id=#{src_id} not found" if src_net.nil?

  dest_group = ensure_group(db, dest_group_name)
  raise 'Could not create/find destination Model Group' if dest_group.nil?

  # Copy into destination group
  copied = dest_group.copy_here(src_net, false, true)
  raise 'Copy failed' if copied.nil?

  # Rename to unique
  base = src_net.name
  new_name = unique_name_in_group(dest_group, base)
  begin
    copied.name = new_name
  rescue => e
    # If rename fails due to conflict, append timestamp
    copied.name = format('%s_v%s', base, Time.now.strftime('%H%M%S'))
  end

  puts "Copied network '#{base}' -> group '#{dest_group_name}' as '#{copied.name}' (ID #{copied.id})"
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end


