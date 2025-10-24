# Scenario Generator Script

This script is used to manage scenarios in an InfoWorks ICM model network. It deletes all existing scenarios (except for the 'Base' scenario) and then creates new scenarios based on a predefined list.

## How it Works

1. The script first accesses the current network.

2. It then defines an array of scenario names that new scenarios should be created for.

3. The script iterates over each existing scenario in the network. If the scenario name is not 'Base', the scenario is deleted.

4. After all non-Base scenarios have been deleted, the script iterates over the array of new scenario names and creates a new scenario for each name.

5. Finally, the script prints a thank you message.

## Usage

To use this script, simply run it in the context of an open network in InfoWorks ICM. The script will automatically delete all non-Base scenarios, create new scenarios based on the predefined list, and print a thank you message.

## Note

This script is originally sourced from [here](https://github.com/ngerdts7/ICM_Tools123) and has been edited for use with ChatGPT.

## Naming Convention

The naming convention for tables in InfoWorks ICM is different. Instead of starting with sw_, tables in ICM usually start with hw_ (for "HydroWorks", the original name of InfoWorks ICM). The field names within these tables can also be different between SWMM and ICM.  Ruby code with the prefix hw_sw can be used in both ICM and SWMM

# Ruby Script: Scenario Generator for ICM InfoWorks

This script is used to manage scenarios in an InfoWorks ICM application.

## Steps

1. The script first accesses the current network in the application.

2. It defines an array of scenario names, starting from "Phase1" and going up to "Phase10".

3. The script then iterates over each scenario in the current network. If the scenario name is not 'Base', it deletes the scenario. This effectively removes all scenarios except for the 'Base' scenario.

4. After deleting the unnecessary scenarios, the script iterates over the predefined array of scenario names. For each name, it adds a new scenario to the current network with that name.

5. Finally, the script prints a thank you message.

## Ruby Code

```ruby
# ... (code omitted for brevity)

# usage example
current_network = WSApplication.current_network
# ... (code omitted for brevity)