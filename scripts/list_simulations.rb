# Ruby script to list all available simulations in the Medium 2D model
# This helps users identify baseline and candidate simulation IDs

# Open the database and get the model
database = WSApplication.open("models/standalone/Medium 2D/Ruby_Hackathon_Medium_2D_Model.icmm")
puts "Database opened: #{database.path}"

# List all model objects of type 'Sim' (simulation results)
simulations = database.model_object_collection('Sim')
puts "\nFound #{simulations.length} simulation result(s):"

# Also check for other possible types
puts "\nChecking other object types..."
['Model Group', 'Model Network', 'Run', 'Sim'].each do |obj_type|
  objects = database.model_object_collection(obj_type)
  puts "#{obj_type}: #{objects.length} objects"
end

# Check if there are any objects at all in the database
puts "\nChecking for any objects in database..."
begin
  # Try to find any objects by searching for common types
  all_objects = []
  ['Asset Group', 'Model Group', 'Master Group'].each do |root_type|
    objects = database.model_object_collection(root_type)
    all_objects.concat(objects.to_a)
  end
  
  puts "Total root objects found: #{all_objects.length}"
  all_objects.each do |obj|
    puts "  - #{obj.type}: #{obj.name} (ID: #{obj.id})"
  end
rescue => e
  puts "Error checking root objects: #{e.message}"
end

index = 0
simulations.each do |sim|
  index += 1
  puts "\nSimulation #{index}:"
  puts "  ID: #{sim.id}"
  puts "  Name: #{sim.name}"
  puts "  Type: #{sim.type}"
  puts "  Description: #{sim.description}" if sim.respond_to?(:description)
  
  # Try to get additional info if it's a WSSimObject
  if sim.respond_to?(:list_timesteps)
    begin
      timesteps = sim.list_timesteps
      puts "  Timesteps: #{timesteps.length} available"
      if timesteps.length > 0
        puts "    First: #{timesteps.first}"
        puts "    Last: #{timesteps.last}"
      end
    rescue => e
      puts "  Timesteps: Error retrieving - #{e.message}"
    end
  end
  
  if sim.respond_to?(:list_results_attributes)
    begin
      attributes = sim.list_results_attributes
      puts "  Available result attributes:"
      attributes.each do |category|
        puts "    #{category[0]}: #{category[1].join(', ')}"
      end
    rescue => e
      puts "  Attributes: Error retrieving - #{e.message}"
    end
  end
end

puts "\nUsage: Use the ID numbers above to specify baseline_id and candidate_id in your analysis."
puts "For example, if you want to compare sim 1 vs sim 2, use baseline_id=1, candidate_id=2"
