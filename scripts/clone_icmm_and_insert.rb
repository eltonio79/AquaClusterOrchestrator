# Exchange script: Clone a standalone .icmm and insert a test polygon into the clone
# Usage:
#   ICMExchange.exe scripts/clone_icmm_and_insert.rb <source_icmm_path> [polygon_id]

require 'fileutils'
require 'json'

def timestamp
  Time.now.strftime('%Y%m%d_%H%M%S')
end

# Rebuild source path from ARGV to handle spaces
src_path = nil
acc = []
ARGV.each do |t|
  acc << t
  candidate = acc.join(' ')
  if File.exist?(candidate)
    src_path = candidate
    break
  end
end
raise 'Source .icmm not provided/found' if src_path.nil?

polygon_id = ARGV[acc.length] && ARGV[acc.length] != '' ? ARGV[acc.length] : 'cluster_test_1'

begin
  # Build destination path next to source
  base = File.basename(src_path, '.icmm')
  dir  = File.dirname(src_path)
  dst  = File.join(dir, "#{base}_CLONE_#{timestamp}.icmm")
  FileUtils.cp(src_path, dst)
  puts "Cloned model: #{dst}"

  # Open clone and insert polygon via the same logic as insert_test_polygon
  db = WSApplication.open(dst)
  network_mo = nil
  %w[Model\ Network Geometry Collection\ Network River\ Network].each do |t|
    begin
      col = db.model_object_collection(t.gsub('\\',''))
      if col && col.length > 0
        mo = col.first
        if mo.respond_to?(:open)
          network_mo = mo
          break
        end
      end
    rescue
    end
  end
  raise 'No model network found in clone' if network_mo.nil?

  net = network_mo.open
  x0 = 151300.0; y0 = 209700.0
  x1 = 151400.0; y1 = 209800.0
  coords = [x0,y0, x1,y0, x1,y1, x0,y1]

  net.transaction_begin
  begin
    ro = net.new_row_object('hw_polygon')
    ro['polygon_id'] = polygon_id
    begin
      ro['boundary_array'] = coords
    rescue
      coords.each_slice(2) { |xy| ro['boundary_array'] << xy }
    end
    ro.write
    net.transaction_commit
    puts "Inserted polygon #{polygon_id} into clone."
  rescue => e
    net.transaction_rollback
    raise e
  ensure
    net.close if net
  end
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  exit 1
end


