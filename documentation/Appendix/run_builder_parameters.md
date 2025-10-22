{WSPRO}

# WSRunBuilder Parameters

Although there are many parameters listed below, most map to the appropriate field names.

## Common Parameters

The following runs can be configured and run from Exchange.

- Normal Hydraulic (0)
- Calibration (1)
- Water Quality (2)
- Watsed (4)
- Critical Link (6)
- Break / Shutdown (7)

You can set parameters for other run types, but you cannot start them from Exchange.

### Run Options

| **Name**                     | **Description** | **Type**  | **Notes**                                     |
| ---------------------------- | --------------- | :-------: | --------------------------------------------- |
| ro_l_run_type                |                 |  Integer  | See notes above for the integer values to use |
| ro_s_run_title               |                 |  String   |                                               |
| ro_l_geometry_id             |                 |  Integer  |                                               |
| ro_l_geometry_commit_id      |                 |  Integer  |                                               |
| ro_l_control_id              |                 |  Integer  |                                               |
| ro_l_control_commit_id       |                 |  Integer  |                                               |
| ro_l_demand_diagram_id       |                 |  Integer  |                                               |
| ro_dte_start_date_time       |                 | Date Time |                                               |
| ro_dte_end_date_time         |                 | Date Time |                                               |
| ro_b_disconnected_system     |                 |  Boolean  |                                               |
| ro_b_eghgf                   |                 |  Boolean  |                                               |
| ro_b_experimental            |                 |  Boolean  |                                               |
| ro_b_gmr_enable              |                 |  Boolean  |                                               |
| ro_b_optimise                |                 |  Boolean  |                                               |
| ro_b_pressure_related_demand |                 |  Boolean  |                                               |
| ro_b_results_on_server       |                 |  Boolean  |                                               |
| ro_b_store_details           |                 |  Boolean  |                                               |
| ro_b_store_max               |                 |  Boolean  |                                               |
| ro_f_computational_accuracy  |                 |   Float   |                                               |
| ro_l_alt_demand_commit_id    |                 |  Integer  |                                               |
| ro_l_alt_demand_id           |                 |  Integer  |                                               |
| ro_l_demand_scaling_id       |                 |  Integer  |                                               |
| ro_l_electricity_tariff_id   |                 |  Integer  |                                               |
| ro_l_gmr_config_id           |                 |  Integer  |                                               |
| ro_l_max_iterations          |                 |  Integer  |                                               |
| ro_l_result_time_step        |                 |  Integer  |                                               |
| ro_l_results_selector_id     |                 |  Integer  |                                               |
| ro_l_rtc_id                  |                 |  Integer  |                                               |
| ro_l_test_cases_per_thread   |                 |  Integer  |                                               |
| ro_l_time_step               |                 |  Integer  |                                               |
| ro_n_demand_timestep         |                 |  Integer  |                                               |
| ro_n_results_selection_mode  |                 |  Integer  |                                               |

### Pressure Related Demand

| **Name**           | **Description** | **Type** | **Notes** |
| ------------------ | --------------- | :------: | --------- |
| pd_l_profile_id    |                 | Integer  |           |
| pd_s_demand_curve  |                 |  String  |           |
| pd_s_leakage_curve |                 |  String  |           |

### Physical Parameters

| **Name**       | **Description** | **Type** | **Notes** |
| -------------- | --------------- | :------: | --------- |
| py_d_density   |                 |  Float   |           |
| py_d_gravity   |                 |  Float   |           |
| py_d_viscosity |                 |  Float   |           |

### Hot Start

| **Name**           | **Description** | **Type** | **Notes** |
| ------------------ | --------------- | :------: | --------- |
| hs_b_save_state    |                 | Boolean  |           |
| hs_l_simulation_id |                 | Integer  |           |
| hs_s_save_times    |                 |  String  |           |
| hs_s_start_times   |                 |  String  |           |

### Other

| **Name**            | **Description** | **Type** | **Notes** |
| ------------------- | --------------- | :------: | --------- |
| In_b_validate_model |                 | Boolean  |           |
| In_b_validate_run   |                 | Boolean  |           |

## Supported Runs

These runs can be configured and launched from Exchange.

### Calibration

ro_l_run_type = 1

| **Name**                 | **Description** | **Type**  | **Notes** |
| ------------------------ | --------------- | :-------: | --------- |
| ca_dte_snapshot_time     |                 | Date Time |           |
| ca_f_init_scaling_factor |                 |   Float   |           |
| ca_f_max_friction        |                 |   Float   |           |
| ca_f_min_friction        |                 |   Float   |           |
| ca_l_live_data_commit_id |                 |  Integer  |           |
| ca_l_live_data_id        |                 |  Integer  |           |
| ca_s_friction_type       |                 |  String   |           |

### Water Quality

ro_l_run_type = 2

| **Name**                    | **Description** | **Type** | **Notes**           |
| --------------------------- | --------------- | :------: | ------------------- |
| wq_b_conservative_substance |                 | Boolean  |                     |
| wq_b_langrangian_solver     |                 | Boolean  |                     |
| wq_b_langrangian_solver     |                 | Boolean  |                     |
| wq_b_turbidity_analysis     |                 | Boolean  |                     |
| wq_b_turbidity_analysis     |                 | Boolean  |                     |
| wq_d_age_tolerance          |                 |  Float   |                     |
| wq_d_age_tolerance          |                 |  Float   |                     |
| wq_d_conc_tolerance         |                 |  Float   |                     |
| wq_d_conc_tolerance         |                 |  Float   |                     |
| wq_d_trace_tolerance        |                 |  Float   |                     |
| wq_d_trace_tolerance        |                 |  Float   |                     |
| wq_d_turbidity_tolerance    |                 |  Float   |                     |
| wq_d_turbidity_tolerance    |                 |  Float   |                     |
| wq_f_init_concentration     |                 |  Float   |                     |
| wq_f_min_flow               |                 |  Float   |                     |
| wq_l_solute_data_id         |                 | Integer  |                     |
| wq_l_timestep               |                 | Integer  |                     |
| wq_trace_node_0 .. 29       |                 |  String  | Fields from 0 to 29 |

### WatSed

ro_l_run_type = 4

| **Name**               | **Description** | **Type** | **Notes** |
| ---------------------- | --------------- | :------: | --------- |
| ws_f_deposition_limit  |                 |  Float   |           |
| ws_f_sediment_density  |                 |  Float   |           |
| ws_f_sediment_diameter |                 |  Float   |           |
| ws_f_suspension_limit  |                 |  Float   |           |
| ws_s_sediment_name     |                 |  String  |           |

### Critical Link Analysis (CLA)

ro_l_run_type = 6

| **Name**                        | **Description** | **Type**  | **Notes** |
| ------------------------------- | --------------- | :-------: | --------- |
| cl_b_allow_flow                 |                 |  Boolean  |           |
| cl_b_include_burst              |                 |  Boolean  |           |
| cl_b_report_outage_only         |                 |  Boolean  |           |
| cl_b_update_criticality         |                 |  Boolean  |           |
| cl_dte_specified_time           |                 | Date Time |           |
| cl_f_burst_duration             |                 |   Float   |           |
| cl_f_burst_rate                 |                 |   Float   |           |
| cl_f_demand_efficiency          |                 |   Float   |           |
| cl_f_duration                   |                 |   Float   |           |
| cl_f_max_pressure               |                 |   Float   |           |
| cl_f_min_pressure               |                 |   Float   |           |
| cl_f_outage_duration            |                 |   Float   |           |
| cl_l_exclude_links_selection_id |                 |  Integer  |           |
| cl_l_ignore_count               |                 |  Integer  |           |
| cl_l_include_links_selection_id |                 |  Integer  |           |
| cl_n_count_affected             |                 |  Integer  |           |
| cl_n_link_outage_period         |                 |  Integer  |           |

### Break / Shutdown

ro_l_run_type = 7

| **Name**                      | **Description** | **Type**  | **Notes** |
| ----------------------------- | --------------- | :-------: | --------- |
| bs_b_whole_simulation_outage  |                 |  Boolean  |           |
| bs_dte_shutdown_end           |                 | Date Time |           |
| bs_dte_shutdown_start         |                 | Date Time |           |
| bs_f_lower_threshold_duration |                 |   Float   |           |
| bs_f_max_dec_lower_threshold  |                 |   Float   |           |
| bs_f_max_inc_upper_threshold  |                 |   Float   |           |
| bs_f_max_press_duration       |                 |   Float   |           |
| bs_f_max_pressure             |                 |   Float   |           |
| bs_f_min_press_duration       |                 |   Float   |           |
| bs_f_min_pressure             |                 |   Float   |           |
| bs_f_upper_threshold_duration |                 |   Float   |           |
| bs_l_base_simulation_id       |                 |  Integer  |           |
| bs_l_close_link_selection_id  |                 |  Integer  |           |

## Unsupported Runs

These runs can be configured, but cannot be launched from Exchange.

### Optimiser

| **Name**                   | **Description** | **Type** | **Notes** |
| -------------------------- | --------------- | :------: | --------- |
| op_b_start_from_existing   |                 | Boolean  |           |
| op_b_update_control_data   |                 | Boolean  |           |
| op_d_crossover_prob        |                 |  Float   |           |
| op_d_mutation_prob         |                 |  Float   |           |
| op_d_profile_time_interval |                 |  Float   |           |
| op_l_population_size       |                 | Integer  |           |

### Fireflow

| **Name**                            | **Description** | **Type**  | **Notes**          |
| ----------------------------------- | --------------- | :-------: | ------------------ |
| ff_b_apply_constraints_demand_nodes |                 |  Boolean  |                    |
| ff_b_calculate_hydrant_curve        |                 |  Boolean  |                    |
| ff_b_calculate_max_flow             |                 |  Boolean  |                    |
| ff_b_cancel_existing_flow           |                 |  Boolean  |                    |
| ff_b_insert_node                    |                 |  Boolean  |                    |
| ff_b_pressure_at_min_and_max        |                 |  Boolean  |                    |
| ff_b_system_constraints             |                 |  Boolean  |                    |
| ff_b_zone_constraints               |                 |  Boolean  |                    |
| ff_dte_fire_time                    |                 | Date Time |                    |
| ff_f_fire_flow                      |                 |   Float   |                    |
| ff_f_hydrant_diameter               |                 |   Float   |                    |
| ff_f_local_loss                     |                 |   Float   |                    |
| ff_f_max_velocity                   |                 |   Float   |                    |
| ff_f_min_node_pressure              |                 |   Float   |                    |
| ff_f_min_system_pressure            |                 |   Float   |                    |
| ff_f_residual_pressure              |                 |   Float   |                    |
| ff_f_split_pipe_distance            |                 |   Float   |                    |
| ff_l_data_id                        |                 |  Integer  |                    |
| ff_l_selection_id                   |                 |  Integer  |                    |
| ff_n_close_pipe_option              |                 |  Integer  |                    |
| ff_n_data_usage                     |                 |  Integer  |                    |
| ff_n_Enforce                        |                 |  Integer  |                    |
| ff_n_simulation_type                |                 |  Integer  |                    |
| ff_s_existing_node_id               |                 |  String   |                    |
| ff_s_split_pipe_id                  |                 |  String   |                    |
| ff_test_flow_0 .. 9                 |                 |   Float   | Fields from 0 to 9 |
