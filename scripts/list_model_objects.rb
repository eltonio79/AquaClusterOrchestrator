# Exchange script: List model objects in an .icmm database
# Usage: ICMExchange.exe scripts/list_model_objects.rb <model_path>

path = ARGV[0]
if path.nil? || path.strip == ''
  puts 'Usage: list_model_objects.rb <model_path>'
  exit 1
end

begin
  db = WSApplication.open(path)
  types = [
    'Model Group', 'Model Network', 'Geometry', 'Control', 'Run', 'Sim',
    'Collection Network', 'River Network', '2D Zone', 'Master Group',
    'Asset Group', 'Master Database'
  ]
  types.each do |t|
    begin
      coll = db.model_object_collection(t)
      puts sprintf('%-20s : %d', t, coll ? coll.length : 0)
      (coll || []).each do |mo|
        begin
          puts "  - #{t} : #{mo.id} : #{mo.name}"
        rescue
          puts "  - #{t} : #{mo.id}"
        end
      end
    rescue => e
      puts sprintf('%-20s : error (%s)', t, e.message)
    end
  end
rescue => e
  puts "ERROR: #{e.class} — #{e.message}"
  exit 1
end


