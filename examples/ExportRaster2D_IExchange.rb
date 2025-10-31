# Ruby macro for exporting 2D raster results from a simulation object results.
#
# Steps:
#   1. Get the current network and simulation result object (WSSimObject).
#   2. Verify that the opened object is of type "WSSimObject".
#      If not, print an error and exit.
#   3. Check if the object responds to the "raster_2d_export" function.
#      If not, print an error and exit (requires updated IWScripting library).
#   4. Build the arguments hash for the export call:
#        - Path               : String. Output folder path.
#        - SummaryMode        : Bool. If true, ignores timestep parameters and exports max values.
#        - Attributes         : Array of strings with result attribute names.
#        - UserUnits          : Bool. false = native (metres), true = user (feet).
#        - Resolution         : Double. Cell size of the raster in chosen units.
#        - AllTimestepsMode   : Bool. If true, export all timesteps.
#        - TimestepMultiplier : Int. Step for timesteps when AllTimestepsMode is true (default 1).
#        - Timestep           : Double. Specific time value. Used if AllTimestepsMode is false.
#        - EPSG               : Int. EPSG code for georeferencing (-1 means unspecified).
#   5. Call "raster_2d_export" on the simulation object model with the prepared arguments.
#
# Exceptions:
#   - Runtime errors are caught and printed, showing the Ruby exception class and message.
#   - Exits early if object type is invalid or function is missing.

# get simulation object model
database = WSApplication.open
model = database.model_object_from_type_and_id 'Sim', 1

modelType = model.class.to_s
if modelType != "WSSimObject"
  puts "Opened model object is \"#{modelType}\". Please activate a \"Simulation Results\" window and re-run the script."
  exit
end

if !model.respond_to?(:raster_2d_export)
  puts "Simulation object does not have \"raster_2d_export\" function. Update the IWScripting library to the newest version in order to use it."
  exit
end

begin
  # compose the export function arguments
  arguments = {}
  arguments['Path'] = "C:\\Users\\brodowm\\OneDrive - Autodesk\\Documents\\InfoWorks ICM\\Exported\\Hackathon Share\\Run - Base\\Rainfall event - Default\\"
  #arguments['Path'] = "C:\\Users\\brodowm\\OneDrive - Autodesk\\Documents\\InfoWorks ICM\\Exported\\Hackathon Share\\Run - Base\\Rainfall event - Classic Mesh\\"
  #arguments['Path'] = "C:\\Users\\brodowm\\OneDrive - Autodesk\\Documents\\InfoWorks ICM\\Exported\\Hackathon Share\\Run - With Polygons\\Rainfall event - Classic Mesh\\"
  arguments['SummaryMode'] = false
  arguments['Attributes'] = ["ANGLE2D", "DEPTH2D", "SPEED2D", "CUMINF2D", "GASMD2D", "GASFLAG2D", "GAMCUZ2D", "GATDUZ2D"]
  arguments['UserUnits'] = false
  arguments['Resolution'] = 1
  arguments['AllTimestepsMode'] = true
  arguments['TimestepMultiplier'] = 1
  #arguments['Timestep'] = 0.0 #-360.0
  arguments['EPSG'] = -1

  # run the export function
  model.raster_2d_export(arguments)
rescue => e
  puts "Internal problem with script execution: #{e.class} — #{e.message}"
end
