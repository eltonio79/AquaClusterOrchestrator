# UI script: Export rasters from the currently open simulation results (WSSimObject)

begin
  raise "This script must be run from the UI" unless WSApplication.ui?

  net = WSApplication.current_network
  raise "No active network" if net.nil?

  model = net.model_object
  raise "No model object in current network" if model.nil?

  if model.class.to_s != 'WSSimObject'
    WSApplication.message_box("Please activate a 'Simulation Results' window and re-run.", 'ok', '!', true)
    exit
  end

  unless model.respond_to?(:raster_2d_export)
    WSApplication.message_box("Simulation object lacks raster_2d_export. Update IWScripting.", 'ok', 'stop', true)
    exit
  end

  # Prompt parameters
  layout = [
    ['Output folder', 'STRING', nil, nil, 'FOLDER', 'Select output folder'],
    ['Attributes CSV', 'STRING', 'DEPTH2D,SPEED2D'],
    ['Resolution (m)', 'NUMBER', 1.0, 2],
    ['All timesteps', 'BOOLEAN', true]
  ]
  values = WSApplication.prompt('Export Current Simulation Rasters', layout, true)
  exit if values.nil?

  out_dir = values[0]
  attrs_csv = (values[1] || '').to_s
  res = (values[2] || 1.0).to_f
  all_ts = !!values[3]

  require 'fileutils'
  FileUtils.mkdir_p(out_dir) if out_dir && out_dir != ''

  attributes = attrs_csv.split(',').map(&:strip).reject(&:empty?)
  attributes = ['DEPTH2D'] if attributes.empty?

  args = {}
  args['Path'] = File.absolute_path(out_dir)
  args['SummaryMode'] = false
  args['Attributes'] = attributes
  args['UserUnits'] = false
  args['Resolution'] = res
  args['AllTimestepsMode'] = all_ts
  args['TimestepMultiplier'] = 1
  args['EPSG'] = -1

  model.raster_2d_export(args)
  WSApplication.message_box("Export complete to:\n#{args['Path']}", 'ok', 'information', true)
rescue => e
  WSApplication.message_box("Error: #{e.class} — #{e.message}", 'ok', 'stop', true)
end

# UI script: export rasters from currently open simulation results
# Prompts for export options and records processed result

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
  net = WSApplication.current_network
  if net.nil?
    puts 'ERROR: No current network open.'
    exit 1
  end

  model = net.model_object
  modelType = model.class.to_s
  if modelType != 'WSSimObject'
    puts "Opened model object is \"#{modelType}\". Please activate a \"Simulation Results\" window and re-run the script."
    exit 1
  end

  unless model.respond_to?(:raster_2d_export)
    puts 'Simulation object does not have "raster_2d_export" function.'
    exit 1
  end

  # Resolve defaults from config if present
  cfg_model_path = nil
  cfg_data_dir = 'data/output'
  begin
    cfg_path = File.join('data', 'input', 'config', 'pipeline_config.json')
    if File.exist?(cfg_path)
      cfg = JSON.parse(File.read(cfg_path))
      cfg_model_path = cfg['model_path'] if cfg['model_path']
      cfg_data_dir = cfg['data_dir'] if cfg['data_dir']
    end
  rescue
  end

  default_out = File.join(cfg_data_dir, 'rasters', "sim_#{model.id}")
  out_dir = prompt('Output directory for rasters', default_out)
  FileUtils.mkdir_p(out_dir)

  attrs_default = 'DEPTH2D,SPEED2D'
  attrs_csv = prompt('Attributes (CSV)', attrs_default)
  attributes = attrs_csv.split(',').map(&:strip)

  resolution = prompt('Resolution (m)', '1.0').to_f

  args = {}
  args['Path'] = File.absolute_path(out_dir)
  args['SummaryMode'] = false
  args['Attributes'] = attributes
  args['UserUnits'] = false
  args['Resolution'] = resolution
  args['AllTimestepsMode'] = true
  args['TimestepMultiplier'] = 1
  args['EPSG'] = -1

  puts "Exporting to #{args['Path']} with attributes: #{attributes.join(', ')}"
  model.raster_2d_export(args)
  puts 'Export completed.'

  # Record processed result
  begin
    base_out = File.join(cfg_data_dir, 'processed_results.json')
    data = { 'items' => [] }
    if File.exist?(base_out)
      data = JSON.parse(File.read(base_out))
    end
    item = {
      'database' => (cfg_model_path || 'current_ui_database'),
      'simulation_id' => model.id,
      'simulation_name' => model.name,
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

rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end


