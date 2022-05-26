; page zero addresses
; tube addresses
; &00          - control block
; &12 - &13    - control block pointer
; &14          - bit 7 tube free
; &15          - claimant id
; &16 - &7F    - tube code etc
;
; &EE - &EF    - current program
; &F0 - &F1    - hex accumulator
; &F2 - &F3    - top of memory
; &F4 - &F5    - address of byte transfer address, nmi addr or trans
; &F6 - &F7    - data transfer address
; &F8 - &F9    - string pointer, osword control block
; &FA - &FB    - ctrl - osfile, osgbpb control block, prtext string pointer
; &FC          - interrupt accumulator
; &FD - &FE    - brk program counter
; &FF          - escape flag
;
; normal workspace
; &A0 - &A7    - nmi workspace (electron only) *** avoid ***
; &A8 - &AF    - os workspace
; &B0 - &BF    - file system scratch space
; &E4 - &E6    - os workspace
; &E7          - auto repeat countdown byte
; &E8 - &E9    - osword &00 input pointer
; &EC          - last key press
; &ED          - penultimate key press
; &EE - &EF    - current program
; &F2 - &F3    - command line pointer
; &F4          - paged rom
; &FC          - interrupt accumulator
; &FD - &FE    - brk program counter
; &FF          - escape flag
;
; unused page zero - &74, &8B, &A9

; general
 stack                                  = &100
 basic_language                         = &400

 page_zero                              = &00

 stack_address                          = &80
 clear_counter                          = &82
 clear_row_counter                      = &83
 list_access                            = &84

; multiply
 distance_dx                            = &90     ;<2>
 distance_dz                            = &92     ;<2>

 product_16                             = &C0     ;<4>
 multiplier_16                          = &C4     ;<2>
 multiplicand_16                        = &C6     ;<2>
 product_16_t1                          = &C8     ;<2>
 product_16_t2                          = &CA
 result_sign_16                         = &CC

 divisor_16                             = &C0     ;<2>
 dividend_16                            = &C2     ;<2>
 division_result_16                     = dividend_16
 division_remainder_16                  = &C4     ;<2>

 dividend_24                            = &C0     ;<3>
 division_result_24                     = dividend_24
 division_remainder_24                  = &C3     ;<3>
 divisor_24                             = &C6     ;<3>
 division_result_sign_24                = &C9

 square_address                         = &D0     ;<8>
 square1_lo                             = square_address
 square1_hi                             = square_address + &02
 square2_lo                             = square_address + &04
 square2_hi                             = square_address + &06

 cs_value_00                            = &C0
 cs_value_01                            = &C1

 m_tank_status                          = &CD
 m_tank_rotation                        = &CE     ;<2>

; radar
 text_counter                           = &9F
 x_coor_tan_01                          = &C0
 z_coor_tan_01                          = &C1
 octant                                 = &C2

 graphic_x_00                           = host_r0 ;<2> 08/16 bit x0/y0 coordinate <--- host register mapped
 graphic_y_00                           = host_r1 ;<2>                            <--- host register mapped
 graphic_x_01                           = host_r2 ;<2> 08/16 bit x1/y1 coordinate <--- host register mapped
 graphic_y_01                           = host_r3 ;<2>                            <--- host register mapped

; line draw
 origin_address                         = &80     ;<2>

 graphic_x_origin                       = &D8     ;<2>
 graphic_y_origin                       = &DA     ;<2>

 graphic_window                         = &DC     ;<8> graphic window coordinates
 window_x_00                            = graphic_window          ;<2>
 window_y_00                            = graphic_window + &02    ;<2>
 window_x_01                            = graphic_window + &04    ;<2>
 window_y_01                            = graphic_window + &06    ;<2>

 graphic_dx                             = &C0     ;<2>
 graphic_dy                             = &C2     ;<2>
 graphic_video                          = &C4     ;<2>
 graphic_accumulator                    = &C6     ;<2>
 graphic_count                          = &C8
 graphic_store                          = &C9
 graphic_line_leave                     = &CA
 graphic_y_sign                         = &CB     ;<2>

; battlezone
 PRINT ""
 PRINT " page zero  : ", ~mathbox_workspace,             "  mathbox_workspace"
 PRINT "            : ", ~mathbox_save_state,            "  mathbox_save_state"
 PRINT "            : ", ~mathbox_save,                  "  mathbox_save"
 PRINT "            : ", ~mathbox_random,                " mathbox_random"
 PRINT "            : ", ~combined_block_start,          " combined_block_start"
 PRINT "            : ", ~combined_block_end,            " combined_block_end"
 PRINT "            : ", ~console_refresh,               " console_refresh"
 PRINT "            : ", ~console_refresh_end,           " console_refresh_end"
 PRINT "            : ", ~clk_mode,                      " clk_mode"
 PRINT "            : ", ~clk_second,                    " clk_second"
 PRINT "            : ", ~clk_update,                    " clk_update"
 PRINT "            : ", ~move_counter,                  " move_counter"
 PRINT "            : ", ~ai_divide_by_three,            " ai_divide_by_three"
 PRINT "            : ", ~ai_rez_protect,                " ai_rez_protect"
 PRINT "            : ", ~x_sine,                        " x_sine"
 PRINT "            : ", ~x_cosine,                      " x_cosine"
 PRINT "            : ", ~y_sine,                        " y_sine"
 PRINT "            : ", ~y_cosine,                      " y_cosine"
 PRINT "            : ", ~z_sine,                        " z_sine"
 PRINT "            : ", ~z_cosine,                      " z_cosine"
 PRINT "            : ", ~y_sine_tank,                   " y_sine_tank"
 PRINT "            : ", ~y_cosine_tank,                 " y_cosine_tank"
 PRINT "            : ", ~game_mode,                     " game_mode"
 PRINT "            : ", ~new_game_mode,                 " new_game_mode"
 PRINT "            : ", ~player_score,                  " player_score"
 PRINT "            : ", ~enemy_score,                   " enemy_score"
 PRINT "            : ", ~recent_collision_flag,         " recent_collision_flag"
 PRINT "            : ", ~b_object_bounce_near,          " b_object_bounce_near"
 PRINT "            : ", ~b_object_bounce_far,           " b_object_bounce_far"
 PRINT "            : ", ~game_number_of_tanks,          " game_number_of_tanks"
 PRINT "            : ", ~extra_tank,                    " extra_tank"
 PRINT "            : ", ~on_target,                     " on_target"
 PRINT "            : ", ~radar_arm_position,            " radar_arm_position"
 PRINT "            : ", ~m_tank_rotation_512,           " m_tank_rotation_512"
 PRINT "            : ", ~missile_flag,                  " missile_flag"
 PRINT "            : ", ~missile_hop_flag,              " missile_hop_flag"
 PRINT "            : ", ~missile_count,                 " missile_count"
 PRINT "            : ", ~missile_rand,                  " missile_rand"
 PRINT "            : ", ~missile_low_altitude,          " missile_low_altitude"
 PRINT "            : ", ~enemy_angle_delta,             " enemy_ang_delta"
 PRINT "            : ", ~enemy_ang_delt_abs,            " enemy_ang_delt_abs"
 PRINT "            : ", ~object_counter,                " object_counter"
 PRINT "            : ", ~saucer_velocity_x,             " saucer_velocity_x"
 PRINT "            : ", ~saucer_velocity_z,             " saucer_velocity_z"
 PRINT "            : ", ~saucer_dying,                  " saucer_dying"
 PRINT "            : ", ~saucer_time_to_live,           " saucer_time_to_live"
 PRINT "            : ", ~m_shell_x_vector,              " m_shell_x_vector"
 PRINT "            : ", ~m_shell_z_vector,              " m_shell_z_vector"
 PRINT "            : ", ~m_shell_time_to_live,          " m_shell_time_to_live"
 PRINT "            : ", ~enemy_projectile_velocity_x,   " enemy_projectile_velocity_x"
 PRINT "            : ", ~enemy_projectile_velocity_z,   " enemy_projectile_velocity_z"
 PRINT "            : ", ~enemy_turn_to,                 " enemy_turn_to"
 PRINT "            : ", ~enemy_angle_adjustment,        " enemy_angle_adjustment"
 PRINT "            : ", ~enemy_rev_flags,               " enemy_rev_flags"
 PRINT "            : ", ~enemy_dist_hi,                 " enemy_dist_hi"
 PRINT "            : ", ~enemy_projectile_time_to_live, " enemy_projectile_time_to_live"
 PRINT "            : ", ~close_firing_angle,            " close_firing_angle"
 PRINT "            : ", ~page_zero_end,                 " page zero end"
 PRINT ""

 combined_block_start                   = &16                           ;<--- key start

 combined_x                             = combined_block_start + &00
 combined_t                             = combined_block_start + &01
 combined_r                             = combined_block_start + &02
 combined_b                             = combined_block_start + &03
 combined_c                             = combined_block_start + &04
 combined_d                             = combined_block_start + &05
 combined_n                             = combined_block_start + &06
 combined_arrow_up                      = combined_block_start + &07
 combined_arrow_down                    = combined_block_start + &08
 combined_arrow_left                    = combined_block_start + &09
 combined_arrow_right                   = combined_block_start + &0A
 combined_a                             = combined_block_start + &0B
 combined_z                             = combined_block_start + &0C
 combined_k                             = combined_block_start + &0D
 combined_m                             = combined_block_start + &0E
 combined_f                             = combined_block_start + &0F
 combined_escape                        = combined_block_start + &10
 combined_space                         = combined_block_start + &11

 combined_block_end                     = combined_block_start + &11    ;<--- key end

 console_refresh                        = combined_block_end + &01

 console_print                          = console_refresh + &00         ;print all right panel, scores etc.
 console_press_start_etc                = console_refresh + &01         ;press start etc
 console_sights_flashing                = console_refresh + &02         ;sights flashing
 console_synchronise_message_flashing   = console_refresh + &03         ;synchronise message flashing
 console_clear_space                    = console_refresh + &04         ;clear top panel when killed
 console_enemy_in_range                 = console_refresh + &05         ;"enemy in range"
 console_motion_blocked                 = console_refresh + &06         ;"motion blocked by object"
 console_enemy_to_left                  = console_refresh + &07         ;"enemy to left"
 console_enemy_to_right                 = console_refresh + &08         ;"enemy to right"
 console_enemy_to_rear                  = console_refresh + &09         ;"enemy to rear"

 console_refresh_end                    = console_refresh + &09

 clk_mode                               = console_refresh_end + &01
 clk_second                             = clk_mode + &01
 clk_update                             = clk_second + &01
 move_counter                           = clk_update + &01
 ai_divide_by_three                     = move_counter + &01
 ai_rez_protect                         = ai_divide_by_three + &01
 x_sine                                 = ai_rez_protect + &01
 x_cosine                               = x_sine + &02
 y_sine                                 = x_cosine + &02
 y_cosine                               = y_sine + &02
 z_sine                                 = y_cosine + &02
 z_cosine                               = z_sine + &02
 y_sine_tank                            = z_cosine + &02
 y_cosine_tank                          = y_sine_tank + &02
 game_mode                              = y_cosine_tank + &02
                                        ;0 main game
                                        ;1 attract mode
                                        ;2 high score table
                                        ;3 service menu
                                        ;4 new high score
                                        ;5 battlezone text
                                        ;6 model test
 new_game_mode                          = game_mode + &01
 player_score                           = new_game_mode + &01
 enemy_score                            = player_score + &02
 recent_collision_flag                  = enemy_score + &01
 hundred_thousand                       = recent_collision_flag + &01
 b_object_bounce_near                   = hundred_thousand + &01
 b_object_bounce_far                    = b_object_bounce_near + &01
 game_number_of_tanks                   = b_object_bounce_far + &01
 extra_tank                             = game_number_of_tanks + &01
 on_target                              = extra_tank + &01
 radar_arm_position                     = on_target + &01
 m_tank_rotation_512                    = radar_arm_position + &01
 missile_flag                           = m_tank_rotation_512 + &02
 missile_hop_flag                       = missile_flag + &01
 missile_count                          = missile_hop_flag + &01
 missile_rand                           = missile_count + &01
 missile_low_altitude                   = missile_rand + &01
 enemy_angle_delta                      = missile_low_altitude + &01
 enemy_ang_delt_abs                     = enemy_angle_delta + &01
 object_counter                         = enemy_ang_delt_abs + &01
 saucer_velocity_x                      = object_counter + &01
 saucer_velocity_z                      = saucer_velocity_x + &02
 saucer_dying                           = saucer_velocity_z + &02
 saucer_time_to_live                    = saucer_dying + &01
 m_shell_x_vector                       = saucer_time_to_live + &01
 m_shell_z_vector                       = m_shell_x_vector + &02
 m_shell_time_to_live                   = m_shell_z_vector + &02
 enemy_projectile_velocity_x            = m_shell_time_to_live + &01
 enemy_projectile_velocity_z            = enemy_projectile_velocity_x + &02
 enemy_turn_to                          = enemy_projectile_velocity_z + &02
 enemy_angle_adjustment                 = enemy_turn_to + &01
 enemy_rev_flags                        = enemy_angle_adjustment + &01
 enemy_dist_hi                          = enemy_rev_flags + &01
 enemy_projectile_time_to_live          = enemy_dist_hi + &01
 close_firing_angle                     = enemy_projectile_time_to_live + &01

 page_zero_end                          = close_firing_angle + &01

 rotation_divide                        = &80
 result_shifted                         = &82

 crack_counter                          = &9F

; render
 vertice_a                              = &75     ;<2>
 vertice_b                              = &77     ;<2>
 object_relative_x                      = &79     ;<2>
 object_relative_y                      = &7B     ;<2>
 object_relative_z                      = &7D     ;<2>
 saucer_state                           = &7F

 tank_or_super_or_missile_workspace_x   = &B0     ;<2>
 tank_or_super_or_missile_workspace_z   = &B2     ;<2>

 vertice_x                              = object_relative_x     ;<2>
 vertice_z                              = object_relative_z     ;<2>

 graphic_temp                           = &80

 i_object_identity                      = &90
 x_object_rotation                      = &91
 y_object_rotation                      = &92
 z_object_rotation                      = &93
 d_object_distance                      = &94     ;<2>

 model_vertices_address                 = &96     ;<2>
 model_segment_address                  = &98     ;<2>
 model_segment_counter                  = &9A
 model_vertices_counter                 = &9B
 model_vertices_work                    = &9C
 model_identity                         = &9D

 ta                                     = &80     ;<3>
 tb                                     = &83     ;<3>
 sine_a                                 = &86     ;<2>
 cosine_a                               = &88     ;<2>

 x_prime                                = &AA     ;<2>
 y_prime                                = &AC     ;<2>
 z_prime                                = &AE     ;<2>

 machine_flag                           = &8C
 mathbox_flag                           = &8D

 screen_work                            = &80

 first_entry                            = &80
 small_address                          = &80
 workspace                              = &80

 destination                            = &82
 sprite_work                            = &82
 second_entry                           = &82
 char_index                             = &82

 char_counter                           = &83

 read_rom                               = &84
 screen_index                           = &84

 convert_small                          = &85
 frame_counter                          = &9E

 object_radar_rotation                  = &F5
 object_rotation_store                  = &F6
 track_counter                          = &F7
 track_exhaust_index                    = &F8
 tracks_active                          = &F9

; landscape
 landscape_segment_ix                   = &80
 landscape_result                       = &81

; tank sights
 sight_address_01                       = &80
 sight_address_02                       = &82
 sight_address_03                       = &84
 sight_address_04                       = &86

; moon
 moon_sprite_address                    = &80
 moon_sprite_store                      = &82
 moon_screen_address                    = &84
 moon_new_x_coor                        = &86
 moon_counter                           = &88

; volcano
 volcano_address                        = &80     ;<2>
 volcano_counter                        = &82
 volcano_x_store                        = &83     ;<2>
 volcano_y_store                        = &85
 volcano_work                           = &86     ;<2>

 radar_address                          = &80     ;<2>

; print characters
 print_block_address                    = &C0
 print_screen                           = &C2
 print_screen_work                      = &C4
 print_y_work                           = &C6
 print_y_reg                            = &C7
 print_character_height                 = &C8

; service menu
 service_box_left                       = &80
 service_box_right                      = &82
 service_box_top                        = &80
 service_box_bottom                     = &82
 service_diagonal_left                  = &80
 service_diagonal_right                 = &80
 service_mask                           = &82
 service_diagonal_counter               = &83

 stack_store                            = &90
 service_brkv_store                     = &91

; tank
 tank_address                           = &C0
 tank_working                           = &C2

; video/swr
 screen_hidden                          = &8E
 found_a_slot                           = &8F

; os
 paged_rom                              = &F4
 interrupt_accumulator                  = &FC

; high score
 zero_blank                             = &80
 bcd_counter                            = &81

 player_line                            = &AC     ;<3>
 player_high_scores_y_coordinate        = &AF

 radar_scr_a                            = &B5
 radar_scr_x                            = &B6
 radar_scr_y                            = &B7

 three_number_text                      = &C0     ;<2>
 enter_text_index                       = &C3
 valid_character_index                  = &C4

; animate
 x_offset                               = &80
 z_offset                               = &82
 sine                                   = &84
 cosine                                 = &86

 unit_x_pos                             = &C0     ;<2>
 unit_z_pos                             = &C2     ;<2>
 movement_vector_x                      = &C4     ;<2>
 movement_vector_z                      = &C6     ;<2>
 general_x                              = &C8
 general_y                              = &C9
 general_store                          = &CA

; op codes
 bit_op                                 = &2C     ;bit
 nop_op                                 = &EA     ;nop
 ora_op                                 = &11     ;ora
