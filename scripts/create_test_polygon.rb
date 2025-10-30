# Exchange script: create a simple test polygon in hw_polygon
# Optional args: [polygon_id] [model_path]

polygon_id = ARGV[0] && ARGV[0] != '' ? ARGV[0] : "cluster_test_1"
model_path = ARGV[1] && ARGV[1] != '' ? ARGV[1] : nil

begin
  db = model_path ? WSApplication.open(model_path) : WSApplication.open

  # Find first Geometry object
  geom = nil
  begin
    col = db.model_object_collection('Geometry')
    geom = col.first if col && col.length > 0
  rescue
  end
  raise 'No Geometry object found in database' if geom.nil?

  net = geom.open

  # Build a small rectangle near existing raster extents (fallback coordinates)
  # If network has any existing polygons, use their first point as anchor; else use a hardcoded area
  anchor = [151200.0, 209550.0]
  begin
    any_poly = net.row_objects('hw_polygon').first
    if any_poly && any_poly.respond_to?(:boundary_array)
      ba = any_poly.boundary_array
      if ba && ba.length >= 2
        anchor = [ba[0].to_f, ba[1].to_f]
      end
    end
  rescue
  end

  x0, y0 = anchor
  size = 50.0
  ring = [
    x0, y0,
    x0 + size, y0,
    x0 + size, y0 + size,
    x0, y0 + size,
    x0, y0
  ]

  net.transaction_begin
  ro = net.new_row_object('hw_polygon')
  ro['polygon_id'] = polygon_id
  begin
    ro['boundary_array'] = ring
  rescue
    ring.each_slice(2) { |xy| ro['boundary_array'] << xy }
  end
  ro.write
  net.transaction_commit
  puts "Created polygon: #{polygon_id}"
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  puts e.backtrace.join("\n")
  begin
    net.transaction_rollback if net
  rescue
  end
  exit 1
end


