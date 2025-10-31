# Exchange script: Launch a Run by ID and wait for completion
# Usage:
#   ICMExchange.exe scripts/launch_run_by_id.rb <run_id> [timeout_seconds]

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
  if ARGV.empty?
    puts 'Usage: launch_run_by_id.rb <run_id> [timeout_seconds]'
    exit 1
  end
  toks = ARGV.dup
  toks.shift if toks[0] == 'ADSK'
  run_id = toks[0].to_i
  timeout_seconds = (toks[1] && toks[1].to_i > 0) ? toks[1].to_i : 3600
  
  model_path = read_config_model_path
  if model_path.nil? || model_path.empty?
    model_path = 'C:/Users/brodowm/OneDrive - Autodesk/Documents/InfoWorks ICM/Standalone Databases/Raster 2d Export/Raster_2d_Export.icmm'
  end
  db = WSApplication.open(model_path)
  
  run_mo = db.model_object_from_type_and_id('Run', run_id)
  raise "Run with id=#{run_id} not found" if run_mo.nil?
  
  sims = run_mo.children || []
  raise "Run has no simulations" if sims.empty?
  
  puts "Launching Run #{run_id} (#{sims.length} simulations)"
  
  begin
    WSApplication.connect_local_agent(1)
  rescue => e
    puts "WARNING: connect_local_agent failed: #{e.message}"
  end
  
  handles = WSApplication.launch_sims(sims, '.', false, 0, 0)
  timeout_ms = timeout_seconds * 1000
  
  result = WSApplication.wait_for_jobs(handles, true, timeout_ms)
  if result.nil?
    puts "ERROR: Timeout after #{timeout_seconds}s"
    exit 1
  end
  
  all_success = true
  sims.each do |sim|
    status = sim.status
    puts "Sim #{sim.id}: status=#{status}"
    all_success = false if status != 'success'
  end
  
  if all_success
    puts "All simulations completed successfully"
    exit 0
  else
    puts "WARNING: Some simulations failed or incomplete"
    exit 2
  end
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end


