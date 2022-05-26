; constants
 zero_size                              = &00
 block_size                             = &08
 vertices_number                        = &1A

; addresses
 PRINT " page one   : ", ~vertices_table,   "vertice start"
 PRINT "            : ", ~page_one_end,     "page one end"
 PRINT ""
 PRINT " page four  : ", ~object_start,     "object start"
 PRINT "            : ", ~object_end,       "object end"
 PRINT "            : ", ~page_four_end,    "page four end"
 PRINT ""

 vertices_table                         = &100
 vertices_x_lsb                         = vertices_table
 vertices_x_msb                         = vertices_table + vertices_number * &01
 vertices_y_lsb                         = vertices_table + vertices_number * &02
 vertices_y_msb                         = vertices_table + vertices_number * &03
 vertices_z_lsb                         = vertices_table + vertices_number * &04
 vertices_z_msb                         = vertices_table + vertices_number * &05
 vertices_end                           = vertices_table + vertices_number * &06

 page_one_end                           = vertices_end

;obstacle x/z coordinates
 obstacle_x_00                          = &2000
 obstacle_x_01                          = &4000
 obstacle_x_02                          = &8000
 obstacle_x_03                          = &8000
 obstacle_x_04                          = &8000
 obstacle_x_05                          = &4000
 obstacle_x_06                          = &0000
 obstacle_x_07                          = &0000
 obstacle_x_08                          = &5000
 obstacle_x_09                          = &1800
 obstacle_x_0A                          = &4400
 obstacle_x_0B                          = &4000
 obstacle_x_0C                          = &8C00
 obstacle_x_0D                          = &0C00
 obstacle_x_0E                          = &E800
 obstacle_x_0F                          = &E400
 obstacle_x_10                          = &9C00
 obstacle_x_11                          = &CC00
 obstacle_x_12                          = &B400
 obstacle_x_13                          = &BC00
 obstacle_x_14                          = &F400

 obstacle_z_00                          = &2000
 obstacle_z_01                          = &0000
 obstacle_z_02                          = &0000
 obstacle_z_03                          = &4000
 obstacle_z_04                          = &8000
 obstacle_z_05                          = &8000
 obstacle_z_06                          = &8000
 obstacle_z_07                          = &4000
 obstacle_z_08                          = &3000
 obstacle_z_09                          = &C000
 obstacle_z_0A                          = &F700
 obstacle_z_0B                          = &C800
 obstacle_z_0C                          = &D800
 obstacle_z_0D                          = &9400
 obstacle_z_0E                          = &9800
 obstacle_z_0F                          = &E800
 obstacle_z_10                          = &7000
 obstacle_z_11                          = &7800
 obstacle_z_12                          = &4000
 obstacle_z_13                          = &2400
 obstacle_z_14                          = &2C00

MACRO object id, angle, xcr, ycr, zcr
 EQUB id                                ;+00 identity
 EQUB angle                             ;+01 object y axis rotation
 EQUW xcr                               ;+02 object x coordinate
 EQUW ycr                               ;+04 object y coordinate
 EQUW zcr                               ;+06 object z coordinate
ENDMACRO

.object_start                           ;short cubes are not checked by my shot/enemy shot collision, gain a little speed here
                                        ;x coordinate negated to compensate for original maths in arcade
 object object_x02_short_cube,     &10, -obstacle_x_01, &00, obstacle_z_01
 object object_x02_short_cube,     &40, -obstacle_x_03, &00, obstacle_z_03
 object object_x02_short_cube,     &48, -obstacle_x_09, &00, obstacle_z_09
 object object_x02_short_cube,     &68, -obstacle_x_0D, &00, obstacle_z_0D
 object object_x02_short_cube,     &88, -obstacle_x_11, &00, obstacle_z_11

.object_shot_collision_start            ;these geometrical objects tall enough for my shot/enemy shot collision

 object object_x00_narrow_pyramid, &28, -obstacle_x_05, &00, obstacle_z_05
 object object_x00_narrow_pyramid, &38, -obstacle_x_07, &00, obstacle_z_07
 object object_x00_narrow_pyramid, &58, -obstacle_x_0B, &00, obstacle_z_0B
 object object_x00_narrow_pyramid, &78, -obstacle_x_0F, &00, obstacle_z_0F
 object object_x00_narrow_pyramid, &98, -obstacle_x_13, &00, obstacle_z_13
 object object_x01_tall_cube,      &30, -obstacle_x_06, &00, obstacle_z_06
 object object_x01_tall_cube,      &40, -obstacle_x_08, &00, obstacle_z_08
 object object_x01_tall_cube,      &60, -obstacle_x_0C, &00, obstacle_z_0C
 object object_x01_tall_cube,      &80, -obstacle_x_10, &00, obstacle_z_10
 object object_x01_tall_cube,      &A0, -obstacle_x_14, &00, obstacle_z_14
 object object_x03_wide_pyramid,   &00, -obstacle_x_00, &00, obstacle_z_00
 object object_x03_wide_pyramid,   &18, -obstacle_x_04, &00, obstacle_z_04
 object object_x03_wide_pyramid,   &20, -obstacle_x_02, &00, obstacle_z_02
 object object_x03_wide_pyramid,   &50, -obstacle_x_0A, &00, obstacle_z_0A
 object object_x03_wide_pyramid,   &70, -obstacle_x_0E, &00, obstacle_z_0E
 object object_x03_wide_pyramid,   &90, -obstacle_x_12, &00, obstacle_z_12

.object_shot_collision_end

.animated_object_start                  ;<--- start block to reset

.unit_shot                              ;unit shot
 EQUW &FF
.unit_shot_x
 EQUW &00
.unit_shot_y
 EQUW &00
.unit_shot_z
 EQUW &00

.m_shell                                ;my shell
 EQUW &FF
.m_shell_x
 EQUW &00
.m_shell_y
 EQUW &00
.m_shell_z
 EQUW &00

.saucer                                 ;saucer
 EQUW &FF
.saucer_x
 EQUW &00
.saucer_y
 EQUW &00
.saucer_z
 EQUW &00

.explosion                              ;exploding stars, x4 frames of animation
 EQUW &FF                               ;only one allowed, new one over rides existing
.explosion_x                            ;one if in progress
 EQUW &00
.explosion_y
 EQUW &00
.explosion_z
 EQUW &00

.debris_start                           ;debris block x6 entries
 object &FF, &00, &00, &00, &00         ;<--- reused for missile exhaust as objects mutually exclusive
                                        missile_exhaust   = debris_start
                                        missile_exhaust_x = missile_exhaust + &02
                                        missile_exhaust_y = missile_exhaust + &04
                                        missile_exhaust_z = missile_exhaust + &06
 object &FF, &00, &00, &00, &00
 object &FF, &00, &00, &00, &00
.debris_last_chunk_to_hit_ground
 object &FF, &00, &00, &00, &00         ;<--- last chunk to hit ground, used as flag for debris active
 object &FF, &00, &00, &00, &00
 object &FF, &00, &00, &00, &00

.debris_end

.tank_or_super_or_missile               ;opponent placed here to index into with my tank below
 EQUW &FF
.tank_or_super_or_missile_x
 EQUW &00
.tank_or_super_or_missile_y
 EQUW &00
.tank_or_super_or_missile_z
 EQUW &00

.object_end                             ;<--- end block to reset

.m_tank                                 ;index x = &00 tank/super/missile, x = &08 my tank
 EQUW &00                               ;my tank placed here to index in for movement
.m_tank_x
 EQUW &00
.m_tank_y
 EQUW &00
.m_tank_z
 EQUW &00

.reset_refresh                          ;reset console messages and keyboard block
 LDX #&04
 LDA #console_double
.refresh_all
 STA console_refresh - &01,X
 DEX
 BNE refresh_all
 LDY #&04                               ;x=0
.zero_combat_messages
 STX console_refresh + &06,Y            ;turn off combat messages
 DEY
 BPL zero_combat_messages
 LDA #&40                               ;set key as pressed
 LDY #combined_block_end - combined_block_start
.clear_combined_block                   ;clear any keys pressed
 STA combined_block_start,Y
 DEY
 BPL clear_combined_block
 RTS

.clear_all_screen                       ;full screen clear
 LDY #&28
 BNE clear_area_of_memory               ;always

.clear_rest_of_space                    ;clear off score, high score and tanks
 LDA console_clear_space
 BEQ clear_exit                         ;already cleared
 INC console_clear_space
 LDY #&09                               ;roll into routine below

.clear_area_of_memory                   ;y = number of pages to clear from screen start
 LDA screen_hidden
 STA clear_a_page + &02
 LDA #&00
 TAX
.clear_a_page
 STA dummy_address,X
 DEX
 BNE clear_a_page
 INC clear_a_page + &02
 DEY
 BNE clear_a_page
.clear_exit
 RTS

.score_increase                         ;a = opponent scoring
 SED                                    ;decimal mode
 CLC
 ADC player_score                       ;add to player score
 STA player_score
 LDA player_score + &01
 ADC #&00
 STA player_score + &01
 CLD                                    ;exit decimal mode
 LDY #console_double                    ;refresh screen score
 STY console_print
 BIT extra_tank                         ;had extra tank?
 BMI test_for_music                     ;yes, so lets check score for music
 LDY bonus_tank_index                   ;any bonus tank?
 BEQ test_for_music                     ;bonus tank not set up, scrooge arcade operator
 LDA player_score
 CMP bonus_score_tanks - &01,Y
 LDA player_score + &01
 SBC #&00
 BCC no_bonus_tank_yet                  ;no bonus tank yet
 DEC extra_tank                         ;extra tank given, set flag for given
 INC sound_extra_life                   ;extra life sound
 BNE increment_tanks                    ;always
.test_for_music
 BIT hundred_thousand                   ;check for 100,000 score
 BMI already_past_hundred_thousand      ;bit 7 = 1 music played
 TAX                                    ;a = high byte, reached score?
 BEQ not_reached_hundred_thousand
 LDX #&FF
 STX hundred_thousand                   ;set flag to &ff for 100,000 reached
 STX sound_music                        ;enable music
 STX sound_gate                         ;disable sound
 INX
 STX sound_note_index
 JSR sound_flush_buffers
 LDY bonus_tank_index                   ;any bonus tanks?
 BEQ not_reached_hundred_thousand       ;none
.increment_tanks
 INC game_number_of_tanks               ;+1 tank
.no_bonus_tank_yet
.not_reached_hundred_thousand
.already_past_hundred_thousand
 RTS

.bonus_score_tanks
 EQUB &15
 EQUB &25
 EQUB &50

.clear_cells                            ;use a list to clear screen objects
 STX list_access                        ;list pointer
 STY list_access + &01
 LDY #&00
.more_blocks
 LDA (list_access),Y
 STA clear_access + &01                 ;self modify address for speed
 INY
 LDA (list_access),Y
 CLC
 ADC screen_hidden                      ;hidden screen address
 STA clear_access + &02
 INY
 LDA (list_access),Y
 TAX                                    ;number of bytes to clear
 LDA #&00                               ;write byte
.clear_access
 STA clear_access,X
 DEX
 BNE clear_access
 RTS

.select_swr_slot
 PHP
 SEI
 LDX found_a_slot
 BIT machine_flag
 BMI select_electron
 STX bbc_romsel
 BPL paged                              ;always
.select_electron
 CPX #&08
 BCS just_select_swr
 LDA #&0C                               ;de-select basic
 STA paged_rom
 STA electron_romsel
.just_select_swr
 STX electron_romsel
.paged
 STX paged_rom
 PLP                                    ;restore irq status
 RTS

.calculate_movement_deltas_player
 LDA m_tank_rotation_512 + &01
 JSR sine_256_08                        ;compute sin(theta), a=msb
 CMP #&80                               ;divide by 2 with sign extension
 ROR A
 STA movement_vector_x                  ;save as delta x
 CMP #&80                               ;divide by 2 with sign extension
 ROR A
 CLC
 ADC movement_vector_x                  ;add to previous to get 3/4 value
 STA movement_vector_x
 ASL A                                  ;sign extend high byte
 LDA #&00
 ADC #&FF
 EOR #&FF
 STA movement_vector_x + &01
 LDA m_tank_rotation_512 + &01          ;get facing cosine angle
 JSR cosine_256_08                      ;compute cos(theta), a=msb
 CMP #&80                               ;divide by 2 with sign extension
 ROR A
 STA movement_vector_z                  ;save as delta z
 CMP #&80                               ;divide by 2 with sign extension
 ROR A
 CLC
 ADC movement_vector_z                  ;add to previous to get 3/4 value
 STA movement_vector_z
 ASL A
 LDA #&00
 ADC #&FF
 EOR #&FF
 STA movement_vector_z + &01
 RTS

.calculate_movement_deltas_unit
 LDA tank_or_super_or_missile + &01
 JSR sine_256_08                        ;compute sin(theta), a=msb
 CMP #&80                               ;divide by 2 with sign extension
 ROR A
 STA movement_vector_x                  ;save as delta x
 CMP #&80                               ;divide by 2 with sign extension
 ROR A
 CLC
 ADC movement_vector_x                  ;add to previous to get 3/4 value
 STA movement_vector_x
 ASL A                                  ;sign extend high byte
 LDA #&00
 ADC #&FF
 EOR #&FF
 STA movement_vector_x + &01
 LDA tank_or_super_or_missile + &01     ;get facing cosine angle
 JSR cosine_256_08                      ;compute cos(theta), a=msb
 CMP #&80                               ;divide by 2 with sign extension
 ROR A
 STA movement_vector_z                  ;save as delta z
 CMP #&80                               ;divide by 2 with sign extension
 ROR A
 CLC
 ADC movement_vector_z                  ;add to previous to get 3/4 value
 STA movement_vector_z
 ASL A
 LDA #&00
 ADC #&FF
 EOR #&FF
 STA movement_vector_z + &01
 RTS

.cosine_256_16                          ;cosine, entry a = angle 0-&ff
 CLC
 ADC #&40                               ;roll into routine below

.sine_256_16                            ;sine, entry a = angle 0-&ff
 TAY
 BPL sine_positive_16
 EOR #&80                               ;bring into +ve range
 TAY
 LDA #&00                               ;invert table value
 SEC
 SBC sine_table_128_lsb,Y
 TAX
 LDA #&00
 SBC sine_table_128_msb,Y
 RTS                                    ;exit x/a lo/hi trig value
.sine_positive_16
 LDX sine_table_128_lsb,Y
 LDA sine_table_128_msb,Y
 RTS

.cosine_256_08
 CLC
 ADC #&40                               ;roll into routine below

.sine_256_08
 TAY
 BPL sine_positive_08
 EOR #&80                               ;bring into +ve range
 TAY
 LDA #&00                               ;invert table value
 SEC
 SBC sine_table_128_msb,Y
 RTS                                    ;exit a hi trig value, x preserved
.sine_positive_08
 LDA sine_table_128_msb,Y
 RTS

.tank_sprite
 EQUW tank_screen_offset
 EQUW battlezone_sprites + tank_offset
 EQUB &01
 EQUB &10

.draw_tanks
 LDX game_number_of_tanks               ;check for zero tanks/in attract mode
 BEQ no_draw_tanks                      ;no tanks
 LDA #LO(tank_screen_offset)
 STA tank_sprite
 LDA #HI(tank_screen_offset)
 STA tank_sprite + &01
.next_tank
 STX tank_working
 LDX #LO(tank_sprite)
 LDY #HI(tank_sprite)
 JSR multiple_row_sprite
 LDX tank_working
 LDA tank_sprite
 CLC
 ADC #&10
 STA tank_sprite
 BCC no_inc_tank
 INC tank_sprite + &01
.no_inc_tank
 DEX
 BNE next_tank
 LDA tank_screen_offset                 ;clear last space
 STA tank_address
 LDA tank_screen_offset + &01
 STA tank_address + &01
 LDY #&0F
 TXA                                    ;x=0
.clear_tank
 STA (tank_address),Y
 DEY
 BPL clear_tank
.no_draw_tanks
 RTS

.timer_interrupt
 LDA user_via_timer_1_latch_lo          ;only source user via interrupt timer 1, clear interrupt
 LDA #&B5                               ;logical colour 1 to physical colour 2 (green)
 STA sheila + &21
 LDA #&A5
 STA sheila + &21
 LDA #&95
 STA sheila + &21
 LDA #&85
 STA sheila + &21
 LDA #&F5
 STA sheila + &21
 LDA #&E5
 STA sheila + &21
 LDA #&D5
 STA sheila + &21
 LDA #&C5
 STA sheila + &21
 LDA interrupt_accumulator
 RTI

.game_initialisation                    ;initialise game variables etc
 LDA #&00                               ;at loader start
 STA m_tank_rotation
 STA m_tank_rotation + &01
 LDA #mode_01_attract_mode              ;start up in attract mode
 STA game_mode
 STA new_game_mode
 LDA #&0C                               ;point radar arm up
 STA radar_arm_position
 BIT machine_flag
 BPL no_colour_change                   ;running on bbc
 LDA #&FB                               ;change electron colour to green
 STA sheila + &08
 LDA #&FF
 STA sheila + &09
.no_colour_change
 LDA #14                                ;enable vertical sync event
 LDX #&04
 JSR osbyte
 JSR mathbox_claim_tube                 ;if present claim the tube
 JSR game_window
 JMP change_mode                        ;start up in attract mode

.bzone1_execute                         ;final loader actions before game start
 JSR relocate_bzone3                    ;move code into place at &0e00
 JSR game_event_and_user_via_vector     ;patch in irq and event processing
 BIT machine_flag                       ;test for disk enabled v=1
 BVC disk_inactive
 LDA #ascii_00                          ;load saved service settings
 JSR load_bz_file
 LDA #ascii_02                          ;load save high scores
 JSR load_bz_file
.disk_inactive
 JSR select_swr_slot

 IF NOT(debug)
   JSR clear_all_screen
   JSR flip_screen
   JSR clear_all_screen
 ENDIF

 JMP main_program_start                 ;game loader over so now start up game

.relocate_bzone3
 LDY #&00
 LDX #&22
.transfer_bzone3_00
 LDA bzone3_loaded_at,Y
.transfer_bzone3_01
 STA bzone3_relocated_to,Y
 DEY
 BNE transfer_bzone3_00
 INC transfer_bzone3_00 + &02
 INC transfer_bzone3_01 + &02
 DEX
 BNE transfer_bzone3_00
 RTS

.game_event_and_user_via_vector
 PHP
 SEI
 BIT machine_flag
 BMI no_user_via                        ;no user via for the electron
 LDA #LO(bbc_game_wait_event)
 STA eventv
 LDA #HI(bbc_game_wait_event)
 STA eventv + &01
 LDA #LO(timer_interrupt)
 STA irq2v
 LDA #HI(timer_interrupt)
 STA irq2v + &01
 PLP                                    ;restore irq status
 RTS

.no_user_via
 LDA #LO(electron_game_wait_event)
 STA eventv
 LDA #HI(electron_game_wait_event)
 STA eventv + &01
 PLP                                    ;restore irq status
 RTS

.print_variables
 LDY #&00
 LDA enemy_turn_to
 JSR print_it_in_hex
 LDY #&08
 LDA tank_or_super_or_missile + &01
 JSR print_it_in_hex
 RTS

.hexx EQUD &FFFFFFFF

.page_four_end
