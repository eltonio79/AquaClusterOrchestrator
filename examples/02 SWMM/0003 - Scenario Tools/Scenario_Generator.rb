# Original Source https://github.com/ngerdts7/ICM_Tools123
# RED + ChatGPT edits 

current_network = WSApplication.current_network

THANK_YOU_MESSAGE = 'Thank you for using Ruby in ICM InfoWorks'

scenarios=Array.new
scenarios = [ 
"FUTURE_II",
"FUTURE_II_2023",
"FUT_II_I25",
"FU_II_ALT1_I25_LS",
"U_II_ALT1_I25_LS"
]

current_network.scenarios do |scenario|
    if scenario != 'Base'
        current_network.delete_scenario(scenario)
    end
end
puts 'All scenarios deleted'

scenarios.each do |scenario|
	current_network.add_scenario(scenario,nil,'')
  end

puts THANK_YOU_MESSAGE

