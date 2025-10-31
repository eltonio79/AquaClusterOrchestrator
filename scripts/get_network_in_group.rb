# Exchange script: Print the ID of the newest Model Network in a given Model Group whose name starts with a prefix
# Usage:
#   ICMExchange.exe scripts/get_network_in_group.rb <group_name> <name_prefix>

group_name = ARGV[0]
prefix = ARGV[1] || ''
if group_name.nil? || group_name.strip == ''
  puts 'Usage: get_network_in_group.rb <group_name> <name_prefix>'
  exit 1
end

begin
  # Use config if available
  db_path = nil
  cfg = File.join('scripts', 'pipeline_config.json')
  if File.exist?(cfg)
    raw = File.open(cfg, 'rb') { |f| f.read }
    raw = raw.sub(/^\xEF\xBB\xBF/, '')
    require 'json'
    j = JSON.parse(raw.force_encoding('UTF-8'))
    db_path = j['model_path'] if j && j['model_path']
  end
  db_path ||= 'models/standalone/Raster 2d Export/Raster_2d_Export.icmm'
  db = WSApplication.open(db_path)

  groups = db.model_object_collection('Model Group')
  grp = groups.find { |g| g.name == group_name }
  raise 'Group not found' if grp.nil?

  # Find child model networks matching prefix
  nets = grp.children.select { |c| c.type == 'Model Network' && c.name.start_with?(prefix) }
  raise 'No matching networks' if nets.nil? || nets.empty?

  # Pick the highest id (newest)
  best = nets.max_by { |n| n.id }
  puts best.id
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  exit 1
end


