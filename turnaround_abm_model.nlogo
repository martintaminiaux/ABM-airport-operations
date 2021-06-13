;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Title : ABM in airport management
; Authors : PAJOT Robin and TAMINIAUX Martin
; Created on December 10th 2020
; Last update on June 9th 2021
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; PROCEDURES are in capital letters, variables in lower cases
; Function arguments are put between parenthesis for clarity : PROC (ARG 1) (...) (ARG N)





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;DEFINITION OF THE GLOBAL VARIABLES

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

extensions[CSV] ;to report directly in CSV files


globals[
  ;globals variables that are comment are declared with buttons in the interface

  ;VARIABLES USED AS INPUT

  ;variables indicating which plane arrives at which stand at what time / lists of ints
  SIBT_list         ; time schedule of the arrival at the stand of each plane of the day (SIBT = scheduled in-block time) [sec]
  AIBT_list         ; actual time of the arrival at the stand of each plane of the day (AIBT = actual in-block time) (take underterministic delays into account) [sec]
  SOBT_list         ; time schedule of the departure of the stand of each plane of the day (SOBT = scheduled off-block time) [sec]
  stand_schedule    ; corresponding stand assignation list
  type_schedule     ; corresponding plane type list

  first_schedule        ; True if this is the first scheduling for Moontecarlo / bool
  lower_bounds_mean     ; computed from Montecarlo / list of float [sec]
  upper_bounds_mean     ; computed from Montecarlo / list of float [sec]
  lower_bounds_raw      ; computed from Montecarlo / list of float [sec]
  upper_bounds_raw      ; computed from Montecarlo / list of float [sec]
  mean_CI               ;
  turnaround_duration


  ;variables indicating how far we are in the day and describe what has happened
  number_of_TA    ; total number of turnarounds during the day / int
  finished_TA     ; number of TA that has been finished at time t / int
  actual_OBT      ; observed off-block time / int [sec]


  ;variables informing about the equipment available in the airport / ints
  number_of_stands
  ;number_of_fueling_trucks
  ;number_of_cleaning_trucks
  ;number_of_catering_trucks
  ;number_of_bulk_trains
  ;number_of_ULD_trains

  ;variables avout the starting time of specific processes
  ;beginning_factor_loading     ; the loading start (if possible) at SOBT - max_loading_planned_time (1 + factor)
  ;beginning_factor_boarding    ; the boarding start (if possible) at SOBT - max_boarding_planned_time (1 + factor)


  ; USE CASE : beginning hour and finishing hour / float
  ;beginning_hour
  ;finishing_hour

  ;time margins
  before_margin ; the equipments must be available at the stand a before_margin period before the scheduled time of their first action at each stand (if no retards) / int [min]
  after_margin  ; the equipments must be dedicated at the stand a after_margin period after the scheduled end time of their last action at each stand / int [min]

  ;FOR DELAYS
  ;mean_delay ;mean of the delay distribution / float
  ;std_delay  ;standard deviation of the delay distribution / float

  ;FOR SCHEDULING METHOD
  ;scheduling_method ; indicate the scheduling method for the agents / int

  ;VARIABLES USED FOR THE MODELING
  time      ; indicate the current time step of the turnaround / int

  ;defined as buttons :
  ;time_step     ; time step (in seconds) during each turnaround simulation step / int
  ;print_bool  ; print what happen at each time step of the turnaround if true / bool

  ;INDEX VARIABLES (incicating the index of the first agent of each type) / ints
  index_0_stand
  index_0_fuel
  index_0_clean
  index_0_cater
  index_0_bulk
  index_0_cargo


  ;VARIABLES FOR TRAVELL TIME / matrix of float [sec]
  travel_time_fuel_trucks
  travel_time_cater_trucks
  travel_time_clean_trucks
  travel_time_bulk_ul         ;for bulk trains, action at stand 1/stand 2 : unloading/loading
  travel_time_bulk_lu         ;for bulk trains, action at stand 1/stand 2 : loading/unloading
  travel_time_bulk_ll         ;for bulk trains, action at stand 1/stand 2 : loading/loading
  travel_time_bulk_uu         ;for bulk trains, action at stand 1/stand 2 : unloading/unloading
  travel_time_cargo_ul        ;for ULD trains, action at stand 1/stand 2 : unloading/loading
  travel_time_cargo_lu        ;for ULD trains, action at stand 1/stand 2 : loading/unloading
  travel_time_cargo_ll        ;for ULD trains, action at stand 1/stand 2 : loading/loading
  travel_time_cargo_uu        ;for ULD trains, action at stand 1/stand 2 : unloading/unloading


  ;VARIABLES RELATIVE TO THE TIME DISTRIBUTION OF EACH PROCESS OF EACH AIRCRAFT
  ;They are lists of size number_of_different_aicraft_types
  ; mean (=average time) of each process : corresponds to the manufacturer announced time / float
  mean_deb
  mean_board
  mean_fuel
  mean_unload_bulk
  mean_load_bulk
  mean_unload_cont_1
  mean_load_cont_1
  mean_unload_cont_2
  mean_load_cont_2
  mean_catering_1
  mean_catering_2
  mean_catering_3
  mean_cleaning

  ; VARIABLES LINK TO THE REALIZATION OF PROCESSES AUTHORIZED WITH PASSENGERS
  ; they are also lise of  size number_of_different_aicraft_types
  fueling_bool_pass     ;True if fueling authorized with passengers on board
  catering_bool_pass    ;True if catering authorized with passengers on board
  cleaning_bool_pass    ;True if cleaning authorized with passengers on board





  ; DISTRIBUTION PARAMETERS
  ; For generalized beta distributions, there are 4 parameters : alpha, beta, c and d
  ; We have :
  ;     -  X ~ Beta (alpha, beta)
  ;     -  Y = c+d*X  is the random variable that represents the process variable
  ; The parameters need to be computed once and for all according to the input

  s_coeff
  min_coeff
  max_coeff

  alpha_deb
  beta_deb
  c_deb
  d_deb

  alpha_board
  beta_board
  c_board
  d_board

  alpha_fuel
  beta_fuel
  c_fuel
  d_fuel

  alpha_unload
  beta_unload
  c_unload
  d_unload

  alpha_load
  beta_load
  c_load
  d_load

  alpha_catering_1
  beta_catering_1
  c_catering_1
  d_catering_1

  alpha_catering_2
  beta_catering_2
  c_catering_2
  d_catering_2

  alpha_catering_3
  beta_catering_3
  c_catering_3
  d_catering_3

  alpha_unload_bulk
  beta_unload_bulk
  c_unload_bulk
  d_unload_bulk

  alpha_unload_cont_1
  beta_unload_cont_1
  c_unload_cont_1
  d_unload_cont_1

  alpha_unload_cont_2
  beta_unload_cont_2
  c_unload_cont_2
  d_unload_cont_2

  alpha_load_bulk
  beta_load_bulk
  c_load_bulk
  d_load_bulk

  alpha_load_cont_1
  beta_load_cont_1
  c_load_cont_1
  d_load_cont_1

  alpha_load_cont_2
  beta_load_cont_2
  c_load_cont_2
  d_load_cont_2

  alpha_cleaning
  beta_cleaning
  c_cleaning
  d_cleaning

  ; MONTECARLO needed global variables
  TA_list                     ; will contain lists of lists [l_1 l_2 l_3 l_4 ... l_n] where l_i contains the actual off-block time of each turnaround of scheduled day and n is the number of simulations with agent-based modelling using Montecarlo
  TA_list_sum_distributions   ; will contain lists of lists [l_1 l_2 l_3 l_4 ... l_n] where l_i contains the actual off-block time of each turnaround of scheduled day and n is the number of simulations without agent-based modeling (only the sum of the timings) using Montecarlo



]






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; DEFINITION OF THE DIFFERENT AGENTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;they are defined by a word (singular and plurial in order to use only one of them or the full type)

; base agent
breed [stands stand]


; mobile agents
breed [fueling_trucks fueling_truck]
breed [cleaning_trucks cleaning_truck]
breed [catering_trucks catering_truck]
breed [bulk_trains bulk_train]
breed [ULD_trains ULD_train]







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;DEFINITION OF VARIABLES SPECIFIC TO AGENTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;For all agents
turtles-own[      ; turtles represent every agents

  ;variables indicating at which stands, on which plane types and at which times the agent works [sec]
  schedule              ; list of the different time at which the agent is needed / list of ints
  stand_assignation     ; corresponding stands (to the schedule) / list of ints
  plane_type            ; corresponding plane types (to the schedule) / list of ints
  processes_types       ; to indicate which process must be done for agent doing diffent types of processes (loading/unloading, ...) / list of ints
  index_TA              ; indicate the index of the turnaround on which the agent must work / list of ints
  travel_times          ; indicate the travel times from stand to stand / list of ints

  ;variables used for the first initialisation (in order to not perform the scheduling several times for a same input) [sec]
  schedule_init           ; list of the different time at which the agent is needed / list of ints
  stand_assignation_init  ; corresponding stands (to the schedule) / list of ints
  plane_type_init         ; corresponding plane types (to the schedule) / list of ints
  processes_types_init    ; to indicate which process must be done for agent doing diffent types of processes (loading/unloading, ...) / list of ints
  index_TA_init           ; indicate the index of the turnaround on which the agent must work / list of ints
  travel_times_init       ; indicate the travel times from stand to stand / list of ints
  next_free_time_init     ; indicate the next free time of the agent comparing to its previous sceduled action / int
  active_travel_time_init ; indicate the travel time left of the agent begore reaching its next stand / int

  ;information about the current action of the agent
  active_stand          ; stand number of the stand at which the agent is (0 if not at a stand) / int
  active_plane_type     ; plane type of the turnaround on which the agent is active / int
  active_TA             ; index of the turnaround on which the agent is active / int
  active_process_type   ; type of the process that the agent is doing / int
  active_travel_time    ;travel time left of the agent begore reaching its next stand / int
  next_free_time        ; next time value at which the agent will be free (based on planning) / int
  activity_done         ; True only during the single time steps at which the activity is over / bool

  ;constant variable
  agent_index           ; describe the indice number of the agent (fixed) / int

  ; to evaluate delay

  start_action          ; True only if the action is started on the current time step / bool
  delay_schedule_in     ; difference between the scheduled and actual start of each action of the agent / list of ints [sec]
  delay_schedule_out    ; difference between the scheduled and actual start of end action of the agent / list of ints [sec]
  mean_delay_in         ; mean of delay_schedule_in over n simulations / list of ints [sec]
  mean_delay_out        ; mean of delay_schedule_out over n simulations / list of ints [sec]



]


;For stands specific agent, it contains all variables with value specific to given turnarounds (depending on the plane type)
stands-own[


  ; VARIABLES TO DETERMINE THE STATE OF THE PROCESSES

  ;linked to deboarding/boarding
  boarding_beginning_time
  deboarding_done
  boarding_done

  ; linked to fueling
  fueling_done            ; true if the fueling is finished / bool

  ;linked to catering
  catering_done           ; true if the catering is finished / bool

  ;linked to cleaning
  cleaning_done           ; true if the cleaning is finished / bool

  ;linked to unloading/loading

  loading_done            ; true if the loading is finished / bool
  loading_beginning_time        ; when the loading is supposed to begin / int
  unloading_done          ; true if the unloading is finished / bool


  ; VARIABLES TO DETERMINE THE AUTHORIZED PROCESS WHEN PEOPLE ARE ONBOARD

  fueling_with_passengers  ; true if fueling allowed with passengers onboard / bool
  catering_with_passengers ; true if catering allowed with passengers onboard / bool
  cleaning_with_passengers ; true if cleaning allowed with passengers onboard / bool

  ; VARIABLES TO DETERMINE THE STATE OF THE TURNAROUND

  active_turnaround ; True if there is currently a turnaround at the stand / bool
  turnaround_done   ; true if the turnaround is finished / bool
  nothing_is_done   ; true if nothing is done during the specific time (buffer or waiting of an agent or pause) / bool



  ; VARIABLES TO DETERMINE REAL DURATION TIMES (depending on the distributions)

  ;linked to deboarding/boarding
  deboarding_time             ; time duration of the deboarding / int
  boarding_time               ; time duration of the boarding / int

  ;linked to fueling
  fueling_time                ; time duration for the fueling to be completed once started / int

  ; linked to catering
  catering_1_time             ; time duration to complete the 1st catering / int
  catering_2_time             ; time duration to complete the 2nd catering / int
  catering_3_time             ; time duration to complete the 3rd catering / int

  ;linked to unloading/loading
  unloading_bulk_time         ; time duration to complete the bulk unloading / int
  unloading_containers_1_time ; time duration to complete the FWD containers unloading / int
  unloading_containers_2_time ; time duration to complete the AFT containers unloading / int
  loading_bulk_time           ; time duration to complete the bulk unloading / int
  loading_containers_1_time   ; time duration to complete the FWD containers unloading / int
  loading_containers_2_time   ; time duration to complete the AFT containers unloading / int

  ;linked to cleaning
  cleaning_time               ; time duration of the cleaning / int



  ;VARIABLES TO DETERMINE THE PLANNING

  ;linked to deboarding/boarding
  deboarding_planned_time       ; planned time duration of the deboarding / int
  boarding_planned_time         ; planned time duration of the boarding / int


  ;linked to fueling
  fueling_planned_time          ; planned time duration for the fueling to be completed once started / int

  ; linked to catering
  catering_1_planned_time       ; planned catering 1 duration / int
  catering_2_planned_time       ; planned catering 2 duration / int
  catering_3_planned_time       ; planned catering 3 duration / int


  ;linked to unloading/loading
  unloading_bulk_planned_time         ; planned unloading bulk duration / int
  unloading_containers_1_planned_time ; planned unloading of the FWD containers / int
  unloading_containers_2_planned_time ; planned unloading of the AFT containers / int
  loading_bulk_planned_time           ; planned loading bulk duration / int
  loading_containers_1_planned_time   ; planned loading of the FWD containers / int
  loading_containers_2_planned_time   ; planned loading of the AFT containers / int


  ;linked to cleaning
  cleaning_planned_time         ; planned time duration of the cleaning / int



  ;VARIABLES TO DETERMINE BUFFERS

  ;general variable
  in_buffer       ; true if the specific time step corresponds to a buffer in the planning / bool


  ;planned buffer length (starting from the end of the planned activity)
  buffer_deboarding_planned_time      ; planned buffer duration after deboarding / int
  buffer_fueling_planned_time         ; planned buffer duration after fueling / int
  buffer_boarding_planned_time        ; planned buffer duration after boarding / int
  buffer_catering_planned_time        ; planned buffer duration after catering / int
  buffer_cleaning_planned_time        ; planned buffer duration after cleaning / int
  buffer_loading_planned_time         ; planned buffer duration after bulk loading / int
  buffer_unloading_planned_time       ; planned buffer duration after bulk unloading / int

  ;counter to determine the end of buffers
  buffer_deboarding_counter_time      ; counter initialized to planned buffer deboarding / int
  buffer_fueling_counter_time         ; counter initialized to planned buffer fueling / int
  buffer_boarding_counter_time        ; counter initialized to planned buffer boarding / int
  buffer_catering_counter_time        ; counter initialized to planned buffer catering / int
  buffer_cleaning_counter_time        ; counter initialized to planned buffer cleaning / int
  buffer_loading_counter_time         ; counter initialized to planned buffer  loading / int
  buffer_unloading_counter_time       ; counter initialized to planned buffer  unloading / int

]










;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; INITIALISATION FUNCTION TO PERFORM BEFORE ANY USE OF THE MODEL (reinitialize all variables)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to INIT

  ;reset of the memory
  clear-ticks
  clear-patches
  clear-drawing
  clear-all-plots
  clear-output
  reset-ticks
  if (first_schedule)[clear-turtles]


  set time 0   ; reset time value to 0

  if (first_schedule)[SETUP_INPUT]  ; initialize the variables relative to the inputs


  SETUP_AGENTS ; initialize the number of agents and their schedule

  if (first_schedule)[set first_schedule False]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; AGENTS INITIALIZATION AND SETTING UP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to SETUP_AGENTS
  if (first_schedule)[
    ; index setting up (to indicate the index of the first agent of each type)
    ; WARNING : the agents must be created in the same order
    set index_0_stand 0                                             ; first stand index
    set index_0_fuel (index_0_stand + number_of_stands + 1)         ; first fueling truck index (the +1 stands for the stand 0 (which is not a real stand))
    set index_0_cater (index_0_fuel + number_of_fueling_trucks)     ; first catering truck index
    set index_0_clean (index_0_cater + number_of_catering_trucks)   ; first cleaning truck index
    set index_0_cargo (index_0_clean + number_of_cleaning_trucks)   ; first ULD train index
    set index_0_bulk (index_0_cargo + number_of_ULD_trains)         ; first bulk train index



    ;AGENTS CREATION (must respect the same order than the setting up of )
    create-stands (number_of_stands + 1)                 ; create stands (stand 0 is a virtual stand which does not really exist)
    create-fueling_trucks (number_of_fueling_trucks)     ; create fueling trucks
    create-catering_trucks (number_of_catering_trucks)   ; create catering trucks
    create-cleaning_trucks (number_of_cleaning_trucks)   ; create cleaning trucks
    create-ULD_trains (number_of_ULD_trains)             ; create ULD trains
    create-bulk_trains (number_of_bulk_trains)           ; create bulk trains


    ;INITIALIZATION OF THE AGENT VARIABLES (0 for ints, empty lists for lists, initial value for bools)
    ask turtles [
      set next_free_time_init 0
      set plane_type_init []
      set schedule_init []
      set stand_assignation_init []
      set processes_types_init []
      set index_TA_init []
      set travel_times_init []
      set active_travel_time_init 0
      set next_free_time 0
      set plane_type []
      set schedule []
      set stand_assignation []
      set processes_types []
      set index_TA []
      set travel_times []
      set active_travel_time 0
    ]




    ; SETTING OF THE AGENT INDEX VALUES (each agent type has agents with index from 1 to agent_number)
    ask stands [set agent_index (who - index_0_stand)]                     ; no +1 since stand 0 is a virtual stand
    ask fueling_trucks [set agent_index (who - index_0_fuel + 1)]        ; +1 to start indices at 1 (not 0 as in Netlogo)
    ask catering_trucks [set agent_index (who - index_0_cater + 1)]
    ask cleaning_trucks [set agent_index (who - index_0_clean + 1)]
    ask ULD_trains [set agent_index (who - index_0_cargo + 1)]
    ask bulk_trains [set agent_index (who - index_0_bulk + 1)]
  ]



  ask turtles [
    set activity_done False
    set start_action False
    set delay_schedule_in []
    set delay_schedule_out []
  ]

  ; SETTING UP OF THE AGENTS VARIABLES AND SCHEDULES (times, stands and plane types)
  CREATE_STANDS_SCHEDULES
  CREATE_AGENT_SCHEDULE (fueling_trucks) ("fueling") (number_of_fueling_trucks) (1)
  CREATE_AGENT_SCHEDULE (catering_trucks) ("catering") (number_of_catering_trucks) (3) ; 3 processe types : cat 1 2 et 3
  CREATE_AGENT_SCHEDULE (cleaning_trucks) ("cleaning") (number_of_cleaning_trucks) (1)
  CREATE_AGENT_SCHEDULE (ULD_trains) ("cargo") (number_of_ULD_trains) (4)  ;4 processes types : two types loading/unloading
  CREATE_AGENT_SCHEDULE (bulk_trains) ("bulk") (number_of_bulk_trains) (2) ;2 processes type : one type loading/unloading

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; TURNAROUND VARIABLES INITIALIZATION AND SETTING UP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to SETUP_TA
  SETUP_PLANNING (active_plane_type) (active_TA) ; set up the initial planning of the different interactions
  set fueling_done False ; processes initially not done
  set catering_done False
  set cleaning_done False
  set unloading_done False
  set loading_done False
  set boarding_done False
  set deboarding_done False
  set turnaround_done False ; turnaround initailly not done
  set in_buffer False       ; initially not in a buffer
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; SETTING UP OF THE SCEDULES (times, stands and avion types)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to CREATE_STANDS_SCHEDULES ; for stands

  ; SETTING UP CLASSICAL VARIABLES
  ask stands [
    set active_stand who          ; the active stand of stands are their index, it always remains constant
    set active_turnaround false   ; initially, no turnaround happens at any stand
    set turnaround_done false     ; initially, no turnaround is done since no one has started

  ]


  ; SETTING UP OF THE VARIABLES OF THE SPECIFIC VIRTUAL stand 0
  ask stand 0 [
    let infinite (10 ^ 100)         ; representation of the infitinity
    set schedule (list infinite)    ; schedule sets at [+ inf], no turnaround will never happend at this stand
    set active_stand -1             ; active stand set at -1 (avoid confusion since active_stand = 0 will stands for inactivity)
  ]

  ;computation of the AIBT from the delays distribution
  let i 0
  set AIBT_list []
  let noise 0
  while [i < length SIBT_list][
    set noise random-normal mean_delay std_delay
    set AIBT_list lput (noise + item i SIBT_list) AIBT_list
    set i (i + 1)
  ]

  ; SCHEDULE CREATION BASED ON THE INPUT FOR THE GLOBAL AIRPORT
  ; the first elements in the lists are the first in time scale
  ; the i^th turnaround of a specific stand happens at schedule[i] and concerns a plane_type[i]
  set i 0                         ; loop variable initialization
  while [i < length (AIBT_list)][           ; loop over all the scheduled turnarounds in input
    ask stands with [agent_index = item i stand_schedule] [ ; ask stand concerned by turnaround i
      set schedule lput (item i AIBT_list) schedule       ; write the schedule of turnaround i at the end of the schedule list concerned by this turnaround
      set plane_type lput (item i type_schedule) plane_type  ; write the plane_type of turnaround i at the end of the plane_type list concerned by this turnaround
      set index_TA lput (i + 1) index_TA        ; write the index of the TA (starting from 1)
      set travel_times lput 0 travel_times]
    set i i + 1                       ; loop variable incrementation
  ]

end





to CREATE_AGENT_SCHEDULE [agent_name agent_surname number_of_agents number_of_processes_types] ;for mobile agents
  if (first_schedule)[ ; to create the initial variables

    ; creation of the paramaters list of ALL action required for the agent type
    let scheduled_need_list []
    let next_free_list []
    let full_processes_types []
    let full_index_TA []
    let i 0
    while [i < length SIBT_list][
      let j 1
      while [j <= number_of_processes_types][
        set scheduled_need_list lput (PLANNED_TIME ("scheduled_need") (j) (item i SIBT_list) (agent_surname) (item i type_schedule) (i + 1)) (scheduled_need_list)
        set next_free_list lput (PLANNED_TIME ("next_free") (j) (item i SIBT_list) (agent_surname) (item i type_schedule) (i + 1)) (next_free_list)
        set full_processes_types lput (j) (full_processes_types)
        set full_index_TA lput (i + 1) full_index_TA
        set j (j + 1)
      ]
      set i (i + 1)
    ]


    ; chronological sorting of the lists
    if (number_of_processes_types > 1) [ ;else already sorted
      let sorted_lists (QUICK_SORT (scheduled_need_list) (next_free_list) (full_processes_types) (full_index_TA) (0) ((length scheduled_need_list) - 1)) ; sort l1 and fit l2, l3 and l4 with corresponding indices
      set scheduled_need_list (item 0 sorted_lists)
      set next_free_list (item 1 sorted_lists)
      set full_processes_types (item 2 sorted_lists)
      set full_index_TA (item 3 sorted_lists)
    ]


    ; assignation of the actions to the different agent occurences
    (ifelse
      (scheduling_method = 1)[ ; SMALLER INDEX METHOD
        set i 0                                                                                                            ; first loop variable initialization
        let agent_assigned false                                                                                           ; boolean assignation (true if a truck has been assigned to time schedule i)

        while [i < length scheduled_need_list][                                                                            ; loop over all scheduled turnarounds in input



          set agent_assigned false                                                                                         ; setting the boolean on false at the beginning of the attribution of each new schedule
          let j 1                                                                                                                                    ; second loop variable initialization
          let this_TA (item i full_index_TA)
          if (item i next_free_list != "activity not done during this TA")[
            while [j <= number_of_agents][                                                                                              ; loop over all the agents of type agent_name
              ask agent_name with [agent_index = j][
                let this_travel_time (TRAVEL_TIME_FROM_AGENT_VAR (agent_surname) (item (this_TA - 1) stand_schedule) (item i full_processes_types))
                if (next_free_time_init + this_travel_time <= (item i scheduled_need_list))[            ; if condition : true if the next planned free time of agent j permits it to be available when needed at turnaround i (at the beginning of the process, not the beginning of the turnaround (before_margin included))
                  set j (number_of_agents + 1)                                                                                             ; second loop variable update to exit the loop (since free agent found)
                  set agent_assigned True                                                                                                                     ; an agent has been found, it is assigned to the current turnaround
                  set schedule_init lput (item i scheduled_need_list) schedule_init ; adding the turnaround to the time schedule of the assigned agent
                  set travel_times_init lput (this_travel_time) travel_times_init
                  set stand_assignation_init lput (item (this_TA - 1) stand_schedule) stand_assignation_init                                                                        ; adding the turnaround to the stand schedule of the assigned agent
                  set plane_type_init lput (item (this_TA - 1) type_schedule) plane_type_init;                                                                                    ; adding the turnaround to the plane_type schedule of the assigned agent
                  set next_free_time_init (item i next_free_list)                 ; next free moment update (since an acitivty has been added)
                  set processes_types_init lput (item i full_processes_types) processes_types_init
                  set index_TA_init lput (this_TA) index_TA_init
                ]
              ]
              set j (j + 1)                                                                                            ; second loop variable incrementation
            ]
            ; first loop variable incrementation
            if (agent_assigned != True)[                                                                                        ; error message if no agent is available for turnaround i
                                                                                                                                ;type "A " type agent_surname print " truck is missing in order to have a perfect planning. "
                                                                                                                                ;type "Turnaround " type this_TA print "will probably have to wait it. "
              ask min-one-of agent_name [next_free_time_init + (TRAVEL_TIME_FROM_AGENT_VAR (agent_surname) (item (this_TA - 1) stand_schedule) (item i full_processes_types))][
                let this_delay (next_free_time_init + (TRAVEL_TIME_FROM_AGENT_VAR (agent_surname) (item (this_TA - 1) stand_schedule) (item i full_processes_types)) - (item i scheduled_need_list))
                set next_free_time_init ((item i next_free_list) + this_delay) ; next free moment update (since an acitivty has been added)
                set schedule_init lput ((item i scheduled_need_list) + this_delay) schedule_init ; adding the turnaround to the time schedule of the assigned agent
                set travel_times_init lput (TRAVEL_TIME_FROM_AGENT_VAR (agent_surname) (item (this_TA - 1) stand_schedule) (item i full_processes_types)) travel_times_init
                set stand_assignation_init lput (item (this_TA - 1) stand_schedule) stand_assignation_init ; adding the turnaround to the stand schedule of the assigned agent
                set plane_type_init lput (item (this_TA - 1) type_schedule) plane_type_init; ; adding the turnaround to the plane_type schedule of the assigned agent
                set processes_types_init lput (item i full_processes_types) processes_types_init
                set index_TA_init lput (this_TA) index_TA_init
              ]
            ]
          ]
          set i (i + 1)
        ]
      ]


      (scheduling_method = 2)[ ; HOMOGENEOUS METHOD
        set i 0
        let j 1
        while [i < length scheduled_need_list][
          let this_TA (item i full_index_TA)
          if (item i next_free_list != "activity not done during this TA")[
            ask agent_name with [agent_index = j][
              let this_delay (next_free_time_init + (TRAVEL_TIME_FROM_AGENT_VAR (agent_surname) (item (this_TA - 1) stand_schedule) (item i full_processes_types)) - (item i scheduled_need_list))
              set this_delay (max (list this_delay 0))
              set next_free_time_init ((item i next_free_list) + this_delay) ; next free moment update (since an acitivty has been added)
              set schedule_init lput ((item i scheduled_need_list) + this_delay) schedule_init ; adding the turnaround to the time schedule of the assigned agent
              set travel_times_init lput (TRAVEL_TIME_FROM_AGENT_VAR (agent_surname) (item (this_TA - 1) stand_schedule) (item i full_processes_types)) travel_times_init
              set stand_assignation_init lput (item (this_TA - 1) stand_schedule) stand_assignation_init ; adding the turnaround to the stand schedule of the assigned agent
              set plane_type_init lput (item (this_TA - 1) type_schedule) plane_type_init; ; adding the turnaround to the plane_type schedule of the assigned agent
              set processes_types_init lput (item i full_processes_types) processes_types_init
              set index_TA_init lput (this_TA) index_TA_init
            ]
            (ifelse
              (j = number_of_agents)[set j 1]
              [set j j + 1]
            )
          ]
          set i i + 1
        ]
      ]

      (scheduling_method = 3)[ ;SOONER AVAILABLE METHOD
        set i 0
        while [i < length scheduled_need_list][
          let this_TA (item i full_index_TA)
          if (item i next_free_list != "activity not done during this TA")[
            ask min-one-of agent_name [next_free_time_init + (TRAVEL_TIME_FROM_AGENT_VAR (agent_surname) (item (this_TA - 1) stand_schedule) (item i full_processes_types))][
              let this_delay (next_free_time_init + (TRAVEL_TIME_FROM_AGENT_VAR (agent_surname) (item (this_TA - 1) stand_schedule) (item i full_processes_types)) - (item i scheduled_need_list))
              set this_delay (max (list this_delay 0))
              set next_free_time_init ((item i next_free_list) + this_delay) ; next free moment update (since an acitivty has been added)
              set schedule_init lput ((item i scheduled_need_list) + this_delay) schedule_init ; adding the turnaround to the time schedule of the assigned agent
              set travel_times_init lput (TRAVEL_TIME_FROM_AGENT_VAR (agent_surname) (item (this_TA - 1) stand_schedule) (item i full_processes_types)) travel_times_init
              set stand_assignation_init lput (item (this_TA - 1) stand_schedule) stand_assignation_init ; adding the turnaround to the stand schedule of the assigned agent
              set plane_type_init lput (item (this_TA - 1) type_schedule) plane_type_init; ; adding the turnaround to the plane_type schedule of the assigned agent
              set processes_types_init lput (item i full_processes_types) processes_types_init
              set index_TA_init lput (this_TA) index_TA_init
            ]
          ]
          set i i + 1
        ]
      ]
    )

    ask agent_name [
      (ifelse
        (length travel_times_init > 0)[
          set active_travel_time_init (item 0 travel_times_init)
          set travel_times_init bf travel_times_init
        ]
        [set active_travel_time_init 0]
      )
    ]
  ]

  ask agent_name[
    set schedule schedule_init
    set stand_assignation stand_assignation_init
    set plane_type plane_type_init
    set next_free_time next_free_time_init
    set processes_types processes_types_init
    set index_TA index_TA_init
    set travel_times travel_times_init
    set active_travel_time active_travel_time_init
  ]
end


to-report PLANNED_TIME [time_type process_step SIBT agent_surname type_of_plane this_TA] ;
; Compute the needed time at the stand or its next free time relative to an action
; Input : the time type to return ('scheduled need' or 'next frre'), the process_type describing the action type, the SIBT of the turnaround, the identifiers surname of the agent type, the type of plane and the index of the TA
; Output : the needed time at the stand before the action or the next free time after the action

  let return_value SIBT
  let activity_scheduled False
  ask stand 0 [ ; stand 0 n'est pas une vraie stand et sert d'outil
    set active_plane_type  type_of_plane
    set active_TA this_TA
    SETUP_TA
    (ifelse

      ((agent_surname = "fueling") and (fueling_planned_time != 0)) [
        set activity_scheduled True
        if (fueling_with_passengers = False)[set return_value (return_value + deboarding_planned_time + buffer_deboarding_planned_time)]
        (ifelse
          (time_type = "scheduled_need")[]
          (time_type = "next_free")[set return_value (return_value + fueling_planned_time)]
        )
      ]

      (agent_surname = "catering")[
        if (catering_with_passengers = False) [set return_value (return_value + deboarding_planned_time + buffer_deboarding_planned_time)]
        (ifelse
          ((process_step = 1) and (catering_1_planned_time != 0))[
            set activity_scheduled True
            (ifelse
              (time_type = "scheduled_need")[]
              (time_type = "next_free")[set return_value (return_value + catering_1_planned_time)]
            )
          ]
          ((process_step = 2) and (catering_2_planned_time != 0))[
            set activity_scheduled True
            (ifelse
              (time_type = "scheduled_need")[]
              (time_type = "next_free")[set return_value (return_value + catering_2_planned_time)]
            )
          ]
          ((process_step = 3) and (catering_3_planned_time != 0))[
            set activity_scheduled True
            (ifelse
              (time_type = "scheduled_need")[]
              (time_type = "next_free")[set return_value (return_value + catering_3_planned_time)]
            )
          ]
        )
      ]

      ((agent_surname = "cleaning") and (cleaning_planned_time != 0))[
        set activity_scheduled True
        if (cleaning_with_passengers = False)[set return_value (return_value + deboarding_planned_time + buffer_deboarding_planned_time)]
        (ifelse
          (time_type = "scheduled_need")[]
          (time_type = "next_free")[set return_value (return_value + cleaning_planned_time)]
        )
      ]

      (agent_surname = "cargo")[
        (ifelse
          ((process_step = 1) and (unloading_containers_1_planned_time != 0))[ ;unload
            set activity_scheduled True
            (ifelse
              (time_type = "scheduled_need")[]
              (time_type = "next_free")[set return_value (return_value + unloading_containers_1_planned_time)]
            )
          ]
          ((process_step = 2) and (unloading_containers_2_planned_time != 0))[ ;unload
            set activity_scheduled True
            (ifelse
              (time_type = "scheduled_need")[]
              (time_type = "next_free")[set return_value (return_value + unloading_containers_2_planned_time)]
            )
          ]
          ((process_step = 3) and (loading_containers_1_planned_time != 0))[ ;load
            set activity_scheduled True
            set return_value (loading_beginning_time)
            (ifelse
              (time_type = "scheduled_need")[]
              (time_type = "next_free")[set return_value (return_value + loading_containers_1_planned_time)]
            )
          ]
          ((process_step = 4) and (loading_containers_2_planned_time != 0))[ ;load
            set activity_scheduled True
            set return_value (loading_beginning_time)
            (ifelse
              (time_type = "scheduled_need")[]
              (time_type = "next_free")[set return_value (return_value + loading_containers_2_planned_time)]
            )
          ]
        )
      ]

      (agent_surname = "bulk") [
        (ifelse
          ((process_step = 1) and (unloading_bulk_planned_time != 0))[ ;unload
            set activity_scheduled True
            (ifelse
              (time_type = "scheduled_need")[]
              (time_type = "next_free")[set return_value (return_value + unloading_bulk_planned_time)]
            )
          ]
          ((process_step = 2) and (loading_bulk_planned_time != 0))[ ;load
            set activity_scheduled True
            set return_value (loading_beginning_time)
            (ifelse
              (time_type = "scheduled_need")[]
              (time_type = "next_free")[set return_value (return_value + loading_bulk_planned_time)]
            )
          ]
        )
      ]

    )

    (ifelse
      (time_type = "scheduled_need")[set return_value (return_value - before_margin)]
      (time_type = "next_free")[set return_value (return_value + after_margin)]
    )



  ]
  (ifelse
    (activity_scheduled or time_type = "scheduled_need") [report return_value]
    [report ("activity not done during this TA")]
  )

end


to-report TRAVEL_TIME_FROM_AGENT_VAR [agent_surname stand_2 process_type_2]
; Compute the travel time between two stands
; Input : the identifiers surname of the agent type, the index of the destination stand and the process type to perform at this stand
; Output : the travel time from the previous stand of the agent to the destination stand

  let list_size (length stand_assignation_init)

  let stand_1 0
  let process_type_1 0
  (ifelse
    (list_size > 0) [
      set stand_1 (item (list_size - 1) stand_assignation_init)
      set process_type_1 (item (list_size - 1) processes_types_init)
    ]
    [
      set stand_1 0
      set process_type_1 process_type_2
    ]
  )

  report (TRAVEL_TIME (agent_surname) (stand_1) (stand_2) (process_type_1) (process_type_2))

end


to-report TRAVEL_TIME [agent_surname stand_1 stand_2 process_type_1 process_type_2]
; Compute the travel time between two stands
; Input : the identifiers surname of the agent type, the indices of the starting and destination stand and the process type to perform at these stands
; Output : the travel time from the previous stand of the agent to the destination stand

  (ifelse
    (agent_surname = "fueling")[
      report (item (stand_2) (item (stand_1) travel_time_fuel_trucks)) ; list (i,j) = list (i) (j) = item j (item i list) = dist de i à j
    ]
    (agent_surname = "catering")[
      report (item (stand_2) (item (stand_1) travel_time_cater_trucks))
    ]
    (agent_surname = "cleaning")[
      report (item (stand_2) (item (stand_1) travel_time_clean_trucks))
    ]
    (agent_surname = "cargo")[
      (ifelse
        ((process_type_1 = 1 or process_type_1 = 2) and (process_type_2 = 1 or process_type_2 = 2))[
          report (item (stand_2) (item (stand_1) travel_time_cargo_uu))
        ]
        ((process_type_1 = 1 or process_type_1 = 2) and (process_type_2 = 3 or process_type_2 = 4))[
          report (item (stand_2) (item (stand_1) travel_time_cargo_ul))
        ]
        ((process_type_1 = 3 or process_type_1 = 4) and (process_type_2 = 1 or process_type_2 = 2))[
          report (item (stand_2) (item (stand_1) travel_time_cargo_lu))
        ]
        ((process_type_1 = 3 or process_type_1 = 4) and (process_type_2 = 3 or process_type_2 = 4))[
          report (item (stand_2) (item (stand_2) travel_time_cargo_ll))
        ]
      )
    ]
    (agent_surname = "bulk")[
      (ifelse
        (process_type_1 = 1 and process_type_2 = 1)[
          report (item (stand_1) (item (stand_2) travel_time_bulk_uu))
        ]
        (process_type_1 = 1 and process_type_2 = 2)[
          report (item (stand_1) (item (stand_2) travel_time_bulk_ul))
        ]
        (process_type_1 = 2 and process_type_2 = 1)[
          report (item (stand_1) (item (stand_2) travel_time_bulk_lu))
        ]
        (process_type_1 = 2 and process_type_2 = 2)[
          report (item (stand_1) (item (stand_2) travel_time_bulk_ll))
        ]
      )
    ]


  )
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; CORE FUNCTIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to GO
;the rules of behavior of each agent according to the time reached by the clock

; set up any activity starting at this step time (turnaround or process)

  ask stands with [(length schedule) > 0 and item 0 schedule <= time and active_turnaround = False] [ ; si pas length = 0, plus de turnaround dans le schedule donc pas d'indice 0, active_turn sur False pour n'avoir qu'un seul TA à la fois
    set active_turnaround True
    set active_plane_type  (item 0 plane_type)
    set active_TA (item 0 index_TA)
    SETUP_TA ;if the next TA of the stand starts now, the stand is activated
  ]

  ask fueling_trucks with [(active_stand = 0) and ((length schedule) > 0) and ((item 0 schedule) <= time) and ((active_travel_time <= 0))][
    PPRINT "Fueling truck"
    PPRINT who
    PPRINT "has arrived at stand n° "
    PPRINT (item 0 stand_assignation)
    set active_stand (item 0 stand_assignation)
    set active_TA (item 0 index_TA)
    set active_process_type (item 0 processes_types)
  ]

  ask cleaning_trucks with [(active_stand = 0) and ((length schedule) > 0) and ((item 0 schedule) <= time) and ((active_travel_time <= 0))][
    PPRINT "Cleaning truck"
    PPRINT who
    PPRINT " has arrived at stand n° "
    PPRINT (item 0 stand_assignation)
    set active_stand (item 0 stand_assignation)
    set active_TA (item 0 index_TA)
    set active_process_type (item 0 processes_types)
  ]

  ask catering_trucks with [(active_stand = 0) and ((length schedule) > 0) and ((item 0 schedule) <= time) and ((active_travel_time <= 0))][
    PPRINT "Catering truck"
    PPRINT who
    PPRINT " has arrived at stand n° "
    PPRINT (item 0 stand_assignation)
    set active_stand (item 0 stand_assignation)
    set active_TA (item 0 index_TA)
    set active_process_type (item 0 processes_types)
  ]

  ask bulk_trains with [(active_stand = 0) and ((length schedule) > 0) and ((item 0 schedule) <= time) and ((active_travel_time <= 0))][
    PPRINT "Bulk train"
    PPRINT who
    PPRINT " has arrived at stand n° "
    PPRINT (item 0 stand_assignation)
    set active_stand (item 0 stand_assignation)
    set active_TA (item 0 index_TA)
    set active_process_type (item 0 processes_types)
  ]

  ask ULD_trains with [(active_stand = 0) and ((length schedule) > 0) and ((item 0 schedule) <= time) and ((active_travel_time <= 0))][
    PPRINT "ULD train"
    PPRINT who
    PPRINT " has arrived at stand n° "
    PPRINT (item 0 stand_assignation)
    set active_stand (item 0 stand_assignation)
    set active_TA (item 0 index_TA)
    set active_process_type (item 0 processes_types)
  ]



  ; turnaroud actions for active stands

  ask stands with [active_turnaround][
    TURNAROUND_STEP ;the active stands perform their TA
  ]
  ask turtles with [active_travel_time > 0][
    set active_travel_time (active_travel_time - time_step)
  ]

  ; set down any activity which is over

  ask stands with [turnaround_done][ ;the stands for which the TA is over must indicate it
                                     ;    let active_stand this
    set turnaround_done False ;the first TA of the schedule list is over
    set active_turnaround False ;there is no more TA process to do for this TA
    set schedule bf schedule ;remove the first schedule of the list (since finished)
    set plane_type bf plane_type ;remove the first plane type of the list (since finished)
    set actual_OBT replace-item (first index_TA - 1) actual_OBT time ; replace the OBT of the corresponding finished TA by the time
    set finished_TA finished_TA + 1 ; adds 1 to the number of finished turnarounds
    set index_TA bf index_TA
    set active_TA 0
  ]


  ask fueling_trucks with [activity_done][
    set activity_done False
    set active_stand 0 ;ready to go to a new stand
    set schedule bf schedule ;remove the first schedule of the list (since finished)
    set stand_assignation bf stand_assignation ; remove the first stand of the list (since work done on it)
    set index_TA bf index_TA
    set active_TA 0
    set processes_types bf processes_types
    set active_process_type 0
    (ifelse
      (length travel_times > 0)[
        set active_travel_time (item 0 travel_times)
        set travel_times bf travel_times
      ]
      [set active_travel_time 0]
    )
  ]

  ask catering_trucks with [activity_done][
    ;show travel_times
    set activity_done False
    set active_stand 0 ;ready to go to a new stand
    set schedule bf schedule ;remove the first schedule of the list (since finished)
    set stand_assignation bf stand_assignation ; remove the first stand of the list (since work done on it)
    set index_TA bf index_TA
    set active_TA 0
    set processes_types bf processes_types
    set active_process_type 0
    (ifelse
      (length travel_times > 0)[
        set active_travel_time (item 0 travel_times)
        set travel_times bf travel_times
        ;show "in length"
      ]
      [set active_travel_time 0]
    )
    ;show active_travel_time
  ]

  ask cleaning_trucks with [activity_done][
    set activity_done False
    set active_stand 0 ;ready to go to a new stand
    set schedule bf schedule ;remove the first schedule of the list (since finished)
    set stand_assignation bf stand_assignation ; remove the first stand of the list (since work done on it)
    set index_TA bf index_TA
    set active_TA 0
    (ifelse
      (length travel_times > 0)[
        set active_travel_time (item 0 travel_times)
        set travel_times bf travel_times
      ]
      [set active_travel_time 0]
    )
  ]

  ask bulk_trains with [activity_done][
    set activity_done False
    set active_stand 0 ;ready to go to a new stand
    set schedule bf schedule ;remove the first schedule of the list (since finished)
    set stand_assignation bf stand_assignation ; remove the first stand of the list (since work done on it)
    set index_TA bf index_TA
    set active_TA 0
    set processes_types bf processes_types
    set active_process_type 0
    (ifelse
      (length travel_times > 0)[
        set active_travel_time (item 0 travel_times)
        set travel_times bf travel_times
      ]
      [set active_travel_time 0]
    )
  ]

  ask ULD_trains with [activity_done][
    set activity_done False
    set active_stand 0 ;ready to go to a new stand
    set schedule bf schedule ;remove the first schedule of the list (since finished)
    set stand_assignation bf stand_assignation ; remove the first stand of the list (since work done on it)
    set index_TA bf index_TA
    set active_TA 0
    set processes_types bf processes_types
    set active_process_type 0
    (ifelse
      (length travel_times > 0)[
        set active_travel_time (item 0 travel_times)
        set travel_times bf travel_times
      ]
      [set active_travel_time 0]
    )
  ]

  set time (time + time_step)

  ; verification that every TA is done
  ask stand 0 [set schedule []] ; modification of the virtual stand to observe the TA realization
  if (all? stands [length schedule = 0])[
    PPRINT "all scheduled turnarounds are done"
    set finished_TA number_of_TA
  ]
  ask stand 0 [
    let infinite (10 ^ 100)
    set schedule (list infinite)
  ]
end


to TURNAROUND_STEP
  ; performing a turnaround step according to the different rules of behaviour
  PRINT_FUNCTION 1 ; print time

  BUFFER_BOOL_UPDATE ;set the values of the buffers boolean
  let this_stand active_stand ; define the current stand as the stand at which the turnaround is done
  let this_TA active_TA
  if turnaround_done = False [

    if unloading_done = False [
      UNLOADING this_stand this_TA
    ]
    if loading_done = False and unloading_done = True and time >= loading_beginning_time and buffer_unloading_counter_time <= 0[
      LOADING this_stand this_TA
    ]



    if (deboarding_done = False)  [ ; if the bridge is put and people are still on board, they debark
      DEBOARDING this_stand this_TA
    ]

    if (( (fueling_done = False ) or (catering_done = False ) or (cleaning_done = False)) )[ ; if people are not on board anymore, the buffer is finished and if the fueling has not be done yet (with the condtion than the fueling truck has arrived)  OR the catering has not been done yet (with the condtion than the catering truck has arrived) OR the cleaning has not been done yet , they can be done
      if (((buffer_deboarding_counter_time <= 0 and deboarding_done = True) or fueling_with_passengers = True)  and fueling_done = False ) [
        FUELING this_stand this_TA
      ]
      if (((buffer_deboarding_counter_time <= 0 and deboarding_done = True) or catering_with_passengers = True)  and  catering_done = False )[
        CATERING this_stand this_TA
      ]
      if (((buffer_deboarding_counter_time <= 0 and deboarding_done = True) or cleaning_with_passengers = True)  and cleaning_done = False )[
        CLEANING this_stand this_TA
      ]
    ]

    if (deboarding_done = True and boarding_done = False and ((cleaning_done = True and buffer_cleaning_counter_time <= 0)  or cleaning_with_passengers = True) and ((fueling_done = True and buffer_fueling_counter_time <= 0) or fueling_with_passengers = True) and ((catering_done = True and buffer_catering_counter_time <= 0) or catering_with_passengers = True) and buffer_fueling_counter_time <= 0 and time >= boarding_beginning_time) [ ; if the fueling is done, the passengers can embark at condition than the buffer between deboarding and fueling is finished (condition que personne dans l'avion utile ????????????????????????)
      BOARDING this_stand this_TA
    ]


    if (deboarding_done = True and unloading_done = True and loading_done = True and catering_done = True and fueling_done = True and cleaning_done = True and boarding_done = True)[
      if (buffer_boarding_counter_time <= 0 and buffer_loading_counter_time <= 0 and buffer_unloading_counter_time <= 0 and buffer_fueling_counter_time <= 0 and buffer_cleaning_counter_time <= 0 and buffer_catering_counter_time <= 0 and buffer_deboarding_counter_time <= 0)[
        set turnaround_done True
      ]
    ]


  ]

  PRINT_FUNCTION 2 ; print if nothing is done, if in buffer and print the left size of buffers and the end of the time step

  BUFFER_COUNT_UPDATE ; set the value of the buffer counters
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Functions relative to the buffers

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to BUFFER_BOOL_UPDATE ; set the in_buffer bool on true if the curent time is in the time planned period of a buffer, also set nothing_is_done bool on True since called at the beginning of eact turnaround
  ; update of the buffer booleans
  set nothing_is_done True
  set in_buffer False

  let deboarding_buffer_start (deboarding_planned_time - 1) ; -1 pcq les times commencent en 0

  let fueling_buffer_start (deboarding_buffer_start + buffer_deboarding_planned_time + fueling_planned_time)
  if (fueling_with_passengers)[
    set fueling_buffer_start (fueling_planned_time - 1)
  ]

  let catering_buffer_start (deboarding_buffer_start + buffer_deboarding_planned_time + max (list catering_1_planned_time catering_2_planned_time catering_3_planned_time))
  if (catering_with_passengers)[
    set catering_buffer_start ((max (list catering_1_planned_time catering_2_planned_time catering_3_planned_time)) - 1)
  ]

  let cleaning_buffer_start (deboarding_buffer_start + buffer_deboarding_planned_time + cleaning_planned_time)
  if (cleaning_with_passengers)[
    set cleaning_buffer_start (cleaning_planned_time - 1)
  ]

  let unloading_buffer_start ((max (list unloading_bulk_planned_time unloading_containers_1_planned_time unloading_containers_2_planned_time)) - 1)

  let loading_buffer_start (loading_beginning_time - 1)

  let boarding_buffer_start (boarding_beginning_time - 1)



  set in_buffer BUFFER_DETERMINATION (deboarding_buffer_start) (buffer_deboarding_counter_time) (in_buffer) (True)
  set in_buffer BUFFER_DETERMINATION (boarding_buffer_start) (buffer_boarding_counter_time) (in_buffer) (True)
  set in_buffer BUFFER_DETERMINATION (fueling_buffer_start) (buffer_fueling_counter_time) (in_buffer) (True)
  set in_buffer BUFFER_DETERMINATION (catering_buffer_start) (buffer_catering_counter_time) (in_buffer) (True)
  set in_buffer BUFFER_DETERMINATION (cleaning_buffer_start) (buffer_cleaning_counter_time) (in_buffer) (True)
  set in_buffer BUFFER_DETERMINATION (unloading_buffer_start) (buffer_unloading_counter_time) (in_buffer) (True)
  set in_buffer BUFFER_DETERMINATION (loading_buffer_start) (buffer_loading_counter_time) (in_buffer) (True)

end

to BUFFER_COUNT_UPDATE ; decrease the buffer counters by one if currently in the planned buffers
  let deboarding_buffer_start (deboarding_planned_time - 1) ; -1 becaus timings start at 0

  let fueling_buffer_start (deboarding_buffer_start + buffer_deboarding_planned_time + fueling_planned_time)
  if (fueling_with_passengers)[
    set fueling_buffer_start (fueling_planned_time - 1)
  ]

  let catering_buffer_start (deboarding_buffer_start + buffer_deboarding_planned_time + max (list catering_1_planned_time catering_2_planned_time catering_3_planned_time))
  if (catering_with_passengers)[
    set catering_buffer_start ((max (list catering_1_planned_time catering_2_planned_time catering_3_planned_time)) - 1)
  ]

  let cleaning_buffer_start (deboarding_buffer_start + buffer_deboarding_planned_time + cleaning_planned_time)
  if (cleaning_with_passengers)[
    set cleaning_buffer_start (cleaning_planned_time - 1)
  ]

  let unloading_buffer_start ((max (list unloading_bulk_planned_time unloading_containers_1_planned_time unloading_containers_2_planned_time)) - 1)

  let loading_buffer_start (loading_beginning_time - 1)

  let boarding_buffer_start (boarding_beginning_time - 1)



  set buffer_deboarding_counter_time BUFFER_DETERMINATION (deboarding_buffer_start) (buffer_deboarding_counter_time) (in_buffer) (False)
  set buffer_boarding_counter_time BUFFER_DETERMINATION (boarding_buffer_start) (buffer_boarding_counter_time) (in_buffer) (False)
  set buffer_fueling_counter_time BUFFER_DETERMINATION (fueling_buffer_start) (buffer_fueling_counter_time) (in_buffer) (False)
  set buffer_catering_counter_time BUFFER_DETERMINATION (catering_buffer_start) (buffer_catering_counter_time) (in_buffer) (False)
  set buffer_cleaning_counter_time BUFFER_DETERMINATION (cleaning_buffer_start) (buffer_cleaning_counter_time) (in_buffer) (False)
  set buffer_unloading_counter_time BUFFER_DETERMINATION (unloading_buffer_start) (buffer_unloading_counter_time) (in_buffer) (False)
  set buffer_loading_counter_time BUFFER_DETERMINATION (loading_buffer_start) (buffer_loading_counter_time) (in_buffer) (False)

end

to-report BUFFER_DETERMINATION [time_planned counting bool_buffer bool_return] ; function to perform the buffer bool and count update, bool_return indicates is true for bool update, false for counter update
  ; practical update of the boolean (if bool_return) or of the counter
  (ifelse
    time > time_planned and counting > 0 [
      ifelse bool_return[
        report True
      ]
      [
        report counting - time_step
      ]
    ]
    [
      ifelse bool_return[
        report bool_buffer
      ]
      [
        report counting
      ]
    ]
  )
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PROCESSES FUNCTIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to DEBOARDING [this_stand this_TA]
  set nothing_is_done False
  PPRINT "Deboarding"
  set deboarding_time deboarding_time - time_step
  if deboarding_time <= 0 [
    set deboarding_done True
  ]
end



to FUELING [this_stand this_TA]
  set nothing_is_done False
  (ifelse
    (any? fueling_trucks with [active_stand = this_stand and active_TA = this_TA]) [
      ; process realization
      if (fueling_time > 0) [;and communication_done = True [ ; else finish fueling
        let scheduled_start (item 0 schedule)
        if (fueling_with_passengers = False)[set scheduled_start (scheduled_start + deboarding_planned_time + buffer_deboarding_planned_time)]
        ask fueling_trucks with [active_stand = this_stand and active_TA = this_TA][
          ;delay computation
          if (start_action = False)[
            set start_action True
            set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
          ]
        ]

        PPRINT "Fueling being completed"
        set fueling_time fueling_time - time_step
      ]
      ;process stop
      if (fueling_time <= 0) [
        PPRINT "Fueling is done"
        set fueling_done True
        let scheduled_end (item 0 schedule + fueling_planned_time)
        if (fueling_with_passengers = False)[set scheduled_end (scheduled_end + deboarding_planned_time + buffer_deboarding_planned_time)]
        ask fueling_trucks with [active_TA = this_TA and active_stand = this_stand][
          set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
          set activity_done True
          set start_action False
        ]
      ]
    ]
    [PPRINT "No fueling truck is available"]
  )
end

to CATERING [this_stand this_TA]
  set nothing_is_done False
  (ifelse
    (any? catering_trucks with [active_stand = this_stand and active_TA = this_TA])[
      if (any? catering_trucks with [active_stand = this_stand and active_TA = this_TA and active_process_type = 1])[
        if (catering_1_time > 0 )[
          let scheduled_start (item 0 schedule)
          if (catering_with_passengers = False)[set scheduled_start (scheduled_start + deboarding_planned_time + buffer_deboarding_planned_time)]
          ask catering_trucks with [active_stand = this_stand and active_TA = this_TA and active_process_type = 1][
            if (start_action = False)[
              set start_action True
              set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
            ]
          ]
          set catering_1_time catering_1_time - time_step
          PPRINT "First catering being completed"
        ]
        if (catering_1_time <= 0 )[
          PPRINT "First catering is done"
          let scheduled_end (item 0 schedule + catering_1_planned_time)
          if (catering_with_passengers = False)[set scheduled_end (scheduled_end + deboarding_planned_time + buffer_deboarding_planned_time)]
          ask catering_trucks with [active_stand = this_stand and active_TA = this_TA and active_process_type = 1][
            set activity_done True
            set start_action False
            set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
          ]
        ]
      ]
      if (any? catering_trucks with [active_stand = this_stand and active_TA = this_TA and active_process_type = 2])[
        if (catering_2_time > 0 )[
          let scheduled_start (item 0 schedule)
          if (catering_with_passengers = False)[set scheduled_start (scheduled_start + deboarding_planned_time + buffer_deboarding_planned_time)]
          set catering_2_time catering_2_time - time_step
          PPRINT "Second catering being completed"
          ask catering_trucks with [active_stand = this_stand and active_TA = this_TA and active_process_type = 2][
            if (start_action = False)[
              set start_action True
              set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
            ]
          ]
        ]
        if (catering_2_time <= 0 )[
          PPRINT "Second catering is done"
          let scheduled_end (item 0 schedule + catering_2_planned_time)
          if (catering_with_passengers = False)[set scheduled_end (scheduled_end + deboarding_planned_time + buffer_deboarding_planned_time)]
          ask catering_trucks with [active_stand = this_stand and active_TA = this_TA and active_process_type = 2][
            set activity_done True
            set start_action False
            set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
          ]
        ]
      ]
      if (any? catering_trucks with [active_stand = this_stand and active_TA = this_TA and active_process_type = 3])[
        if (catering_3_time > 0 )[
          let scheduled_start (item 0 schedule)
          if (catering_with_passengers = False)[set scheduled_start (scheduled_start + deboarding_planned_time + buffer_deboarding_planned_time)]
          set catering_3_time catering_3_time - time_step
          PPRINT "Third catering being completed"
          ask catering_trucks with [active_stand = this_stand and active_TA = this_TA and active_process_type = 3][
            if (start_action = False)[
              set start_action True
              set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
            ]
          ]
        ]
        if (catering_3_time <= 0 )[
          PPRINT "Third catering is done"
          let scheduled_end (item 0 schedule + catering_3_planned_time)
          if (catering_with_passengers = False)[set scheduled_end (scheduled_end + deboarding_planned_time + buffer_deboarding_planned_time)]
          ask catering_trucks with [active_stand = this_stand and active_TA = this_TA and active_process_type = 3][
            set activity_done True
            set start_action False
            set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
          ]
        ]
      ]
      if (catering_1_time <= 0 and catering_2_time <= 0 and catering_3_time <= 0)[
        set catering_done True
        PPRINT "The whole catering is done"
      ]
    ]
    [PPRINT "No catering truck is available"]
  )
end


to CLEANING [this_stand this_TA]
  set nothing_is_done False
  (ifelse
    (any? cleaning_trucks with [active_stand = this_stand and active_TA = this_TA])[
      if (cleaning_time > 0 )[
        let scheduled_start (item 0 schedule)
        if (cleaning_with_passengers = False)[set scheduled_start (scheduled_start + deboarding_planned_time + buffer_deboarding_planned_time)]
        PPRINT "Cleaning being completed"
        ask cleaning_trucks with [active_stand = this_stand and active_TA = this_TA][
          if (start_action = False)[
            set start_action True
            set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
          ]
        ]
        set cleaning_time (cleaning_time - time_step)

      ]
      if (cleaning_time <= 0) [
        PPRINT "Cleaning is done"
        let scheduled_end (item 0 schedule + cleaning_planned_time)
        if (cleaning_with_passengers = False)[set scheduled_end (scheduled_end + deboarding_planned_time + buffer_deboarding_planned_time)]
        set cleaning_done True
        ask cleaning_trucks with [active_TA = this_TA and active_stand = this_stand][
          set activity_done True
          set start_action False
          set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
        ]
      ]
    ]
    [PPRINT "No cleaning truck is available"]
  )

end

to UNLOADING [this_stand this_TA]
  set nothing_is_done False
  (ifelse
    ((any? ULD_trains with [active_stand = this_stand and active_TA = this_TA and (active_process_type = 1 or active_process_type = 2)]) or (any? bulk_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 1]))[
      if (any? ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 1])[
        if (unloading_containers_1_time > 0)[
          let scheduled_start (item 0 schedule)
          PPRINT "First cargo unloading being completed"
          ask ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 1][
            if (start_action = False)[
              set start_action True
              set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
            ]
          ]
          set unloading_containers_1_time (unloading_containers_1_time - time_step)
        ]
        if (unloading_containers_1_time <= 0)[
          let scheduled_end (item 0 schedule + unloading_containers_1_planned_time)
          PPRINT "First cargo unloading done"
          ask ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 1][
            set activity_done True
            set start_action False
            set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
          ]
        ]
      ]
      if (any? ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 2])[
        if (unloading_containers_2_time > 0)[
          let scheduled_start (item 0 schedule)
          PPRINT "Second cargo unloading being completed"
          ask ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 2][
            if (start_action = False)[
              set start_action True
              set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
            ]
          ]
          set unloading_containers_2_time (unloading_containers_2_time - time_step)
        ]
        if (unloading_containers_2_time <= 0)[
          PPRINT "Second cargo unloading done"
          let scheduled_end (item 0 schedule + unloading_containers_2_planned_time)
          ask ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 2][
            set activity_done True
            set start_action False
            set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
          ]
        ]
      ]
      if (any? bulk_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 1])[
        if (unloading_bulk_time > 0)[
          let scheduled_start (item 0 schedule)
          PPRINT "Bulk unloading being completed"
          ask bulk_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 1][
            if (start_action = False)[
              set start_action True
              set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
            ]
          ]
          set unloading_bulk_time (unloading_bulk_time - time_step)
        ]
        if (unloading_bulk_time <= 0)[
          PPRINT "Bulk unloading done"
          let scheduled_end (item 0 schedule + unloading_bulk_planned_time)
          ask bulk_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 1][
            set activity_done True
            set start_action False
            set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
          ]
        ]
      ]
      if (unloading_containers_1_time <= 0 and unloading_containers_2_time <= 0 and unloading_bulk_time <= 0)[
        PPRINT "Unloading is completely done"
        set unloading_done True
      ]


    ]
    [PPRINT "No unloader available"]
  )

end


to LOADING [this_stand this_TA]
  set nothing_is_done False
  (ifelse
    ((any? ULD_trains with [active_stand = this_stand and active_TA = this_TA and (active_process_type = 3 or active_process_type = 4)]) or (any? bulk_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 2]))[
      if (any? ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 3])[
        if (loading_containers_1_time > 0)[
          PPRINT "First cargo loading being completed"
          let scheduled_start loading_beginning_time
          ask ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 3][
            if (start_action = False)[
              set start_action True
              set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
            ]
          ]
          set loading_containers_1_time (loading_containers_1_time - time_step)
        ]
        if (loading_containers_1_time <= 0)[
          PPRINT "First cargo loading done"
          let scheduled_end (loading_beginning_time + loading_containers_1_planned_time)
          ask ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 3][
            set activity_done True
            set start_action False
            set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
          ]
        ]
      ]
      if (any? ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 4])[
        if (loading_containers_2_time > 0)[
          PPRINT "Second cargo loading being completed"
          let scheduled_start loading_beginning_time
          ask ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 4][
            if (start_action = False)[
              set start_action True
              set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
            ]
          ]
          set loading_containers_2_time (loading_containers_2_time - time_step)
        ]
        if (loading_containers_2_time <= 0)[
          PPRINT "Second cargo loading done"
          let scheduled_end (loading_beginning_time + loading_containers_2_planned_time)
          ask ULD_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 4][
            set activity_done True
            set start_action False
            set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
          ]
        ]
      ]
      if (any? bulk_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 2])[
        if (loading_bulk_time > 0)[
          PPRINT "Bulk loading being completed"
          let scheduled_start loading_beginning_time
          ask bulk_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 2][
            if (start_action = False)[
              set start_action True
              set delay_schedule_in lput (time - scheduled_start) delay_schedule_in
            ]
          ]
          set loading_bulk_time (loading_bulk_time - time_step)
        ]
        if (loading_bulk_time <= 0)[
          let scheduled_end (loading_beginning_time + loading_bulk_planned_time)
          PPRINT "Bulk loading done"
          ask bulk_trains with [active_stand = this_stand and active_TA = this_TA and active_process_type = 2][
            set activity_done True
            set start_action False
            set delay_schedule_out lput (time - scheduled_end) delay_schedule_out
          ]
        ]
      ]
      if (loading_containers_1_time <= 0 and loading_containers_2_time <= 0 and loading_bulk_time <= 0)[
        PPRINT "Loading is completely done"
        set loading_done True
      ]

    ]
    [PPRINT "No loader available"]
  )

end

to BOARDING [this_stand this_TA]
  set nothing_is_done False

  PPRINT "Boarding"
  set boarding_time boarding_time - time_step
  if boarding_time <= 0 [
    set boarding_done True
  ]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; AIRCRAFT TYPE VARIABLES DEFINITION

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





; SETUP OF THE MEANS OF THE DIFFERENT PROCESSES FOR THE DIFFERENT AIRCRAFT TYPES
to SETUP_PLANE_DATA

  let z 0.42
  set min_coeff (list z z z z z z)
  let y 1.8
  set max_coeff (list y y y y y y)
  let x 0.05
  set s_coeff   (list x x x x x x)

  set mean_deb [9.35 7.5 6.55 10.76 9.222 8.222 7.58 9.075 6.48 4 3.375]
  set mean_board [15.75 12.67 11.08 20.1 11.83 10.33 11.97 13.92 10.13 5.5 4.563]
  set mean_fuel [21 21 21 50 19 19 46 32 27 15.2 12]


  set mean_unload_bulk [5.333 5.333 5.333 7.045 0 0 26 27 23 0 0]
  set mean_unload_cont_1 [9.5 6.5 5 24.1 15 14 26 28 20 5.3 4.6] ; ATTENTION : still 2 ULD trains for the "zero time"
  set mean_unload_cont_2 [9.5 8 5 19.3 15 14 22 0 16 4.5 3.7]


  set mean_load_bulk [5.667 5.667 5.667 7.763 0 0 26 30 25 0 0] ; ATTENTION : when zero, the sample really needs to be zero !
  set mean_load_cont_1 [9 6 4.5 27.7 22 21 26 28 22 8.1 6.8]
  set mean_load_cont_2 [9 7.5 4.5 22.1 22 21 22 0 18 6.8 5.4]


  set mean_catering_1 [18.7 18.7 15.1 14 18 15.8 29.5 34 21 8 8] ; if everything is sequential (1 catering truck), all the timings are in the catering_1 and the catring_2 and 3 are 0
  set mean_catering_2 [0 0 0 21.5 0 0 34 0 0 8 8] ; if 2 actions are performed in parallel, the first is in catering_1 and the 2nd in catering_2
  set mean_catering_3 [0 0 0 41 0 0 0 0 0 0 0] ; same for 3 actions in parallel


  set mean_cleaning [19 19 15 15 10.8 10 33 33 19 6.1 4.9]

  set fueling_bool_pass [False False False False False False False False False False False]
  set catering_bool_pass [False False False False False False False False False False False]
  set cleaning_bool_pass [False False False False False False False False False False False]

  let i 0
  while [i < length mean_deb] [
    set mean_deb (replace-item i mean_deb floor ((item i mean_deb) * 60))
    set mean_board (replace-item i mean_board floor ((item i mean_board) * 60))
    set mean_fuel  (replace-item i mean_fuel floor ((item i mean_fuel) * 60))
    set mean_unload_bulk (replace-item i mean_unload_bulk floor ((item i mean_unload_bulk ) * 60))
    set mean_unload_cont_1 (replace-item i mean_unload_cont_1 floor ((item i mean_unload_cont_1) * 60))
    set mean_unload_cont_2 (replace-item i mean_unload_cont_2 floor ((item i mean_unload_cont_2) * 60))
    set mean_load_bulk (replace-item i mean_load_bulk floor ((item i mean_load_bulk) * 60))
    set mean_load_cont_1 (replace-item i mean_load_cont_1 floor ((item i mean_load_cont_1) * 60))
    set mean_load_cont_2 (replace-item i mean_load_cont_2 floor ((item i mean_load_cont_2) * 60))
    set mean_catering_1 (replace-item i mean_catering_1 floor ((item i mean_catering_1) * 60))
    set mean_catering_2 (replace-item i mean_catering_2 floor ((item i mean_catering_2) * 60))
    set mean_catering_3 (replace-item i mean_catering_3 floor ((item i mean_catering_3) * 60))
    set mean_cleaning (replace-item i mean_cleaning floor ((item i mean_cleaning) * 60))


    set i i + 1
  ]



end












to SETUP_PLANNING [plane this_TA]
; take the plane type and the TA index and setup the turnaround variables accordingly

  set with_buffer False
  set beginning_factor_loading (1 / 3)
  set beginning_factor_boarding (0)

  let index (plane - 1) ; index of the plane type (the index must begin at 0)
  if (index < 0) [
    set index 4 ; si le type était 0 (pas les plus utilisés), on le remplace par un B738
  ]

  ;linked to fueling
  set fueling_with_passengers (item index fueling_bool_pass)
  set catering_with_passengers (item index catering_bool_pass)
  set cleaning_with_passengers (item index cleaning_bool_pass)



  ;linked to deboarding/boarding
  set deboarding_time floor (BETA_DISTRIBUTION (item index alpha_deb) (item index beta_deb) (item index c_deb) (item index d_deb))
  set boarding_time floor (BETA_DISTRIBUTION (item index alpha_board) (item index beta_board) (item index c_board) (item index d_board))

  ; linked to catering
  ; NB : catering 1, 2 and 3 are simultaneous and performed by 3 different catering agents
  ; The timings are only sampled if the mean is different than 0. If 0, the process is not needed for this airplane type.
  (ifelse
    ((item index mean_fuel) != 0)[  set fueling_time floor (BETA_DISTRIBUTION (item index alpha_fuel) (item index beta_fuel) (item index c_fuel) (item index d_fuel))]
    [
      set fueling_time 0
    ]
  )

  (ifelse
    ((item index mean_catering_1) != 0 ) [set catering_1_time floor (BETA_DISTRIBUTION (item index alpha_catering_1) (item index beta_catering_1) (item index c_catering_1) (item index d_catering_1))]
    [
      set catering_1_time 0
    ]
  )
  (ifelse
    ((item index mean_catering_2) != 0 ) [set catering_2_time floor (BETA_DISTRIBUTION (item index alpha_catering_2) (item index beta_catering_2) (item index c_catering_2) (item index d_catering_2))]
    [
      set catering_2_time 0
    ]
  )
  (ifelse
    ((item index mean_catering_3) != 0 ) [set catering_3_time floor (BETA_DISTRIBUTION (item index alpha_catering_3) (item index beta_catering_3) (item index c_catering_3) (item index d_catering_3))]
    [
      set catering_3_time 0
    ]
  )

  (ifelse
    ((item index mean_unload_bulk) != 0 ) [set unloading_bulk_time floor (BETA_DISTRIBUTION (item index alpha_unload_bulk) (item index beta_unload_bulk) (item index c_unload_bulk) (item index d_unload_bulk))]
    [
      set unloading_bulk_time 0
    ]
  )

  (ifelse
    ((item index mean_unload_cont_1) != 0 ) [set unloading_containers_1_time floor (BETA_DISTRIBUTION (item index alpha_unload_cont_1 ) (item index beta_unload_cont_1 ) (item index c_unload_cont_1 ) (item index d_unload_cont_1))]
    [
      set unloading_containers_1_time 0
    ]
  )
  (ifelse
    ((item index mean_unload_cont_2) != 0 ) [set unloading_containers_2_time floor (BETA_DISTRIBUTION (item index alpha_unload_cont_2 ) (item index beta_unload_cont_2 ) (item index c_unload_cont_2 ) (item index d_unload_cont_2))]
    [
      set unloading_containers_2_time 0
    ]
  )
  (ifelse
    ((item index mean_load_bulk) != 0 ) [set loading_bulk_time floor (BETA_DISTRIBUTION (item index alpha_load_bulk ) (item index beta_load_bulk) (item index c_load_bulk) (item index d_load_bulk))]    [
      set loading_bulk_time 0
    ]
  )
  (ifelse
    ((item index mean_load_cont_1) != 0 ) [set loading_containers_1_time floor (BETA_DISTRIBUTION (item index alpha_load_cont_1 ) (item index beta_load_cont_1 ) (item index c_load_cont_1 ) (item index d_load_cont_1))]
    [
      set loading_containers_1_time 0
    ]
  )
  (ifelse
    ((item index mean_load_cont_2) != 0 ) [set loading_containers_2_time floor (BETA_DISTRIBUTION (item index alpha_load_cont_2 ) (item index beta_load_cont_2 ) (item index c_load_cont_2 ) (item index d_load_cont_2))]
    [
      set loading_containers_2_time 0
    ]
  )

  (ifelse
    ((item index mean_cleaning) != 0)[set cleaning_time floor (BETA_DISTRIBUTION (item index alpha_cleaning ) (item index beta_cleaning) (item index c_cleaning) (item index d_cleaning))]
    [
      set cleaning_time 0
    ]
  )


      ;VARIABLES TO DETERMINE THE PLANNING

    ;linked to deboarding/boarding
  set deboarding_planned_time (item index mean_deb)    ; planned time duration of the deboarding / int
  set boarding_planned_time (item index mean_board)    ; planned time duration of the boarding / int
  let boarding_beginning_security_time (floor (boarding_planned_time * beginning_factor_boarding)) ;

  ;linked to fueling
  set fueling_planned_time (item index mean_fuel)       ; planned time duration for the fueling to be completed once started / int

  ; linked to catering
  set catering_1_planned_time (item index mean_catering_1)  ; planned time duration for the catering 1 to be completed once started / int
  set catering_2_planned_time (item index mean_catering_2)  ; planned time duration for the catering 2 to be completed once started / int
  set catering_3_planned_time (item index mean_catering_3)  ; planned time duration for the catering 3 to be completed once started / int
  let max_catering_planned_time (max (list catering_1_planned_time catering_2_planned_time catering_3_planned_time))
  ;linked to unloading/loading

  set unloading_bulk_planned_time (item index mean_unload_bulk)          ; planned time duration for the bulk unloading to be processed / int
  set unloading_containers_1_planned_time (item index mean_unload_cont_1)  ; planned time duration for the FWD containers unloading to be processed / int
  set unloading_containers_2_planned_time (item index mean_unload_cont_2)  ; planned time duration for the AFT containers unloading to be processed / int
  let max_unloading_planned_time (max (list unloading_bulk_planned_time unloading_containers_1_planned_time unloading_containers_2_planned_time))

  set loading_bulk_planned_time (item index mean_load_bulk)              ; planned time duration for the bulk loading to be processed / int
  set loading_containers_1_planned_time (item index mean_load_cont_1)      ; planned time duration for the FWD containers loading to be processed / int
  set loading_containers_2_planned_time (item index mean_load_cont_2)      ; planned time duration for the AFT containers loading to be processed / int
  let max_loading_planned_time (max (list loading_bulk_planned_time loading_containers_1_planned_time loading_containers_2_planned_time))
  let loading_beginning_security_time (floor (max_loading_planned_time * beginning_factor_loading))


  ;linked to cleaning
  set cleaning_planned_time (item index mean_cleaning)


  if with_buffer = True[
    set buffer_deboarding_planned_time floor (deboarding_planned_time / 2)      ; planned buffer duration after deboarding / int
    set buffer_fueling_planned_time  floor (fueling_planned_time / 2)       ; planned buffer duration after fueling / int
    set buffer_boarding_planned_time  floor (boarding_planned_time / 2)     ; planned buffer duration after boarding / int
    set buffer_catering_planned_time  floor (max_catering_planned_time / 2)      ; planned buffer duration after catering / int
    set buffer_cleaning_planned_time  floor (cleaning_planned_time / 2)     ; planned buffer duration after cleaning / int
    set buffer_loading_planned_time floor (max_loading_planned_time / 2) ; planned buffer duration after containers loading / int
    set buffer_unloading_planned_time  floor (max_unloading_planned_time / 2); planned buffer duration after containers unloading / int
  ]



  ;counter to determine the end of buffers

  set buffer_deboarding_counter_time buffer_deboarding_planned_time     ; counter initialized to planned buffer deboarding / int
  set buffer_fueling_counter_time buffer_fueling_planned_time         ; counter initialized to planned buffer fueling / int
  set buffer_boarding_counter_time  buffer_boarding_planned_time      ; counter initialized to planned buffer boarding / int
  set buffer_catering_counter_time  buffer_catering_planned_time      ; counter initialized to planned buffer catering / int
  set buffer_cleaning_counter_time  buffer_cleaning_planned_time      ; counter initialized to planned buffer cleaning / int
  set buffer_loading_counter_time  buffer_loading_planned_time    ; counter initialized to planned buffer bulk loading / int
  set buffer_unloading_counter_time buffer_unloading_planned_time   ; counter initialized to planned buffer bulk unloading / int


  ; SECURITY TIME
  ;loading and boarding beginning time

  let planned_boarding_waiting 0
  if (fueling_with_passengers = False)[
    set planned_boarding_waiting (max (list (planned_boarding_waiting) (fueling_planned_time + buffer_fueling_planned_time)))
  ]
  if (catering_with_passengers = False)[
    set planned_boarding_waiting (max (list (planned_boarding_waiting) (max_catering_planned_time + buffer_catering_planned_time)))
  ]
  if (cleaning_with_passengers = False)[
    set planned_boarding_waiting (max (list (planned_boarding_waiting) (cleaning_planned_time + buffer_cleaning_planned_time)))
  ]
  set boarding_beginning_time ((item (this_TA - 1) SOBT_list) - buffer_boarding_planned_time - boarding_planned_time - boarding_beginning_security_time)
  set boarding_beginning_time (max (list (boarding_beginning_time) ((item (this_TA - 1) SIBT_list) + deboarding_planned_time + buffer_deboarding_planned_time + planned_boarding_waiting)))

  set loading_beginning_time ((item (this_TA - 1) SOBT_list) - buffer_loading_planned_time - max_loading_planned_time - loading_beginning_security_time)
  ;if (max (list (loading_beginning_time) ((item (this_TA - 1) SIBT_list) + max_unloading_planned_time + buffer_unloading_planned_time)) != loading_beginning_time)[show this_TA]
  set loading_beginning_time (max (list (loading_beginning_time) ((item (this_TA - 1) SIBT_list) + max_unloading_planned_time + buffer_unloading_planned_time)))

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; INPUTS SETTING UP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to SETUP_INPUT
;set up input, if commentef then set up with buttons

  ; GENERAL VARIABLE
  ;set print_bool True ; True if we want the info to be printed



  INPUT_USE_CASE_EXCEL
  CUT_INPUT

  set SIBT_list SCALAR_VECTOR_MULTIPLICATION 60 SIBT_list
  set SOBT_list SCALAR_VECTOR_MULTIPLICATION 60 SOBT_list



  ; TIME WINDOW MARGINS

  set before_margin before_margin_min * 60
  set after_margin after_margin_min * 60


  ;VARIABLES FOR travel TIME
  let travel_time_general INPUT_travel_MATRIX
  set number_of_stands length travel_time_general - 1


  set travel_time_fuel_trucks SCALAR_MATRIX_ADDITION (additional_time_fueling_truck * 60) travel_time_general
  set travel_time_cater_trucks SCALAR_MATRIX_ADDITION (additional_time_catering_truck * 60) travel_time_general
  set travel_time_clean_trucks SCALAR_MATRIX_ADDITION (additional_time_cleaning_truck * 60) travel_time_general
  set travel_time_bulk_ul SCALAR_MATRIX_ADDITION (additional_time_bulk_ul * 60) travel_time_general
  set travel_time_bulk_uu SCALAR_MATRIX_ADDITION (additional_time_bulk_uu * 60) travel_time_general
  set travel_time_bulk_ll SCALAR_MATRIX_ADDITION (additional_time_bulk_ll * 60) travel_time_general
  set travel_time_bulk_lu SCALAR_MATRIX_ADDITION (additional_time_bulk_lu * 60) travel_time_general
  set travel_time_cargo_ul SCALAR_MATRIX_ADDITION (additional_time_cargo_ul * 60) travel_time_general
  set travel_time_cargo_ll SCALAR_MATRIX_ADDITION (additional_time_cargo_ll * 60) travel_time_general
  set travel_time_cargo_uu SCALAR_MATRIX_ADDITION (additional_time_cargo_uu * 60) travel_time_general
  set travel_time_cargo_lu SCALAR_MATRIX_ADDITION (additional_time_cargo_lu * 60) travel_time_general


  ; SIMULATION VARIABLES
  ; set time_step 15

  ; DELAY VARIABLES
  set mean_delay 0
  set std_delay 0


end





to CUT_INPUT
  ; remove the input turnarounds which are not between the begginning and finishing hour
  let i 0
  while [i < beginning_hour * 60][
    if (first SIBT_list = i)[
      set type_schedule bf type_schedule
      set stand_schedule bf stand_schedule
      set SOBT_list bf SOBT_list
      set SIBT_list bf SIBT_list
    ]
    if (first SIBT_list != i)[
      set i i + 1
    ]
  ]
  set i 24 * 60
  while [i > finishing_hour * 60][
    if (last SIBT_list = i)[
      set type_schedule bl type_schedule
      set stand_schedule bl stand_schedule
      set SOBT_list bl SOBT_list
      set SIBT_list bl SIBT_list
    ]
    if (last SIBT_list != i )[
      set i i - 1
    ]
  ]
end


to INPUT_USE_CASE_EXCEL
set type_schedule	[	5	0	9	0	4	8	0	0	4	7	0	8	0	9	7	10	8	10	6	0	0	5	0	0	0	6	0	10	5	10	0	0	6	0	2	6	5	10	7	2	9	0	8	6	0	10	10	0	6	0	7	2	4	5	5	10	0	0	4	2	5	5	0	10	10	2	0	9	4	0	0	7	6	0	10	10	0	3	5	10	4	4	4	6	6	0	5	7	3	0	5	5	10	0	1	2	5	5	5	5	10	10	10	0	0	0	0	10	4	2	2	5	10	10	2	3	0	0	5	2	2	5	8	6	5	0	5	10	10	0	0	0	8	5	0	3	3	0	4	0	8	2	2	0	0	9	2	5	0	0	5	2	5	1	0	1	4	0	5	1	0	0	0	0	10	2	5	0	2	6	0	0	0	2	2	0	6	4	9	10	2	0	6	10	1	0	0	6	5	4	0	2	4	6	6	3	5	6	6	5	10	0	0	0	0	0	2	5	6	0	0	10	5	6	1	10	0	2	10	5	6	0	0	3	2	3	6	6	0	5	0	0	10	10	10	10	2	3	10	5	5	0	6	0	0	10	5	5	2	8	10	5	5	5	4	0	3	0	5	10	0	0	2	9	9	7	0	5	0	6	5	10	4	0	10	0	0	2	0	5	0	2	2	2	9	0	2	2	1	5	0	5	10	0	5	0	3	4	2	0	5	0	2	9	0	6	0	2	0	6	10	0	4	5	10	0	5	5	5	5	6	6	5	10	10	10	5	0	6	6	5	5	5	10	5	0	7	5	5	0	5	0	0	0	5	1	0	10	5	3	0	2	0	2	2	3	5	0	5	10	5	2	10	5	7	1	8	5	1	5	0	0	5	5	10	10	7	5	5	10	0	3	3	0	0	0	7	5	0	10	0	0	10	5	5	0	0	0	0	10	0	5	10	0	5	5	0	10	2	6	6	0	0	10	5	5	5	10	0	0	0	10	10	3	0	0	5	6	5	10	0	10	10	10	5	6	2	0	0	10	3	6	6	6	6	5	2	3	5	0	0	0	2	2	5	2	5	0	8	3	1	2	2	5	8	8	5	0	0	1	0	2	0	0	0	1	5	3	10	5	0	5	0	1	10	5	4	2	3	0	2	3	6	0	5	3	7	6	0	5	2	2	10	5	10	10	5	0	2	2	6	2	10	5	2	9	0	7	5	1	3	2	10	5	0	5	0	9	2	5	10	10	5	5	2	3	6	0	0	5	2	10	2	0	5	0	5	5	0	0	10	5	2	10	3	5	5	0	0	3	6	0	0	10	10	0	0	10	10	1	3	5	0	10	0	10	0	5	6	5	0	10	6	6	6	5	0	10	10	10	5	0	5	10	10	10	5	5	5	10	2	6	0	0	2	0	2	3	2	0	6	3	0	0	6	2	2	10	1	3	2	5	2	3	3	2	10	3	10	3	5	3	5	3	1	0	1	]
set SIBT_list	[	80	180	185	210	230	230	235	235	235	240	260	290	295	295	295	295	305	305	310	315	315	315	315	315	315	320	320	325	325	330	335	335	335	340	340	340	340	340	340	345	345	345	345	350	350	350	350	350	355	355	355	360	360	360	360	360	365	370	370	370	370	370	370	370	370	375	375	375	375	375	375	375	380	380	380	380	380	385	385	385	390	390	390	390	390	390	390	390	395	395	395	395	395	400	400	400	400	400	400	400	400	400	400	405	405	405	405	405	405	410	410	410	410	410	415	415	415	420	420	420	420	420	420	420	420	420	420	420	420	420	425	425	430	430	430	430	435	435	435	435	435	440	440	440	440	440	440	440	440	445	450	450	455	460	460	460	460	460	465	465	475	475	480	480	480	485	485	490	490	490	495	495	500	500	500	500	500	505	505	505	510	515	515	515	520	520	520	520	520	525	525	530	530	535	535	540	540	540	540	540	540	545	545	550	550	550	555	555	555	555	555	555	555	560	560	565	565	570	570	570	570	575	575	575	575	575	575	575	575	575	575	575	575	575	575	575	575	580	580	580	585	585	590	590	595	595	595	595	600	600	600	600	600	600	600	600	605	605	605	610	615	615	620	620	620	620	620	620	620	625	625	625	630	630	630	630	640	640	645	645	650	650	655	655	655	660	660	660	660	660	660	660	660	660	660	660	665	665	670	670	670	675	675	675	675	675	680	680	680	680	680	680	685	685	685	690	690	695	695	695	695	695	695	695	695	695	695	695	700	700	700	700	700	700	700	700	705	705	705	705	705	710	710	710	710	715	715	720	725	725	725	730	730	735	735	735	735	740	740	740	740	745	745	750	760	760	760	760	765	765	775	775	775	775	780	790	790	790	790	795	800	800	800	800	800	800	800	805	805	805	810	810	810	810	815	815	815	815	815	815	820	820	820	825	825	825	825	825	825	830	830	830	830	830	835	835	835	835	835	835	835	835	835	840	840	840	840	840	840	840	840	840	840	840	840	840	845	845	845	845	850	850	850	850	850	850	855	860	860	860	865	870	880	880	890	890	890	895	900	900	900	900	900	900	900	900	905	910	910	910	920	920	920	925	925	925	930	930	930	935	935	935	945	945	945	945	945	950	950	950	955	955	955	955	960	960	960	960	960	970	970	970	970	975	980	980	980	980	985	985	985	985	985	990	995	995	1005	1005	1005	1010	1010	1010	1010	1010	1015	1015	1015	1015	1015	1015	1015	1015	1015	1015	1020	1020	1020	1025	1025	1030	1035	1035	1035	1035	1035	1035	1035	1035	1035	1035	1035	1035	1040	1040	1045	1045	1050	1050	1050	1055	1055	1055	1055	1055	1055	1055	1055	1055	1055	1060	1060	1065	1065	1065	1065	1065	1070	1070	1070	1070	1070	1070	1075	1075	1075	1075	1075	1075	1075	1075	1075	1080	1080	1080	1080	1080	1085	1085	1085	1085	1090	1090	1100	1100	1100	1100	1100	1100	1105	1110	1115	1120	1120	1130	1130	1135	1135	1135	1140	1140	1140	1140	1145	1145	1145	1150	1150	1155	1155	1160	1160	1165	1180	1200	1215	1215	1230	]
set SOBT_list	[	325	1270	480	390	480	480	500	440	395	490	420	475	560	515	515	345	435	345	355	555	600	370	350	350	375	385	375	385	375	370	435	625	460	540	375	385	395	380	610	375	645	380	1215	395	405	395	385	510	405	440	580	390	520	410	415	420	410	475	515	405	425	425	460	405	405	405	415	500	535	420	425	565	455	440	440	415	420	415	450	445	510	510	685	470	450	440	445	605	445	635	445	450	460	570	450	430	450	455	465	455	490	445	435	530	465	485	445	590	530	450	460	460	445	460	455	455	570	480	465	465	495	495	655	470	500	495	500	480	460	480	495	500	550	460	470	480	465	760	660	490	625	485	470	475	540	545	480	500	480	495	480	480	505	515	505	595	550	500	525	505	595	525	630	625	610	535	535	585	535	530	595	555	540	550	530	800	540	555	655	540	560	605	560	560	575	570	750	635	580	660	680	590	650	580	590	590	595	585	585	590	580	730	580	600	585	585	605	605	635	590	600	590	625	615	625	600	615	610	605	620	620	610	755	615	605	635	625	630	800	630	615	610	740	615	615	610	630	630	615	610	640	625	635	630	635	630	655	675	630	750	720	660	650	720	675	810	635	740	655	645	900	650	660	900	745	760	660	675	690	670	680	660	795	670	665	630	735	680	755	695	695	690	855	700	800	680	700	720	710	710	720	820	700	695	720	780	715	760	710	705	725	800	735	1130	735	745	720	710	755	725	740	720	805	795	760	760	795	765	745	745	740	740	745	760	735	730	775	740	830	780	790	750	750	765	750	740	855	730	735	1005	810	890	760	825	825	770	840	775	810	770	775	770	780	765	785	775	795	925	795	865	890	795	785	815	1165	805	920	820	820	860	840	805	880	840	815	860	920	840	875	840	845	845	830	835	845	955	950	865	840	865	950	845	860	865	890	865	870	875	875	895	1130	950	895	870	875	875	890	860	875	880	900	900	865	875	885	885	870	870	930	880	890	875	880	885	875	885	900	935	890	890	880	915	880	975	915	900	880	895	890	910	895	920	930	885	915	895	895	890	915	1035	900	915	910	930	950	920	940	1060	1080	935	955	945	940	915	1035	1110	1030	960	960	975	965	950	970	990	1020	990	1020	960	1140	995	980	955	1035	1010	985	995	1035	990	990	1010	1020	1005	1000	1015	990	995	1145	1010	1225	995	1025	1020	1150	1015	1080	1040	1045	1015	1045	1035	1025	1030	1025	1040	1045	1165	1170	1140	1065	1060	1040	1040	1140	1070	1180	1040	1080	1160	1055	1130	1155	1110	1080	1065	1060	1065	1130	1160	1130	1115	1110	1070	1080	1080	1115	1145	1155	1115	1115	1125	1165	1135	1070	1115	1095	1110	1135	1115	1175	1095	1145	1150	1155	1115	1110	1110	1110	1110	1150	1110	1090	1115	1135	1115	1175	1130	1115	1140	1155	1135	1130	1130	1145	1120	1125	1130	1150	1170	1115	1120	1135	1190	1150	1165	1120	1140	1160	1140	1125	1170	1130	1185	1200	1145	1160	1135	1135	1150	1155	1175	1145	1160	1165	1165	1175	1180	1180	1180	1185	1170	1170	1175	1180	1185	1185	1200	1185	1185	1200	1190	1210	1195	1205	1230	1275	1355	1335	]
set stand_schedule	[	59	154	99	147	95	104	91	100	97	113	146	114	107	98	110	20	122	17	57	120	62	46	23	38	16	56	10	32	77	34	62	126	55	103	31	35	116	40	119	130	97	12	152	60	4	7	36	138	37	5	123	127	124	44	49	24	6	108	94	132	43	86	15	14	30	129	33	136	85	17	18	121	65	64	13	38	21	128	68	11	89	58	106	88	72	19	81	117	39	112	47	70	20	144	46	133	77	50	45	53	3	34	40	137	84	93	23	41	125	76	48	56	16	10	75	127	139	143	29	63	71	54	115	79	60	73	51	36	30	7	59	37	145	130	32	69	132	92	82	31	111	33	129	66	57	80	131	116	35	67	133	128	86	44	14	48	122	17	43	50	153	6	156	102	26	74	77	118	64	53	100	70	28	29	127	95	56	78	109	34	69	150	46	32	72	73	91	88	71	96	114	31	61	65	54	47	67	55	50	86	21	99	30	75	68	13	45	51	84	16	15	36	53	57	132	38	40	28	4	60	79	7	146	127	133	129	46	49	94	77	34	11	42	14	12	17	93	44	32	43	66	19	63	10	5	8	56	74	130	110	30	52	70	116	122	151	128	103	50	21	141	13	127	105	121	104	16	86	140	47	67	18	78	34	9	134	15	132	57	59	68	128	37	130	111	143	28	75	44	62	51	65	36	38	79	145	72	98	31	8	35	123	73	112	54	81	143	129	122	77	32	63	58	48	11	85	64	29	49	53	56	50	47	12	34	9	88	7	83	82	55	60	43	40	87	6	113	131	127	10	52	148	46	156	33	39	142	36	31	76	84	28	118	127	133	51	45	96	59	15	79	130	30	80	97	35	99	93	120	54	143	131	81	63	32	72	109	49	86	9	29	74	127	70	68	110	104	77	40	26	122	17	38	88	121	41	27	19	21	12	92	60	5	6	59	46	22	3	28	43	58	20	1	13	48	64	44	36	30	42	34	16	4	51	7	67	57	78	47	2	32	23	14	24	85	61	127	25	18	11	129	50	52	83	80	84	76	133	87	95	29	66	128	45	116	132	88	146	145	63	74	33	49	82	149	151	81	143	68	118	67	130	70	29	134	131	51	129	13	48	72	82	73	47	8	87	98	31	128	28	57	44	46	17	62	130	105	86	102	133	127	121	42	49	9	14	89	6	116	74	45	119	11	79	70	110	94	104	85	53	132	131	32	120	100	133	66	109	129	55	36	38	75	29	33	63	83	7	27	50	44	72	31	28	56	65	82	61	41	2	23	46	130	26	47	58	84	4	19	62	88	37	81	11	18	1	16	22	21	48	127	43	80	30	20	15	6	60	51	54	10	40	77	79	57	87	17	5	35	34	85	123	86	24	12	8	73	49	45	25	76	63	155	68	72	67	133	93	70	9	53	28	66	35	58	39	75	11	29	129	131	57	127	59	45	116	12	117	15	133	83	128	130	129	93	121	117	]
end




to-report INPUT_travel_MATRIX

  let matrix [[	0	277	292	281	288	280	289	272	289	297	292	282	297	282	294	275	278	275	286	287	300	298	291	297	289	276	280	282	233	237	222	239	222	216	228	240	212	238	234	239	227	223	214	162	157	159	176	171	171	168	155	160	171	164	173	173	165	76	71	81	63	83	67	78	84	86	84	78	85	63	80	69	85	89	71	70	78	82	87	68	86	66	62	62	73	61	84	88	77	82	76	180	198	184	175	180	180	194	195	184	177	177	178	196	186	178	194	187	184	190	176	187	174	200	190	190	196	199	175	176	201	175	199	198	194	201	175	179	177	181	193	185	186	198	203	175	189	186	182	182	196	178	198	184	186	194	179	181	189	192	199	187	177	174	175	181	200	]
    [	277	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	89	94	79	96	78	72	85	96	68	94	91	96	84	80	70	138	133	136	152	148	148	144	132	137	147	141	150	149	142	233	228	237	220	240	223	234	241	243	240	235	242	220	237	226	242	246	228	226	234	238	244	225	242	223	218	219	230	218	240	244	233	239	233	234	251	237	229	234	233	247	248	237	231	231	232	250	240	231	248	241	237	243	229	240	228	254	243	244	249	252	229	229	254	229	252	251	247	255	228	485	484	488	500	492	492	505	509	229	242	240	236	235	249	232	251	237	239	247	232	235	242	246	253	240	230	228	228	235	253	]
    [	292	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	105	110	95	112	94	88	101	112	84	110	107	111	100	95	86	154	149	152	168	163	163	160	148	153	163	157	166	165	158	248	244	253	236	256	239	250	257	259	256	250	257	236	252	242	258	262	244	242	250	254	260	241	258	238	234	235	246	234	256	260	249	255	249	250	267	253	244	249	249	263	264	253	247	247	247	266	256	247	264	257	253	259	245	256	244	270	259	260	265	268	245	245	270	244	268	267	263	271	244	501	500	504	515	508	508	521	525	245	258	255	252	251	265	248	267	253	255	263	248	250	258	261	269	256	246	243	244	250	269	]
    [	281	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	94	98	84	101	83	77	89	101	73	99	95	100	88	84	75	143	138	140	157	152	152	149	137	141	152	145	154	154	147	237	233	242	224	244	228	239	245	248	245	239	246	224	241	230	246	250	232	231	239	243	248	229	247	227	223	223	234	222	245	249	238	243	237	238	256	241	233	238	238	252	253	242	235	235	236	254	244	235	252	245	242	248	234	245	232	258	248	248	254	256	233	234	259	233	257	255	252	259	232	490	489	492	504	496	497	509	514	233	247	244	240	240	254	236	256	242	243	252	237	239	247	250	257	245	235	232	233	239	258	]
    [	288	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	101	105	90	107	89	83	96	108	79	106	102	107	95	91	82	150	144	147	164	159	159	155	143	148	158	152	161	160	153	244	239	248	231	251	234	246	252	254	252	246	253	231	248	237	253	257	239	238	245	249	255	236	253	234	229	230	241	229	251	256	244	250	244	245	262	248	240	245	244	258	259	248	242	242	243	261	251	242	259	252	249	254	241	252	239	265	254	255	260	263	240	241	266	240	263	262	258	266	239	497	495	499	511	503	503	516	520	240	254	251	247	247	261	243	262	248	250	259	243	246	253	257	264	251	241	239	239	246	264	]
    [	280	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	93	97	83	100	82	76	88	100	72	98	94	99	87	83	74	142	137	139	156	151	151	148	136	140	151	144	153	153	146	236	232	241	224	243	227	238	245	247	244	238	245	223	240	229	245	250	231	230	238	242	248	228	246	226	222	223	233	222	244	248	237	242	236	237	255	241	232	237	237	251	252	241	234	234	235	253	243	235	251	244	241	247	233	244	231	257	247	247	253	256	232	233	258	232	256	255	251	258	232	489	488	491	503	495	496	508	513	232	246	243	240	239	253	235	255	241	243	251	236	238	246	249	256	244	234	231	232	238	257	]
    [	289	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	102	106	91	108	90	85	97	109	81	107	103	108	96	92	83	151	145	148	165	160	160	156	144	149	160	153	162	161	154	245	240	249	232	252	235	247	253	255	253	247	254	232	249	238	254	258	240	239	247	251	256	237	255	235	231	231	242	230	252	257	245	251	245	246	263	249	241	246	245	259	260	249	243	243	244	262	252	243	260	253	250	256	242	253	240	266	255	256	262	264	241	242	267	241	264	263	259	267	240	498	496	500	512	504	504	517	521	241	255	252	248	248	262	244	263	249	251	260	245	247	254	258	265	252	242	240	241	247	265	]
    [	272	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	85	89	74	91	73	67	80	92	63	90	86	91	79	75	66	134	128	131	148	143	143	139	127	132	142	136	145	144	137	228	223	232	215	235	218	229	236	238	236	230	237	215	232	221	237	241	223	222	229	233	239	220	237	218	213	214	225	213	235	240	228	234	228	229	246	232	224	229	228	242	243	232	226	226	227	245	235	226	243	236	233	238	225	235	223	249	238	239	244	247	224	225	250	224	247	246	242	250	223	481	479	483	495	487	487	500	504	224	238	235	231	231	245	227	246	232	234	243	227	230	237	241	248	235	225	223	223	230	248	]
    [	289	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	102	106	91	108	90	84	97	109	80	107	103	108	96	92	83	151	145	148	165	160	160	156	144	149	159	153	162	161	154	245	240	249	232	252	235	247	253	255	253	247	254	232	249	238	254	258	240	239	246	250	256	237	254	235	230	231	242	230	252	257	245	251	245	246	263	249	241	246	245	259	260	249	243	243	244	262	252	243	260	253	250	255	242	253	240	266	255	256	261	264	241	242	267	241	264	263	259	267	240	498	496	500	512	504	504	517	521	241	255	252	248	248	262	244	263	249	251	260	244	247	254	258	265	252	242	240	240	247	265	]
    [	297	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	110	114	100	117	99	93	105	117	89	115	112	116	104	100	91	159	154	157	173	168	168	165	153	158	168	162	171	170	163	253	249	258	241	261	244	255	262	264	261	255	262	240	257	247	262	267	248	247	255	259	265	246	263	243	239	240	250	239	261	265	254	260	254	255	272	258	249	254	254	268	269	258	252	252	252	270	261	252	269	262	258	264	250	261	248	275	264	265	270	273	250	250	275	249	273	272	268	276	249	506	505	509	520	512	513	525	530	249	263	260	257	256	270	253	272	258	260	268	253	255	263	266	274	261	251	248	249	255	274	]
    [	292	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	105	109	94	111	93	88	100	112	84	110	106	111	99	95	86	154	148	151	168	163	163	159	147	152	163	156	165	164	157	248	243	252	235	255	238	250	256	258	256	250	257	235	252	241	257	261	243	242	249	254	259	240	257	238	233	234	245	233	255	260	248	254	248	249	266	252	244	249	248	262	263	252	246	246	247	265	255	246	263	256	253	259	245	256	243	269	258	259	264	267	244	245	270	244	267	266	262	270	243	501	499	503	515	507	507	520	524	244	258	255	251	251	265	247	266	252	254	263	247	250	257	261	268	255	245	243	244	250	268	]
    [	282	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	95	99	84	101	83	78	90	102	74	100	96	101	89	85	76	144	139	141	158	153	153	150	137	142	153	146	155	154	147	238	233	243	225	245	229	240	246	248	246	240	247	225	242	231	247	251	233	232	240	244	249	230	248	228	224	224	235	223	245	250	239	244	238	239	257	242	234	239	239	252	253	243	236	236	237	255	245	236	253	246	243	249	235	246	233	259	249	249	255	257	234	235	260	234	257	256	252	260	233	491	489	493	505	497	497	510	514	234	248	245	241	241	255	237	257	242	244	253	238	240	247	251	258	245	235	233	234	240	258	]
    [	297	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	110	114	100	117	99	93	105	117	89	115	112	116	104	100	91	159	154	156	173	168	168	165	153	157	168	162	171	170	163	253	249	258	241	260	244	255	262	264	261	255	262	240	257	247	262	267	248	247	255	259	265	246	263	243	239	240	250	239	261	265	254	260	254	255	272	258	249	254	254	268	269	258	251	251	252	270	261	252	269	262	258	264	250	261	248	274	264	265	270	273	249	250	275	249	273	272	268	276	249	506	505	509	520	512	513	525	530	249	263	260	257	256	270	253	272	258	260	268	253	255	263	266	274	261	251	248	249	255	274	]
    [	282	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	95	100	85	102	84	78	91	102	74	100	97	101	90	85	76	144	139	142	158	153	153	150	138	143	153	147	156	155	148	238	234	243	226	246	229	240	247	249	246	240	247	226	242	232	248	252	234	232	240	244	250	231	248	228	224	225	236	224	246	250	239	245	239	240	257	243	234	240	239	253	254	243	237	237	237	256	246	237	254	247	243	249	235	246	234	260	249	250	255	258	235	235	260	234	258	257	253	261	234	491	490	494	505	498	498	511	515	235	248	245	242	241	255	238	257	243	245	253	238	240	248	251	259	246	236	233	234	240	259	]
    [	294	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	107	111	96	113	95	89	102	114	85	112	108	113	101	97	88	156	150	153	170	165	165	161	149	154	164	158	167	166	159	250	245	254	237	257	240	252	258	260	258	252	259	237	254	243	259	263	245	244	251	255	261	242	259	240	235	236	247	235	257	262	250	256	250	251	268	254	246	251	250	264	265	254	248	248	249	267	257	248	265	258	255	260	247	258	245	271	260	261	266	269	246	247	272	246	269	268	264	272	245	503	501	505	517	509	509	522	526	246	260	257	253	253	267	249	268	254	256	265	249	252	259	263	270	257	247	245	245	252	270	]
    [	275	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	88	92	78	95	77	71	83	95	67	93	89	94	82	78	69	137	132	134	151	146	146	143	131	135	146	139	148	148	141	231	227	236	218	238	222	233	239	242	239	233	240	218	235	224	240	244	226	225	233	237	242	223	241	221	217	217	228	216	239	243	232	237	231	232	250	235	227	232	232	246	247	236	229	229	230	248	238	229	246	239	236	242	228	239	226	252	242	242	248	250	227	228	253	227	251	249	246	253	226	484	483	486	498	490	491	503	508	227	241	238	234	234	248	230	250	236	237	246	231	233	241	244	251	239	229	226	227	233	252	]
    [	278	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	90	95	80	97	79	73	86	97	69	95	92	96	85	80	71	139	134	137	153	148	148	145	133	138	148	142	151	150	143	234	229	238	221	241	224	235	242	244	241	235	242	221	237	227	243	247	229	227	235	239	245	226	243	223	219	220	231	219	241	245	234	240	234	235	252	238	229	235	234	248	249	238	232	232	232	251	241	232	249	242	238	244	230	241	229	255	244	245	250	253	230	230	255	229	253	252	248	256	229	486	485	489	500	493	493	506	510	230	243	240	237	236	250	233	252	238	240	248	233	235	243	246	254	241	231	228	229	235	254	]
    [	275	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	87	92	77	94	76	70	83	94	66	93	89	94	82	78	68	136	131	134	150	146	146	142	130	135	145	139	148	147	140	231	226	235	218	238	221	232	239	241	239	233	240	218	235	224	240	244	226	225	232	236	242	223	240	221	216	217	228	216	238	242	231	237	231	232	249	235	227	232	231	245	246	235	229	229	230	248	238	229	246	239	236	241	228	238	226	252	241	242	247	250	227	228	252	227	250	249	245	253	226	483	482	486	498	490	490	503	507	227	240	238	234	233	247	230	249	235	237	245	230	233	240	244	251	238	228	226	226	233	251	]
    [	286	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	99	103	88	106	88	82	94	106	78	104	100	105	93	89	80	148	143	145	162	157	157	154	142	146	157	150	159	159	152	242	238	247	229	249	233	244	250	253	250	244	251	229	246	235	251	255	237	236	244	248	253	234	252	232	228	228	239	227	250	254	243	248	242	243	261	246	238	243	243	257	258	247	240	240	241	259	249	240	257	250	247	253	239	250	237	263	253	253	259	261	238	239	264	238	262	260	256	264	237	495	494	497	509	501	502	514	519	238	252	249	245	245	259	241	261	247	248	257	242	244	252	255	262	250	239	237	238	244	263	]
    [	287	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	100	104	90	107	89	83	95	107	79	105	102	106	94	90	81	149	144	146	163	158	158	155	143	147	158	152	161	160	153	243	239	248	231	250	234	245	252	254	251	245	252	230	247	237	252	257	238	237	245	249	255	236	253	233	229	230	240	229	251	255	244	250	244	245	262	248	239	244	244	258	259	248	241	241	242	260	251	242	259	252	248	254	240	251	238	264	254	255	260	263	240	240	265	239	263	262	258	266	239	496	495	499	510	502	503	515	520	239	253	250	247	246	260	243	262	248	250	258	243	245	253	256	264	251	241	238	239	245	264	]
    [	300	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	113	117	102	119	101	96	108	120	92	118	114	119	107	103	94	162	157	159	176	171	171	168	155	160	171	164	173	172	165	256	251	261	243	263	247	258	264	266	264	258	265	243	260	249	265	269	251	250	258	262	267	248	266	246	242	242	253	241	263	268	257	262	256	257	275	260	252	257	257	270	271	261	254	254	255	273	263	254	271	264	261	267	253	264	251	277	267	267	273	275	252	253	278	252	275	274	270	278	251	509	507	511	523	515	515	528	532	252	266	263	259	259	273	255	275	260	262	271	256	258	265	269	276	263	253	251	252	258	276	]
    [	298	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	111	115	100	117	100	94	106	118	90	116	112	117	105	101	92	160	155	157	174	169	169	166	153	158	169	162	171	171	163	254	249	259	241	261	245	256	262	264	262	256	263	241	258	247	263	267	249	248	256	260	265	246	264	244	240	240	251	239	261	266	255	260	254	255	273	258	250	255	255	268	269	259	252	252	253	271	261	252	269	262	259	265	251	262	249	275	265	265	271	273	250	251	276	250	273	272	268	276	249	507	505	509	521	513	513	526	531	250	264	261	257	257	271	253	273	259	260	269	254	256	264	267	274	262	251	249	250	256	275	]
    [	291	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	103	108	93	110	92	86	99	110	82	108	105	110	98	94	84	152	147	150	166	162	162	158	146	151	161	155	164	163	156	247	242	251	234	254	237	248	255	257	254	248	256	234	251	240	256	260	242	240	248	252	258	239	256	237	232	233	244	232	254	258	247	253	247	248	265	251	243	248	247	261	262	251	245	245	246	264	254	245	262	255	251	257	243	254	242	268	257	258	263	266	243	243	268	243	266	265	261	269	242	499	498	502	514	506	506	519	523	243	256	254	250	249	263	246	265	251	253	261	246	249	256	260	267	254	244	242	242	249	267	]
    [	297	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	110	114	100	117	99	93	105	117	89	115	112	116	105	100	91	159	154	157	173	168	168	165	153	158	168	162	171	170	163	253	249	258	241	261	244	255	262	264	261	255	262	240	257	247	263	267	249	247	255	259	265	246	263	243	239	240	250	239	261	265	254	260	254	255	272	258	249	254	254	268	269	258	252	252	252	270	261	252	269	262	258	264	250	261	248	275	264	265	270	273	250	250	275	249	273	272	268	276	249	506	505	509	520	512	513	526	530	249	263	260	257	256	270	253	272	258	260	268	253	255	263	266	274	261	251	248	249	255	274	]
    [	289	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	101	106	91	108	90	84	97	108	80	106	103	108	96	92	82	150	145	148	164	159	159	156	144	149	159	153	162	161	154	245	240	249	232	252	235	246	253	255	252	246	254	232	248	238	254	258	240	238	246	250	256	237	254	235	230	231	242	230	252	256	245	251	245	246	263	249	241	246	245	259	260	249	243	243	243	262	252	243	260	253	249	255	241	252	240	266	255	256	261	264	241	241	266	240	264	263	259	267	240	497	496	500	512	504	504	517	521	241	254	252	248	247	261	244	263	249	251	259	244	247	254	257	265	252	242	239	240	247	265	]
    [	276	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	88	93	78	95	77	71	84	95	67	94	90	95	83	79	70	137	132	135	151	147	147	143	131	136	146	140	149	148	141	232	227	236	219	239	222	233	240	242	240	234	241	219	236	225	241	245	227	226	233	237	243	224	241	222	217	218	229	217	239	244	232	238	232	233	250	236	228	233	232	246	247	236	230	230	231	249	239	230	247	240	237	242	229	239	227	253	242	243	248	251	228	229	254	228	251	250	246	254	227	485	483	487	499	491	491	504	508	228	241	239	235	235	249	231	250	236	238	247	231	234	241	245	252	239	229	227	227	234	252	]
    [	280	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	93	97	82	99	81	76	88	100	72	98	94	99	87	83	74	142	136	139	156	151	151	147	135	140	151	144	153	152	145	236	231	240	223	243	226	238	244	246	244	238	245	223	240	229	245	249	231	230	238	242	247	228	246	226	222	222	233	221	243	248	236	242	236	237	254	240	232	237	236	250	251	241	234	234	235	253	243	234	251	244	241	247	233	244	231	257	247	247	253	255	232	233	258	232	255	254	250	258	231	489	487	491	503	495	495	508	512	232	246	243	239	239	253	235	254	240	242	251	236	238	245	249	256	243	233	231	232	238	256	]
    [	282	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	94	99	84	101	83	77	90	101	73	99	96	100	89	84	75	143	138	141	157	152	152	149	137	142	152	146	155	154	147	238	233	242	225	245	228	239	246	248	245	239	246	225	241	231	247	251	233	231	239	243	249	230	247	227	223	224	235	223	245	249	238	244	238	239	256	242	234	239	238	252	253	242	236	236	236	255	245	236	253	246	242	248	234	245	233	259	248	249	254	257	234	234	259	233	257	256	252	260	233	490	489	493	504	497	497	510	514	234	247	244	241	240	254	237	256	242	244	252	237	239	247	250	258	245	235	232	233	239	258	]
    [	233	89	105	94	101	93	102	85	102	110	105	95	110	95	107	88	90	87	99	100	113	111	103	110	101	88	93	94	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	95	89	92	109	104	104	100	88	93	103	97	106	105	98	189	184	193	176	196	179	191	197	199	197	191	198	176	193	182	198	202	184	183	190	195	200	181	198	179	174	175	186	174	196	201	189	195	189	250	267	253	245	250	249	263	264	253	247	247	248	266	256	247	264	257	254	260	246	257	244	270	259	260	265	268	245	246	271	245	268	267	263	271	244	442	440	444	456	448	448	461	465	245	259	256	252	252	266	248	267	253	255	264	248	251	258	262	269	256	246	244	245	251	269	]
    [	237	94	110	98	105	97	106	89	106	114	109	99	114	100	111	92	95	92	103	104	117	115	108	114	106	93	97	99	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	99	94	96	113	108	108	105	93	97	108	101	110	110	103	193	189	198	180	200	184	195	201	204	201	195	202	180	197	186	202	206	188	187	195	199	204	185	203	183	179	179	190	178	201	205	194	199	193	254	272	257	249	254	254	268	269	258	251	251	252	270	260	251	268	261	258	264	250	261	248	274	264	264	270	272	249	250	275	249	273	271	268	275	248	446	445	448	460	452	453	465	470	249	263	260	256	256	270	252	272	258	259	268	253	255	263	266	273	261	250	248	249	255	274	]
    [	222	79	95	84	90	83	91	74	91	100	94	84	100	85	96	78	80	77	88	90	102	100	93	100	91	78	82	84	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	84	79	82	98	93	93	90	78	83	93	87	96	95	88	178	174	183	166	186	169	180	187	189	186	180	187	165	182	172	188	192	174	172	180	184	190	171	188	168	164	165	175	164	186	190	179	185	179	240	257	243	234	239	239	253	254	243	237	237	237	255	246	237	254	247	243	249	235	246	234	260	249	250	255	258	235	235	260	234	258	257	253	261	234	431	430	434	445	437	438	451	455	234	248	245	242	241	255	238	257	243	245	253	238	240	248	251	259	246	236	233	234	240	259	]
    [	239	96	112	101	107	100	108	91	108	117	111	101	117	102	113	95	97	94	106	107	119	117	110	117	108	95	99	101	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	101	96	99	115	110	110	107	95	100	110	104	113	112	105	195	191	200	183	203	186	197	204	206	203	197	204	183	199	189	205	209	191	189	197	201	207	188	205	185	181	182	193	181	203	207	196	202	196	257	274	260	251	256	256	270	271	260	254	254	254	273	263	254	271	264	260	266	252	263	251	277	266	267	272	275	252	252	277	251	275	274	270	278	251	448	447	451	462	455	455	468	472	252	265	262	259	258	272	255	274	260	262	270	255	257	265	268	276	263	253	250	251	257	276	]
    [	222	78	94	83	89	82	90	73	90	99	93	83	99	84	95	77	79	76	88	89	101	100	92	99	90	77	81	83	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	83	78	81	97	92	92	89	77	82	92	86	95	94	87	178	173	182	165	185	168	179	186	188	185	179	186	165	181	171	187	191	173	171	179	183	189	170	187	167	163	164	175	163	185	189	178	184	178	239	256	242	234	239	238	252	253	242	236	236	236	255	245	236	253	246	242	248	234	245	233	259	248	249	254	257	234	234	259	233	257	256	252	260	233	430	429	433	444	437	437	450	454	234	247	244	241	240	254	237	256	242	244	252	237	239	247	250	258	245	235	232	233	239	258	]
    [	216	72	88	77	83	76	85	67	84	93	88	78	93	78	89	71	73	70	82	83	96	94	86	93	84	71	76	77	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	78	72	75	92	87	87	83	71	76	86	80	89	88	81	172	167	176	159	179	162	173	180	182	180	174	181	159	176	165	181	185	167	166	173	177	183	164	181	162	157	158	169	157	179	184	172	178	172	233	250	236	228	233	232	246	247	236	230	230	231	249	239	230	247	240	237	242	229	239	227	253	242	243	248	251	228	229	254	228	251	250	246	254	227	425	423	427	439	431	431	444	448	228	242	239	235	235	249	231	250	236	238	247	231	234	241	245	252	239	229	227	227	234	252	]
    [	228	85	101	89	96	88	97	80	97	105	100	90	105	91	102	83	86	83	94	95	108	106	99	105	97	84	88	90	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	90	85	87	104	99	99	96	84	88	99	92	101	101	94	184	180	189	171	191	175	186	192	195	192	186	193	171	188	177	193	197	179	178	186	190	195	176	194	174	170	170	181	169	192	196	185	190	184	245	263	248	240	245	245	259	259	249	242	242	243	261	251	242	259	252	249	255	241	252	239	265	255	255	261	263	240	241	266	240	263	262	258	266	239	437	436	439	451	443	444	456	461	240	254	251	247	247	261	243	263	249	250	259	244	246	254	257	264	252	241	239	240	246	265	]
    [	240	96	112	101	108	100	109	92	109	117	112	102	117	102	114	95	97	94	106	107	120	118	110	117	108	95	100	101	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	102	96	99	116	111	111	107	95	100	110	104	113	112	105	196	191	200	183	203	186	198	204	206	204	198	205	183	200	189	205	209	191	190	197	202	207	188	205	186	181	182	193	181	203	208	196	202	196	257	274	260	252	257	256	270	271	260	254	254	255	273	263	254	271	264	261	266	253	264	251	277	266	267	272	275	252	253	278	252	275	274	270	278	251	449	447	451	463	455	455	468	472	252	266	263	259	259	273	255	274	260	262	271	255	258	265	269	276	263	253	251	252	258	276	]
    [	212	68	84	73	79	72	81	63	80	89	84	74	89	74	85	67	69	66	78	79	92	90	82	89	80	67	72	73	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	73	68	71	87	83	83	79	67	72	82	76	85	84	77	168	163	172	155	175	158	169	176	178	176	170	177	155	172	161	177	181	163	162	169	173	179	160	177	158	153	154	165	153	175	179	168	174	168	229	246	232	224	229	228	242	243	232	226	226	227	245	235	226	243	236	233	238	225	235	223	249	238	239	244	247	224	225	249	224	247	246	242	250	223	421	419	423	435	427	427	440	444	224	237	235	231	231	244	227	246	232	234	243	227	230	237	241	248	235	225	223	223	230	248	]
    [	238	94	110	99	106	98	107	90	107	115	110	100	115	100	112	93	95	93	104	105	118	116	108	115	106	94	98	99	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	100	94	97	114	109	109	105	93	98	109	102	111	110	103	194	189	198	181	201	184	196	202	204	202	196	203	181	198	187	203	207	189	188	196	200	205	186	204	184	180	180	191	179	201	206	194	200	194	255	272	258	250	255	254	268	269	258	252	252	253	271	261	252	269	262	259	265	251	262	249	275	264	265	271	273	250	251	276	250	273	272	268	276	249	447	445	449	461	453	453	466	470	250	264	261	257	257	271	253	272	258	260	269	254	256	263	267	274	261	251	249	250	256	274	]
    [	234	91	107	95	102	94	103	86	103	112	106	96	112	97	108	89	92	89	100	102	114	112	105	112	103	90	94	96	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	96	91	93	110	105	105	102	90	94	105	98	107	107	100	190	186	195	178	197	181	192	198	201	198	192	199	177	194	183	199	204	185	184	192	196	201	182	200	180	176	177	187	175	198	202	191	196	190	251	269	255	246	251	251	265	266	255	248	248	249	267	257	249	265	258	255	261	247	258	245	271	261	261	267	270	246	247	272	246	270	269	265	272	246	443	442	445	457	449	450	462	467	246	260	257	253	253	267	249	269	255	257	265	250	252	260	263	270	258	248	245	246	252	271	]
    [	239	96	111	100	107	99	108	91	108	116	111	101	116	101	113	94	96	94	105	106	119	117	110	116	108	95	99	100	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	101	96	98	115	110	110	107	94	99	110	103	112	111	104	195	190	200	182	202	186	197	203	205	203	197	204	182	199	188	204	208	190	189	197	201	206	187	205	185	181	181	192	180	202	207	196	201	195	256	274	259	251	256	256	269	270	260	253	253	254	272	262	253	270	263	260	266	252	263	250	276	266	266	272	274	251	252	277	251	274	273	269	277	250	448	446	450	462	454	454	467	471	251	265	262	258	258	272	254	274	259	261	270	255	257	264	268	275	262	252	250	251	257	275	]
    [	227	84	100	88	95	87	96	79	96	104	99	89	104	90	101	82	85	82	93	94	107	105	98	105	96	83	87	89	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	89	84	86	103	98	98	95	83	87	98	91	100	100	93	183	179	188	170	190	174	185	191	194	191	185	192	170	187	176	192	196	178	177	185	189	194	175	193	173	169	169	180	168	191	195	184	189	183	244	262	247	239	244	244	258	259	248	241	241	242	260	250	241	258	251	248	254	240	251	238	264	254	254	260	262	239	240	265	239	263	261	258	265	238	436	435	438	450	442	443	455	460	239	253	250	246	246	260	242	262	248	249	258	243	245	253	256	263	251	241	238	239	245	264	]
    [	223	80	95	84	91	83	92	75	92	100	95	85	100	85	97	78	80	78	89	90	103	101	94	100	92	79	83	84	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	85	80	82	99	94	94	91	78	83	94	87	96	95	88	179	174	184	166	186	170	181	187	189	187	181	188	166	183	172	188	192	174	173	181	185	190	171	189	169	165	165	176	164	186	191	180	185	179	240	258	243	235	240	240	253	254	244	237	237	238	256	246	237	254	247	244	250	236	247	234	260	250	250	256	258	235	236	261	235	258	257	253	261	234	432	430	434	446	438	438	451	455	235	249	246	242	242	256	238	258	243	245	254	239	241	248	252	259	246	236	234	235	241	259	]
    [	214	70	86	75	82	74	83	66	83	91	86	76	91	76	88	69	71	68	80	81	94	92	84	91	82	70	74	75	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	76	70	73	90	85	85	81	69	74	85	78	87	86	79	170	165	174	157	177	160	172	178	180	178	172	179	157	174	163	179	183	165	164	171	176	181	162	179	160	155	156	167	155	177	182	170	176	170	231	248	234	226	231	230	244	245	234	228	228	229	247	237	228	245	238	235	241	227	238	225	251	240	241	246	249	226	227	252	226	249	248	244	252	225	423	421	425	437	429	429	442	446	226	240	237	233	233	247	229	248	234	236	245	229	232	239	243	250	237	227	225	226	232	250	]
    [	162	138	154	143	150	142	151	134	151	159	154	144	159	144	156	137	139	136	148	149	162	160	152	159	150	137	142	143	95	99	84	101	83	78	90	102	73	100	96	101	89	85	76	0	0	0	0	0	0	0	0	0	0	0	0	0	0	118	113	122	105	125	108	120	126	128	126	120	127	105	122	111	127	131	113	112	119	124	129	110	127	108	103	104	115	103	125	130	118	124	118	239	256	242	234	239	238	252	253	242	236	236	237	255	245	236	253	246	243	248	235	246	233	259	248	249	254	257	234	235	260	234	257	256	252	260	233	371	369	373	385	377	377	390	394	234	248	245	241	241	255	237	256	242	244	253	237	240	247	251	258	245	235	233	234	240	258	]
    [	157	133	149	138	144	137	145	128	145	154	148	139	154	139	150	132	134	131	143	144	157	155	147	154	145	132	136	138	89	94	79	96	78	72	85	96	68	94	91	96	84	80	70	0	0	0	0	0	0	0	0	0	0	0	0	0	0	113	108	117	100	120	103	114	121	123	120	114	122	100	117	106	122	126	108	106	114	118	124	105	122	103	98	99	110	98	120	124	113	119	113	234	251	237	229	234	233	247	248	237	231	231	231	250	240	231	248	241	237	243	229	240	228	254	243	244	249	252	229	229	254	229	252	251	247	255	228	365	364	368	380	372	372	385	389	229	242	240	236	235	249	232	251	237	239	247	232	235	242	246	253	240	230	227	228	235	253	]
    [	159	136	152	140	147	139	148	131	148	157	151	141	156	142	153	134	137	134	145	146	159	157	150	157	148	135	139	141	92	96	82	99	81	75	87	99	71	97	93	98	86	82	73	0	0	0	0	0	0	0	0	0	0	0	0	0	0	115	111	120	102	122	106	117	123	126	123	117	124	102	119	108	124	128	110	109	117	121	126	107	125	105	101	101	112	100	123	127	116	121	115	236	254	240	231	236	236	250	251	240	233	233	234	252	242	233	250	243	240	246	232	243	230	256	246	246	252	254	231	232	257	231	255	253	250	257	230	368	367	370	382	374	375	387	392	231	245	242	238	238	252	234	254	240	242	250	235	237	245	248	255	243	233	230	231	237	256	]
    [	176	152	168	157	164	156	165	148	165	173	168	158	173	158	170	151	153	150	162	163	176	174	166	173	164	151	156	157	109	113	98	115	97	92	104	116	87	114	110	115	103	99	90	0	0	0	0	0	0	0	0	0	0	0	0	0	0	132	127	136	119	139	122	134	140	142	140	134	141	119	136	125	141	145	127	126	133	138	143	124	141	122	117	118	129	117	139	144	132	138	132	253	270	256	248	253	252	266	267	256	250	250	251	269	259	250	267	260	257	262	249	260	247	273	262	263	268	271	248	249	274	248	271	270	266	274	247	385	383	387	399	391	391	404	408	248	262	259	255	255	269	251	270	256	258	267	251	254	261	265	272	259	249	247	248	254	272	]
    [	171	148	163	152	159	151	160	143	160	168	163	153	168	153	165	146	148	146	157	158	171	169	162	168	159	147	151	152	104	108	93	110	92	87	99	111	83	109	105	110	98	94	85	0	0	0	0	0	0	0	0	0	0	0	0	0	0	127	122	132	114	134	117	129	135	137	135	129	136	114	131	120	136	140	122	121	129	133	138	119	137	117	113	113	124	112	134	139	127	133	127	248	265	251	243	248	248	261	262	252	245	245	246	264	254	245	262	255	252	258	244	255	242	268	258	258	264	266	243	244	269	243	266	265	261	269	242	380	378	382	394	386	386	399	403	243	257	254	250	250	264	246	266	251	253	262	247	249	256	260	267	254	244	242	243	249	267	]
    [	171	148	163	152	159	151	160	143	160	168	163	153	168	153	165	146	148	146	157	158	171	169	162	168	159	147	151	152	104	108	93	110	92	87	99	111	83	109	105	110	98	94	85	0	0	0	0	0	0	0	0	0	0	0	0	0	0	127	122	132	114	134	117	129	135	137	135	129	136	114	131	120	136	140	122	121	129	133	138	119	137	117	113	113	124	112	134	139	127	133	127	248	265	251	243	248	248	261	262	252	245	245	246	264	254	245	262	255	252	258	244	255	242	268	258	258	264	266	243	244	269	243	266	265	261	269	242	380	378	382	394	386	386	399	403	243	257	254	250	250	264	246	266	251	253	262	247	249	256	260	267	254	244	242	243	249	267	]
    [	168	144	160	149	155	148	156	139	156	165	159	150	165	150	161	143	145	142	154	155	168	166	158	165	156	143	147	149	100	105	90	107	89	83	96	107	79	105	102	107	95	91	81	0	0	0	0	0	0	0	0	0	0	0	0	0	0	124	119	128	111	131	114	125	132	134	131	125	133	111	128	117	133	137	119	117	125	129	135	116	133	114	109	110	121	109	131	135	124	130	124	245	262	248	240	245	244	258	259	248	242	242	242	261	251	242	259	252	248	254	240	251	239	265	254	255	260	263	240	240	265	240	263	262	258	266	239	376	375	379	391	383	383	396	400	240	253	251	247	246	260	243	262	248	250	258	243	246	253	257	264	251	241	238	239	246	264	]
    [	155	132	148	137	143	136	144	127	144	153	147	137	153	138	149	131	133	130	142	143	155	153	146	153	144	131	135	137	88	93	78	95	77	71	84	95	67	93	90	94	83	78	69	0	0	0	0	0	0	0	0	0	0	0	0	0	0	111	107	116	99	119	102	113	120	122	119	113	120	99	115	105	121	125	107	105	113	117	123	104	121	101	97	98	109	97	119	123	112	118	112	233	250	236	227	233	232	246	247	236	230	230	230	249	239	230	247	240	236	242	228	239	227	253	242	243	248	251	228	228	253	227	251	250	246	254	227	364	363	367	378	371	371	384	388	228	241	238	235	234	248	231	250	236	238	246	231	233	241	244	252	239	229	226	227	233	252	]
    [	160	137	153	141	148	140	149	132	149	158	152	142	157	143	154	135	138	135	146	147	160	158	151	158	149	136	140	142	93	97	83	100	82	76	88	100	72	98	94	99	87	83	74	0	0	0	0	0	0	0	0	0	0	0	0	0	0	116	112	121	103	123	107	118	124	127	124	118	125	103	120	109	125	129	111	110	118	122	127	108	126	106	102	102	113	101	124	128	117	122	116	237	255	241	232	237	237	251	252	241	234	234	235	253	243	234	251	244	241	247	233	244	231	257	247	247	253	255	232	233	258	232	256	254	251	258	231	369	368	371	383	375	376	388	393	232	246	243	239	239	253	235	255	241	243	251	236	238	246	249	256	244	234	231	232	238	257	]
    [	171	147	163	152	158	151	160	142	159	168	163	153	168	153	164	146	148	145	157	158	171	169	161	168	159	146	151	152	103	108	93	110	92	86	99	110	82	109	105	110	98	94	85	0	0	0	0	0	0	0	0	0	0	0	0	0	0	127	122	131	114	134	117	128	135	137	135	129	136	114	131	120	136	140	122	121	128	132	138	119	136	117	112	113	124	112	134	138	127	133	127	248	265	251	243	248	247	261	262	251	245	245	246	264	254	245	262	255	252	257	244	254	242	268	257	258	263	266	243	244	268	243	266	265	261	269	242	380	378	382	394	386	386	399	403	243	256	254	250	250	263	246	265	251	253	262	246	249	256	260	267	254	244	242	242	249	267	]
    [	164	141	157	145	152	144	153	136	153	162	156	146	162	147	158	139	142	139	150	152	164	162	155	162	153	140	144	146	97	101	87	104	86	80	92	104	76	102	98	103	91	87	78	0	0	0	0	0	0	0	0	0	0	0	0	0	0	120	116	125	108	127	111	122	128	131	128	122	129	107	124	113	129	134	115	114	122	126	131	112	130	110	106	107	117	105	128	132	121	126	120	241	259	245	236	241	241	255	256	245	238	238	239	257	247	239	255	248	245	251	237	248	235	261	251	251	257	260	236	237	262	236	260	259	255	262	235	373	372	375	387	379	380	392	397	236	250	247	243	243	257	239	259	245	247	255	240	242	250	253	260	248	238	235	236	242	261	]
    [	173	150	166	154	161	153	162	145	162	171	165	155	171	156	167	148	151	148	159	161	173	171	164	171	162	149	153	155	106	110	96	113	95	89	101	113	85	111	107	112	100	96	87	0	0	0	0	0	0	0	0	0	0	0	0	0	0	129	125	134	117	136	120	131	137	140	137	131	138	116	133	122	138	143	124	123	131	135	140	121	139	119	115	116	126	115	137	141	130	135	129	250	268	254	245	250	250	264	265	254	247	247	248	266	256	248	264	257	254	260	246	257	244	270	260	260	266	269	245	246	271	245	269	268	264	271	245	382	381	384	396	388	389	401	406	245	259	256	252	252	266	248	268	254	256	264	249	251	259	262	269	257	247	244	245	251	270	]
    [	173	149	165	154	160	153	161	144	161	170	164	154	170	155	166	148	150	147	159	160	172	171	163	170	161	148	152	154	105	110	95	112	94	88	101	112	84	110	107	111	100	95	86	0	0	0	0	0	0	0	0	0	0	0	0	0	0	129	124	133	116	136	119	130	137	139	136	130	137	116	132	122	138	142	124	122	130	134	140	121	138	118	114	115	126	114	136	140	129	135	129	250	267	253	245	250	249	263	264	253	247	247	247	266	256	247	264	257	253	259	245	256	244	270	259	260	265	268	245	245	270	244	268	267	263	271	244	381	380	384	395	388	388	401	405	245	258	255	252	251	265	248	267	253	255	263	248	250	258	261	269	256	246	243	244	250	269	]
    [	165	142	158	147	153	146	154	137	154	163	157	147	163	148	159	141	143	140	152	153	165	163	156	163	154	141	145	147	98	103	88	105	87	81	94	105	77	103	100	104	93	88	79	0	0	0	0	0	0	0	0	0	0	0	0	0	0	121	117	126	109	129	112	123	130	132	129	123	130	109	125	115	131	135	117	115	123	127	133	114	131	111	107	108	119	107	129	133	122	128	122	243	260	246	237	243	242	256	257	246	240	240	240	259	249	240	257	250	246	252	238	249	237	263	252	253	258	261	238	238	263	237	261	260	256	264	237	374	373	377	388	381	381	394	398	238	251	248	245	244	258	241	260	246	248	256	241	243	251	254	262	249	239	236	237	243	262	]
    [	76	233	248	237	244	236	245	228	245	253	248	238	253	238	250	231	234	231	242	243	256	254	247	253	245	232	236	238	189	193	178	195	178	172	184	196	168	194	190	195	183	179	170	118	113	115	132	127	127	124	111	116	127	120	129	129	121	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	243	261	246	238	243	243	256	257	247	240	240	241	259	249	240	257	250	247	253	239	250	237	263	253	253	259	261	238	239	264	238	261	260	256	264	237	285	283	287	299	291	292	304	309	238	252	249	245	245	259	241	261	247	248	257	242	244	252	255	262	250	239	237	238	244	263	]
    [	71	228	244	233	239	232	240	223	240	249	243	233	249	234	245	227	229	226	238	239	251	249	242	249	240	227	231	233	184	189	174	191	173	167	180	191	163	189	186	190	179	174	165	113	108	111	127	122	122	119	107	112	122	116	125	124	117	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	239	256	242	233	239	238	252	253	242	236	236	236	255	245	236	253	246	242	248	234	245	233	259	248	249	254	257	234	234	259	233	257	256	252	260	233	280	279	283	294	287	287	300	304	234	247	244	241	240	254	237	256	242	244	252	237	239	247	250	258	245	235	232	233	239	258	]
    [	81	237	253	242	248	241	249	232	249	258	252	243	258	243	254	236	238	235	247	248	261	259	251	258	249	236	240	242	193	198	183	200	182	176	189	200	172	198	195	200	188	184	174	122	117	120	136	132	132	128	116	121	131	125	134	133	126	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	248	265	251	243	248	247	261	262	251	245	245	246	264	254	245	262	255	251	257	243	254	242	268	257	258	263	266	243	243	268	243	266	265	261	269	242	289	288	292	304	296	296	309	313	243	256	254	250	249	263	246	265	251	253	261	246	249	256	260	267	254	244	242	242	249	267	]
    [	63	220	236	224	231	224	232	215	232	241	235	225	241	226	237	218	221	218	229	231	243	241	234	241	232	219	223	225	176	180	166	183	165	159	171	183	155	181	178	182	170	166	157	105	100	102	119	114	114	111	99	103	114	108	117	116	109	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	231	248	234	225	230	230	244	245	234	227	227	228	246	237	228	245	238	234	240	226	237	224	250	240	241	246	249	225	226	251	225	249	248	244	252	225	272	271	274	286	278	279	291	296	225	239	236	233	232	246	229	248	234	236	244	229	231	239	242	250	237	227	224	225	231	250	]
    [	83	240	256	244	251	243	252	235	252	261	255	245	260	246	257	238	241	238	249	250	263	261	254	261	252	239	243	245	196	200	186	203	185	179	191	203	175	201	197	202	190	186	177	125	120	122	139	134	134	131	119	123	134	127	136	136	129	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	250	268	254	245	250	250	264	265	254	247	247	248	266	256	247	264	257	254	260	246	257	244	270	260	260	266	268	245	246	271	245	269	267	264	271	244	292	291	294	306	298	299	311	316	245	259	256	252	252	266	248	268	254	255	264	249	251	259	262	269	257	247	244	245	251	270	]
    [	67	223	239	228	234	227	235	218	235	244	238	229	244	229	240	222	224	221	233	234	247	245	237	244	235	222	226	228	179	184	169	186	168	162	175	186	158	184	181	186	174	170	160	108	103	106	122	117	117	114	102	107	117	111	120	119	112	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	234	251	237	229	234	233	247	248	237	231	231	231	250	240	231	248	241	237	243	229	240	228	254	243	244	249	252	229	229	254	228	252	251	247	255	228	275	274	278	290	282	282	295	299	229	242	240	236	235	249	232	251	237	239	247	232	235	242	245	253	240	230	227	228	235	253	]
    [	78	234	250	239	246	238	247	229	247	255	250	240	255	240	252	233	235	232	244	245	258	256	248	255	246	233	238	239	191	195	180	197	179	173	186	198	169	196	192	197	185	181	172	120	114	117	134	129	129	125	113	118	128	122	131	130	123	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	245	262	248	240	245	244	258	259	248	242	242	243	261	251	242	259	252	249	254	241	252	239	265	254	255	260	263	240	241	266	240	263	262	258	266	239	287	285	289	301	293	293	306	310	240	254	251	247	247	261	243	262	248	250	259	243	246	253	257	264	251	241	239	239	246	264	]
    [	84	241	257	245	252	245	253	236	253	262	256	246	262	247	258	239	242	239	250	252	264	262	255	262	253	240	244	246	197	201	187	204	186	180	192	204	176	202	198	203	191	187	178	126	121	123	140	135	135	132	120	124	135	128	137	137	130	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	252	269	255	246	251	251	265	266	255	248	248	249	267	258	249	265	259	255	261	247	258	245	271	261	261	267	270	246	247	272	246	270	269	265	273	246	293	292	295	307	299	300	312	317	246	260	257	254	253	267	249	269	255	257	265	250	252	260	263	270	258	248	245	246	252	271	]
    [	86	243	259	248	254	247	255	238	255	264	258	248	264	249	260	242	244	241	253	254	266	264	257	264	255	242	246	248	199	204	189	206	188	182	195	206	178	204	201	205	194	189	180	128	123	126	142	137	137	134	122	127	137	131	140	139	132	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	254	271	257	248	254	253	267	268	257	251	251	251	270	260	251	268	261	257	263	249	260	248	274	263	264	269	272	249	249	274	248	272	271	267	275	248	295	294	298	309	302	302	315	319	249	262	259	256	255	269	252	271	257	259	267	252	254	262	265	273	260	250	247	248	254	273	]
    [	84	240	256	245	252	244	253	236	253	261	256	246	261	246	258	239	241	239	250	251	264	262	254	261	252	240	244	245	197	201	186	203	185	180	192	204	176	202	198	203	191	187	178	126	120	123	140	135	135	131	119	124	135	128	137	136	129	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	251	268	254	246	251	250	264	265	254	248	248	249	267	257	248	265	258	255	261	247	258	245	271	260	261	267	269	246	247	272	246	269	268	264	272	245	293	291	295	307	299	299	312	316	246	260	257	253	253	267	249	268	254	256	265	250	252	259	263	270	257	247	245	246	252	270	]
    [	78	235	250	239	246	238	247	230	247	255	250	240	255	240	252	233	235	233	244	245	258	256	248	255	246	234	238	239	191	195	180	197	179	174	186	198	170	196	192	197	185	181	172	120	114	117	134	129	129	125	113	118	129	122	131	130	123	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	245	262	248	240	245	244	258	259	249	242	242	243	261	251	242	259	252	249	255	241	252	239	265	255	255	261	263	240	241	266	240	263	262	258	266	239	287	285	289	301	293	293	306	310	240	254	251	247	247	261	243	262	248	250	259	244	246	253	257	264	251	241	239	240	246	264	]
    [	85	242	257	246	253	245	254	237	254	262	257	247	262	247	259	240	242	240	251	252	265	263	256	262	254	241	245	246	198	202	187	204	186	181	193	205	177	203	199	204	192	188	179	127	122	124	141	136	136	133	120	125	136	129	138	137	130	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	252	270	255	247	252	252	265	266	256	249	249	250	268	258	249	266	259	256	262	248	259	246	272	262	262	268	270	247	248	273	247	270	269	265	273	246	294	292	296	308	300	300	313	317	247	261	258	254	254	268	250	270	255	257	266	251	253	260	264	271	258	248	246	247	253	271	]
    [	63	220	236	224	231	223	232	215	232	240	235	225	240	226	237	218	221	218	229	230	243	241	234	240	232	219	223	225	176	180	165	183	165	159	171	183	155	181	177	182	170	166	157	105	100	102	119	114	114	111	99	103	114	107	116	116	109	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	230	248	233	225	230	230	244	245	234	227	227	228	246	236	227	244	237	234	240	226	237	224	250	240	240	246	248	225	226	251	225	249	247	243	251	224	272	271	274	286	278	279	291	296	225	239	236	232	232	246	228	248	234	235	244	229	231	239	242	249	237	226	224	225	231	250	]
    [	80	237	252	241	248	240	249	232	249	257	252	242	257	242	254	235	237	235	246	247	260	258	251	257	248	236	240	241	193	197	182	199	181	176	188	200	172	198	194	199	187	183	174	122	117	119	136	131	131	128	115	120	131	124	133	132	125	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	247	264	250	242	247	247	260	261	251	244	244	245	263	253	244	261	254	251	257	243	254	241	267	257	257	263	265	242	243	268	242	265	264	260	268	241	289	287	291	303	295	295	308	312	242	256	253	249	249	263	245	265	250	252	261	246	248	255	259	266	253	243	241	242	248	266	]
    [	69	226	242	230	237	229	238	221	238	247	241	231	247	232	243	224	227	224	235	237	249	247	240	247	238	225	229	231	182	186	172	189	171	165	177	189	161	187	183	188	176	172	163	111	106	108	125	120	120	117	105	109	120	113	122	122	115	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	236	254	240	231	236	236	250	251	240	233	233	234	252	242	234	250	243	240	246	232	243	230	256	246	246	252	255	231	232	257	231	255	254	250	257	231	278	277	280	292	284	285	297	302	231	245	242	238	238	252	234	254	240	242	250	235	237	245	248	255	243	233	230	231	237	256	]
    [	85	242	258	246	253	245	254	237	254	262	257	247	262	248	259	240	243	240	251	252	265	263	256	263	254	241	245	247	198	202	188	205	187	181	193	205	177	203	199	204	192	188	179	127	122	124	141	136	136	133	121	125	136	129	138	138	131	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	252	270	255	247	252	252	266	267	256	249	249	250	268	258	249	266	259	256	262	248	259	246	272	262	262	268	270	247	248	273	247	271	269	266	273	246	294	293	296	308	300	301	313	318	247	261	258	254	254	268	250	270	256	257	266	251	253	261	264	271	259	249	246	247	253	272	]
    [	89	246	262	250	257	250	258	241	258	267	261	251	267	252	263	244	247	244	255	257	269	267	260	267	258	245	249	251	202	206	192	209	191	185	197	209	181	207	204	208	196	192	183	131	126	128	145	140	140	137	125	129	140	134	143	142	135	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	257	274	260	251	256	256	270	271	260	253	253	254	272	263	254	271	264	260	266	252	263	250	276	266	267	272	275	251	252	277	251	275	274	270	278	251	298	297	301	312	304	305	317	322	251	265	262	259	258	272	255	274	260	262	270	255	257	265	268	276	263	253	250	251	257	276	]
    [	71	228	244	232	239	231	240	223	240	248	243	233	248	234	245	226	229	226	237	238	251	249	242	249	240	227	231	233	184	188	174	191	173	167	179	191	163	189	185	190	178	174	165	113	108	110	127	122	122	119	107	111	122	115	124	124	117	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	238	256	241	233	238	238	252	253	242	235	235	236	254	244	235	252	245	242	248	234	245	232	258	248	248	254	256	233	234	259	233	257	255	252	259	232	280	279	282	294	286	287	299	304	233	247	244	240	240	254	236	256	242	243	252	237	239	247	250	257	245	234	232	233	239	258	]
    [	70	226	242	231	238	230	239	222	239	247	242	232	247	232	244	225	227	225	236	237	250	248	240	247	238	226	230	231	183	187	172	189	171	166	178	190	162	188	184	189	177	173	164	112	106	109	126	121	121	117	105	110	121	114	123	122	115	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	237	254	240	232	237	236	250	251	240	234	234	235	253	243	234	251	244	241	247	233	244	231	257	246	247	252	255	232	233	258	232	255	254	250	258	231	279	277	281	293	285	285	298	302	232	246	243	239	239	253	235	254	240	242	251	235	238	245	249	256	243	233	231	232	238	256	]
    [	78	234	250	239	245	238	247	229	246	255	249	240	255	240	251	233	235	232	244	245	258	256	248	255	246	233	238	239	190	195	180	197	179	173	186	197	169	196	192	197	185	181	171	119	114	117	133	129	129	125	113	118	128	122	131	130	123	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	245	262	248	240	245	244	258	259	248	242	242	243	261	251	242	259	252	249	254	241	251	239	265	254	255	260	263	240	241	265	240	263	262	258	266	239	286	285	289	301	293	293	306	310	240	253	251	247	246	260	243	262	248	250	258	243	246	253	257	264	251	241	239	239	246	264	]
    [	82	238	254	243	249	242	251	233	250	259	254	244	259	244	255	237	239	236	248	249	262	260	252	259	250	237	242	243	195	199	184	201	183	177	190	202	173	200	196	201	189	185	176	124	118	121	138	133	133	129	117	122	132	126	135	134	127	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	249	266	252	244	249	248	262	263	252	246	246	247	265	255	246	263	256	253	258	245	255	243	269	258	259	264	267	244	245	270	244	267	266	262	270	243	291	289	293	305	297	297	310	314	244	258	255	251	251	265	247	266	252	254	263	247	250	257	261	268	255	245	243	243	250	268	]
    [	87	244	260	248	255	248	256	239	256	265	259	249	265	250	261	242	245	242	253	255	267	265	258	265	256	243	247	249	200	204	190	207	189	183	195	207	179	205	201	206	194	190	181	129	124	126	143	138	138	135	123	127	138	131	140	140	133	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	255	272	258	249	254	254	268	269	258	251	251	252	270	261	252	268	262	258	264	250	261	248	274	264	264	270	273	249	250	275	249	273	272	268	276	249	296	295	298	310	302	303	315	320	249	263	260	257	256	270	252	272	258	260	268	253	255	263	266	273	261	251	248	249	255	274	]
    [	68	225	241	229	236	228	237	220	237	246	240	230	246	231	242	223	226	223	234	236	248	246	239	246	237	224	228	230	181	185	171	188	170	164	176	188	160	186	182	187	175	171	162	110	105	107	124	119	119	116	104	108	119	112	121	121	114	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	235	253	239	230	235	235	249	250	239	232	232	233	251	241	233	249	242	239	245	231	242	229	255	245	245	251	254	230	231	256	230	254	253	249	256	230	277	276	279	291	283	284	296	301	230	244	241	238	237	251	233	253	239	241	249	234	236	244	247	254	242	232	229	230	236	255	]
    [	86	242	258	247	253	246	255	237	254	263	257	248	263	248	259	241	243	240	252	253	266	264	256	263	254	241	246	247	198	203	188	205	187	181	194	205	177	204	200	205	193	189	179	127	122	125	141	137	137	133	121	126	136	130	139	138	131	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	253	270	256	248	253	252	266	267	256	250	250	251	269	259	250	267	260	257	262	249	259	247	273	262	263	268	271	248	249	273	248	271	270	266	274	247	294	293	297	309	301	301	314	318	248	261	259	255	254	268	251	270	256	258	266	251	254	261	265	272	259	249	247	247	254	272	]
    [	66	223	238	227	234	226	235	218	235	243	238	228	243	228	240	221	223	221	232	233	246	244	237	243	235	222	226	227	179	183	168	185	167	162	174	186	158	184	180	185	173	169	160	108	103	105	122	117	117	114	101	106	117	110	119	118	111	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	233	251	236	228	233	233	246	247	237	230	230	231	249	239	230	247	240	237	243	229	240	227	253	243	243	249	251	228	229	254	228	251	250	246	254	227	275	273	277	289	281	281	294	298	228	242	239	235	235	249	231	251	236	238	247	232	234	242	245	252	240	229	227	228	234	252	]
    [	62	218	234	223	229	222	231	213	230	239	233	224	239	224	235	217	219	216	228	229	242	240	232	239	230	217	222	223	174	179	164	181	163	157	170	181	153	180	176	181	169	165	155	103	98	101	117	113	113	109	97	102	112	106	115	114	107	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	229	246	232	224	229	228	242	243	232	226	226	227	245	235	226	243	236	233	238	225	235	223	249	238	239	244	247	224	225	249	224	247	246	242	250	223	270	269	273	285	277	277	290	294	224	237	235	231	230	244	227	246	232	234	242	227	230	237	241	248	235	225	223	223	230	248	]
    [	62	219	235	223	230	223	231	214	231	240	234	224	240	225	236	217	220	217	228	230	242	240	233	240	231	218	222	224	175	179	165	182	164	158	170	182	154	180	177	181	169	165	156	104	99	101	118	113	113	110	98	102	113	107	116	115	108	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	230	247	233	224	229	229	243	244	233	226	226	227	245	236	227	244	237	233	239	225	236	223	249	239	240	245	248	225	225	250	224	248	247	243	251	224	271	270	274	285	277	278	290	295	224	238	235	232	231	245	228	247	233	235	243	228	230	238	241	249	236	226	223	224	230	249	]
    [	73	230	246	234	241	233	242	225	242	250	245	235	250	236	247	228	231	228	239	240	253	251	244	250	242	229	233	235	186	190	175	193	175	169	181	193	165	191	187	192	180	176	167	115	110	112	129	124	124	121	109	113	124	117	126	126	119	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	240	258	243	235	240	240	254	255	244	237	237	238	256	246	237	254	247	244	250	236	247	234	260	250	250	256	258	235	236	261	235	259	257	253	261	234	282	281	284	296	288	289	301	306	235	249	246	242	242	256	238	258	244	245	254	239	241	249	252	259	247	236	234	235	241	260	]
    [	61	218	234	222	229	222	230	213	230	239	233	223	239	224	235	216	219	216	227	229	241	239	232	239	230	217	221	223	174	178	164	181	163	157	169	181	153	179	175	180	168	164	155	103	98	100	117	112	112	109	97	101	112	105	115	114	107	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	229	246	232	223	228	228	242	243	232	225	225	226	244	235	226	242	236	232	238	224	235	222	248	238	238	244	247	223	224	249	223	247	246	242	250	223	270	269	272	284	276	277	289	294	223	237	234	231	230	244	226	246	232	234	242	227	229	237	240	247	235	225	222	223	229	248	]
    [	84	240	256	245	251	244	252	235	252	261	255	245	261	246	257	239	241	238	250	251	263	261	254	261	252	239	243	245	196	201	186	203	185	179	192	203	175	201	198	202	191	186	177	125	120	123	139	134	134	131	119	124	134	128	137	136	129	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	251	268	254	246	251	250	264	265	254	248	248	248	267	257	248	265	258	254	260	246	257	245	271	260	261	266	269	246	246	271	245	269	268	264	272	245	292	291	295	306	299	299	312	316	246	259	256	253	252	266	249	268	254	256	264	249	251	259	262	270	257	247	244	245	251	270	]
    [	88	244	260	249	256	248	257	240	257	265	260	250	265	250	262	243	245	242	254	255	268	266	258	265	256	244	248	249	201	205	190	207	189	184	196	208	179	206	202	207	195	191	182	130	124	127	144	139	139	135	123	128	138	132	141	140	133	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	255	272	258	250	255	254	268	269	258	252	252	253	271	261	252	269	262	259	265	251	262	249	275	264	265	270	273	250	251	276	250	273	272	268	276	249	297	295	299	311	303	303	316	320	250	264	261	257	257	271	253	272	258	260	269	253	256	263	267	274	261	251	249	250	256	274	]
    [	77	233	249	238	244	237	245	228	245	254	248	239	254	239	250	232	234	231	243	244	257	255	247	254	245	232	236	238	189	194	179	196	178	172	185	196	168	194	191	196	184	180	170	118	113	116	132	127	127	124	112	117	127	121	130	129	122	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	244	261	247	239	244	243	257	258	247	241	241	241	260	250	241	258	251	247	253	239	250	238	264	253	254	259	262	239	239	264	238	262	261	257	265	238	285	284	288	300	292	292	305	309	239	252	250	246	245	259	242	261	247	249	257	242	245	252	255	263	250	240	237	238	245	263	]
    [	82	239	255	243	250	242	251	234	251	260	254	244	260	245	256	237	240	237	248	250	262	260	253	260	251	238	242	244	195	199	185	202	184	178	190	202	174	200	196	201	189	185	176	124	119	121	138	133	133	130	118	122	133	126	135	135	128	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	249	267	253	244	249	249	263	264	253	246	246	247	265	255	247	263	256	253	259	245	256	243	269	259	259	265	268	244	245	270	244	268	267	263	270	244	291	290	293	305	297	298	310	315	244	258	255	252	251	265	247	267	253	255	263	248	250	258	261	268	256	246	243	244	250	269	]
    [	76	233	249	237	244	236	245	228	245	254	248	238	254	239	250	231	234	231	242	244	256	254	247	254	245	232	236	238	189	193	179	196	178	172	184	196	168	194	190	195	183	179	170	118	113	115	132	127	127	124	112	116	127	120	129	129	122	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	243	261	247	238	243	243	257	258	247	240	240	241	259	249	241	257	250	247	253	239	250	237	263	253	253	259	262	238	239	264	238	262	261	257	264	238	285	284	287	299	291	292	304	309	238	252	249	245	245	259	241	261	247	249	257	242	244	252	255	262	250	240	237	238	244	263	]
    [	180	234	250	238	245	237	246	229	246	255	249	239	255	240	251	232	235	232	243	245	257	255	248	255	246	233	237	239	250	254	240	257	239	233	245	257	229	255	251	256	244	240	231	239	234	236	253	248	248	245	233	237	248	241	250	250	243	243	239	248	231	250	234	245	252	254	251	245	252	230	247	236	252	257	238	237	245	249	255	235	253	233	229	230	240	229	251	255	244	249	243	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	244	230	241	229	255	244	245	250	253	230	230	255	230	253	252	248	256	229	232	231	234	246	238	239	251	256	230	243	241	237	236	250	233	252	238	240	248	233	236	243	247	254	241	231	229	229	236	254	]
    [	198	251	267	256	262	255	263	246	263	272	266	257	272	257	268	250	252	249	261	262	275	273	265	272	263	250	254	256	267	272	257	274	256	250	263	274	246	272	269	274	262	258	248	256	251	254	270	265	265	262	250	255	265	259	268	267	260	261	256	265	248	268	251	262	269	271	268	262	270	248	264	254	270	274	256	254	262	266	272	253	270	251	246	247	258	246	268	272	261	267	261	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	262	248	259	246	272	262	262	268	270	247	248	273	247	270	269	265	273	246	249	248	252	264	256	256	269	273	247	261	258	254	254	268	250	270	256	257	266	251	253	261	264	271	259	248	246	247	253	272	]
    [	184	237	253	241	248	241	249	232	249	258	252	242	258	243	254	235	238	235	246	248	260	258	251	258	249	236	240	242	253	257	243	260	242	236	248	260	232	258	255	259	247	243	234	242	237	240	256	251	251	248	236	241	251	245	254	253	246	246	242	251	234	254	237	248	255	257	254	248	255	233	250	240	255	260	241	240	248	252	258	239	256	236	232	233	243	232	254	258	247	253	247	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	248	234	245	232	258	247	248	253	256	233	234	259	233	256	255	251	259	232	235	234	238	249	241	242	254	259	233	247	244	240	240	254	236	255	241	243	252	236	239	246	250	257	244	234	232	233	239	257	]
    [	175	229	244	233	240	232	241	224	241	249	244	234	249	234	246	227	229	227	238	239	252	250	243	249	241	228	232	234	245	249	234	251	234	228	240	252	224	250	246	251	239	235	226	234	229	231	248	243	243	240	227	232	243	236	245	245	237	238	233	243	225	245	229	240	246	248	246	240	247	225	242	231	247	251	233	232	240	244	249	230	248	228	224	224	235	223	246	250	239	244	238	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	239	225	236	223	249	239	240	245	248	225	225	250	224	248	247	243	251	224	227	225	229	241	233	234	246	251	224	238	235	232	231	245	228	247	233	235	243	228	230	238	241	249	236	226	223	224	230	249	]
    [	180	234	249	238	245	237	246	229	246	254	249	239	254	240	251	232	235	232	243	244	257	255	248	254	246	233	237	239	250	254	239	256	239	233	245	257	229	255	251	256	244	240	231	239	234	236	253	248	248	245	233	237	248	241	250	250	243	243	239	248	230	250	234	245	251	254	251	245	252	230	247	236	252	256	238	237	245	249	254	235	253	233	229	229	240	228	251	255	244	249	243	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	244	230	241	228	255	244	245	250	253	230	230	255	229	253	252	248	256	229	232	231	234	246	238	239	251	256	229	243	240	237	236	250	233	252	238	240	248	233	235	243	246	254	241	231	228	229	235	254	]
    [	180	233	249	238	244	237	245	228	245	254	248	239	254	239	250	232	234	231	243	244	257	255	247	254	245	232	236	238	249	254	239	256	238	232	245	256	228	254	251	256	244	240	230	238	233	236	252	248	248	244	232	237	247	241	250	249	242	243	238	247	230	250	233	244	251	253	250	244	252	230	247	236	252	256	238	236	244	248	254	235	252	233	228	229	240	228	250	254	243	249	243	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	244	230	241	228	254	244	244	250	252	229	230	255	229	252	251	247	255	228	231	230	234	246	238	238	251	255	229	243	240	236	236	250	232	252	238	239	248	233	235	243	246	253	241	230	228	229	235	254	]
    [	194	247	263	252	258	251	259	242	259	268	262	252	268	253	264	246	248	245	257	258	270	268	261	268	259	246	250	252	263	268	253	270	252	246	259	270	242	268	265	269	258	253	244	252	247	250	266	261	261	258	246	251	261	255	264	263	256	256	252	261	244	264	247	258	265	267	264	258	265	244	260	250	266	270	252	250	258	262	268	249	266	246	242	243	254	242	264	268	257	263	257	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	258	244	255	242	268	258	258	264	266	243	244	269	243	266	265	261	269	242	245	244	248	259	252	252	265	269	243	257	254	250	250	264	246	266	251	253	262	247	249	256	260	267	254	244	242	243	249	267	]
    [	195	248	264	253	259	252	260	243	260	269	263	253	269	254	265	247	249	246	258	259	271	269	262	269	260	247	251	253	264	269	254	271	253	247	259	271	243	269	266	270	259	254	245	253	248	251	267	262	262	259	247	252	262	256	265	264	257	257	253	262	245	265	248	259	266	268	265	259	266	245	261	251	267	271	253	251	259	263	269	250	267	247	243	244	255	243	265	269	258	264	258	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	259	245	256	243	269	259	259	265	267	244	245	270	244	267	266	262	270	243	246	245	249	260	253	253	266	270	244	258	255	251	251	265	247	267	252	254	263	248	250	257	261	268	255	245	243	244	250	268	]
    [	184	237	253	242	248	241	249	232	249	258	252	243	258	243	254	236	238	235	247	248	261	259	251	258	249	236	241	242	253	258	243	260	242	236	249	260	232	258	255	260	248	244	234	242	237	240	256	252	252	248	236	241	251	245	254	253	246	247	242	251	234	254	237	248	255	257	254	249	256	234	251	240	256	260	242	240	248	252	258	239	256	237	232	233	244	232	254	258	247	253	247	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	248	234	245	232	258	248	248	254	256	233	234	259	233	256	255	251	259	232	235	234	238	250	242	242	255	259	233	247	244	240	240	254	236	256	242	243	252	237	239	247	250	257	245	234	232	233	239	258	]
    [	177	231	247	235	242	234	243	226	243	252	246	236	251	237	248	229	232	229	240	241	254	252	245	252	243	230	234	236	247	251	237	254	236	230	242	254	226	252	248	253	241	237	228	236	231	233	250	245	245	242	230	234	245	238	247	247	240	240	236	245	227	247	231	242	248	251	248	242	249	227	244	233	249	253	235	234	242	246	251	232	250	230	226	226	237	225	248	252	241	246	240	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	241	227	238	226	252	241	242	247	250	227	227	252	226	250	249	245	253	226	229	228	231	243	235	236	248	253	227	240	237	234	233	247	230	249	235	237	245	230	232	240	243	251	238	228	225	226	232	251	]
    [	177	231	247	235	242	234	243	226	243	252	246	236	251	237	248	229	232	229	240	241	254	252	245	252	243	230	234	236	247	251	237	254	236	230	242	254	226	252	248	253	241	237	228	236	231	233	250	245	245	242	230	234	245	238	247	247	240	240	236	245	227	247	231	242	248	251	248	242	249	227	244	233	249	253	235	234	242	246	251	232	250	230	226	226	237	225	248	252	241	246	240	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	241	227	238	226	252	241	242	247	250	227	227	252	226	250	249	245	253	226	229	228	231	243	235	236	248	253	227	240	237	234	233	247	230	249	235	237	245	230	232	240	243	251	238	228	225	226	232	251	]
    [	178	232	247	236	243	235	244	227	244	252	247	237	252	237	249	230	232	230	241	242	255	253	246	252	243	231	235	236	248	252	237	254	236	231	243	255	227	253	249	254	242	238	229	237	231	234	251	246	246	242	230	235	246	239	248	247	240	241	236	246	228	248	231	243	249	251	249	243	250	228	245	234	250	254	236	235	243	247	252	233	251	231	227	227	238	226	248	253	241	247	241	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	242	228	239	226	252	242	242	248	251	227	228	253	227	251	250	246	254	227	230	228	232	244	236	236	249	253	227	241	238	235	234	248	230	250	236	238	246	231	233	241	244	251	239	229	226	227	233	252	]
    [	196	250	266	254	261	253	262	245	262	270	265	255	270	256	267	248	251	248	259	260	273	271	264	270	262	249	253	255	266	270	255	273	255	249	261	273	245	271	267	272	260	256	247	255	250	252	269	264	264	261	249	253	264	257	266	266	259	259	255	264	246	266	250	261	267	270	267	261	268	246	263	252	268	272	254	253	261	265	270	251	269	249	245	245	256	244	267	271	260	265	259	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	260	246	257	244	271	260	261	266	269	246	246	271	245	269	268	264	272	245	248	247	250	262	254	255	267	272	245	259	256	253	252	266	249	268	254	256	264	249	251	259	262	270	257	247	244	245	251	270	]
    [	186	240	256	244	251	243	252	235	252	261	255	245	261	246	257	238	241	238	249	251	263	261	254	261	252	239	243	245	256	260	246	263	245	239	251	263	235	261	257	262	250	246	237	245	240	242	259	254	254	251	239	243	254	247	256	256	249	249	245	254	237	256	240	251	258	260	257	251	258	236	253	242	258	263	244	243	251	255	261	241	259	239	235	236	246	235	257	261	250	255	249	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	250	236	247	235	261	250	251	256	259	236	236	261	236	259	258	254	262	235	238	237	240	252	244	245	257	262	236	249	247	243	242	256	239	258	244	246	254	239	242	249	253	260	247	237	235	235	242	260	]
    [	178	231	247	235	242	235	243	226	243	252	246	236	252	237	248	229	232	229	240	242	254	252	245	252	243	230	234	236	247	251	237	254	236	230	242	254	226	252	249	253	241	237	228	236	231	233	250	245	245	242	230	234	245	239	248	247	240	240	236	245	228	247	231	242	249	251	248	242	249	227	244	234	249	254	235	234	242	246	252	233	250	230	226	227	237	226	248	252	241	247	241	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	242	228	239	226	252	241	242	247	250	227	228	253	227	250	249	245	253	226	229	228	232	243	235	236	248	253	227	241	238	234	234	248	230	249	235	237	246	230	233	240	244	251	238	228	226	227	233	251	]
    [	194	248	264	252	259	251	260	243	260	269	263	253	269	254	265	246	249	246	257	259	271	269	262	269	260	247	251	253	264	268	254	271	253	247	259	271	243	269	265	270	258	254	245	253	248	250	267	262	262	259	247	251	262	255	264	264	257	257	253	262	245	264	248	259	265	268	265	259	266	244	261	250	266	271	252	251	259	263	268	249	267	247	243	244	254	242	265	269	258	263	257	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	258	244	255	243	269	258	259	264	267	244	244	269	243	267	266	262	270	243	246	245	248	260	252	253	265	270	244	257	254	251	250	264	247	266	252	254	262	247	249	257	260	268	255	245	242	243	249	268	]
    [	187	241	257	245	252	244	253	236	253	262	256	246	262	247	258	239	242	239	250	252	264	262	255	262	253	240	244	246	257	261	247	264	246	240	252	264	236	262	258	263	251	247	238	246	241	243	260	255	255	252	240	244	255	248	257	257	250	250	246	255	238	257	241	252	259	261	258	252	259	237	254	243	259	264	245	244	252	256	262	242	260	240	236	237	247	236	258	262	251	256	250	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	251	237	248	236	262	251	252	257	260	237	237	262	237	260	259	255	263	236	239	238	241	253	245	246	258	263	237	250	248	244	243	257	240	259	245	247	255	240	243	250	254	261	248	238	236	236	243	261	]
    [	184	237	253	242	249	241	250	233	250	258	253	243	258	243	255	236	238	236	247	248	261	259	251	258	249	237	241	242	254	258	243	260	242	237	249	261	233	259	255	260	248	244	235	243	237	240	257	252	252	248	236	241	252	245	254	253	246	247	242	251	234	254	237	249	255	257	255	249	256	234	251	240	256	260	242	241	249	253	258	239	257	237	233	233	244	232	254	259	247	253	247	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	248	234	245	232	258	248	248	254	257	233	234	259	233	257	256	252	259	233	236	234	238	250	242	242	255	259	233	247	244	241	240	254	236	256	242	244	252	237	239	247	250	257	245	235	232	233	239	258	]
    [	190	243	259	248	254	247	256	238	255	264	259	249	264	249	260	242	244	241	253	254	267	265	257	264	255	242	247	248	260	264	249	266	248	242	255	266	238	265	261	266	254	250	241	248	243	246	262	258	258	254	242	247	257	251	260	259	252	253	248	257	240	260	243	254	261	263	261	255	262	240	257	246	262	266	248	247	254	258	264	245	262	243	238	239	250	238	260	265	253	259	253	244	262	248	239	244	244	258	259	248	241	241	242	260	250	242	258	251	248	0	0	0	0	0	0	0	260	263	239	240	265	239	263	261	258	265	238	242	240	244	256	248	248	261	265	239	253	250	246	246	260	242	262	248	250	258	243	245	253	256	263	251	241	238	239	245	264	]
    [	176	229	245	234	241	233	242	225	242	250	245	235	250	235	247	228	230	228	239	240	253	251	243	250	241	229	233	234	246	250	235	252	234	229	241	253	225	251	247	252	240	236	227	235	229	232	249	244	244	240	228	233	244	237	246	245	238	239	234	243	226	246	229	241	247	249	247	241	248	226	243	232	248	252	234	233	241	245	250	231	249	229	225	225	236	224	246	251	239	245	239	230	248	234	225	230	230	244	245	234	227	227	228	246	236	228	244	237	234	0	0	0	0	0	0	0	246	249	225	226	251	225	249	248	244	251	225	228	226	230	242	234	234	247	251	225	239	236	233	232	246	228	248	234	236	244	229	231	239	242	249	237	227	224	225	231	250	]
    [	187	240	256	245	252	244	253	235	253	261	256	246	261	246	258	239	241	238	250	251	264	262	254	261	252	239	244	245	257	261	246	263	245	239	252	264	235	262	258	263	251	247	238	246	240	243	260	255	255	251	239	244	254	248	257	256	249	250	245	254	237	257	240	252	258	260	258	252	259	237	254	243	259	263	245	244	251	255	261	242	259	240	235	236	247	235	257	262	250	256	250	241	259	245	236	241	241	255	256	245	238	238	239	257	247	239	255	248	245	0	0	0	0	0	0	0	257	260	236	237	262	236	260	259	255	262	235	239	237	241	253	245	245	258	262	236	250	247	243	243	257	239	259	245	247	255	240	242	250	253	260	248	238	235	236	242	261	]
    [	174	228	244	232	239	231	240	223	240	248	243	233	248	234	245	226	229	226	237	238	251	249	242	248	240	227	231	233	244	248	234	251	233	227	239	251	223	249	245	250	238	234	225	233	228	230	247	242	242	239	227	231	242	235	244	244	237	237	233	242	224	244	228	239	245	248	245	239	246	224	241	230	246	250	232	231	239	243	248	229	247	227	223	223	234	222	245	249	238	243	237	229	246	232	223	228	228	242	243	232	226	226	226	244	235	226	243	236	232	0	0	0	0	0	0	0	244	247	224	224	249	223	247	246	242	250	223	226	225	228	240	232	233	245	250	223	237	234	231	230	244	227	246	232	234	242	227	229	237	240	248	235	225	222	223	229	248	]
    [	200	254	270	258	265	257	266	249	266	275	269	259	274	260	271	252	255	252	263	264	277	275	268	275	266	253	257	259	270	274	260	277	259	253	265	277	249	275	271	276	264	260	251	259	254	256	273	268	268	265	253	257	268	261	270	270	263	263	259	268	250	270	254	265	271	274	271	265	272	250	267	256	272	276	258	257	265	269	274	255	273	253	249	249	260	248	271	275	264	269	263	255	272	258	249	255	254	268	269	258	252	252	252	271	261	252	269	262	258	0	0	0	0	0	0	0	270	273	250	250	275	249	273	272	268	276	249	252	251	254	266	258	259	271	276	250	263	260	257	256	270	253	272	258	260	268	253	255	263	266	274	261	251	248	249	255	274	]
    [	190	243	259	248	254	247	255	238	255	264	258	249	264	249	260	242	244	241	253	254	267	265	257	264	255	242	247	248	259	264	249	266	248	242	255	266	238	264	261	266	254	250	240	248	243	246	262	258	258	254	242	247	257	251	260	259	252	253	248	257	240	260	243	254	261	263	260	255	262	240	257	246	262	266	248	246	254	258	264	245	262	243	238	239	250	238	260	264	253	259	253	244	262	247	239	244	244	258	259	248	241	241	242	260	250	241	258	251	248	0	0	0	0	0	0	0	260	262	239	240	265	239	262	261	257	265	238	241	240	244	256	248	248	261	265	239	253	250	246	246	260	242	262	248	249	258	243	245	253	256	263	251	240	238	239	245	264	]
    [	190	244	260	248	255	247	256	239	256	265	259	249	265	250	261	242	245	242	253	255	267	265	258	265	256	243	247	249	260	264	250	267	249	243	255	267	239	265	261	266	254	250	241	249	244	246	263	258	258	255	243	247	258	251	260	260	253	253	249	258	241	260	244	255	261	264	261	255	262	240	257	246	262	267	248	247	255	259	264	245	263	243	239	240	250	238	261	265	254	259	253	245	262	248	240	245	244	258	259	248	242	242	242	261	251	242	259	252	248	0	0	0	0	0	0	0	260	263	240	240	265	239	263	262	258	266	239	242	241	244	256	248	249	261	266	240	253	250	247	246	260	243	262	248	250	258	243	245	253	256	264	251	241	238	239	245	264	]
    [	196	249	265	254	260	253	262	244	261	270	264	255	270	255	266	248	250	247	259	260	273	271	263	270	261	248	253	254	265	270	255	272	254	248	261	272	244	271	267	272	260	256	246	254	249	252	268	264	264	260	248	253	263	257	266	265	258	259	254	263	246	266	249	260	267	269	267	261	268	246	263	252	268	272	254	252	260	264	270	251	268	249	244	245	256	244	266	270	259	265	259	250	268	253	245	250	250	264	265	254	247	247	248	266	256	247	264	257	254	260	246	257	244	270	260	260	0	0	0	0	0	0	0	0	0	0	0	247	246	250	262	254	254	267	271	245	259	256	252	252	266	248	268	254	255	264	249	251	259	262	269	257	247	244	245	251	270	]
    [	199	252	268	256	263	256	264	247	264	273	267	257	273	258	269	250	253	250	261	263	275	273	266	273	264	251	255	257	268	272	258	275	257	251	263	275	247	273	270	274	262	258	249	257	252	254	271	266	266	263	251	255	266	260	269	268	261	261	257	266	249	268	252	263	270	272	269	263	270	248	265	255	270	275	256	255	263	267	273	254	271	251	247	248	258	247	269	273	262	268	262	253	270	256	248	253	252	266	267	256	250	250	251	269	259	250	267	260	257	263	249	260	247	273	262	263	0	0	0	0	0	0	0	0	0	0	0	250	249	253	264	256	257	269	274	248	262	259	255	255	269	251	270	256	258	267	251	254	261	265	272	259	249	247	248	254	272	]
    [	175	229	245	233	240	232	241	224	241	250	244	234	249	235	246	227	230	227	238	240	252	250	243	250	241	228	232	234	245	249	235	252	234	228	240	252	224	250	246	251	239	235	226	234	229	231	248	243	243	240	228	232	243	236	245	245	238	238	234	243	225	245	229	240	246	249	246	240	247	225	242	231	247	251	233	232	240	244	249	230	248	228	224	225	235	223	246	250	239	244	238	230	247	233	225	230	229	243	244	233	227	227	227	246	236	227	244	237	233	239	225	236	224	250	239	240	0	0	0	0	0	0	0	0	0	0	0	227	226	229	241	233	234	246	251	225	238	235	232	231	245	228	247	233	235	243	228	230	238	241	249	236	226	223	224	230	249	]
    [	176	229	245	234	241	233	242	225	242	250	245	235	250	235	247	228	230	228	239	240	253	251	243	250	241	229	233	234	246	250	235	252	234	229	241	253	225	251	247	252	240	236	227	235	229	232	249	244	244	240	228	233	244	237	246	245	238	239	234	243	226	246	229	241	247	249	247	241	248	226	243	232	248	252	234	233	241	245	250	231	249	229	225	225	236	224	246	251	239	245	239	230	248	234	225	230	230	244	245	234	227	227	228	246	236	228	244	237	234	240	226	237	224	250	240	240	0	0	0	0	0	0	0	0	0	0	0	228	226	230	242	234	234	247	251	225	239	236	233	232	246	228	248	234	236	244	229	231	239	242	249	237	227	224	225	231	250	]
    [	201	254	270	259	266	258	267	250	267	275	270	260	275	260	272	253	255	252	264	265	278	276	268	275	266	254	258	259	271	275	260	277	259	254	266	278	249	276	272	277	265	261	252	260	254	257	274	269	269	265	253	258	268	262	271	270	263	264	259	268	251	271	254	266	272	274	272	266	273	251	268	257	273	277	259	258	265	270	275	256	273	254	249	250	261	249	271	276	264	270	264	255	273	259	250	255	255	269	270	259	252	252	253	271	261	253	269	262	259	265	251	262	249	275	265	265	0	0	0	0	0	0	0	0	0	0	0	253	251	255	267	259	259	272	276	250	264	261	257	257	271	253	273	259	261	269	254	256	264	267	274	262	252	249	250	256	275	]
    [	175	229	244	233	240	232	241	224	241	249	244	234	249	234	246	227	229	227	238	239	252	250	243	249	240	228	232	233	245	249	234	251	233	228	240	252	224	250	246	251	239	235	226	234	229	231	248	243	243	240	227	232	243	236	245	244	237	238	233	243	225	245	228	240	246	248	246	240	247	225	242	231	247	251	233	232	240	244	249	230	248	228	224	224	235	223	245	250	238	244	238	230	247	233	224	229	229	243	244	233	226	226	227	245	236	227	243	237	233	239	225	236	223	249	239	239	0	0	0	0	0	0	0	0	0	0	0	227	225	229	241	233	233	246	250	224	238	235	232	231	245	227	247	233	235	243	228	230	238	241	248	236	226	223	224	230	249	]
    [	199	252	268	257	263	256	264	247	264	273	267	257	273	258	269	251	253	250	262	263	275	273	266	273	264	251	255	257	268	273	258	275	257	251	263	275	247	273	270	274	263	258	249	257	252	255	271	266	266	263	251	256	266	260	269	268	261	261	257	266	249	269	252	263	270	272	269	263	270	249	265	255	271	275	257	255	263	267	273	254	271	251	247	248	259	247	269	273	262	268	262	253	270	256	248	253	252	266	267	256	250	250	251	269	259	250	267	260	257	263	249	260	247	273	262	263	0	0	0	0	0	0	0	0	0	0	0	250	249	253	264	256	257	270	274	248	262	259	255	255	269	251	270	256	258	267	252	254	261	265	272	259	249	247	248	254	272	]
    [	198	251	267	255	262	255	263	246	263	272	266	256	272	257	268	249	252	249	260	262	274	272	265	272	263	250	254	256	267	271	257	274	256	250	262	274	246	272	269	273	261	257	248	256	251	253	270	265	265	262	250	254	265	259	268	267	260	260	256	265	248	267	251	262	269	271	268	262	269	247	264	254	269	274	255	254	262	266	272	253	270	250	246	247	257	246	268	272	261	267	261	252	269	255	247	252	251	265	266	255	249	249	250	268	258	249	266	259	256	261	248	259	246	272	261	262	0	0	0	0	0	0	0	0	0	0	0	249	248	252	263	255	256	268	273	247	261	258	254	254	268	250	269	255	257	266	250	253	260	264	271	258	248	246	246	253	271	]
    [	194	247	263	252	258	251	259	242	259	268	262	252	268	253	264	246	248	245	256	258	270	268	261	268	259	246	250	252	263	268	253	270	252	246	258	270	242	268	265	269	258	253	244	252	247	250	266	261	261	258	246	251	261	255	264	263	256	256	252	261	244	264	247	258	265	267	264	258	265	243	260	250	266	270	252	250	258	262	268	249	266	246	242	243	253	242	264	268	257	263	257	248	265	251	243	248	247	261	262	251	245	245	246	264	254	245	262	255	252	258	244	255	242	268	257	258	0	0	0	0	0	0	0	0	0	0	0	245	244	248	259	251	252	265	269	243	257	254	250	250	264	246	265	251	253	262	247	249	256	260	267	254	244	242	243	249	267	]
    [	201	255	271	259	266	258	267	250	267	276	270	260	276	261	272	253	256	253	264	266	278	276	269	276	267	254	258	260	271	275	261	278	260	254	266	278	250	276	272	277	265	261	252	260	255	257	274	269	269	266	254	258	269	262	271	271	264	264	260	269	252	271	255	266	273	275	272	266	273	251	268	257	273	278	259	258	266	270	276	256	274	254	250	251	261	250	272	276	265	270	264	256	273	259	251	256	255	269	270	259	253	253	254	272	262	253	270	263	259	265	251	262	250	276	265	266	0	0	0	0	0	0	0	0	0	0	0	253	252	255	267	259	260	272	277	251	264	262	258	257	271	254	273	259	261	269	254	257	264	268	275	262	252	250	250	257	275	]
    [	175	228	244	232	239	232	240	223	240	249	243	233	249	234	245	226	229	226	237	239	251	249	242	249	240	227	231	233	244	248	234	251	233	227	239	251	223	249	246	250	238	234	225	233	228	230	247	242	242	239	227	231	242	235	245	244	237	237	233	242	225	244	228	239	246	248	245	239	246	224	241	231	246	251	232	231	239	243	249	230	247	227	223	224	234	223	245	249	238	244	238	229	246	232	224	229	228	242	243	232	226	226	227	245	235	226	243	236	233	238	225	235	223	249	238	239	0	0	0	0	0	0	0	0	0	0	0	226	225	228	240	232	233	245	250	224	238	235	231	231	245	227	246	232	234	243	227	230	237	241	248	235	225	223	223	230	248	]
    [	179	485	501	490	497	489	498	481	498	506	501	491	506	491	503	484	486	483	495	496	509	507	499	506	497	485	489	490	442	446	431	448	430	425	437	449	421	447	443	448	436	432	423	371	365	368	385	380	380	376	364	369	380	373	382	381	374	285	280	289	272	292	275	287	293	295	293	287	294	272	289	278	294	298	280	279	286	291	296	277	294	275	270	271	282	270	292	297	285	291	285	232	249	235	227	232	231	245	246	235	229	229	230	248	238	229	246	239	236	242	228	239	226	252	241	242	247	250	227	228	253	227	250	249	245	253	226	0	0	0	0	0	0	0	0	227	241	238	234	234	248	230	249	235	237	246	230	233	240	244	251	238	228	226	227	233	251	]
    [	177	484	500	489	495	488	496	479	496	505	499	489	505	490	501	483	485	482	494	495	507	505	498	505	496	483	487	489	440	445	430	447	429	423	436	447	419	445	442	446	435	430	421	369	364	367	383	378	378	375	363	368	378	372	381	380	373	283	279	288	271	291	274	285	292	294	291	285	292	271	287	277	293	297	279	277	285	289	295	276	293	273	269	270	281	269	291	295	284	290	284	231	248	234	225	231	230	244	245	234	228	228	228	247	237	228	245	238	234	240	226	237	225	251	240	241	246	249	226	226	251	225	249	248	244	252	225	0	0	0	0	0	0	0	0	226	239	236	233	232	246	229	248	234	236	244	229	231	239	242	250	237	227	224	225	231	250	]
    [	181	488	504	492	499	491	500	483	500	509	503	493	509	494	505	486	489	486	497	499	511	509	502	509	500	487	491	493	444	448	434	451	433	427	439	451	423	449	445	450	438	434	425	373	368	370	387	382	382	379	367	371	382	375	384	384	377	287	283	292	274	294	278	289	295	298	295	289	296	274	291	280	296	301	282	281	289	293	298	279	297	277	273	274	284	272	295	299	288	293	287	234	252	238	229	234	234	248	249	238	231	231	232	250	240	232	248	241	238	244	230	241	228	254	244	244	250	253	229	230	255	229	253	252	248	255	228	0	0	0	0	0	0	0	0	229	243	240	236	236	250	232	252	238	240	248	233	235	243	246	253	241	231	228	229	235	254	]
    [	193	500	515	504	511	503	512	495	512	520	515	505	520	505	517	498	500	498	509	510	523	521	514	520	512	499	503	504	456	460	445	462	444	439	451	463	435	461	457	462	450	446	437	385	380	382	399	394	394	391	378	383	394	387	396	395	388	299	294	304	286	306	290	301	307	309	307	301	308	286	303	292	308	312	294	293	301	305	310	291	309	289	285	285	296	284	306	311	300	305	299	246	264	249	241	246	246	259	260	250	243	243	244	262	252	243	260	253	250	256	242	253	240	266	256	256	262	264	241	242	267	241	264	263	259	267	240	0	0	0	0	0	0	0	0	241	255	252	248	248	262	244	264	249	251	260	245	247	254	258	265	252	242	240	241	247	265	]
    [	185	492	508	496	503	495	504	487	504	512	507	497	512	498	509	490	493	490	501	502	515	513	506	512	504	491	495	497	448	452	437	455	437	431	443	455	427	453	449	454	442	438	429	377	372	374	391	386	386	383	371	375	386	379	388	388	381	291	287	296	278	298	282	293	299	302	299	293	300	278	295	284	300	304	286	285	293	297	302	283	301	281	277	277	288	276	299	303	292	297	291	238	256	241	233	238	238	252	253	242	235	235	236	254	244	235	252	245	242	248	234	245	232	258	248	248	254	256	233	234	259	233	256	255	251	259	232	0	0	0	0	0	0	0	0	233	247	244	240	240	254	236	256	242	243	252	237	239	247	250	257	245	234	232	233	239	258	]
    [	186	492	508	497	503	496	504	487	504	513	507	497	513	498	509	491	493	490	502	503	515	513	506	513	504	491	495	497	448	453	438	455	437	431	444	455	427	453	450	454	443	438	429	377	372	375	391	386	386	383	371	376	386	380	389	388	381	292	287	296	279	299	282	293	300	302	299	293	300	279	295	285	301	305	287	285	293	297	303	284	301	281	277	278	289	277	299	303	292	298	292	239	256	242	234	239	238	252	253	242	236	236	236	255	245	236	253	246	242	248	234	245	233	259	248	249	254	257	234	234	259	233	257	256	252	260	233	0	0	0	0	0	0	0	0	234	247	244	241	240	254	237	256	242	244	252	237	239	247	250	258	245	235	232	233	239	258	]
    [	198	505	521	509	516	508	517	500	517	525	520	510	525	511	522	503	506	503	514	515	528	526	519	526	517	504	508	510	461	465	451	468	450	444	456	468	440	466	462	467	455	451	442	390	385	387	404	399	399	396	384	388	399	392	401	401	394	304	300	309	291	311	295	306	312	315	312	306	313	291	308	297	313	317	299	298	306	310	315	296	314	294	290	290	301	289	312	316	305	310	304	251	269	254	246	251	251	265	266	255	248	248	249	267	257	248	265	258	255	261	247	258	245	271	261	261	267	269	246	247	272	246	270	268	265	272	245	0	0	0	0	0	0	0	0	246	260	257	253	253	267	249	269	255	256	265	250	252	260	263	270	258	248	245	246	252	271	]
    [	203	509	525	514	520	513	521	504	521	530	524	514	530	515	526	508	510	507	519	520	532	531	523	530	521	508	512	514	465	470	455	472	454	448	461	472	444	470	467	471	460	455	446	394	389	392	408	403	403	400	388	393	403	397	406	405	398	309	304	313	296	316	299	310	317	319	316	310	317	296	312	302	318	322	304	302	310	314	320	301	318	298	294	295	306	294	316	320	309	315	309	256	273	259	251	256	255	269	270	259	253	253	253	272	262	253	270	263	259	265	251	262	250	276	265	266	271	274	251	251	276	250	274	273	269	277	250	0	0	0	0	0	0	0	0	251	264	261	258	257	271	254	273	259	261	269	254	256	264	267	275	262	252	249	250	256	275	]
    [	175	229	245	233	240	232	241	224	241	249	244	234	249	235	246	227	230	227	238	239	252	250	243	249	241	228	232	234	245	249	234	252	234	228	240	252	224	250	246	251	239	235	226	234	229	231	248	243	243	240	228	232	243	236	245	245	238	238	234	243	225	245	229	240	246	249	246	240	247	225	242	231	247	251	233	232	240	244	249	230	248	228	224	224	235	223	246	250	239	244	238	230	247	233	224	229	229	243	244	233	227	227	227	245	236	227	244	237	233	239	225	236	223	250	239	240	245	248	225	225	250	224	248	247	243	251	224	227	226	229	241	233	234	246	251	0	0	0	0	0	245	228	247	233	235	243	228	230	238	241	249	236	226	223	224	230	249	]
    [	189	242	258	247	254	246	255	238	255	263	258	248	263	248	260	241	243	240	252	253	266	264	256	263	254	241	246	247	259	263	248	265	247	242	254	266	237	264	260	265	253	249	240	248	242	245	262	257	257	253	241	246	256	250	259	258	251	252	247	256	239	259	242	254	260	262	260	254	261	239	256	245	261	265	247	246	253	258	263	244	261	242	237	238	249	237	259	264	252	258	252	243	261	247	238	243	243	257	258	247	240	240	241	259	249	241	257	250	247	253	239	250	237	263	253	253	259	262	238	239	264	238	262	261	257	264	238	241	239	243	255	247	247	260	264	0	0	0	0	0	259	241	261	247	249	257	242	244	252	255	262	250	240	237	238	244	263	]
    [	186	240	255	244	251	243	252	235	252	260	255	245	260	245	257	238	240	238	249	250	263	261	254	260	252	239	243	244	256	260	245	262	244	239	251	263	235	261	257	262	250	246	237	245	240	242	259	254	254	251	238	243	254	247	256	255	248	249	244	254	236	256	240	251	257	259	257	251	258	236	253	242	258	262	244	243	251	255	260	241	259	239	235	235	246	234	256	261	250	255	249	241	258	244	235	240	240	254	255	244	237	237	238	256	247	238	254	248	244	250	236	247	234	260	250	250	256	259	235	236	261	235	259	258	254	262	235	238	236	240	252	244	244	257	261	0	0	0	0	0	256	239	258	244	246	254	239	241	249	252	259	247	237	234	235	241	260	]
    [	182	236	252	240	247	240	248	231	248	257	251	241	257	242	253	234	237	234	245	247	259	257	250	257	248	235	239	241	252	256	242	259	241	235	247	259	231	257	253	258	246	242	233	241	236	238	255	250	250	247	235	239	250	243	252	252	245	245	241	250	233	252	236	247	254	256	253	247	254	232	249	238	254	259	240	239	247	251	257	238	255	235	231	232	242	231	253	257	246	252	245	237	254	240	232	237	236	250	251	240	234	234	235	253	243	234	251	244	241	246	233	243	231	257	246	247	252	255	232	233	257	232	255	254	250	258	231	234	233	236	248	240	241	253	258	0	0	0	0	0	252	235	254	240	242	250	235	238	245	249	256	243	233	231	231	238	256	]
    [	182	235	251	240	247	239	248	231	248	256	251	241	256	241	253	234	236	233	245	246	259	257	249	256	247	235	239	240	252	256	241	258	240	235	247	259	231	257	253	258	246	242	233	241	235	238	255	250	250	246	234	239	250	243	252	251	244	245	240	249	232	252	235	247	253	255	253	247	254	232	249	238	254	258	240	239	246	251	256	237	254	235	230	231	242	230	252	257	245	251	245	236	254	240	231	236	236	250	251	240	233	233	234	252	242	234	250	243	240	246	232	243	230	256	246	246	252	255	231	232	257	231	255	254	250	257	231	234	232	236	248	240	240	253	257	0	0	0	0	0	252	234	254	240	242	250	235	237	245	248	255	243	233	230	231	237	256	]
    [	196	249	265	254	261	253	262	245	262	270	265	255	270	255	267	248	250	247	259	260	273	271	263	270	261	249	253	254	266	270	255	272	254	249	261	273	244	271	267	272	260	256	247	255	249	252	269	264	264	260	248	253	263	257	266	265	258	259	254	263	246	266	249	261	267	269	267	261	268	246	263	252	268	272	254	253	260	265	270	251	268	249	244	245	256	244	266	271	259	265	259	250	268	254	245	250	250	264	265	254	247	247	248	266	256	248	264	257	254	260	246	257	244	270	260	260	266	269	245	246	271	245	269	268	264	271	245	248	246	250	262	254	254	267	271	245	259	256	252	252	0	0	0	0	256	264	249	251	259	262	269	257	247	244	245	251	270	]
    [	178	232	248	236	243	235	244	227	244	253	247	237	253	238	249	230	233	230	241	243	255	253	246	253	244	231	235	237	248	252	238	255	237	231	243	255	227	253	249	254	242	238	229	237	232	234	251	246	246	243	231	235	246	239	248	248	241	241	237	246	229	248	232	243	249	252	249	243	250	228	245	234	250	255	236	235	243	247	252	233	251	231	227	228	238	226	249	253	242	247	241	233	250	236	228	233	232	246	247	236	230	230	230	249	239	230	247	240	236	242	228	239	227	253	242	243	248	251	228	228	253	227	251	250	246	254	227	230	229	232	244	236	237	249	254	228	241	239	235	234	0	0	0	0	238	246	231	234	241	244	252	239	229	226	227	233	252	]
    [	198	251	267	256	262	255	263	246	263	272	266	257	272	257	268	250	252	249	261	262	275	273	265	272	263	250	254	256	267	272	257	274	256	250	263	274	246	272	269	274	262	258	248	256	251	254	270	266	266	262	250	255	265	259	268	267	260	261	256	265	248	268	251	262	269	271	268	262	270	248	265	254	270	274	256	254	262	266	272	253	270	251	246	247	258	246	268	272	261	267	261	252	270	255	247	252	252	266	267	256	249	249	250	268	258	249	266	259	256	262	248	259	246	272	262	262	268	270	247	248	273	247	270	269	265	273	246	249	248	252	264	256	256	269	273	247	261	258	254	254	0	0	0	0	257	266	251	253	261	264	271	259	248	246	247	253	272	]
    [	184	237	253	242	248	241	249	232	249	258	252	242	258	243	254	236	238	235	247	248	260	259	251	258	249	236	240	242	253	258	243	260	242	236	249	260	232	258	255	259	248	243	234	242	237	240	256	251	251	248	236	241	251	245	254	253	246	247	242	251	234	254	237	248	255	257	254	248	255	234	250	240	256	260	242	240	248	252	258	239	256	236	232	233	244	232	254	258	247	253	247	238	256	241	233	238	238	251	252	242	235	235	236	254	244	235	252	245	242	248	234	245	232	258	248	248	254	256	233	234	259	233	256	255	251	259	232	235	234	238	249	242	242	255	259	233	247	244	240	240	0	0	0	0	243	252	237	239	246	250	257	244	234	232	233	239	257	]
    [	186	239	255	243	250	243	251	234	251	260	254	244	260	245	256	237	240	237	248	250	262	260	253	260	251	238	242	244	255	259	245	262	244	238	250	262	234	260	257	261	249	245	236	244	239	242	258	253	253	250	238	243	253	247	256	255	248	248	244	253	236	255	239	250	257	259	256	250	257	235	252	242	257	262	243	242	250	254	260	241	258	238	234	235	245	234	256	260	249	255	249	240	257	243	235	240	239	253	254	243	237	237	238	256	246	237	254	247	244	250	236	247	234	260	249	250	255	258	235	236	261	235	258	257	253	261	234	237	236	240	251	243	244	256	261	235	249	246	242	242	256	238	257	243	0	0	0	0	0	252	259	246	236	234	235	241	259	]
    [	194	247	263	252	259	251	260	243	260	268	263	253	268	253	265	246	248	245	257	258	271	269	261	268	259	247	251	252	264	268	253	270	252	247	259	271	243	269	265	270	258	254	245	253	247	250	267	262	262	258	246	251	262	255	264	263	256	257	252	261	244	264	247	259	265	267	265	259	266	244	261	250	266	270	252	251	258	263	268	249	266	247	242	243	254	242	264	269	257	263	257	248	266	252	243	248	248	262	263	252	245	245	246	264	254	246	262	255	252	258	244	255	242	268	258	258	264	267	243	244	269	243	267	266	262	269	243	246	244	248	260	252	252	265	269	243	257	254	250	250	264	246	266	252	0	0	0	0	0	260	267	255	245	242	243	249	268	]
    [	179	232	248	237	243	236	245	227	244	253	247	238	253	238	249	231	233	230	242	243	256	254	246	253	244	231	236	237	248	253	238	255	237	231	244	255	227	254	250	255	243	239	229	237	232	235	251	247	247	243	231	236	246	240	249	248	241	242	237	246	229	249	232	243	250	252	250	244	251	229	246	235	251	255	237	235	243	247	253	234	251	232	227	228	239	227	249	253	242	248	242	233	251	236	228	233	233	247	248	237	230	230	231	249	239	230	247	240	237	243	229	240	227	253	243	243	249	251	228	229	254	228	252	250	247	254	227	230	229	233	245	237	237	250	254	228	242	239	235	235	249	231	251	237	0	0	0	0	0	245	252	240	229	227	228	234	253	]
    [	181	235	250	239	246	238	247	230	247	255	250	240	255	240	252	233	235	233	244	245	258	256	249	255	247	234	238	239	251	255	240	257	239	234	246	258	230	256	252	257	245	241	232	240	235	237	254	249	249	246	233	238	249	242	251	250	243	244	239	249	231	251	235	246	252	254	252	246	253	231	248	237	253	257	239	238	246	250	255	236	254	234	230	230	241	229	251	256	245	250	244	236	253	239	230	235	235	249	250	239	232	232	233	251	242	233	249	243	239	245	231	242	229	255	245	245	251	254	230	231	256	230	254	253	249	257	230	233	231	235	247	239	239	252	256	230	244	241	238	237	251	234	253	239	0	0	0	0	0	247	254	242	232	229	230	236	255	]
    [	189	242	258	247	253	246	254	237	254	263	257	247	263	248	259	241	243	240	252	253	265	264	256	263	254	241	245	247	258	263	248	265	247	241	254	265	237	263	260	264	253	248	239	247	242	245	261	256	256	253	241	246	256	250	259	258	251	252	247	256	239	259	242	253	260	262	259	253	260	239	255	245	261	265	247	245	253	257	263	244	261	242	237	238	249	237	259	263	252	258	252	243	261	246	238	243	243	256	257	247	240	240	241	259	249	240	257	250	247	253	239	250	237	263	253	253	259	261	238	239	264	238	261	260	256	264	237	240	239	243	254	247	247	260	264	238	252	249	245	245	259	241	261	246	0	0	0	0	0	255	262	250	239	237	238	244	263	]
    [	192	246	261	250	257	249	258	241	258	266	261	251	266	251	263	244	246	244	255	256	269	267	260	266	257	245	249	250	262	266	251	268	250	245	257	269	241	267	263	268	256	252	243	251	246	248	265	260	260	257	244	249	260	253	262	261	254	255	250	260	242	262	245	257	263	265	263	257	264	242	259	248	264	268	250	249	257	261	266	247	265	245	241	241	252	240	262	267	255	261	255	247	264	250	241	246	246	260	261	250	243	243	244	262	253	244	260	254	250	256	242	253	240	266	256	256	262	265	241	242	267	241	265	264	260	268	241	244	242	246	258	250	250	263	267	241	255	252	249	248	262	244	264	250	252	260	245	247	255	0	0	0	0	0	0	0	0	]
    [	199	253	269	257	264	256	265	248	265	274	268	258	274	259	270	251	254	251	262	264	276	274	267	274	265	252	256	258	269	273	259	276	258	252	264	276	248	274	270	275	263	259	250	258	253	255	272	267	267	264	252	256	267	260	269	269	262	262	258	267	250	269	253	264	270	273	270	264	271	249	266	255	271	276	257	256	264	268	273	254	272	252	248	249	259	247	270	274	263	268	262	254	271	257	249	254	253	267	268	257	251	251	251	270	260	251	268	261	257	263	249	260	248	274	263	264	269	272	249	249	274	248	272	271	267	275	248	251	250	253	265	257	258	270	275	249	262	259	256	255	269	252	271	257	259	267	252	254	262	0	0	0	0	0	0	0	0	]
    [	187	240	256	245	251	244	252	235	252	261	255	245	261	246	257	239	241	238	250	251	263	262	254	261	252	239	243	245	256	261	246	263	245	239	252	263	235	261	258	262	251	246	237	245	240	243	259	254	254	251	239	244	254	248	257	256	249	250	245	254	237	257	240	251	258	260	257	251	258	237	253	243	259	263	245	243	251	255	261	242	259	240	235	236	247	235	257	261	250	256	250	241	259	244	236	241	241	254	255	245	238	238	239	257	247	238	255	248	245	251	237	248	235	261	251	251	257	259	236	237	262	236	259	258	254	262	235	238	237	241	252	245	245	258	262	236	250	247	243	243	257	239	259	244	246	255	240	242	250	0	0	0	0	0	0	0	0	]
    [	177	230	246	235	241	234	242	225	242	251	245	235	251	236	247	229	231	228	239	241	253	251	244	251	242	229	233	235	246	250	236	253	235	229	241	253	225	251	248	252	241	236	227	235	230	233	249	244	244	241	229	234	244	238	247	246	239	239	235	244	227	247	230	241	248	250	247	241	248	226	243	233	249	253	234	233	241	245	251	232	249	229	225	226	236	225	247	251	240	246	240	231	248	234	226	231	230	244	245	234	228	228	229	247	237	228	245	238	235	241	227	238	225	251	240	241	247	249	226	227	252	226	249	248	244	252	225	228	227	231	242	234	235	248	252	226	240	237	233	233	247	229	248	234	236	245	229	232	239	0	0	0	0	0	0	0	0	]
    [	174	228	243	232	239	231	240	223	240	248	243	233	248	233	245	226	228	226	237	238	251	249	242	248	239	227	231	232	244	248	233	250	232	227	239	251	223	249	245	250	238	234	225	233	227	230	247	242	242	238	226	231	242	235	244	243	236	237	232	242	224	244	227	239	245	247	245	239	246	224	241	230	246	250	232	231	239	243	248	229	247	227	223	223	234	222	244	249	237	243	237	229	246	232	223	228	228	242	243	232	225	225	226	244	235	226	242	236	232	238	224	235	222	248	238	238	244	247	223	224	249	223	247	246	242	250	223	226	224	228	240	232	232	245	249	223	237	234	231	230	244	226	246	232	234	242	227	229	237	0	0	0	0	0	0	0	0	]
    [	175	228	244	233	239	232	241	223	240	249	244	234	249	234	245	227	229	226	238	239	252	250	242	249	240	227	232	233	245	249	234	251	233	227	240	252	223	250	246	251	239	235	226	234	228	231	248	243	243	239	227	232	242	236	245	244	237	238	233	242	225	245	228	239	246	248	246	240	247	225	242	231	247	251	233	232	239	243	249	230	247	228	223	224	235	223	245	250	238	244	238	229	247	233	224	229	229	243	244	233	226	226	227	245	235	227	243	236	233	239	225	236	223	249	239	239	245	248	224	225	250	224	248	246	243	250	223	227	225	229	241	233	233	246	250	224	238	235	231	231	245	227	247	233	235	243	228	230	238	0	0	0	0	0	0	0	0	]
    [	181	235	250	239	246	238	247	230	247	255	250	240	255	240	252	233	235	233	244	245	258	256	249	255	247	234	238	239	251	255	240	257	239	234	246	258	230	256	252	257	245	241	232	240	235	237	254	249	249	246	233	238	249	242	251	250	243	244	239	249	231	251	235	246	252	254	252	246	253	231	248	237	253	257	239	238	246	250	255	236	254	234	230	230	241	229	251	256	245	250	244	236	253	239	230	235	235	249	250	239	232	232	233	251	242	233	249	243	239	245	231	242	229	255	245	245	251	254	230	231	256	230	254	253	249	257	230	233	231	235	247	239	239	252	256	230	244	241	238	237	251	233	253	239	241	249	234	236	244	0	0	0	0	0	0	0	0	]
    [	200	253	269	258	264	257	265	248	265	274	268	258	274	259	270	252	254	251	263	264	276	275	267	274	265	252	256	258	269	274	259	276	258	252	265	276	248	274	271	275	264	259	250	258	253	256	272	267	267	264	252	257	267	261	270	269	262	263	258	267	250	270	253	264	271	273	270	264	271	250	266	256	272	276	258	256	264	268	274	255	272	252	248	249	260	248	270	274	263	269	263	254	272	257	249	254	254	267	268	258	251	251	252	270	260	251	268	261	258	264	250	261	248	274	264	264	270	272	249	250	275	249	272	271	267	275	248	251	250	254	265	258	258	271	275	249	263	260	256	256	270	252	272	257	259	268	253	255	263	0	0	0	0	0	0	0	0	]]


  report matrix
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;COMPUTE THE NUMBER OF TRUCKS AND AGENTS NEEDED;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to COMPUTE_NUMBER_OF_AGENTS_NEEDED
  ;compute and set up the optimal number of mobile agents with the SMALLER INDEX scheduling method
  clear-turtles
  SETUP_INPUT
  set first_schedule True
  let x length SIBT_list * 10
  set number_of_fueling_trucks x
  set number_of_catering_trucks 3 * x
  set number_of_cleaning_trucks x
  set number_of_ULD_trains 2 * x
  set number_of_bulk_trains x


  SETUP_AGENTS

  let too_much_fueling count fueling_trucks with [length schedule = 0]
  set number_of_fueling_trucks number_of_fueling_trucks - too_much_fueling

  let too_much_catering count catering_trucks with [length schedule = 0]
  set number_of_catering_trucks number_of_catering_trucks - too_much_catering

  let too_much_cleaning count cleaning_trucks with [length schedule = 0]
  set number_of_cleaning_trucks number_of_cleaning_trucks - too_much_cleaning

  let too_much_cargo count ULD_trains with [length schedule = 0]
  set number_of_ULD_trains number_of_ULD_trains - too_much_cargo

  let too_much_bulk count bulk_trains with [length schedule = 0]
  set number_of_bulk_trains number_of_bulk_trains - too_much_bulk

  clear-turtles
  set first_schedule True
  SETUP_AGENTS

  show "Number of fueling agents : "
  show number_of_fueling_trucks
  show "Number of catering trucks :"
  show number_of_catering_trucks
  show "Number of cleaning trucks :"
  show number_of_cleaning_trucks
  show "Number of ULD trains :"
  show number_of_ULD_trains
  show "Number of bulk trains :"
  show number_of_bulk_trains
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DISTRIBUTION FUNCTIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to COMPUTE_DISTRIBUTION_PARAMETERS

; Computes the parameters of each generalized beta distribution
; Each generalized distribution is attached to a process duration (deboarding, boarding, unloading, loading, catering, cleaning)
; Input : / (it uses the global variables mean_{process name} and the coefficients that are some inputs to the model outside this function)
; Output : / (it modifies the global variables alpha_{process name}, beta_{process name}, c_{process name} and d_{process name})
  let i 0
  set alpha_deb []
  set beta_deb []
  set c_deb []
  set d_deb []

  set alpha_board []
  set beta_board []
  set c_board []
  set d_board []

  set alpha_fuel []
  set beta_fuel []
  set c_fuel []
  set d_fuel []

  set alpha_catering_1 []
  set beta_catering_1 []
  set c_catering_1 []
  set d_catering_1 []

  set alpha_catering_2 []
  set beta_catering_2 []
  set c_catering_2 []
  set d_catering_2 []

  set alpha_catering_3 []
  set beta_catering_3 []
  set c_catering_3 []
  set d_catering_3 []

  set alpha_cleaning []
  set beta_cleaning []
  set c_cleaning []
  set d_cleaning []

  set alpha_unload_bulk []
  set beta_unload_bulk []
  set c_unload_bulk []
  set d_unload_bulk []

  set alpha_unload_cont_1 []
  set beta_unload_cont_1 []
  set c_unload_cont_1 []
  set d_unload_cont_1 []

  set alpha_unload_cont_2 []
  set beta_unload_cont_2 []
  set c_unload_cont_2 []
  set d_unload_cont_2 []

  set alpha_load_bulk []
  set beta_load_bulk []
  set c_load_bulk []
  set d_load_bulk []

  set alpha_load_cont_1 []
  set beta_load_cont_1 []
  set c_load_cont_1 []
  set d_load_cont_1 []

  set alpha_load_cont_2 []
  set beta_load_cont_2 []
  set c_load_cont_2 []
  set d_load_cont_2 []

  while [i < length mean_deb][ ; 2 is the number of different plane types

    set alpha_deb lput (COMPUTE_ALPHA (item i mean_deb) 0) alpha_deb
    set beta_deb lput (COMPUTE_BETA (item i mean_deb) (item i alpha_deb) 0) beta_deb
    set c_deb lput (item 0 min_coeff * (item i mean_deb)) c_deb
    set d_deb lput (item 0 max_coeff * (item i mean_deb)) d_deb

    set alpha_board lput (COMPUTE_ALPHA (item i mean_board) 1) alpha_board
    set beta_board lput (COMPUTE_BETA (item i mean_board) (item i alpha_board) 1) beta_board
    set c_board lput (item 1 min_coeff * (item i mean_board)) c_board
    set d_board lput (item 1 max_coeff * (item i mean_board)) d_board

    set alpha_fuel lput (COMPUTE_ALPHA (item i mean_fuel) 2) alpha_fuel
    set beta_fuel lput (COMPUTE_BETA (item i mean_fuel) (item i alpha_fuel) 2) beta_fuel
    set c_fuel lput (item 2 min_coeff * (item i mean_fuel )) c_fuel
    set d_fuel lput (item 2 max_coeff * (item i mean_fuel )) d_fuel

    set alpha_cleaning lput (COMPUTE_ALPHA (item i mean_cleaning ) 3) alpha_cleaning
    set beta_cleaning lput (COMPUTE_BETA (item i mean_cleaning) (item i alpha_cleaning) 3) beta_cleaning
    set c_cleaning lput (item 3 min_coeff * (item i mean_cleaning )) c_cleaning
    set d_cleaning lput (item 3 max_coeff * (item i mean_cleaning )) d_cleaning


    (ifelse
      (item i mean_unload_bulk != 0) [
        set alpha_unload_bulk lput (COMPUTE_ALPHA (item i mean_unload_bulk) 4) alpha_unload_bulk
        set beta_unload_bulk  lput (COMPUTE_BETA (item i mean_unload_bulk ) (item i alpha_unload_bulk ) 4) beta_unload_bulk
        set c_unload_bulk  lput (item 4 min_coeff * (item i mean_unload_bulk  )) c_unload_bulk
        set d_unload_bulk  lput (item 4 max_coeff * (item i mean_unload_bulk  )) d_unload_bulk
      ]
      [
        set alpha_unload_bulk lput 0 alpha_unload_bulk
        set beta_unload_bulk  lput 0 beta_unload_bulk
        set c_unload_bulk  lput 0 c_unload_bulk
        set d_unload_bulk  lput 0 d_unload_bulk

    ])

    (ifelse
      (item i mean_unload_cont_1 != 0)[
        set alpha_unload_cont_1 lput (COMPUTE_ALPHA (item i mean_unload_cont_1) 4) alpha_unload_cont_1
        set beta_unload_cont_1 lput (COMPUTE_BETA (item i mean_unload_cont_1 ) (item i alpha_unload_cont_1 ) 4) beta_unload_cont_1
        set c_unload_cont_1 lput (item 4 min_coeff * (item i mean_unload_cont_1 )) c_unload_cont_1
        set d_unload_cont_1  lput (item 4 max_coeff * (item i mean_unload_cont_1 )) d_unload_cont_1
      ]
      [
        set alpha_unload_cont_1 lput 0 alpha_unload_cont_1
        set beta_unload_cont_1 lput 0 beta_unload_cont_1
        set c_unload_cont_1 lput 0 c_unload_cont_1
        set d_unload_cont_1  lput 0 d_unload_cont_1

    ])

    (ifelse
      (item i mean_unload_cont_2 != 0)[
        set alpha_unload_cont_2 lput (COMPUTE_ALPHA (item i mean_unload_cont_2) 4) alpha_unload_cont_2
        set beta_unload_cont_2 lput (COMPUTE_BETA (item i mean_unload_cont_2 ) (item i alpha_unload_cont_2 ) 4) beta_unload_cont_2
        set c_unload_cont_2 lput (item 4 min_coeff * (item i mean_unload_cont_2 )) c_unload_cont_2
        set d_unload_cont_2  lput (item 4 max_coeff * (item i mean_unload_cont_2)) d_unload_cont_2
      ]
      [
        set alpha_unload_cont_2 lput 0 alpha_unload_cont_2
        set beta_unload_cont_2 lput 0 beta_unload_cont_2
        set c_unload_cont_2 lput 0 c_unload_cont_2
        set d_unload_cont_2  lput 0 d_unload_cont_2
      ]
    )

    (ifelse
      (item i mean_load_bulk != 0)[
        set alpha_load_bulk lput (COMPUTE_ALPHA (item i mean_load_bulk  ) 5) alpha_load_bulk
        set beta_load_bulk  lput (COMPUTE_BETA (item i mean_load_bulk ) (item i alpha_load_bulk ) 5) beta_load_bulk
        set c_load_bulk  lput (item 5 min_coeff * (item i mean_load_bulk  )) c_load_bulk
        set d_load_bulk  lput (item 5 max_coeff * (item i mean_load_bulk  )) d_load_bulk
      ]
      [
        set alpha_load_bulk lput 0 alpha_load_bulk
        set beta_load_bulk  lput 0 beta_load_bulk
        set c_load_bulk  lput 0 c_load_bulk
        set d_load_bulk  lput 0 d_load_bulk
    ])


    (ifelse
      (item i mean_load_cont_1 != 0)[
        set alpha_load_cont_1 lput (COMPUTE_ALPHA (item i mean_load_cont_1) 5) alpha_load_cont_1
        set beta_load_cont_1 lput (COMPUTE_BETA (item i mean_load_cont_1 ) (item i alpha_load_cont_1 ) 5) beta_load_cont_1
        set c_load_cont_1 lput (item 5 min_coeff * (item i mean_load_cont_1 )) c_load_cont_1
        set d_load_cont_1  lput (item 5 max_coeff * (item i mean_load_cont_1 )) d_load_cont_1
      ]
      [
        set alpha_load_cont_1 lput 0 alpha_load_cont_1
        set beta_load_cont_1 lput 0 beta_load_cont_1
        set c_load_cont_1 lput 0 c_load_cont_1
        set d_load_cont_1  lput 0 d_load_cont_1
    ])

    (ifelse
      (item i mean_load_cont_2 != 0)[
        set alpha_load_cont_2 lput (COMPUTE_ALPHA (item i mean_load_cont_2) 5) alpha_load_cont_2
        set beta_load_cont_2 lput (COMPUTE_BETA (item i mean_load_cont_2 ) (item i alpha_load_cont_2 ) 5) beta_load_cont_2
        set c_load_cont_2 lput (item 5 min_coeff * (item i mean_load_cont_2 )) c_load_cont_2
        set d_load_cont_2  lput (item 5 max_coeff * (item i mean_load_cont_2)) d_load_cont_2
      ]
      [
        set alpha_load_cont_2 lput 0 alpha_load_cont_2
        set beta_load_cont_2 lput 0 beta_load_cont_2
        set c_load_cont_2 lput 0 c_load_cont_2
        set d_load_cont_2  lput 0 d_load_cont_2
    ])


    (ifelse
      (item i mean_catering_1 != 0)[
        set alpha_catering_1 lput (COMPUTE_ALPHA (item i mean_catering_1 ) 2) alpha_catering_1
        set beta_catering_1 lput (COMPUTE_BETA (item i mean_catering_1) (item i alpha_catering_1) 2) beta_catering_1
        set c_catering_1 lput (item 2 min_coeff * (item i mean_catering_1 )) c_catering_1
        set d_catering_1 lput (item 2 max_coeff * (item i mean_catering_1)) d_catering_1
      ]
      [
        set alpha_catering_1 lput 0 alpha_catering_1
        set beta_catering_1 lput 0 beta_catering_1
        set c_catering_1 lput 0 c_catering_1
        set d_catering_1 lput 0 d_catering_1
    ])


    (ifelse
      (item i mean_catering_2 != 0)[
        set alpha_catering_2 lput (COMPUTE_ALPHA (item i mean_catering_2 ) 2) alpha_catering_2
        set beta_catering_2 lput (COMPUTE_BETA (item i mean_catering_2) (item i alpha_catering_2) 2) beta_catering_2
        set c_catering_2 lput (item 2 min_coeff * (item i mean_catering_2 )) c_catering_2
        set d_catering_2 lput (item 2 max_coeff * (item i mean_catering_2)) d_catering_2
      ]
      [
        set alpha_catering_2 lput 0 alpha_catering_2
        set beta_catering_2 lput 0 beta_catering_2
        set c_catering_2 lput 0 c_catering_2
        set d_catering_2 lput 0 d_catering_2
    ])

    (ifelse
      (item i mean_catering_3 != 0)[
        set alpha_catering_3 lput (COMPUTE_ALPHA (item i mean_catering_3 ) 2) alpha_catering_3
        set beta_catering_3 lput (COMPUTE_BETA (item i mean_catering_3) (item i alpha_catering_3) 2) beta_catering_3
        set c_catering_3 lput (item 2 min_coeff * (item i mean_catering_3 )) c_catering_3
        set d_catering_3 lput (item 2 max_coeff * (item i mean_catering_3)) d_catering_3
      ]
      [
        set alpha_catering_3 lput 0 alpha_catering_3
        set beta_catering_3 lput 0 beta_catering_3
        set c_catering_3 lput 0 c_catering_3
        set d_catering_3 lput 0 d_catering_3
    ])


    set i i + 1
  ]

end






to PLOT_OBT [i]
 ; plot the off block time
  set-current-plot "Off-block time distribution (item i)"
  set-plot-x-range (min item i TA_list) (max item i TA_list)
  set-plot-y-range 0 (length item i TA_list / 100)
  set-histogram-num-bars (((max item i TA_list) - (min item i TA_list)) / 15)
  histogram (item i TA_list)



end



; Performs the plot of the deboarding distribution of airplane-type 1 as an example
to PLOT_DISTRIBUTION
  ; plot the distribution
  SETUP_PLANE_DATA
  COMPUTE_DISTRIBUTION_PARAMETERS
  let plot_vector []
  let alpha item 0 alpha_deb
  let beta item 0 beta_deb
  let c item 0 c_deb
  let d item 0 d_deb
  let counter 0
  let sample_1 0

  let a 180
  let nb 10000;length item a TA_list
  while [counter < nb][
    set sample_1 BETA_DISTRIBUTION alpha beta 0 1
    ;set plot_vector lput (item counter (item a TA_list)) plot_vector
    set plot_vector lput sample_1 plot_vector
    set counter counter + 1
  ]
  show plot_vector
  let mn mean plot_vector
  show mn
  show standard-deviation plot_vector
  set-current-plot "Distribution"

  ;set-plot-x-range (min item a TA_list) (max item a TA_list)
  set-plot-x-range 0 1
  set-plot-y-range 0 (nb / 100)
  set-histogram-num-bars 100
  histogram plot_vector
end



; Computation of the alpha parameter of the beta distribution
; Input : mean and stdev of the real distribution (not standardized)
to-report COMPUTE_ALPHA [m i] ; mean and stdev

  let s2 (item i s_coeff) * (m ^ 2)
  let c (item i min_coeff) * m
  let d (item i max_coeff) * m
  let m_z ( (m - c) / d )
  let s2_z (s2 / (d ^ 2))
  let alpha (((m_z ^ 2) * ( 1 - m_z )) / s2_z ) - m_z
  report alpha
end


; Computation of the beta parameter of the beta distribution with the mean, the standard deviation and alpha
; Input : mean and stdev of the real distribution (not standardized), alpha
to-report COMPUTE_BETA [m alpha i]
  let s2 (item i s_coeff) * (m ^ 2)
  let c (item i min_coeff) * m
  let d (item i max_coeff) * m
  let m_z ( (m - c) / d )
  let s2_z (s2 / (d ^ 2))
  let beta (alpha * (1 - m_z)) / m_z
  report beta
end

; Reports a sample of a generalized distribution with parameters alpha, beta, c and d
; The sample lies between c and c + d
; The beta distribution has
;         - mean : c + d * (alpha/(alpha+beta))
;         - variance : d^2 * ((alpha*beta)/((alpha+beta)^2 *(alpha+beta+1)))
; Input : alpha, beta, c,  d
; Output : sample
to-report BETA_DISTRIBUTION [ alpha beta c d]
  let XX random-gamma alpha 1
  let YY random-gamma beta 1
  let ZZ XX / (XX + YY)
  report c + d * ZZ
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; OUTPUT COMPUTATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Performs a whole day :
;          - The initialisation  : the scheduling, the initialisation of all the random timings
;          - The iterations until the day is finished : when all the turnarounds are finished
to ONE_DAY
  ; on peut les mettre autre part
  INIT
  set number_of_TA length SIBT_list
  set finished_TA 0
  set actual_OBT n-values (length SIBT_list) [0]
  ;set print_bool False
  while [finished_TA < number_of_TA][
    go
  ]
end



; Computes confidence intervals on the off-block time of each turnaround
; Computes confidence intervals on the off-block time of each turnaround
to MONTECARLO
  clear-turtles
  SETUP_PLANE_DATA
  COMPUTE_DISTRIBUTION_PARAMETERS
  SETUP_INPUT
  set print_bool False
  set first_schedule True
  set TA_list []
  let counter 0
  while [counter < n][
    ONE_DAY
    set TA_list lput actual_OBT TA_list
    set counter counter + 1
    show counter
  ]
  ;show scheduling_method
  show "with buffer : " show with_buffer
  set TA_list RESHAPE_TA_LIST TA_list
  set lower_bounds_mean []
  set upper_bounds_mean []
  set lower_bounds_raw []
  set upper_bounds_raw []
  set mean_CI []
  set turnaround_duration []
  let i 0
  let z 1.96 ; for a 95% confidence interval
  let alpha 0.05
  let percentage 1 - alpha
  let actual_CI_length floor (n * percentage)
  while [i < length TA_list ][
    set TA_list replace-item i TA_list (sort item i TA_list)
    let average mean item i TA_list



    ; CI on the mean
    let std standard-deviation item i TA_list
    let lower_bound average - ( z * std / ( sqrt n ) )
    let upper_bound average + ( z * std / ( sqrt n ) )
    set lower_bounds_mean lput lower_bound lower_bounds_mean
    set upper_bounds_mean lput upper_bound upper_bounds_mean



    ; CI on the observed OBT



    let j 0
    let l length (item i TA_list)
    let vector_CI_length []
    while [j  < floor (alpha * l)][
      set vector_CI_length lput ((item (j + actual_CI_length) (item i TA_list)) -  (item (j) (item i TA_list))) vector_CI_length
      set j j + 1
    ]

    let good_index position (min vector_CI_length) vector_CI_length

    let lower_bound_raw item good_index (item i TA_list)
    let upper_bound_raw item (good_index + actual_CI_length) (item i TA_list)
    set lower_bounds_raw lput lower_bound_raw lower_bounds_raw
    set upper_bounds_raw lput upper_bound_raw upper_bounds_raw
    set mean_CI lput average mean_CI
    set turnaround_duration lput (average - (item i AIBT_list)) turnaround_duration
    set i i + 1
  ]

  show " Bounds on the OBT :  "
  show lower_bounds_raw
  show upper_bounds_raw




  show " Bounds on the mean OBT :  "
  show lower_bounds_mean
  show upper_bounds_mean
  csv:to-file "/montecarlo_mean.csv" (list (lower_bounds_mean) (upper_bounds_mean) (SIBT_list) (SOBT_list))
  csv:to-file "/montecarlo_raw.csv" (list (lower_bounds_raw) (upper_bounds_raw) (SIBT_list) (SOBT_list))
  csv:to-file "/montecarlo_both.csv" (list (lower_bounds_mean) (upper_bounds_mean) (SIBT_list) (SOBT_list) (lower_bounds_raw) (upper_bounds_raw))
end


to AGENTS_MEAN_DELAY
  ; compute the mean delay of the start of each agent action over n simulations
  clear-turtles
  SETUP_PLANE_DATA
  COMPUTE_DISTRIBUTION_PARAMETERS
  SETUP_INPUT
  set print_bool False
  set first_schedule True
  set TA_list []
  let counter 0
  while [counter < n][
    ONE_DAY
    set TA_list lput actual_OBT TA_list

    ask turtles [

      (ifelse
        (counter = 0)[
          set mean_delay_in delay_schedule_in
          set mean_delay_out delay_schedule_out
        ]
        [
          let i 0
          while [i < length delay_schedule_in][
            set mean_delay_in (replace-item (i) (mean_delay_in) ((item i mean_delay_in) + (item i delay_schedule_in)))
            set mean_delay_out (replace-item (i) (mean_delay_out) ((item i mean_delay_out) + (item i delay_schedule_out)))
            set i i + 1
          ]
        ]

      )
    ]
    set counter counter + 1
    show counter
  ]
  ask turtles [
    let i 0
    while [i < length delay_schedule_in][
      set mean_delay_in (replace-item i (mean_delay_in) ((item i mean_delay_in) / n))
      set mean_delay_out (replace-item i (mean_delay_out) ((item i mean_delay_out) / n))
      set i i + 1
    ]
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PRACTICAL FUNCTIONS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to-report QUICK_SORT [l1 l2 l3 l4 low high]
  ;input : fives lists and the smallest and higher index
  ;output : the list sorted according to the order of the first one
  if (low < high)[
    let parti (PARTITION (l1) (l2) (l3) (l4) (low) (high))
    let pivot (item 0 parti)
    set l1 (item 1 parti)
    set l2 (item 2 parti)
    set l3 (item 3 parti)
    set l4 (item 4 parti)
    let new_quick (QUICK_SORT (l1) (l2) (l3) (l4) (low) (pivot - 1))
    set l1 (item 0 new_quick)
    set l2 (item 1 new_quick)
    set l3 (item 2 new_quick)
    set l4 (item 3 new_quick)
    set new_quick (QUICK_SORT (l1) (l2) (l3) (l4)(pivot + 1) (high))
    set l1 (item 0 new_quick)
    set l2 (item 1 new_quick)
    set l3 (item 2 new_quick)
    set l4 (item 3 new_quick)
  ]
  report (list (l1) (l2) (l3) (l4))
end

to-report PARTITION [l1 l2 l3 l4 low high]
  ; partion fonction for the quick sort fonction
  let pivot (item high l1)
  let i low
  let j low

  while [j <= (high)][
    if ((item j l1) < pivot)[
      let replacement (item j l1)
      set l1 (replace-item (j) (l1) (item i l1))
      set l1 (replace-item (i) (l1) (replacement))

      set replacement (item j l2)
      set l2 (replace-item (j) (l2) (item i l2))
      set l2 (replace-item (i) (l2) (replacement))

      set replacement (item j l3)
      set l3 (replace-item (j) (l3) (item i l3))
      set l3 (replace-item (i) (l3) (replacement))

      set replacement (item j l4)
      set l4 (replace-item (j) (l4) (item i l4))
      set l4 (replace-item (i) (l4) (replacement))

      set i (i + 1)
    ]
    set j (j + 1)
  ]
  let replacement (item high l1)
  set l1 (replace-item (high) (l1) (item (i) l1))
  set l1 (replace-item (i) (l1) (replacement))

  set replacement (item high l2)
  set l2 (replace-item (high) (l2) (item (i) l2))
  set l2 (replace-item (i) (l2) (replacement))

  set replacement (item high l3)
  set l3 (replace-item (high) (l3) (item (i) l3))
  set l3 (replace-item (i) (l3) (replacement))

  set replacement (item high l4)
  set l4 (replace-item (high) (l4) (item (i) l4))
  set l4 (replace-item (i) (l4) (replacement))



  report (list (i) (l1) (l2) (l3) (l4))
end



to-report RESHAPE_TA_LIST [TA_l]
; Reshapes the TA_list
; Input : TA_list of size n*m where n is the number of Montecarlo simulations and m is the number of different turnarounds through the day
; Output : TA_list of size m*n
  let new_list []
  let i 0
  while [i < length (item 1 TA_l )] [
    let j 0
    let little_list []
    while [j < n][
      set little_list lput (item i ( item j TA_l)) little_list
      set j j + 1
    ]
    set new_list lput little_list new_list
    set i i + 1
  ]
  report new_list
end



to-report ADD [l1 l2]
; Performs the element-wise addition of two lists
; Input : list l1, list l2
; Output : element-wise addition l1+l2
  if (length l1 != length l2) [
    report "the 2 lists have not the same size"
  ]
  let i 0
  let new_list []
  while [i < length l1][
    set new_list lput (item i l1 + item i l2) new_list
    set i i + 1
  ]
  report new_list
end



to-report DIFFERENCE [l1 l2]
; Performs the element-wise difference of two lists
; Input : list l1, list l2
; Output : element-wise difference l1-l2
  if (length l1 != length l2) [
    report "the 2 lists have not the same size"
  ]
  let i 0
  let new_list []
  while [i < length l1][
    set new_list lput (item i l1 - item i l2) new_list
    set i i + 1
  ]
  report new_list

end

to-report SCALAR_MATRIX_ADDITION [s matrix]
  let i 0
  let j 0
  while [i < length matrix][
    set j 0
    let i_line (item i matrix)
    while [j < length item 0 matrix] [
      set i_line replace-item j i_line ((item j i_line) + s)
      set j j + 1
    ]
    set matrix replace-item i matrix i_line
    set i i + 1
  ]
  report matrix
end

to-report SCALAR_VECTOR_MULTIPLICATION [s v]
  let i 0
  while [i < length v][
    set v replace-item i v (item i v * s)
    set i i + 1
  ]

  report v
end





to PRINT_FUNCTION [print_number]
; print_number indicates what to print, print only if print_bool is true
  if print_bool[
    ;if (active_stand = 103)[
    (ifelse

      print_number = 1[
        print " -------------" ; print va a la ligne, pas type
        type "time : " type time
        print ""
        type "at stand : " type active_stand
        print " --"]

      print_number = 2[
        if nothing_is_done = True [
          print "Nothing is done"
        ]
        if in_buffer = True [
          print "In buffer"
        ]
        type "BUFFER 1 : " type buffer_deboarding_counter_time type "   BUFFER 2 : " type buffer_fueling_counter_time
        print " --"
        print "End of the time step"
      ]
    )
  ]
  ;]
end

to PPRINT [to_print]
; print only if print_bool is true
  if print_bool[
    print to_print
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
239
10
247
19
-1
-1
0.0
1
0
1
1
1
0
0
0
1
0
0
0
0
0
0
1
ticks
10000.0

BUTTON
12
325
122
358
Initialisation
set first_schedule True\nset actual_OBT n-values (length SIBT_list) [0]\nINIT
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
19
372
75
405
NIL
GO\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
970
57
1323
90
n
n
0
1000
50.0
1
1
NIL
HORIZONTAL

BUTTON
791
56
954
89
NIL
MONTECARLO\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
13
53
501
86
Plane data, distribution parameters & Input
SETUP_PLANE_DATA\nCOMPUTE_DISTRIBUTION_PARAMETERS\nSETUP_INPUT\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
792
275
1073
507
Distribution
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 1 -7500403 true "" ""

BUTTON
793
228
958
261
NIL
PLOT_DISTRIBUTION\n\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
14
421
135
454
print_bool
print_bool
1
1
-1000

BUTTON
113
371
176
404
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
100
298
133
NIL
COMPUTE_NUMBER_OF_AGENTS_NEEDED
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
20
284
170
315
For 1 DAY
25
25.0
0

TEXTBOX
17
12
167
43
SETUP
25
25.0
1

TEXTBOX
792
10
1162
42
ACTIONS WITH THE MODEL
25
25.0
1

SLIDER
1675
137
1847
170
time_step
time_step
0
20
15.0
1
1
sec
HORIZONTAL

SLIDER
2187
95
2359
128
beginning_hour
beginning_hour
0
24
13.0
1
1
h
HORIZONTAL

SLIDER
2185
142
2357
175
finishing_hour
finishing_hour
0
24
17.0
1
1
h
HORIZONTAL

TEXTBOX
1682
45
1998
69
GENERAL PARAMETERS
20
25.0
1

TEXTBOX
2184
11
2334
86
LIFE-SIZE USE CASE AIRPORT PARAMETERS
20
25.0
1

SLIDER
1689
220
1906
253
number_of_fueling_trucks
number_of_fueling_trucks
0
70
55.0
1
1
NIL
HORIZONTAL

SLIDER
1692
303
1918
336
number_of_cleaning_trucks
number_of_cleaning_trucks
0
50
49.0
1
1
NIL
HORIZONTAL

SLIDER
1691
264
1916
297
number_of_catering_trucks
number_of_catering_trucks
0
70
64.0
1
1
NIL
HORIZONTAL

SLIDER
1693
342
1910
375
number_of_ULD_trains
number_of_ULD_trains
0
200
179.0
1
1
NIL
HORIZONTAL

SLIDER
1693
383
1890
416
number_of_bulk_trains
number_of_bulk_trains
0
300
21.0
1
1
NIL
HORIZONTAL

SLIDER
1696
474
1889
507
before_margin_min
before_margin_min
0
20
5.0
1
1
min
HORIZONTAL

SLIDER
1697
509
1878
542
after_margin_min
after_margin_min
0
20
10.0
1
1
min
HORIZONTAL

SLIDER
2206
510
2429
543
additional_time_cargo_ll
additional_time_cargo_ll
0
50
10.0
1
1
min
HORIZONTAL

SLIDER
2205
358
2460
391
additional_time_fueling_truck
additional_time_fueling_truck
0
50
5.0
1
1
min
HORIZONTAL

SLIDER
2205
427
2468
460
additional_time_catering_truck
additional_time_catering_truck
0
50
5.0
1
1
min
HORIZONTAL

SLIDER
2204
393
2468
426
additional_time_cleaning_truck
additional_time_cleaning_truck
0
50
5.0
1
1
min
HORIZONTAL

SLIDER
2438
581
2665
614
additional_time_bulk_ul
additional_time_bulk_ul
0
50
20.0
1
1
min
HORIZONTAL

SLIDER
2437
544
2663
577
additional_time_bulk_uu
additional_time_bulk_uu
0
50
10.0
1
1
min
HORIZONTAL

SLIDER
2437
508
2661
541
additional_time_bulk_ll
additional_time_bulk_ll
0
50
10.0
1
1
min
HORIZONTAL

SLIDER
2437
468
2659
501
additional_time_bulk_lu
additional_time_bulk_lu
0
50
0.0
1
1
min
HORIZONTAL

SLIDER
2206
549
2430
582
additional_time_cargo_uu
additional_time_cargo_uu
0
50
10.0
1
1
min
HORIZONTAL

SLIDER
2205
475
2430
508
additional_time_cargo_lu
additional_time_cargo_lu
0
50
0.0
1
1
min
HORIZONTAL

SLIDER
2206
583
2431
616
additional_time_cargo_ul
additional_time_cargo_ul
0
50
20.0
1
1
min
HORIZONTAL

SLIDER
1697
685
1869
718
mean_delay
mean_delay
-1000
1000
0.0
1
1
sec
HORIZONTAL

SLIDER
1697
727
1869
760
std_delay
std_delay
0
1000
0.0
1
1
sec
HORIZONTAL

SWITCH
2187
193
2314
226
with_buffer
with_buffer
1
1
-1000

SLIDER
1696
574
1884
607
beginning_factor_loading
beginning_factor_loading
0
1
0.3333333333333333
0.05
1
NIL
HORIZONTAL

SLIDER
1695
610
1887
643
beginning_factor_boarding
beginning_factor_boarding
0
1
0.0
0.05
1
NIL
HORIZONTAL

BUTTON
223
358
494
391
GO UNTIL THRESHOLD WITHOUT PRINT
set first_schedule True\nset print_bool False\nset actual_OBT n-values (length SIBT_list) [0]\nINIT\nwhile [time < threshold][go]\nset print_bool True
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
224
325
396
358
threshold
threshold
0
200000
36500.0
100
1
NIL
HORIZONTAL

BUTTON
223
397
466
430
GO UNTIL THRESHOLD WITH PRINT
set first_schedule True\nset print_bool True\nset actual_OBT n-values (length SIBT_list) [0]\nINIT\nwhile [time < threshold][go]\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1674
94
1849
127
scheduling_method
scheduling_method
1
3
1.0
1
1
NIL
HORIZONTAL

PLOT
792
538
1101
775
Off-block time distribution (item i)
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

SLIDER
1193
563
1365
596
obt_to_plot
obt_to_plot
0
500
17.0
1
1
NIL
HORIZONTAL

BUTTON
1192
603
1421
636
NIL
PLOT_OBT obt_to_plot
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
