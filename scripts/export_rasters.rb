# Ruby script for exporting 2D raster results from simulation objects
# Based on the ExportRaster2D_IExchange.rb example but adapted for the pipeline

require 'json'

# Parse command line arguments
# Some Exchange environments prepend the script path in ARGV[0]. Detect and shift if needed.
args = ARGV.dup
if args.length >= 1 && (args[0] !~ /^\d+$/)
  # First arg is not a number → likely the script path; drop it
  args.shift
end

if args.length < 2
  puts "Usage: export_rasters.rb <simulation_id> <output_directory> [attributes_csv] [model_path]"
  puts "Example: export_rasters.rb 1 data/output/rasters/sim_1 'DEPTH2D,SPEED2D' 'models/standalone/Medium 2D/Ruby_Hackathon_Medium_2D_Model.icmm'"
  exit 1
end

simulation_id = args[0].to_i
output_directory = args[1]
attributes = args[2] ? args[2].split(',') : ['DEPTH2D', 'SPEED2D', 'ANGLE2D', 'CUMINF2D', 'GASMD2D', 'GASFLAG2D', 'GAMCUZ2D', 'GATDUZ2D']
model_path_arg = args[3]

def read_config_model_path
  begin
    cfg_path = File.join('scripts', 'pipeline_config.json')
    if File.exist?(cfg_path)
      raw = File.open(cfg_path, 'rb') { |f| f.read }
      raw = raw.sub(/^\xEF\xBB\xBF/, '')
      cfg = JSON.parse(raw.force_encoding('UTF-8'))
      return cfg['model_path'] if cfg && cfg['model_path'] && !cfg['model_path'].empty?
    end
  rescue => e
    puts "Warning: Could not read config: #{e.message}"
  end
  nil
end

puts "Exporting simulation #{simulation_id} to #{output_directory}"
puts "Attributes: #{attributes.join(', ')}"

# Open the database and get the simulation object
begin
  model_path = model_path_arg || read_config_model_path || "models/standalone/Medium 2D/Ruby_Hackathon_Medium_2D_Model.icmm"
  database = WSApplication.open(model_path)
  
  model = database.model_object_from_type_and_id('Sim', simulation_id)
  modelType = model.class.to_s
  
  if modelType != "WSSimObject"
    puts "ERROR: Opened model object is \"#{modelType}\". Expected WSSimObject."
    exit 1
  end
  
  puts "Found simulation: #{model.name} (ID: #{model.id})"
  
  # Check if raster_2d_export method is available
  if !model.respond_to?(:raster_2d_export)
    puts "ERROR: Simulation object does not have \"raster_2d_export\" function."
    puts "Update the IWScripting library to the newest version."
    exit 1
  end
  
  # Create output directory if it doesn't exist
  require 'fileutils'
  FileUtils.mkdir_p(output_directory)
  
  # Compose the export function arguments
  arguments = {}
  arguments['Path'] = File.absolute_path(output_directory)
  arguments['SummaryMode'] = false  # Export all timesteps
  arguments['Attributes'] = attributes
  arguments['UserUnits'] = false    # Use native units (meters)
  arguments['Resolution'] = 1.0     # 1 meter resolution
  arguments['AllTimestepsMode'] = true
  arguments['TimestepMultiplier'] = 1
  arguments['EPSG'] = -1            # Unspecified EPSG
  
  puts "Export arguments:"
  puts "  Path: #{arguments['Path']}"
  puts "  Attributes: #{arguments['Attributes'].join(', ')}"
  puts "  Resolution: #{arguments['Resolution']}m"
  puts "  All timesteps: #{arguments['AllTimestepsMode']}"
  
  # Run the export function
  puts "\nStarting raster export..."
  model.raster_2d_export(arguments)
  puts "Export completed successfully!"
  
  # List exported files
  exported_files = Dir.glob(File.join(output_directory, "*.tif"))
  puts "\nExported files (#{exported_files.length}):"
  exported_files.each do |file|
    puts "  #{File.basename(file)}"
  end
  
rescue => e
  puts "ERROR: Internal problem with script execution: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end
