# Last Updated: 2024-10-04

=begin
This script is used to import data from InfoSewer BASE scenario to InfoWorks ICM. It follows several steps to complete the import:

It prompts the user to select the folders where the IEDB, SHP, and CFG files are located.
It defines and executes a series of import steps, using the CSV and SHP files and their corresponding CFG files. The steps include importing information related to nodes, conduits, unit hydrographs, manholes, pump curves, pump controls, subcatchments, and conduit vertices from CSV and SHP files.
Throughout the process, the script handles potential errors and prints out the status of each import step.
It also performs various SQL operations to manipulate the data, such as setting node types, creating subcatchments, setting the number of barrels, assigning R values, finding pumps, setting pump on and off levels, and calculating wet well areas.
After each series of SQL operations, the script begins a single transaction and commits it after the operations are completed.
The script uses different import options for different steps, including unit behavior and duplication behavior, and whether to update based on asset ID or only update existing objects.
Finally, it prints a message indicating that the import process is finished.
Overall, this script is designed to automate the process of importing and preprocessing InfoSewer data into InfoWorks ICM, ensuring data consistency and saving time for the user.
=end

# net.odic_import_ex(format, config, options, table, file)
    # format: String - e.g. 'csv' or 'shp'
    # config: String - absolute filepath to CFG file
    # options: Hash, nil - hash of options for import, or nil to use defaults
    # table: String - name of the destination table, as displayed in the UI with any spaces removed
    # file: String - path to the file to import

# Access the current open network in the application
net = WSApplication.current_network

# Prompt user to select the IEDB, SHP, and CFG file locations
file_locations = WSApplication.prompt("Provide Import File Locations", [
    ['Folder containing shapefiles', 'String', nil, nil, 'FOLDER', 'Scenario Folder'],
    ['Folder containing CSVs', 'String', nil, nil, 'FOLDER', 'Scenario Folder'],
    ['Folder containing CFG files', 'String', nil, nil, 'FOLDER', 'Scenario Folder']
  ], false)

# Check if the user clicked 'Cancel'
if file_locations.nil? || file_locations.empty?
    WSApplication.message_box("Import process was canceled. No data was imported. Script aborted.", "OK", "!", false)
    return
end

# Assign the user-selected paths to shp, csv, and cfg variables
shp = file_locations[0]
csv = file_locations[1]
cfg = file_locations[2]

# Check if all required file locations are provided
if shp.nil? || shp.empty? || csv.nil? || csv.empty? || cfg.nil? || cfg.empty?
    WSApplication.message_box("One or more file location(s) missing. Script aborted.", "OK", "!", false)
    return
end

# Output the chosen paths
puts "Imported information from the following locations:"
puts shp
puts csv
puts cfg
puts "\n"

# Define import steps as arrays containing layer name, CFG file name, and corresponding CSV/shp file name
import_steps_i = [
    ['Node', 'Step01_InfoSewer_Node_csv.cfg', 'node.csv'],
    ['Conduit', 'Step02_InfoSewer_Link_csv.cfg', 'link.csv'],
    ['Unithydrograph', 'Step09_rdii_hydrograph_csv.cfg', 'hydrogrh.csv']
]

import_steps_ii = [
    ['Node', 'Step01a_InfoSewer_Manhole_csv.cfg', 'manhole.csv'],
    ['Node', 'Step03_InfoSewer_manhole_hydraulics_mhhyd_csv.cfg', 'mhhyd.csv'],
    ['Conduit', 'Step04_InfoSewer_link_hydraulics_pipehyd_csv.cfg', 'pipehyd.csv'],
    ['Node', 'Step05_InfoSewer_wetwell_wwellhyd_csv.cfg', 'wwellhyd.csv']
]

import_steps_iii = [
    ['Pump', 'Step05a_InfoSewer_pump_curve_pumphyd_csv.cfg', 'pumphyd.csv'],
    ['Pump', 'Step06_InfoSewer_pump_control_control_csv.cfg', 'control.csv']
]

import_steps_iv = [
    ['Subcatchment', 'Step07_InfoSewer_subcatchment_dwf_mhhyd_csv.cfg', 'mhhyd.csv']
]

import_steps_v = [
    ['Conduit', 'Step02a_InfoSewer_ConduitVertices_Pipe_shp.cfg', 'Pipe.shp'],
    ['Conduit', 'Step02b_InfoSewer_ConduitVertices_Forcemain_shp.cfg', 'Forcemain.shp'],
    ['Pump', 'Step02c_InfoSewer_ConduitVertices_Pump_shp.cfg', 'Pump.shp']
]

# Options notes
    #Step 01 - Prompt
    #Step 01a - Overwrite, Update based on asset ID
    #Step 02 - Prompt
    #Step 03 - Overwrite, Update based on asset ID
    #Step 04 - Overwrite, Update based on asset ID
    #Step 05 - Overwrite, Update based on asset ID
    #Step 05a - Overwrite, Update based on asset ID
    #Step 06 - Overwrite, Update based on asset ID
    #Step 07 - Overwrite, Update only existing objects
    #Step 09 - Prompt

# Set options for import of steps i										    
options = {
    'Units Behaviour' => 'User'
}

# Iterate over each element in the import_steps_i array
import_steps_i.each do |layer, cfg_file, csv_file|
    begin
        # Import CSV data to the specified layer using the given configuration file 
        net.odic_import_ex('csv', File.join(cfg, cfg_file), options, layer, File.join(csv, csv_file))
        # Output success message after successful import
        puts "   Imported to #{layer} table from #{csv_file} using #{cfg_file}"
    # Catch any errors that occur during the import process
    rescue StandardError => e
        # Output error message if an error occurs during import
        puts ("An error occurred during the import of #{layer} from #{cfg_file}: #{e.message}")
    end
end

# Set options for import of steps ii										    
options = {
    'Units Behaviour' => 'User',
    'Duplication Behaviour' => 'Overwrite',					
    'Update Based On Asset ID' => true
}				        

# Iterate over each element in the import_steps_ii array
import_steps_ii.each do |layer, cfg_file, csv_file|
    begin
        net.odic_import_ex('csv', File.join(cfg, cfg_file), options, layer, File.join(csv, csv_file))
        puts "   Imported to #{layer} table from #{csv_file} using #{cfg_file}"
    rescue StandardError => e
        puts ("An error occurred during the import of #{layer} from #{cfg_file}: #{e.message}")
    end
end

# Begin single transaction
net.transaction_begin

# SQL 01_SET node_type = 'Outfall'
net.run_SQL("_nodes", "SET node_type = 'Outfall' WHERE user_text_2 = '2';
SET user_text_10 = 'Outfall' WHERE user_text_2 = '2';")

# SQL 02_Create_Subcatchments
net.run_SQL("_nodes", "INSERT INTO subcatchment (subcatchment_id, node_id, total_area, x, y, connectivity)
SELECT node_id, node_id, 0.10, x, y, 100 WHERE user_text_10 = 'Manhole';")

# SQL 03_SET number_of_barrels
net.run_SQL("_links", "SET number_of_barrels = 1 WHERE number_of_barrels = 0")

# SQL 08_Assign R Values
net.run_SQL("RTK hydrograph", "SET R1 = (user_number_2/100)*(user_number_1/100),
R2 = (user_number_3/100)*(user_number_1/100),
R3 = ((100 - user_number_2 - user_number_3)/100)*(user_number_1/100)")

# Commit the transaction
net.transaction_commit

# SQL 04_Find_Pumps
net.run_SQL("_links", "LIST $asset_id String;
SELECT DISTINCT asset_id INTO $asset_id WHERE user_text_10 = 'Pump';
LET $i = 1;
WHILE $i <= LEN($asset_id);
SELECT us_node_id INTO $us_node_id WHERE asset_id =AREF($i, $asset_id);
SELECT ds_node_id INTO $ds_node_id WHERE asset_id =AREF($i, $asset_id);
SELECT link_suffix into $link_suffix WHERE asset_id =AREF($i, $asset_id); 
DELETE WHERE asset_id =AREF($i, $asset_id);
INSERT INTO pump (us_node_id, ds_node_id, link_suffix, asset_id)
VALUES($us_node_id, $ds_node_id, $link_suffix, AREF($i, $asset_id));
LET $i = $i+1;
WEND;")

# Set options for import of steps iii										    
options = {
    'Units Behaviour' => 'User',
    'Duplication Behaviour' => 'Overwrite',					
    'Update Based On Asset ID' => true
}				        

# Iterate over each element in the import_steps_iii array
import_steps_iii.each do |layer, cfg_file, csv_file|
    begin
        net.odic_import_ex('csv', File.join(cfg, cfg_file), options, layer, File.join(csv, csv_file))
        puts "   Imported to #{layer} table from #{csv_file} using #{cfg_file}"
    rescue StandardError => e
        puts ("An error occurred during the import of #{layer} from #{cfg_file}: #{e.message}")
    end
end

# Begin single transaction
net.transaction_begin

# SQL 05_SET pump on and off
net.run_SQL("hw_pump", "SET switch_on_level = switch_on_level + us_node.chamber_floor,
switch_off_level = switch_off_level + us_node.chamber_floor")

# SQL 06_SET calculate wet well area
net.run_SQL("_nodes", "SET chamber_area = 3.14159 * (chamber_area/2) * (chamber_area/2) WHERE user_text_10 = 'WW';
SET shaft_area = 3.14159 * (shaft_area/2) * (shaft_area/2) WHERE user_text_10 = 'WW';
SET ground_level = ground_level + chamber_floor WHERE user_text_10 = 'WW'")

# SQL 10_Insert pump curves
net.run_SQL("hw_pump", "
SET link_type = 'ROTPMP' WHERE user_text_1 = 1 OR user_text_1 = 2;
SELECT WHERE link_type = 'ROTPMP';
INSERT INTO [Head Discharge] (head_discharge_id) SELECT SELECTED asset_id FROM Pump;
SET head_discharge_id = asset_id;
DELETE ALL FROM [Head discharge].HDP_table;
INSERT INTO [Head discharge].HDP_table (head_discharge_id, HDP_table.head, HDP_table.discharge) SELECT asset_id, 1.33 * user_number_3, 0 FROM Pump WHERE user_text_1 = 1;
INSERT INTO [Head discharge].HDP_table (head_discharge_id, HDP_table.head, HDP_table.discharge) SELECT asset_id, user_number_3, user_number_4  FROM Pump WHERE user_text_1 = 1;
INSERT INTO [Head discharge].HDP_table (head_discharge_id, HDP_table.head, HDP_table.discharge) SELECT asset_id, 0, 2 * user_number_4  FROM Pump WHERE user_text_1 = 1;
INSERT INTO [Head discharge].HDP_table (head_discharge_id, HDP_table.head, HDP_table.discharge) SELECT asset_id, user_number_2, 0 FROM Pump WHERE user_text_1 = 2;
INSERT INTO [Head discharge].HDP_table (head_discharge_id, HDP_table.head, HDP_table.discharge) SELECT asset_id, user_number_3, user_number_4  FROM Pump WHERE user_text_1 = 2;
INSERT INTO [Head discharge].HDP_table (head_discharge_id, HDP_table.head, HDP_table.discharge) SELECT asset_id, user_number_5, user_number_6  FROM Pump WHERE user_text_1 = 2;
DESELECT ALL")

# Commit the transaction
net.transaction_commit

# Set options for import of steps iv										    
options = {
    'Units Behaviour' => 'User',
    'Duplication Behaviour' => 'Overwrite',					
    'Update Only' => true
}		        

# Iterate over each element in the import_steps_iv array
import_steps_iv.each do |layer, cfg_file, csv_file|
    begin
        net.odic_import_ex('csv', File.join(cfg, cfg_file), options, layer, File.join(csv, csv_file))
        puts "   Imported to #{layer} table from #{csv_file} using #{cfg_file}"
    rescue StandardError => e
        puts ("An error occurred during the import of #{layer} from #{cfg_file}: #{e.message}")
    end
end

# Set options for import of steps v
options = {											    
    'Units Behaviour' => 'User',
    'Duplication Behaviour' => 'Overwrite',					
    'Update Based On Asset ID' => true
}				        

# Iterate over each element in the import_steps_v array
import_steps_v.each do |layer, cfg_file, shp_file|
    begin
        net.odic_import_ex('shp', File.join(cfg, cfg_file), options, layer, File.join(shp, shp_file))
        puts "   Imported to #{layer} table from #{shp_file} using #{cfg_file}"
    rescue StandardError => e
        puts ("An error occurred during the import of #{layer} from #{cfg_file}: #{e.message}")
    end
end

# Print a message indicating that the import process is finished
puts "\nFinished import of InfoSewer BASE scenario network data to InfoWorks ICM"

# Print notable limitations of the import process
puts "\nNotable limitations of the import process:"
puts "   Converts only the BASE scenario from InfoSewer to InfoWorks."
puts "   Does not convert pattern data."
puts "   Does not apply flow data in final locations. Loads 1 through 10 are imported to the Subcatchment table in the user number fields. It is up to the user to decide how to apply the loads."
puts "   Does not apply flow patterns in final locations. Patterns 1 through 10 are imported to the Subcatchment table in the user text fields. It is up to the user to decide how to apply the patterns."
puts "   Does not convert Extra Loadings, Flow Splits, or Pipe Infiltration."
puts "   Does not import rainfall data or create a simulation."

# Print potential next steps for the user
puts "\nPotential next steps:"
puts "   Validate the network and resolve any errors."
puts "   Use Scenario Tools available on Github to assist in importing scenarios."
puts "   Use Pattern Tools available on Github to assist in importing diurnal patterns."
puts "   Assign loads and patterns to the appropriate fields within the subcatchment table."