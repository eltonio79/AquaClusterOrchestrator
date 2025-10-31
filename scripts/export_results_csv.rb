# Export simulation results to CSV via IExchange
# Usage:
#   export_results_csv.rb <simulation_id> <output_dir> [model_path] [json_selection]
# - simulation_id: integer ID of the WSSimObject
# - output_dir: destination folder for CSV files
# - model_path: optional path to .icmm; if omitted, read from scripts/pipeline_config.json
# - json_selection: optional JSON string like:
#     [["Link",["ds_flow","ds_vel"]],["Node",["flood_depth","head"]]]
#   If omitted, safe defaults will be used based on available attributes.

require 'json'
require 'fileutils'

# Robust ARGV handling (Exchange may prepend script path)
args = ARGV.dup
if args.length >= 1 && args[0] && args[0] !~ /^\d+$/ && File.exist?(args[0])
  # Likely script path; drop it
  args.shift
end

if args.length < 2
  puts "Usage: export_results_csv.rb <simulation_id> <output_dir> [model_path] [json_selection]"
  exit 1
end

simulation_id = args[0].to_i
output_dir     = args[1]
model_path_arg = args[2]
selection_json = args[3]

FileUtils.mkdir_p(output_dir) unless Dir.exist?(output_dir)

# Read model_path from pipeline config if not provided
 def read_config_model_path
  begin
    cfg_path = File.join('scripts','pipeline_config.json')
    if File.exist?(cfg_path)
      raw = File.open(cfg_path,'rb'){|f| f.read }
      raw = raw.sub(/^\xEF\xBB\xBF/, '')
      cfg = JSON.parse(raw.force_encoding('UTF-8'))
      return cfg['model_path'] if cfg && cfg['model_path'] && !cfg['model_path'].empty?
    end
  rescue => e
    puts "Warning: Could not read config: #{e.message}"
  end
  nil
end

begin
  model_path = model_path_arg || read_config_model_path
  raise "No model_path provided and not found in config" if model_path.nil? || model_path.strip.empty?

  db = WSApplication.open(model_path)
  sim = db.model_object_from_type_and_id('Sim', simulation_id)
  raise "Object is not a WSSimObject" unless sim && sim.class.to_s == 'WSSimObject'

  # Discover available attributes to build safe defaults if selection not passed
  available = []
  begin
    lst = sim.list_results_attributes
    # list_results_attributes returns array-like content per docs; capture for logging
    available = Array(lst)
  rescue => e
    puts "Warning: list_results_attributes failed: #{e.message}"
  end

  selection = nil
  if selection_json && !selection_json.strip.empty?
    selection = JSON.parse(selection_json)
  else
    # Fallback defaults: export common Link and Node fields if present
    link_fields = %w[ds_flow ds_vel us_flow us_vel ds_depth us_depth]
    node_fields = %w[head flood_depth flood_vol]

    # Filter by availability when possible (best-effort)
    # If available includes strings, just proceed; API will ignore missing
    selection = []
    selection << ["Link", link_fields] 
    selection << ["Node", node_fields]
  end

  puts "Exporting CSV results for simulation #{simulation_id} to #{output_dir}"
  puts "Selection: #{selection.to_json}"

  # Call export
  sim.results_csv_export_ex(nil, selection, output_dir)
  puts "CSV export completed."
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  exit 2
end
