# UI script: Compare current simulation with another from the current database

begin
  raise "This script must be run from the UI" unless WSApplication.ui?

  net = WSApplication.current_network
  db  = WSApplication.current_database
  raise "No active network" if net.nil?
  raise "No current database" if db.nil?

  current = net.model_object
  if current.nil? || current.class.to_s != 'WSSimObject'
    WSApplication.message_box("Please activate a 'Simulation Results' window and re-run.", 'ok', '!', true)
    exit
  end

  # List available simulations in current database
  sims = db.model_object_collection('Sim')
  entries = sims.map { |s| [s.id, s.name] }

  if entries.empty?
    WSApplication.message_box("No simulations found in the current database.", 'ok', '!', true)
    exit
  end

  # Build a list for selection (LIST subtype)
  list_values = entries.map { |id, name| "#{id} : #{name}" }
  default_item = list_values.find { |v| v.start_with?("#{current.id} :") } || list_values.first

  layout = [
    ['Baseline (current)', 'READONLY', "#{current.id} : #{current.name}"],
    ['Candidate (choose)', 'STRING', default_item, nil, 'LIST', list_values],
    ['Export baseline rasters', 'BOOLEAN', false],
    ['Export candidate rasters', 'BOOLEAN', true],
    ['Output folder (root)', 'STRING', nil, nil, 'FOLDER', 'Select root folder for exports']
  ]
  values = WSApplication.prompt('Compare Simulations', layout, true)
  exit if values.nil?

  candidate_str = values[1]
  do_base = !!values[2]
  do_cand = !!values[3]
  root_out = values[4]

  cand_id = candidate_str.split(':').first.to_i
  candidate = sims.find { |s| s.id == cand_id }
  raise "Selected candidate not found" if candidate.nil?

  require 'fileutils'
  FileUtils.mkdir_p(root_out) if root_out && root_out != ''

  # Helper to export rasters for a given sim
  def export_rasters_for(sim_obj, dst)
    raise "Object must be WSSimObject" unless sim_obj.class.to_s == 'WSSimObject'
    unless sim_obj.respond_to?(:raster_2d_export)
      raise "Simulation lacks raster_2d_export"
    end
    require 'fileutils'
    FileUtils.mkdir_p(dst)
    args = {}
    args['Path'] = File.absolute_path(dst)
    args['SummaryMode'] = false
    args['Attributes'] = ['DEPTH2D']
    args['UserUnits'] = false
    args['Resolution'] = 1.0
    args['AllTimestepsMode'] = true
    args['TimestepMultiplier'] = 1
    args['EPSG'] = -1
    sim_obj.raster_2d_export(args)
  end

  base_out = File.join(root_out, "sim_#{current.id}")
  cand_out = File.join(root_out, "sim_#{candidate.id}")

  if do_base
    export_rasters_for(current, base_out)
  end
  if do_cand
    export_rasters_for(candidate, cand_out)
  end

  WSApplication.message_box(
    "Prepared rasters for comparison:\nBaseline: #{base_out}\nCandidate: #{cand_out}",
    'ok', 'information', true
  )
rescue => e
  WSApplication.message_box("Error: #{e.class} — #{e.message}", 'ok', 'stop', true)
end

# UI script: compare current simulation to another available simulation in project
# Exports rasters for both and records processed results

require 'json'
require 'fileutils'

def prompt(message, default_val = '')
  begin
    v = WSApplication.prompt(message, default_val)
    return v.nil? || v == '' ? default_val : v
  rescue
    return default_val
  end
end

begin
  db = WSApplication.current_database
  net = WSApplication.current_network
  if db.nil? || net.nil?
    puts 'ERROR: No current database/network open.'
    exit 1
  end

  current = net.model_object
  if current.nil? || current.class.to_s != 'WSSimObject'
    puts 'Please activate a Simulation Results window as the current context.'
    exit 1
  end

  sims = db.model_object_collection('Sim')
  list = sims.to_a
  if list.length == 0
    puts 'No simulations found in current database.'
    exit 1
  end

  # Display list
  puts "Available simulations:"
  list.each_with_index do |s, idx|
    mark = (s.id == current.id) ? '*' : ' '
    puts sprintf("%s [%02d]  ID=%d  Name=%s", mark, idx+1, s.id, s.name)
  end

  sel = prompt('Enter index to compare AGAINST current (e.g., 2)', '')
  if sel.nil? || sel.strip == ''
    puts 'No selection provided.'
    exit 1
  end
  idx = sel.to_i - 1
  if idx < 0 || idx >= list.length
    puts 'Invalid index.'
    exit 1
  end

  other = list[idx]

  # Resolve config
  cfg_data_dir = 'data/output'
  cfg_model_path = nil
  begin
    cfg_path = File.join('scripts', 'pipeline_config.json')
    if File.exist?(cfg_path)
      cfg = JSON.parse(File.read(cfg_path))
      cfg_data_dir = cfg['data_dir'] if cfg['data_dir']
      cfg_model_path = cfg['model_path'] if cfg['model_path']
    end
  rescue
  end

  # Prompt export options
  attrs_default = 'DEPTH2D,SPEED2D'
  attrs_csv = prompt('Attributes (CSV)', attrs_default)
  attributes = attrs_csv.split(',').map(&:strip)
  resolution = prompt('Resolution (m)', '1.0').to_f

  [[current, 'baseline'], [other, 'candidate']].each do |sim, role|
    out_dir = File.join(cfg_data_dir, 'rasters', "sim_#{sim.id}")
    FileUtils.mkdir_p(out_dir)
    args = {}
    args['Path'] = File.absolute_path(out_dir)
    args['SummaryMode'] = false
    args['Attributes'] = attributes
    args['UserUnits'] = false
    args['Resolution'] = resolution
    args['AllTimestepsMode'] = true
    args['TimestepMultiplier'] = 1
    args['EPSG'] = -1
    puts "Exporting #{role} sim #{sim.id} to #{out_dir}"
    sim.raster_2d_export(args)

    # Track
    begin
      base_out = File.join(cfg_data_dir, 'processed_results.json')
      data = { 'items' => [] }
      data = JSON.parse(File.read(base_out)) if File.exist?(base_out)
      item = {
        'database' => (cfg_model_path || 'current_ui_database'),
        'simulation_id' => sim.id,
        'simulation_name' => sim.name,
        'output_dir' => File.absolute_path(out_dir),
        'rules' => [],
        'status' => 'complete',
        'timestamp' => Time.now.strftime('%Y-%m-%dT%H:%M:%S')
      }
      rest = data['items'].reject { |x| x['database'] == item['database'] && x['simulation_id'].to_i == item['simulation_id'].to_i }
      data['items'] = rest + [item]
      File.open(base_out, 'w') { |f| f.write(JSON.pretty_generate(data)) }
    rescue => e
      puts "Warning: could not record processed result: #{e.message}"
    end
  end

  puts 'Export for both simulations completed.'

rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end


