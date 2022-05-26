; high score maintenance
;
; display high score table and entry screen for initials
; if score on table
;
; informational messages for player
; screen messages rows
; 0 enemy in range
; 1 motion blocked by object
; 2 enemy to left/right/rear
;
; text display on attract screen for different kinds of play message
;
; constants
 score                                  = &05
 high_score_tank                        = &100
 high_score_address                     = screen_row * &03 + &FA
 game_over_address                      = screen_row * &0A + &78
 high_screen_address                    = screen_row * &03 + &C8

 enemy_in_range_screen                  = screen_row * &01 + &10
 motion_blocked_screen                  = screen_row * &02 + &10
 enemy_to_mess_screen                   = screen_row * &03 + &10

 radar_center_x                         = &9F
 radar_center_y                         = &17
 radar_limit                            = &2E

 great_score_address                    = screen_row * &0B + &40
 select_address                         = great_score_address + screen_row * &02 + 16

; small message character space clear
MACRO small_message_clear screen_address_offset, number_of_characters
 LDX #LO(parameter)
 LDY #HI(parameter)
 JMP clear_cells

.parameter
 EQUW screen_address_offset
 EQUB number_of_characters * &08
ENDMACRO

; place small message on screen
MACRO small_message screen_address, sprite_address, number_of_characters
 LDX #LO(parameter)
 LDY #HI(parameter)
 JMP multiple_row_sprite

.parameter
 EQUW screen_address - &01
 EQUW sprite_address - &01
 EQUB &01
 EQUB number_of_characters * &08
ENDMACRO

; parameter block for fast sprites
MACRO fast_block screen, sprite, rows, bytes
 EQUW screen - &01
 EQUW sprite - &01
 EQUB rows
 EQUB bytes
ENDMACRO

; calculate an address in screen buffer
MACRO initialise_hidden page_zero, address
 LDA #LO(address)
 STA page_zero
 LDA #HI(address)
 CLC
 ADC screen_hidden
 STA page_zero + &01
ENDMACRO

.high_scores_save_start                 ;<--- high score block start

.high_scores
 EQUW score                             ;highest score used for game screen
 EQUW score
 EQUW score
 EQUW score
 EQUW score
 EQUW score
 EQUW score
 EQUW score
 EQUW score
.bottom_high_score
 EQUW score
.high_scores_end

.high_score_names
.player_01
 EQUS "    000 EDR  "
 EQUB bit_ascii_space

.player_02
 EQUS "    000 MPH  "
 EQUB bit_ascii_space

.player_03
 EQUS "    000 JED  "
 EQUB bit_ascii_space

.player_04
 EQUS "    000 DES  "
 EQUB bit_ascii_space

.player_05
 EQUS "    000 TKE  "
 EQUB bit_ascii_space

.player_06
 EQUS "    000 VKB  "
 EQUB bit_ascii_space

.player_07
 EQUS "    000 EL   "
 EQUB bit_ascii_space

.player_08
 EQUS "    000 HAD  "
 EQUB bit_ascii_space

.player_09
 EQUS "    000 ORR  "
 EQUB bit_ascii_space

.player_10
 EQUS "    000 GJR  "
 EQUB bit_ascii_space

.high_scores_save_end
 EQUB &00                               ;<--- high score block end

.convert_high_scores_bcd_to_ascii
 LDX #high_scores_end - high_scores - &01
 LDY #player_10 - high_score_names
.next_high_score
 LDA #ascii_space                       ;suppress leading zeroes
 STA zero_blank
 LDA #&02
 STA bcd_counter
.bcd_two_digits
 LDA high_scores,X
 PHA
 LSR A
 LSR A
 LSR A
 LSR A
 BNE non_zero
 LDA zero_blank
 STA high_score_names,Y
 BPL next_digit
.non_zero
 ORA #&30                               ;0-9 digits
 STA high_score_names,Y
 LDA #ascii_00                          ;0 digit
 STA zero_blank
.next_digit
 PLA
 AND #&0F
 BNE non_zero_two
 LDA zero_blank
 STA high_score_names + &01,Y
 BPL digit_exit
.non_zero_two
 ORA #&30
 STA high_score_names + &01,Y
.digit_exit
 DEX
 INY
 INY
 DEC bcd_counter
 BNE bcd_two_digits
 TYA
 SEC
 SBC #&12
 TAY
 TXA
 BPL next_high_score
 RTS

.print_player_table
 EQUW player_01
 EQUW player_02
 EQUW player_03
 EQUW player_04
 EQUW player_05
 EQUW player_06
 EQUW player_07
 EQUW player_08
 EQUW player_09
 EQUW player_10

.print_high_scores_table
 JSR print_table_header_and_footer
 JSR convert_high_scores_bcd_to_ascii
 LDA #&C0                               ;print each high score line
 STA player_high_scores_y_coordinate
 LDA #&68
 STA player_line + &02
 LDX #&12
.player_high_score_line
 LDA print_player_table,X
 STA player_line
 LDA print_player_table + &01,X
 STA player_line + &01
 TXA
 PHA
 LDX #LO(player_line)
 LDY #HI(player_line)
 JSR print
 LDA player_high_scores_y_coordinate
 SEC
 SBC #&0C
 STA player_high_scores_y_coordinate
 PLA
 TAX
 DEX
 DEX
 BPL player_high_score_line
 RTS

.player_high_score_header
 EQUW high_scores_table
 EQUB &74
 EQUB &48
.high_scores_table
 EQUS "HIGH SCORE"
 EQUB bit_ascii_s

.player_table_footer_00
 EQUW table_footer_00
 EQUB &28
 EQUB &CC
.table_footer_00
 EQUS "BONUS TANK AT "
.table_double_digits
 EQUS "15000 AND 10000"
 EQUB bit_ascii_00

.print_table_header_and_footer
 LDX #LO(player_high_score_header)
 LDY #HI(player_high_score_header)
 JSR print
 LDX bonus_tank_index
 BEQ no_bonus_at_all
 LDA bonus_double_digits_low - &01,X
 STA table_double_digits + &01
 LDA bonus_double_digits_high - &01,X
 STA table_double_digits
 LDX #LO(player_table_footer_00)
 LDY #HI(player_table_footer_00)
 JMP print

.bonus_double_digits_low
 EQUB LO(&3135)
 EQUB LO(&3235)
 EQUB LO(&3530)
.bonus_double_digits_high
 EQUB HI(&3135)
 EQUB HI(&3235)
 EQUB HI(&3530)

.bubble_sort_high_score_table           ;bubble up entry ten until at top or below next score
 LDX #&10
.insert_sort
 LDA high_scores,X                      ;compare score with one above
 CMP high_scores + &02,X                ;c=result
 LDA high_scores + &01,X
 SBC high_scores + &03,X
 BCS no_swap_data                       ;cannot move further so exit
 JSR swap_scores_and_name
 DEX
 DEX
 BPL insert_sort
.no_swap_data
.no_bonus_at_all
 RTS

.swap_scores_and_name
 LDA high_scores,X                      ;save score above on stack
 PHA
 LDA high_scores + &01,X                ;move score above down one
 PHA
 LDA high_scores + &02,X
 STA high_scores,X
 LDA high_scores + &03,X
 STA high_scores + &01,X
 PLA                                    ;pop score off stack and put one place up
 STA high_scores + &03,X
 PLA
 STA high_scores + &02,X
 TXA
 LSR A
 TAY
 LDA print_player_table,Y
 STA first_entry
 LDA print_player_table + &01,Y
 STA first_entry + &01
 LDA print_player_table + &02,Y
 STA second_entry
 LDA print_player_table + &03,Y
 STA second_entry + &01
 LDY #&09                               ;move three character name and any tank icon up
.shift_name_and_tank
 LDA (first_entry),Y
 TAX
 LDA (second_entry),Y
 STA (first_entry),Y
 TXA
 STA (second_entry),Y
 INY
 CPY #&0F
 BNE shift_name_and_tank
 RTS

.great_score_parameters

 fast_block great_score_address, battlezone_sprites + great_score_offset, &02, 184

.select_parameters

 fast_block select_address, battlezone_sprites + select_offset, &01, 144

.new_high_score_mode                    ;enter new high score
 LDX #LO(great_score_parameters)        ;great score message etc
 LDY #HI(great_score_parameters)
 JSR multiple_row_sprite
 LDX #LO(select_parameters)
 LDY #HI(select_parameters)
 JSR multiple_row_sprite
 LDX #LO(three_number_set)
 LDY #HI(three_number_set)
 JSR print
 BIT combined_t
 BMI increase_text
 BIT combined_r
 BMI decrease_text
 BIT combined_space
 BMI enter_character
 LDA clk_mode                           ;name entry timed out?
 BMI new_high_exit
 JSR enter_score_on_time_out
 JMP switch_to_high_score

.increase_text
 LDX enter_text_index
 LDY valid_character_index
 INY
 CPY #27
 BNE text_okay
 LDY #&00
 BEQ text_okay                          ;always

.three_number_set
 EQUW three_number_text
 EQUB &94
 EQUB &90

.decrease_text
 LDX enter_text_index
 LDY valid_character_index
 DEY
 BPL text_okay
 LDY #26
.text_okay
 LDA service_char_text,Y
 STA three_number_text,X
 STY valid_character_index
.refresh_score
 LDA #console_score_entry
 STA console_synchronise_message_flashing
.new_high_exit
 RTS

.enter_character
 INC enter_text_index
 LDX enter_text_index
 CPX #&03
 BNE new_character                      ;three characters entered now insert in table

.enter_score_on_time_out                ;update high score with whatever present
 LDX #&02
 LDY #bit_ascii_space
.transfer_triple                        ;transfer three characters to table
 LDA three_number_text,X
 AND #&7F                               ;remove top bit if present
 CMP #ascii_under_score
 BNE no_under_scores
 TYA                                    ;store top bit set space
.no_under_scores
 STA player_10 + &09,X
 DEX
 BPL transfer_triple
 LDA bottom_high_score + &01            ;score > 100,000?
 BEQ no_tank_icon
 LDY #ascii_equals                      ;set tank to display
 LDA #bit_ascii_greater_than            ;= followed by >
 STA player_10 + &0D
.no_tank_icon
 STY player_10 + &0C                    ;set tank to y register
 JSR bubble_sort_high_score_table       ;sort new score to correct position
 JMP switch_to_high_score

.new_character
 LDA #&00
 STA valid_character_index
 LDA #ascii_a
 STA three_number_text,X
 BNE refresh_score                      ;always

.test_for_new_high_score                ;test for new high score if so enter into table
 LDX player_score
 CPX bottom_high_score
 LDY player_score + &01
 TYA
 SBC bottom_high_score + &01
 BEQ not_on_table                       ;if equals existing then score stays on
 BCC not_on_table                       ;not greater than tenth score in table
 STX bottom_high_score
 STY bottom_high_score + &01
 LDX #&04
.three_initial
 LDA high_initial_block,X
 STA three_number_text,X                ;clear text entry
 DEX
 BPL three_initial
 JMP switch_to_new_high_score           ;change mode to enter new high score name
.not_on_table                           ;did not make the high score table
 JMP switch_to_attract

.high_initial_block
 EQUB ascii_a
 EQUB ascii_under_score
 EQUB bit_ascii_under_score
 EQUB &00
 EQUB &00

.clear_message_top
 small_message_clear enemy_in_range_screen - &01, &08

.check_enemy_in_range
 LDA console_enemy_in_range
 BEQ common_exit_point                  ;no "enemy to range"
 INC console_enemy_in_range
 CMP #console_double - &01
 BCS clear_message_top
 BIT console_synchronise_message_flashing
 BPL clear_message_top

 small_message enemy_in_range_screen, battlezone_sprites + enemy_in_range_offset, &08

.check_left_right_rear
 LDA console_enemy_to_left
 BEQ enemy_to_right                     ;no "enemy to left" so check "enemy to right"
 INC console_enemy_to_left
 CMP #console_double - &01
 BCS clear_message_bottom
 BIT console_synchronise_message_flashing
 BPL clear_message_bottom

 small_message enemy_to_mess_screen, battlezone_sprites + enemy_to_left_offset, &08

.enemy_to_right
 LDA console_enemy_to_right
 BEQ enemy_to_rear
 INC console_enemy_to_right
 CMP #console_double - &01
 BCS clear_message_bottom
 BIT console_synchronise_message_flashing
 BPL clear_message_bottom

 small_message enemy_to_mess_screen, battlezone_sprites + enemy_to_right_offset, &08

.enemy_to_rear
 LDA console_enemy_to_rear
 BEQ common_exit_point
 INC console_enemy_to_rear
 CMP #console_double - &01
 BCS clear_message_bottom
 BIT console_synchronise_message_flashing
 BPL clear_message_bottom

 small_message enemy_to_mess_screen, battlezone_sprites + enemy_to_rear_offset, &08

.clear_message_bottom                   ;clear message and exit
 small_message_clear enemy_to_mess_screen - &01, &08

.common_exit_point
 RTS

.status_messages
 LDA console_synchronise_message_flashing
 EOR #&80                               ;flip bit 7
 STA console_synchronise_message_flashing
 JSR check_left_right_rear
 JSR check_enemy_in_range               ;roll into routine below

.motion_blocked
 LDA console_motion_blocked
 BEQ common_exit_point
 INC console_motion_blocked
 CMP #console_double - &01
 BCS clear_motion_blocked
 BIT console_synchronise_message_flashing
 BMI clear_motion_blocked               ;-ve for middle row, +ve for top/bottom row

 small_message motion_blocked_screen, battlezone_sprites + motion_blocked_offset, &0E

.clear_motion_blocked
 INC sound_motion_blocked               ;motion blocked
 small_message_clear motion_blocked_screen - &01, &0E

.game_over_copyright_and_start
 LDX #LO(game_over)
 LDY #HI(game_over)
 JSR print_or
 LDX #LO(copyright)
 LDY #HI(copyright)
 JSR print
 LDX coins_amount                       ;coins required index
 BEQ press_to_start                     ;exit, no coins message
 LDA coins_added
 CMP coins_required,X
 BCS press_to_start
 LDX coins_amount                       ;coins required index
 LDY play_table_hi - &01,X
 LDA play_table_lo - &01,X
 TAX
 JSR print_or
 LDA console_press_start_etc
 AND #&02
 BNE play_table_message_pass            ;flash text
 LDX #LO(insert_coin)                   ;insert coin
 LDY #HI(insert_coin)
 JMP print_or
.play_table_message_pass
 RTS

.press_to_start
 LDA console_press_start_etc
 AND #&02
 BNE common_exit_point                  ;exit
 LDX #LO(press_start)
 LDY #HI(press_start)
 JMP print_or

.insert_coin
 EQUW insert_coin_text
 EQUB &70
 EQUB &96
.insert_coin_text
 EQUS "INSERT COI"
 EQUB bit_ascii_n

.game_over
 EQUW game_over_text
 EQUB &78
 EQUB &5A
.game_over_text
 EQUS "GAME OVE"
 EQUB bit_ascii_r

.play_table_lo
 EQUB LO(one_coin_for_two)
 EQUB LO(one_coin_for_one)
 EQUB LO(two_coins_for_one)

.play_table_hi
 EQUB HI(one_coin_for_two)
 EQUB HI(one_coin_for_one)
 EQUB HI(two_coins_for_one)

.one_coin_for_two
 EQUW one_coin_for_two_service_text
 EQUB &68
 EQUB &78

.one_coin_for_one
 EQUW one_coin_for_one_service_text
 EQUB &70
 EQUB &78

.two_coins_for_one
 EQUW two_coins_for_one_service_text
 EQUB &68
 EQUB &78

.copyright
 EQUW copyright_text
 EQUB &68
 EQUB &C8
.copyright_text
 EQUS ":;  ATARI 198"
 EQUB bit_ascii_00

.press_start
 EQUW press_start_text
 EQUB &70
 EQUB &77
.press_start_text
 EQUS "PRESS STAR"
 EQUB bit_ascii_t

.print_player_score
 BIT console_print                      ;print score
 BPL exit_small_number
 INC console_print
 JSR draw_tanks
 JSR high_score_text
 LDX #&00                               ;print large score
 LDY #&03
.convert_all_digits
 LDA player_score,X
 AND #&0F
 ORA #&30
 STA player_score_text,Y
 DEY
 LDA player_score,X
 LSR A
 LSR A
 LSR A
 LSR A
 ORA #&30
 STA player_score_text,Y
 INX
 DEY
 BPL convert_all_digits
.test_next_digit                        ;remove leading zeroes
 INY                                    ;entry y=&ff from loop
 LDA player_score_text,Y
 EOR #ascii_00                          ;'0'
 BNE found_non_ascii_zero_digit
 LDA #ascii_space                       ;' '
 STA player_score_text,Y
 CPY #&02
 BNE test_next_digit
.found_non_ascii_zero_digit
 LDX #LO(player_score_screen)           ;print player score
 LDY #HI(player_score_screen)
 JMP print

.player_score_screen
 EQUW player_score_full
 EQUB &C8
 EQUB &0E
.player_score_full
 EQUS "SCORE "
.player_score_text
 EQUS "000000"
 EQUB bit_ascii_00

.right_hand_side
 LDA battlezone_sprites + small_numbers_offset - &02,X
 AND #&0F
 STA (small_address),Y
 DEX
 DEY
 DEC char_index
 BNE right_hand_side
 DEC char_counter
 BPL print_small_number
.exit_small_number
 RTS

.high_score_text                        ;small high score text
 LDX #LO(high_score_parameters)
 LDY #HI(high_score_parameters)
 JSR multiple_row_sprite                ;"highscore"
 LDA high_scores + &01
 TAX
 LSR A
 LSR A
 LSR A
 LSR A
 STA convert_small
 TXA
 AND #&0F
 STA convert_small + &01
 LDA high_scores
 TAX
 LSR A
 LSR A
 LSR A
 LSR A
 STA convert_small + &02
 TXA
 AND #&0F
 STA convert_small + &03
 LDX #&00
 STX convert_small + &04                ;trailing 0's
 STX convert_small + &05
 STX convert_small + &06
.find_more                              ;set top bit for leading 0's
 LDA convert_small,X
 BNE not_zero_digit
 SEC
 ROR convert_small,X
 INX
 BNE find_more
.not_zero_digit

 initialise_hidden small_address, high_score_address

 LDX #&06
 STX char_counter
 LDY #&1D
 STY screen_index
.print_small_number
 LDA #&05
 STA char_index
 LDX char_counter
 LDA convert_small,X
 BMI exit_small_number                  ;no more to print
 ASL A
 ASL A
 ADC convert_small,X                    ;*5
 ADC #&06                               ;+6
 TAX                                    ;index into character data
 LDY screen_index
 LDA char_counter
 LSR A
 BCS right_hand_side                    ;small number to right
.small_char_ora
 LDA battlezone_sprites + small_numbers_offset - &02,X
 AND #&F0
 ORA (small_address),Y
 STA (small_address),Y
 DEX
 DEY
 DEC char_index
 BNE small_char_ora
 DEY
 DEY
 DEY
 STY screen_index
 DEC char_counter
 BPL print_small_number
 RTS

.high_score_parameters

 fast_block high_screen_address, battlezone_sprites + high_score_offset, &01, 48
              
.orientation_cset_exit
 ROR radar_scr_a                        ;radar spot flag
 LSR on_target                          ;clear sights flag
 BIT radar_scr_a                        ;radar spot on?
 BPL not_out_of_range                   ;not out of range so exit
 BIT missile_flag                       ;was it a missile?
 BPL not_missile                        ;no keep on going
 LDA mathbox_random
 CMP #&04
 BCC make_missile                       ;not tired of missiles yet, make another
 JMP create_tank                        ;let's go back to tanks
.make_missile
 JMP create_missile

.orientation_exit                       ;turn radar spot off, used when explosion in progress etc
 SEC
 ROR radar_scr_a                        ;radar spot flag
 LSR on_target
.not_missile
.not_out_of_range
 RTS

.orientation                            ;maintain messages/in sights flag/angle to player/radar spot
 BIT tank_or_super_or_missile
 BMI orientation_exit                   ;not on, messages will time out, no radar spot/on target sights
 LDA tank_or_super_or_missile_workspace_x
 STA distance_dx
 LDA tank_or_super_or_missile_workspace_x + &01
 STA distance_dx + &01
 STA x_coor_tan_01                      ;initialise for arctangent
 CMP #&80                               ;calculate radar x screen coordinate
 ROR A
 CLC
 ADC #radar_center_x                    ;radar spot x
 STA radar_scr_x
 LDA distance_dx
 STA workspace + &01                    ;initialise for arctangent
 LDA tank_or_super_or_missile_workspace_z
 STA distance_dz
 STA workspace + &02                    ;initialise for arctangent
 LDA tank_or_super_or_missile_workspace_z + &01
 STA distance_dz + &01
 STA z_coor_tan_01                      ;initialise for arctangent
 CMP #&80                               ;calculate radar y screen coordinate
 ROR A                                  ;signed divide by 2
 EOR #&FF                               ;invert
 CLC
 ADC #radar_center_y
 STA radar_scr_y                        ;radar spot y
 JSR distance_16                        ;exit a=d_object_distance + &01
 STA enemy_dist_hi                      ;store for use later by unit ai
 CMP #radar_limit
 BCS orientation_cset_exit              ;out of range so exit
 STA workspace
.scale_again                            ;scale the coordinates to increase accuracy
 BIT workspace                          ;change n/v flags
 BMI no_scaling_required_for_arctangent
 BVS no_scaling_required_for_arctangent
 ASL workspace
 ASL workspace + &01
 ROL x_coor_tan_01
 ASL workspace + &02
 ROL z_coor_tan_01
 BVC scale_again                        ;always
.no_scaling_required_for_arctangent     ;arctangent at 8 bits, arcade at 16 bits
 JSR arctangent                         ;exit a = 0-255 angle between my tank and tank/super/missile
 TAY                                    ;save for messages/ai
 LSR A                                  ;place radar spot on
 LSR A
 LSR A
 LSR A                                  ;bring into radar counter range 0-15
 CMP radar_arm_position
 BNE place_radar_spot
 LDX #&0F                               ;large spot
 STX radar_scr_a
 INC sound_enemy_radar                  ;radar ping sound
 BNE radar_not_activate                 ;always
.place_radar_spot
 BIT radar_scr_a
 BPL radar_not_activate
 LDX #&00
 STX radar_scr_a
.radar_not_activate
 LDX #console_messages                  ;enemy on radar activate "enemy in range"
 STX console_enemy_in_range             ;x = message counter
 TYA                                    ;negate angle then rotate
 EOR #&FF                               ;through quarter turn
 SEC
 SBC #&40 - &01                         ;+&01 for negate, -&40 for rotate
 STA enemy_angle_delta                  ;save for use by opponent ai etc
 BPL enemy_angle_is_positive
 EOR #&FF
 CLC
 ADC #&01
.enemy_angle_is_positive
 STA enemy_ang_delt_abs                 ;absolute angle
 TYA                                    ;to move/attack the player
 CLC
 ADC #&40                               ;rotate angle to make comparisons easier for messages
 CMP #&20
 BCC check_sights
 CMP #&E0
 BCS check_sights_set                   ;check sights if in front 45' view so no left/right/rear messages
 LDY #&00                               ;message zero page index
 CMP #&A0
 BCS target_message                     ;target to left
 INY
 CMP #&60
 BCC target_message                     ;target to right
 INY                                    ;target to rear
.target_message
 STX console_enemy_to_left,Y
 RTS
.check_sights
 SEC
.check_sights_set
 SBC #&02
 CMP #LO(-&04)
 ROR on_target                          ;in sights flag updated
 RTS
