# Exchange script: Create or copy a Run for the copied network in Clusters group
# Usage:
#   ICMExchange.exe scripts/create_or_copy_run_by_name.rb <source_run_group_name> <source_run_name> [dest_run_group_name] [dest_run_name]

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

def find_run_in_group(group, run_name)
  kids = group.children || []
  kids.each do |c|
    return c if c.type == 'Run' && c.name.downcase == run_name.downcase
  end
  nil
end

def copy_run_to_group(source_run, dest_group, dest_network, new_name)
  events_hash = {}
  scenarios_hash = {}
  source_run.children.each do |c|
    this_event = c['Rainfall Event']
    events_hash[this_event] = true if this_event && !this_event.empty?
    scenario = c['NetworkScenarioUID']
    scenarios_hash[scenario] = true if scenario && !scenario.empty?
  end
  events = events_hash.empty? ? nil : events_hash.keys
  scenarios = scenarios_hash.empty? ? nil : scenarios_hash.keys.map { |k| k.nil? ? 'Base' : k }
  
  params = {}
  begin
    fields = WSApplication.open_db.read_write_run_fields
    fields.each do |p|
      params[p] = source_run[p] if source_run.respond_to?(p)
    end
  rescue
    params['ExitOnFailedInit'] = true
  end
  network = source_run['Model Network']
  commit_id = source_run['Model Network Commit ID']
  
  dest_group.new_run(new_name, dest_network, commit_id, events, scenarios, params)
end

begin
  if ARGV.length < 2
    puts 'Usage: create_or_copy_run_by_name.rb <source_run_group_name> <source_run_name> [dest_run_group_name] [dest_run_name]'
    exit 1
  end
  toks = ARGV.dup
  toks.shift if toks[0] == 'ADSK'
  source_run_group = toks[0]
  source_run_name = toks[1]
  dest_group_name = (toks[2] && toks[2] != '') ? toks[2] : 'Clusters'
  dest_run_name = (toks[3] && toks[3] != '') ? toks[3] : "#{source_run_name}_copy"
  
  model_path = read_config_model_path
  if model_path.nil? || model_path.empty?
    model_path = 'C:/Users/brodowm/OneDrive - Autodesk/Documents/InfoWorks ICM/Standalone Databases/Raster 2d Export/Raster_2d_Export.icmm'
  end
  db = WSApplication.open(model_path)
  
  source_group = find_group(db, source_run_group)
  raise "Source group not found: #{source_run_group}" if source_group.nil?
  source_run = find_run_in_group(source_group, source_run_name)
  raise "Run not found in group '#{source_run_group}': #{source_run_name}" if source_run.nil?
  
  dest_group = find_group(db, dest_group_name)
  raise "Destination group not found: #{dest_group_name}" if dest_group.nil?
  
  cfg_path = File.join(File.dirname(__FILE__), 'pipeline_config.json')
  cfg = nil
  if File.exist?(cfg_path)
    begin
      raw = File.open(cfg_path, 'rb') { |f| f.read }
      raw = raw.sub(/^\xEF\xBB\xBF/, '')
      cfg = JSON.parse(raw.force_encoding('UTF-8'))
    rescue
    end
  end
  dest_network_name = cfg && cfg['source_network_name'] ? cfg['source_network_name'] : '5k'
  dest_network = find_network_in_group(dest_group, dest_network_name)
  raise "Network not found in destination group '#{dest_group_name}': #{dest_network_name}" if dest_network.nil?
  
  copied_run = copy_run_to_group(source_run, dest_group, dest_network, dest_run_name)
  puts "Created run '#{dest_run_name}' in group '#{dest_group_name}' using network '#{dest_network_name}' (Run ID #{copied_run.id})"
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end


