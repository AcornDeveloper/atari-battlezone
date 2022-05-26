; ******************************************************************************
; *                                                                            *
; *  atari battlezone                                                          *
; *  copyright 1980 atari, inc.                                                *
; *                                                                            *
; *  by ed rotberg, jed margolin, harry jenkins, roger hector, howard delman,  *
; *  mike albaugh, dan pliskin, doug snyder, owen rubin, and morgan hoff       *
; *                                                                            *
; *  bbc/electron source/object code for battlezone conversion                 *
; *  target machines : electron, bbc b/b+ with 16k swr or bbc master 128,      *
; *                    arm tdmi second processor or faster                     *
; *  program         : atari battlezone 1980                                   *
; *                                                                            *
; ******************************************************************************
;
; view game instructions
; ----------------------
; change to mode 0, ctrl-n to scroll lock and then *type readme
; then use return key to page through, also credits and notes
;
; electron keyboard
; -----------------
; keyboard is mapped to rom number 8 or 9
; column  address bit 0   bit 1    bit 2   bit 3
; 0       &bffe   right   copy     nc      space
; 1       &bffd   left    down     return  delete
; 2       &bffb   -       up       :       nc
; 3       &bff7   0       p        ;       /
; 4       &bfef   9       o        l       .
; 5       &bfdf   8       i        k       ,
; 6       &bfbf   7       u        j       m
; 7       &bf7f   6       y        h       n
; 8       &beff   5       t        g       b
; 9       &bdff   4       r        f       v
; a       &bbff   3       e        d       c
; b       &b7ff   2       w        s       x
; c       &afff   1       q        a       z
; d       &9fff   escape  caps lck ctrl    shift
;
; build variable
 debug                                  = FALSE

; constants
 hertz_03                               = &03
 hertz_25                               = &19
 hertz_50                               = &32
 seconds_02                             = &02
 seconds_17                             = &11
 model_z_coordinate                     = &3FF
 screen_row                             = &140
 counter_refresh                        = &02

 mode_00_main_game                      = &00
 mode_01_attract_mode                   = &01
 mode_02_high_score_table               = &02
 mode_03_service_menu                   = &03
 mode_04_new_high_score                 = &04
 mode_05_battlezone_text                = &05
 mode_06_model_test                     = &06

 end_the_crack                          = &10
 page                                   = &E007A

 text_initial_y                         = &280
 text_initial_z                         = &140

 sine_peak                              = &7FFF
 sine_full_512                          = &200
 sine_quarter_512                       = sine_full_512 / 4

 score_tank                             = &01
 score_missile                          = &02
 score_super_tank                       = &03
 score_saucer                           = &05

 random_seed                            = &AA

; console variables action on current hidden screen
; &00 - do nothing
; &FF - clear the message
; &FE - clear the message
; &FD - display message *                          <--- start value for rhs
; &FC - start and display message, initial value * <--- start value for lhs
; * dependant on bit 0 of console_refresh + &03, middle row uses
; bit invert to synchronise message flashing

 console_messages                       = &FC   ;value controls messages
 console_score_entry                    = &FD   ;value controls flashing text
 console_double                         = &FE   ;value controls score, tanks and high score print

 dummy_address                          = &1000 ;16 bit address with zero lsb

 bbc_a_key                              = 65    ;make inkey value positive and subtract 1
 bbc_b_key                              = 100
 bbc_c_key                              = 82
 bbc_d_key                              = 50
 bbc_k_key                              = 70
 bbc_m_key                              = 101
 bbc_n_key                              = 85
 bbc_r_key                              = 51
 bbc_t_key                              = 35
 bbc_x_key                              = 66
 bbc_z_key                              = 97
 bbc_escape                             = 112
 bbc_space                              = 98
 bbc_f_key                              = 67
 bbc_arrow_up                           = 57
 bbc_arrow_down                         = 41
 bbc_arrow_left                         = 25
 bbc_arrow_right                        = 121

 column_00                              = &BFFE
 column_01                              = &BFFD
 column_02                              = &BFFB
 column_03                              = &BFF7
 column_04                              = &BFEF
 column_05                              = &BFDF
 column_06                              = &BFBF
 column_07                              = &BF7F
 column_08                              = &BEFF
 column_09                              = &BDFF
 column_0A                              = &BBFF
 column_0B                              = &B7FF
 column_0C                              = &AFFF
 column_0D                              = &9FFF

 electron_plus_1_rom                    = &2AC

 game_timer                             = &1200
 tank_screen_offset                     = &C7

 text_frames                            = &84

 host_addr                              = &30000 ;set bits to force load to host processor

 bzone0_loaded_at_host                  = &2000 + host_addr
 bzone2_loaded_at                       = &2000
 bzone2_loaded_at_host                  = &2000 + host_addr
 bzone2_relocated_to                    = &8000
 bzone3_loaded_at                       = &2000
 bzone3_loaded_at_host                  = &2000 + host_addr
 bzone3_relocated_to                    = &0E00
 bzone5_loaded_at                       = &2000
 bzone5_loaded_at_host                  = &2000 + host_addr
 bzone5_relocated_to                    = &0400

; addresses
 screen_start                           = &3000
 electron_romsel                        = &FE05

 INCLUDE "operating system.asm"         ;data files for main assembly
 INCLUDE "mathbox variables.asm"        ;mathbox usage
 INCLUDE "page zero.asm"                ;zp declarations
 INCLUDE "ascii.asm"                    ;ascii values etc
 INCLUDE "battlezone sprites.bin.info"  ;general sprite info

; debounce bbc key press
MACRO debounce_bbc_key key_address
 BPL clear_key                          ;y=&ff
 BIT key_address
 BMI clear_key                          ;if pressed last time clear bit 7
 BVS debounce_end                       ;debounce
 STY key_address                        ;set key pressed flag and debounce flag
 BVC debounce_end                       ;always
.clear_key
 LSR key_address                        ;key not pressed, second pass clears debounce flag
.debounce_end
ENDMACRO

; debounce electron key press
MACRO debounce_electron_key key_address
 BEQ clear_key                          ;y=&ff
 BIT key_address
 BMI clear_key                          ;if pressed last time clear bit 7
 BVS debounce_end                       ;debounce
 STY key_address                        ;set key pressed flag and debounce flag
 BVC debounce_end                       ;always
.clear_key
 LSR key_address                        ;key not pressed, second pass clears debounce flag
.debounce_end
ENDMACRO

; direct key press on the bbc
MACRO read_key_bbc key_value
 LDA #key_value
 STA sheila + &4F
 LDA sheila + &4F                       ;n flag = key pressed
ENDMACRO

; store unbounced key press result on bbc
MACRO store_unbounced_bbc unbounced_address
 STA unbounced_address
ENDMACRO

; direct read of key press on the electron
MACRO read_electron_key rom_address, key_bit_mask
 LDA rom_address
 AND #key_bit_mask                      ;z flag = key pressed
ENDMACRO

; store unbounced key press result on the electron
MACRO store_unbounced_electron unbounced_address
 BEQ electron_not_pressed
 TYA
.electron_not_pressed
 STA unbounced_address
ENDMACRO

; loader and code from disc, sequence is:-
; bz     - &0a00
;  > run bzone0, logo etc
; bzone0 - &2000
;  > test for swr and abort if not present
;  > test for arm second processor and set flag if present
;  > load arm parasite code
;  > one-off game set up code
;  > play atari logo
; bzone1 - &0a00
; bzone2 - &2000
; bzone3 - &3000
; bzone4 - &9000 - arm code
; bzone5 - &0400
; bz0/1  - settings
; bz2/3  - scores
;
; addresses available outside of normal workspace
; &0400 - &07ff language workspace/second processor code
; &0a00 - &0aff rs232/cassette buffer
; &0b00 - &0bff function keys
; &0c00 - &0cff expanded character set
;
; game memory map
; &2000 - &2fff initialisation code and atari logo
;
; &0400 - &07ff general workspace/code
; &0a00 - &0cff loader/workspace
;
; &0e00 - &2fff main code/data
; &3000 - &7fff double buffered mode 4
; &8000 - &bfff swr code/data

 ORG   &0A00
 CLEAR &0A00, &0CFF
 GUARD &0D00

.bz                                     ;battlezone loader
 LDX #&C0                               ;temporary lower stack for loader while second processor initialised etc
 TXS
 LDA #ascii_00                          ;load bzone0 initialise environment/atari logo
 STA bzone_name + &05
 LDA #&FF
 LDX #LO(load_bzone_file)
 LDY #HI(load_bzone_file)
 JSR osfile
 JSR bzone0                             ;run bzone0 logo
 LDX #&FF                               ;flatten stack for rest of loader
 TXS
 JSR square_table                       ;multiplication square table
 LDA #ascii_02                          ;load bzone2
 STA bzone_name + &05
 LDA #&FF                               ;load file to &2000
 LDX #LO(load_bzone_file)
 LDY #HI(load_bzone_file)
 JSR osfile
 LDX #&40                               ;transfer to swr &8000
 LDY #&00
.transfer_bzone2_00
 LDA bzone2_loaded_at,Y
.transfer_bzone2_01
 STA bzone2_relocated_to,Y
 DEY
 BNE transfer_bzone2_00
 INC transfer_bzone2_00 + &02
 INC transfer_bzone2_01 + &02
 DEX
 BNE transfer_bzone2_00
 LDA #ascii_05                          ;load bzone5
 STA bzone_name + &05
 LDA #&FF
 LDX #LO(load_bzone_file)
 LDY #HI(load_bzone_file)
 JSR osfile
 LDY #&00                               ;transfer to language workspace &400
.transfer_bzone5
 LDA bzone5_loaded_at,Y
 STA basic_language,Y
 LDA bzone5_loaded_at + &100,Y
 STA basic_language + &100,Y
 LDA bzone5_loaded_at + &200,Y
 STA basic_language + &200,Y
 LDA bzone5_loaded_at + &300,Y
 STA basic_language + &300,Y
 DEY
 BNE transfer_bzone5
 LDA #ascii_03                          ;load bzone3
 STA bzone_name + &05
 LDA #&FF
 LDX #LO(load_bzone_file)
 LDY #HI(load_bzone_file)
 JSR osfile
 LDA #ascii_01                          ;*run bzone1
 STA bzone_name + &05
 LDA #&04
 LDX #LO(bzone_name)
 LDY #HI(bzone_name)
 JMP (fscv)

.load_bzone_file
 EQUW bzone_name
 EQUD &00
 EQUD &FF
 EQUD &00
 EQUD &00
.bzone_name
 EQUS "bzone0", &0D

.address_pointer
 EQUW square1_lo_16
 EQUW square1_hi_16
 EQUW square2_lo_16
 EQUW square2_hi_16

.square_table                           ;quarter square table used for multiplication
 LDX #&07
.load_table
 LDA address_pointer,X
 STA square_address,X
 DEX
 BPL load_table
 LDA #random_seed
 STA mathbox_random                     ;initialise random number generator
 STA mathbox_random + &01
 STA mathbox_random + &02
 STA mathbox_random + &03
 STA mathbox_random + &04
 RTS

.bz_end
 SAVE "bz", bz, &0CFF, bz + host_addr, bz + host_addr

 ORG   &0A00
 CLEAR &0A00, &0CFF
 GUARD &0D00

.bzone1
 INCLUDE "mathbox.asm"

.bzone1_end
 SAVE "bzone1", bzone1, &0CFF, bzone1_execute + host_addr, bzone1 + host_addr

 ORG   &0E00
 CLEAR &0E00, &2FFF
 GUARD &3000

.bzone3
 INCLUDE "multiply.asm"                 ;must be aligned on a page boundary
 INCLUDE "service.asm"
 INCLUDE "high score.asm"
 INCLUDE "sound.asm"

.bbc_game_wait_event
 PHP                                    ;only vertical sync event 4 enabled
 PHA
 LDA game_mode                          ;no screen interrupt service mode
 CMP #mode_03_service_menu
 BEQ maintain_counters
 LDA #&B6                               ;logical colour 1 to physical colour 1 (red)
 STA sheila + &21
 LDA #&A6
 STA sheila + &21
 LDA #&96
 STA sheila + &21
 LDA #&86
 STA sheila + &21
 LDA #&F6
 STA sheila + &21
 LDA #&E6
 STA sheila + &21
 LDA #&D6
 STA sheila + &21
 LDA #&C6
 STA sheila + &21
 LDA #user_via_aux_timer_1_one_shot     ;auxillary register set for timer 1 one shot
 STA user_via_aux_reg
 LDA #HI(game_timer)                    ;set up one shot timer
 STA user_via_timer_1_latch_hi          ;no latch low as sufficent gap between areas
 LDA #user_via_ier_timer_1              ;enable user via timer 1 interrupt
 STA user_via_ier_reg
 BNE maintain_counters                  ;always

.electron_game_wait_event
 PHP                                    ;only vertical sync event 4 enabled
 PHA
.maintain_counters
 DEC clk_update                         ;update clock, change triggered on -ve variable update
 DEC ai_divide_by_three                 ;divide 50hz clock by 3 for ~16hz clock, 16.667r
 BNE not_third                          ;simulates 16hz clock in arcade game used in ai
 LDA #hertz_03
 STA ai_divide_by_three
 LDA move_counter                       ;decrement move counter at ~16hz if > 0
 BEQ not_third
 DEC move_counter                       ;now decrease move counter at ~16hz
.not_third
 DEC clk_second                         ;decrement 50hz clock
 BNE event_exit_timer
 LDA #hertz_50                          ;reload second clock
 STA clk_second
 DEC clk_mode                           ;update mode clock, change triggered on -ve
 INC ai_rez_protect                     ;update aggression protect
 BNE event_exit_timer                   ;0?
 DEC ai_rez_protect                     ;reset aggression protect to &ff
.event_exit_timer
 PLA
 PLP
 RTS

.electron_columns_lsb
 EQUB LO(column_0B - &FF)               ;subtract &ff as y loaded with &ff
 EQUB LO(column_08 - &FF)
 EQUB LO(column_09 - &FF)
 EQUB LO(column_08 - &FF)
 EQUB LO(column_0A - &FF)
 EQUB LO(column_0A - &FF)
 EQUB LO(column_07 - &FF)
 EQUB LO(column_02 - &FF)
 EQUB LO(column_01 - &FF)
 EQUB LO(column_01 - &FF)
 EQUB LO(column_00 - &FF)

.electron_columns_msb
 EQUB HI(column_0B - &FF)
 EQUB HI(column_08 - &FF)
 EQUB HI(column_09 - &FF)
 EQUB HI(column_08 - &FF)
 EQUB HI(column_0A - &FF)
 EQUB HI(column_0A - &FF)
 EQUB HI(column_07 - &FF)
 EQUB HI(column_02 - &FF)
 EQUB HI(column_01 - &FF)
 EQUB HI(column_01 - &FF)
 EQUB HI(column_00 - &FF)

.electron_key_mask
 EQUB (&08 << &01)                      ;x
 EQUB (&02 << &01)                      ;t
 EQUB (&02 << &01)                      ;r
 EQUB (&08 << &01)                      ;b
 EQUB (&08 << &01)                      ;c
 EQUB (&04 << &01)                      ;d
 EQUB (&08 << &01) + &01                ;n
 EQUB (&02 << &01) + &01                ;up
 EQUB (&02 << &01) + &01                ;down
 EQUB (&01 << &01) + &01                ;left
 EQUB (&01 << &01) + &01                ;right

.electron_keyboard
 LDA #&08                               ;select keyboard rom 8
 STA electron_romsel
 LDA game_mode
 BEQ read_rest_electron_keyboard
 LDX #electron_columns_msb - electron_columns_lsb - &01
.electron_read_keys
 LDA electron_columns_lsb,X
 STA workspace
 LDA electron_columns_msb,X
 STA workspace + &01
 LDA electron_key_mask,X                ;bit 0 = debounce into carry
 LSR A
 AND (workspace),Y
 BEQ clear_electron_key                 ;y=&ff
 LDA combined_block_start,X
 BCS no_electron_debounce
 BMI clear_electron_key                 ;if pressed last time then not pressed
 ASL A                                  ;check debounce flag
 BMI electron_debounce_end
.no_electron_debounce
 STY combined_block_start,X             ;set key pressed/debounce flags
 BPL electron_debounce_end              ;always
.clear_electron_key
 LSR combined_block_start,X             ;key not pressed, second pass clears debounce flag
.electron_debounce_end
 DEX
 BPL electron_read_keys

.read_rest_electron_keyboard            ;read individually for speed
 read_electron_key column_0C, &04       ;a
 store_unbounced_electron combined_a
 read_electron_key column_0C, &08       ;z
 store_unbounced_electron combined_z
 read_electron_key column_05, &04       ;k
 store_unbounced_electron combined_k
 read_electron_key column_06, &08       ;m
 store_unbounced_electron combined_m
 read_electron_key column_0D, &01       ;escape
 store_unbounced_electron combined_escape
 read_electron_key column_00, &08       ;space
 store_unbounced_electron combined_space

 LDA #&0C                               ;deselect basic
 STA electron_romsel
 LDA paged_rom                          ;restore sideways ram
 STA electron_romsel
 PLP                                    ;restore irq status
 RTS

.read_keyboard
 LDY #&FF                               ;key reset, y=&ff
 PHP
 SEI
 BIT machine_flag
 BMI electron_keyboard
 LDA #&7F                               ;system via port a data direction register a
 STA sheila + &43                       ;bottom 7 bits are outputs and the top bit is an input
 LDA #&0F
 STA sheila + &42                       ;allow write to addressable latch
 LDA #&03
 STA sheila + &40                       ;set bit 3 to 0
 LDA game_mode                          ;game mode
 BEQ bbc_00_main_game                   ;read all keys after here
 LDX #bbc_key_values_end - bbc_key_values - &01
.bbc_read_keys
 LDA bbc_key_values,X                   ;bit 0 = debounce into carry
 LSR A
 STA sheila + &4F
 LDA sheila + &4F
 BPL clear_key
 LDA combined_block_start,X
 BCS no_bbc_debounce                    ;c=1 do not debounce key
 BMI clear_key                          ;if pressed last time clear bit 7
 ASL A                                  ;check bit 6
 BMI debounce_end                       ;debounce
.no_bbc_debounce
 STY combined_block_start,X             ;set key pressed flag and debounce flag
 BPL debounce_end                       ;always
.clear_key
 LSR combined_block_start,X             ;key not pressed, second pass clears debounce flag
.debounce_end
 DEX
 BPL bbc_read_keys

.bbc_00_main_game                       ;read individually for speed
 read_key_bbc bbc_a_key
 store_unbounced_bbc combined_a
 read_key_bbc bbc_z_key
 store_unbounced_bbc combined_z
 read_key_bbc bbc_k_key
 store_unbounced_bbc combined_k
 read_key_bbc bbc_m_key
 store_unbounced_bbc combined_m
 read_key_bbc bbc_escape
 store_unbounced_bbc combined_escape
 read_key_bbc bbc_space
 store_unbounced_bbc combined_space
 read_key_bbc bbc_f_key
 debounce_bbc_key combined_f

 PLP                                    ;restore irq status
 RTS

.bbc_key_values
 EQUB bbc_x_key        << &01
 EQUB bbc_t_key        << &01
 EQUB bbc_r_key        << &01
 EQUB bbc_b_key        << &01
 EQUB bbc_c_key        << &01
 EQUB bbc_d_key        << &01
 EQUB (bbc_n_key       << &01) + &01    ;do not debounce keys with bit 0 = 1
 EQUB (bbc_arrow_up    << &01) + &01
 EQUB (bbc_arrow_down  << &01) + &01
 EQUB (bbc_arrow_left  << &01) + &01
 EQUB (bbc_arrow_right << &01) + &01
.bbc_key_values_end

.battlezone_sprites
 INCBIN  "battlezone sprites.bin"

.bzone3_end
 SAVE "bzone3", bzone3,                 &3000,                bzone3 + host_addr,                 bzone3_loaded_at_host
 SAVE "bz0",    service_block_start,    service_block_end,    service_block_start    + host_addr, service_block_start    + host_addr
 SAVE "bz1",    service_block_start,    service_block_end,    service_block_start    + host_addr, service_block_start    + host_addr
 SAVE "bz2",    high_scores_save_start, high_scores_save_end, high_scores_save_start + host_addr, high_scores_save_start + host_addr
 SAVE "bz3",    high_scores_save_start, high_scores_save_end, high_scores_save_start + host_addr, high_scores_save_start + host_addr

 ORG   &8000
 CLEAR &8000, &BFFF
 GUARD &C000

.bzone2

.sine_table_128_lsb                     ;<--- aligned on a page boundary for access speed
 FOR angle, 0, &7F                      ;sine table &00 - &7f, half wave &00 - &ff
   EQUB LO(sine_peak * SIN(angle * 2 * PI / 256))
 NEXT

.sine_table_128_msb
 FOR angle, 0, &7F                      ;sine table &00 - &7f, half wave &00 - &ff
   EQUB HI(sine_peak * SIN(angle * 2 * PI / 256))
 NEXT

.sine_table_512_lsb                     ;<--- aligned on a page boundary for access speed
 FOR angle, 0, &7F                      ;sine table &00 - &7f, quarter wave &00 - &1ff
   EQUB LO(sine_peak * SIN(angle * 2 * PI / 512))
 NEXT

.sine_table_512_msb
 FOR angle, 0, &7F                     ;sine table &00 - &7f, quarter wave &00 - &1ff
   EQUB HI(sine_peak * SIN(angle * 2 * PI / 512))
 NEXT

 INCLUDE "radar.asm"                    ;<--- aligned on a page boundary for access speed

.cosine_512                             ;entry :- x/a 9-bit angle, x = top 8 bits/a = bottom bit in bit 7
 ASL A                                  ;exit  :- y/a lsb/msb trig value
 TXA                                    ;put top bit y into bottom bit x
 ROL A
 TAX
 ROL A
 AND #&01
 TAY                                    ;x/y - full 9 bit value
 TXA                                    ;add in quarter value for cosine
 CLC
 ADC #LO(sine_quarter_512)
 TAX
 TYA
 ADC #&00
 BEQ first_half_512                     ;still in range
 TAY
 TXA
 SEC
 SBC #LO(sine_full_512)                 ;c=1, bring into range
 TAX
 TYA
 SBC #HI(sine_full_512)
 BNE second_half_512
.first_half_512
 TXA                                    ;if in second quarter then invert into first
 BPL not_negative_512_00
 EOR #&FF
 TAX
.not_negative_512_00
 LDA sine_table_512_msb,X
 LDY sine_table_512_lsb,X
 RTS

.sine_512                               ;entry :- x/y 9-bit angle, x = top 8 bits/y = bottom bit in bit 7
 ASL A                                  ;exit  :- y/a lsb/msb trig value
 TXA                                    ;put top bit y into bottom bit x
 ROL A
 TAX
 BCC first_half_512                     ;carry contains top bit
.second_half_512
 TXA                                    ;if in second quarter then invert into first
 BPL not_negative_512_01
 EOR #&FF
 TAX
.not_negative_512_01
 LDA #&00
 SEC
 SBC sine_table_512_lsb,X
 TAY
 LDA #&00
 SBC sine_table_512_msb,X
 RTS

; common sprite routine for multiple row based sprite operations
; + 00 screen address offset
; + 02 sprite address
; + 04 number of rows
; + 05 number of bytes

.multiple_row_sprite                    ;works at row level
 STX sprite_work
 STY sprite_work + &01
 LDY #&00
 LDA (sprite_work),Y                    ;screen address
 STA fast_store + &01
 INY
 LDA (sprite_work),Y
 CLC
 ADC screen_hidden
 STA fast_store + &02
 INY
 LDA (sprite_work),Y                    ;sprite address
 STA fast_load + &01
 INY
 LDA (sprite_work),Y
 STA fast_load + &02
 INY
 LDA (sprite_work),Y                    ;number of rows
 TAX
 INY
 LDA (sprite_work),Y                    ;number of bytes in row
 STA fast_add + &01
 TAY
 STY fast_bytes + &01
.fast_bytes
 LDY #&00
.fast_load
 LDA fast_load,Y
.fast_store
 STA fast_store,Y
 DEY
 BNE fast_load
 LDA fast_store + &01                   ;next screen row
 CLC
 ADC #LO(screen_row)
 STA fast_store + &01
 LDA fast_store + &02
 ADC #HI(screen_row)
 STA fast_store + &02
 LDA fast_load + &01
.fast_add
 ADC #&00
 STA fast_load + &01
 BCC fast_no_inc
 INC fast_load + &02
.fast_no_inc
 DEX
 BNE fast_bytes
 RTS

.game_mode_select
 EQUW main_game_mode
 EQUW main_attract_mode
 EQUW high_score_mode
 EQUW service_menu
 EQUW new_high_score_mode
 EQUW battlezone_text_mode
 EQUW model_test_mode
.game_mode_select_end

.that_game_mode
 LDA new_game_mode
 EQUB bit_op
.this_game_mode
 LDA game_mode                          ;vector to mode routine
 ASL A                                  ;c=0
 ADC #LO(game_mode_select)
 STA game_vector + &01
.game_vector
 JMP (game_mode_select)

 IF (game_mode_select >> 8) <> (game_mode_select_end >> 8)
   ;PRINT ~game_mode_select, ~game_mode_select_end
   ERROR ">>>> game vector table across two pages"
 ENDIF

.main_program_start
 JSR game_initialisation                ;set up
.game_loop
 JSR read_keyboard                      ;read keys according to mode
 JSR mathbox_random_number
;                                       <--- game start block
 LSR b_object_bounce_far                ;>> 1
 LSR b_object_bounce_near               ;>> 1
 BIT tracks_active                      ;is unit moving?
 BMI no_track_move                      ;no
 INC track_exhaust_index                ;update track/exhaust index
 LDA track_exhaust_index
 AND #&03
 STA track_exhaust_index
.no_track_move
 LDA object_radar_rotation              ;update tank radar internal rotation
 ADC #object_radar_spin
 STA object_radar_rotation
 LDX explosion                          ;animate explosion
 BMI exit_game_block
 INX
 STX explosion                          ;next explosion frame
 CPX #object_x1E_explosion_03 + &01
 BCC exit_game_block
 ROR explosion                          ;c=1, this explosion now done
.exit_game_block
;                                       <--- game end block
 JSR sound_control                      ;scan for sounds to make
 JSR this_game_mode
 JSR mathbox_toggle_activated
 JSR flip_screen
 JSR change_mode_now
;                                       <--- timer start block
 BIT clk_update                         ;clock used to smooth on screen effects
 BPL game_loop                          ;not yet
 INC radar_arm_position                 ;update radar arm
 LDA radar_arm_position
 AND #(number_of_sectors - &01)
 STA radar_arm_position
 DEC console_sights_flashing            ;maintain flashing sights
 DEC console_press_start_etc            ;maintain flashing attract text
 LDA #counter_refresh                   ;ready for next time
 STA clk_update
;                                       <--- timer end block
 BNE game_loop                          ;always

.flip_screen
 JSR print_variables
 LDA #19
 JSR osbyte
 LDA screen_hidden
 EOR #&68
 STA screen_hidden
 EOR #&68
 LSR A
 BIT machine_flag
 BPL bbc_screen_flip
 STA sheila + &03
.exit_function
 RTS

.bbc_screen_flip                        ;screen change
 LDX #x6845_r12
 STX sheila
 LSR A
 LSR A
 STA sheila + &01
 BIT mathbox_flag                       ;mathbox present?
 BVC exit_function
 LDA screen_hidden
 STA host_r0                            ;ready for mathbox
 LDA #mathbox_code_screen_address       ;write screen address to mathbox
 JMP mathbox_function_a_only

.in_playing_game
 JSR sound_tchaikovsky
 JSR sound_engine_missile_control       ;engine/missile sound
 JSR my_projectile
 JSR enemy_projectile
 JSR object_render
 JSR orientation                        ;maintain messages
 JSR radar_spot
 BIT m_tank_status                      ;player dead?
 BPL exit_function                      ;no
 JSR clear_rest_of_space                ;player dying, clear radar/score/high score/tanks
 JSR crack_screen_open
 LDA crack_counter
 CMP #end_the_crack
 BCC exit_routine                       ;delay before leaving crack
 DEC game_number_of_tanks
 BEQ last_tank_gone                     ;no tanks left
 LDX #&00                               ;reinitialise for new tank
 STX crack_counter
 STX m_tank_status
 JSR reset_refresh
 JSR clear_all_screen
 JSR flip_screen
 JSR clear_all_screen
 JMP create_tank                        ;create tank after being shot

.last_tank_gone
 JMP test_for_new_high_score            ;check if a high score

.main_game_mode                         ;play game
 JSR movement_keys
 BIT combined_escape                    ;check for escape, exit to attract
 BMI switch_to_attract

.main_attract_mode                      ;common code for main game/attract mode
 JSR object_view_rotate_angles          ;player rotation angles
 JSR clear_play_area
 JSR moon
 JSR tank_sights
 JSR landscape
 JSR horizon
 JSR volcano
 JSR animate_debris
 JSR update_saucer
 JSR update_enemy_unit
 JSR animate_exhaust                    ;after update enemy unit to copy over coordinates
 JSR status_messages
 JSR radar
 JSR print_player_score
 LDA new_game_mode
 BEQ in_playing_game                    ;playing game, different code path
 JSR game_over_copyright_and_start      ;attract mode from here
 JSR attract_movement
 JSR start_coins                        ;add coins
 JSR object_render
 JSR orientation                        ;maintain messages
 JSR radar_spot
 LDA clk_mode                           ;time to switch?
 BMI switch_to_high_score
.test_exit_keys
 BIT combined_b                         ;test keys while in attract mode
 BMI check_coins                        ;check enough coins to play game
 BIT combined_r
 BMI switch_to_model                    ;enter model mode
 BIT combined_x
 BMI switch_to_service                  ;enter service mode
.exit_routine
 RTS

.battlezone_text_mode                   ;battlezone text mode
 JSR clear_play_area
 JSR moon
 JSR landscape
 JSR horizon
 JSR radar
 JSR volcano
 JSR print_player_score
 LDX #LO(copyright)
 LDY #HI(copyright)
 JSR print
 BIT text_counter                       ;pause before text displayed
 BMI no_start_text_yet
 JSR battlezone_text
.no_start_text_yet
 DEC text_counter
 BNE test_exit_keys                     ;timed section not finished, if so switch to attract below

.switch_to_attract                      ;switch tree, all game mode switching occurs here
 LDA #mode_01_attract_mode
 EQUB bit_op
.switch_to_game
 LDA #mode_00_main_game
 EQUB bit_op
.switch_to_high_score
 LDA #mode_02_high_score_table
 EQUB bit_op
.switch_to_service
 LDA #mode_03_service_menu
 EQUB bit_op
.switch_to_new_high_score
 LDA #mode_04_new_high_score
 EQUB bit_op
.switch_to_battlezone_text
 LDA #mode_05_battlezone_text
 EQUB bit_op
.switch_to_model
 LDA #mode_06_model_test
 STA new_game_mode
 RTS

.model_test_mode
 BIT combined_escape
 BMI switch_to_attract
 JSR clear_play_area
 JMP model_display

.high_score_mode                        ;display high score table
 JSR clear_play_area
 JSR print_player_score
 JSR print_high_scores_table
 LDA clk_mode
 BMI switch_to_battlezone_text
 BPL test_exit_keys                     ;always

.check_coins                            ;enough coins to play?
 LDX coins_amount
 LDA coins_added
 SEC
 SBC coins_required,X
 BCC exit_routine                       ;insufficent funds
 STA coins_added                        ;use coins for game
 BCS switch_to_game                     ;always

.coins_required
 EQUB &00
 EQUB &01
 EQUB &02
 EQUB &04

.change_mode_now
 LDA game_mode
 EOR new_game_mode
 BNE change_mode
.exit_change                            ;exit here if no initialisation
 RTS

.change_mode
 JSR reset_volcano
 JSR reset_refresh
 JSR new_game_switch                    ;any initialisation to be done
 JSR clear_all_screen
 PHP
 SEI                                    ;set timer
 LDX new_game_mode
 LDA #hertz_50                          ;50hz timer
 STA clk_second
 LDA time_out,X                         ;timer for mode shift etc
 STA clk_mode
 PLP                                    ;restore irq status
 JSR that_game_mode
 LDA new_game_mode
 STA game_mode
 JSR mathbox_toggle_activated
 JSR flip_screen
 JSR sound_gate_mode                    ;set sound enabled/disabled according to mode
 JMP clear_all_screen

.new_game_switch
 LDA new_game_mode                      ;vector to change routine
 ASL A                                  ;c=0
 ADC #LO(change_type)
 STA change_vector + &01
.change_vector
 JMP (change_type)

.change_type
 EQUW change_00                         ;0 main game
 EQUW change_01                         ;1 attract mode
 EQUW exit_change                       ;2 high score table
 EQUW exit_change                       ;3 service menu
 EQUW exit_change                       ;4 new high score
 EQUW change_05                         ;5 battlezone text
 EQUW change_06                         ;6 model test
.change_type_end

 IF (change_type >> 8) <> (change_type_end >> 8)
   ;PRINT ~change_type, ~change_type_end
   ERROR ">>>> change vector table across two pages"
 ENDIF

.change_00                              ;00 main game
 LDA service_number_of_tanks            ;set up game variables
 STA game_number_of_tanks
 LDX #&01
 STX ai_divide_by_three
 STX saucer_time_to_live
 DEX                                    ;x=&00
 STX move_counter
 STX saucer_dying
 STX bonus_coins_tab                    ;clear bonus coins tabs as playing game
 STX m_tank_status
 STX player_score                       ;clear scores
 STX player_score + &01
 STX enemy_score
 STX extra_tank
 STX hundred_thousand
 STX ai_rez_protect                     ;protect from aggression at game start
 STX tank_or_super_or_missile_x         ;place player at 0,0
 STX tank_or_super_or_missile_x + &01
 STX tank_or_super_or_missile_y
 STX tank_or_super_or_missile_y + &01   ;clear workspace
 STX tank_or_super_or_missile_workspace_x
 STX tank_or_super_or_missile_workspace_x + &01
 STX tank_or_super_or_missile_workspace_z
 STX tank_or_super_or_missile_workspace_z + &01
 STX sound_music                        ;disable music
 STX m_tank_rotation                    ;player looking directly forward
 STX m_tank_rotation + &01
 STX m_tank_rotation_512
 STX m_tank_rotation_512 + &01
 DEX                                    ;x=&ff
 STX saucer
 STX missile_count
.create_new_tank
 JSR create_tank                        ;spawn a tank
 JMP graphics_origin_game

.change_01                              ;01 attract mode
 LDX #&01
 STX ai_divide_by_three
 STX saucer_time_to_live
 DEX                                    ;x=&00
 STX move_counter
 STX saucer_dying
 STX game_number_of_tanks               ;don't display tanks on panel
 STX player_score
 STX player_score + &01
 STX clk_update                         ;initialise on game entry
 STX b_object_bounce_near
 STX b_object_bounce_far
 STX frame_counter                      ;attract change counter
 STX m_tank_status
 STX on_target
 STX crack_counter
 STX sound_music                        ;disable music
 STX m_tank_rotation                    ;player looking directly forward
 STX m_tank_rotation + &01
 STX m_tank_rotation_512
 STX m_tank_rotation_512 + &01
 DEX                                    ;x=&ff
 STX missile_count
 LDA tank_or_super_or_missile           ;going into attract from game?
 BMI create_new_tank                    ;dead, create a standard tank
 CMP #object_x07_missile                ;if missile then replace with standard tank
 BEQ create_new_tank                    ;not present in arcade as no way to abort a game
 JMP graphics_origin_game

.change_05                              ;05 battlezone text
 LDX #&00
 STX object_relative_x
 STX object_relative_x + &01
 STX object_relative_z
 LDA #HI(text_initial_z)
 STA object_relative_z + &01
 LDA #LO(text_initial_y)
 STA object_relative_y
 LDA #HI(text_initial_y)
 STA object_relative_y + &01
 LDA #text_frames                       ;frame counter
 STA text_counter
 JSR tank_random
 JMP graphics_origin_text

.change_06                              ;06 model test
 LDA #&70                               ;set up model x/y/z rotations
 STA y_object_rotation
 LDA #&00
 STA tracks_active
 STA x_object_rotation
 STA z_object_rotation
 STA object_relative_x
 STA object_relative_x + &01
 STA object_relative_y
 STA object_relative_y + &01
 STA model_identity
 LDA #LO(model_z_coordinate)
 STA object_relative_z
 LDA #HI(model_z_coordinate)
 STA object_relative_z + &01
 LDA #object_x00_narrow_pyramid         ;initial object
 STA i_object_identity
 JMP graphics_origin_game

.tank_random                            ;place somewhere in battlefield with random rotation in the landscape
 JSR mathbox_random_number              ;used to create positions after the first one generated
 LDA mathbox_random                     ;x/z low populate
 STA m_tank_x
 LDA mathbox_random + &01
 STA m_tank_z
 LDA mathbox_random + &02               ;x/z high populate
 STA m_tank_x + &01
 LDA mathbox_random + &03
 AND #&3F                               ;limit z axis
 STA m_tank_z + &01
 LDX #block_size                        ;check player not inside a geometrical object
 JSR object_collision_test
 BCS tank_random                        ;try again
 LDA #&00
 STA recent_collision_flag              ;clear collision flag
 LDA mathbox_random + &04
 STA m_tank_rotation_512 + &01          ;random rotation
 LDA m_tank_rotation_512                ;multiply by 2.5
 ASL A
 LDA m_tank_rotation_512 + &01
 ROL A
 STA m_tank_rotation
 ROL A
 AND #&01
 ASL m_tank_rotation
 ROL A
 TAX
 LDA m_tank_rotation_512 + &01          ;calculate 0.5 then add in
 CLC
 ADC m_tank_rotation
 STA m_tank_rotation
 TXA
 ADC #&00
 STA m_tank_rotation + &01              ;&00 - &4ff
 RTS

.time_out
 EQUB &00                               ;main game        = 0     used to control tank engine sound
 EQUB &10                               ;attract mode     = 1  16 seconds
 EQUB &08                               ;high score table = 2  08 seconds
 EQUB &00                               ;service menu     = 3   0 not used, set up for use in disc error message
 EQUB &3C                               ;new high score   = 4  60 seconds
 EQUB &00                               ;battlezone text  = 5   0 not used, frame counter used instead
 EQUB &00                               ;test models      = 6   0 not used

 INCLUDE "models.asm"
 INCLUDE "reticule.asm"
 INCLUDE "linedraw.asm"
 INCLUDE "render.asm"
 INCLUDE "animate.asm"
 INCLUDE "landscape.asm"

.bzone2_end
 SAVE "bzone2", bzone2, &C000, bzone2 + host_addr, bzone2_loaded_at_host

; system via on the bbc has multiple interrupts suppressed in order
; to make the machine as fast as possible on the atari logo display
; to prevent colour jumps
;
; configuration
; bit 0 = 1 a key has been pressed
; bit 1 = 1 vertical synchronisation has occurred on the video system (a 50hz time signal)
; bit 2 = 1 the system via shift register times out
; bit 3 = 1 a light pen strobe off the screen has occurred
; bit 4 = 1 the analogue converter has finished a conversion
; bit 5 = 1 timer 2 has timed out used for the speech system
; bit 6 = 1 timer 1 has timed out this timer provides the 100hz signal for the internal clocks
; bit 7 = 1 the system via was the source of the interrupt

 INCLUDE "atari logo.asm"

 ORG   &9000
 CLEAR &9000, &EFFF
 GUARD &F000

.bzone4                                 ;import file to save it to disk
 INCBIN "C:\Program Files (x86)\RPCEmu\hostfs\Mathbox\bzarm,10e38-10e38"

.bzone4_end
 SAVE "bzone4", bzone4, bzone4_end, bzone4, bzone4

 ORG   &0400
 CLEAR &0400, &07FF
 GUARD &0800

.bzone5
 INCLUDE "page four.asm"                ;variable declarations/code for pages &04-&07

.bzone5_end
 SAVE "bzone5", bzone5, &07FF, bzone5 + host_addr, bzone5_loaded_at_host

 PUTTEXT "credits.txt", "credits", &0000, &0000
 PUTTEXT "notes.txt",   "notes",   &0000, &0000
 PUTTEXT "readme.txt",  "readme",  &0000, &0000

 bz_limit     = &0B00
 bzone0_limit = &3000
 bzone1_limit = &0D00
 bzone2_limit = &C000
 bzone3_limit = &3000
 bzone4_limit = &D000
 bzone5_limit = &0800

 total_free_space = (bzone1_limit - bzone1_end) + (bzone2_limit - bzone2_end) + (bzone3_limit - bzone3_end) + (bzone5_limit - bzone5_end)

 PRINT "          >      <      |      ><"
 PRINT " bz     :", ~bz    , " ", ~bz_end    , " ", ~bz_limit
 PRINT " bzone0 :", ~bzone0, "" , ~bzone0_end, "" , ~bzone0_limit
 PRINT " bzone1 :", ~bzone1, " ", ~bzone1_end, " ", ~bzone1_limit, " " , bzone1_limit - bzone1_end
 PRINT " bzone2 :", ~bzone2, "" , ~bzone2_end, "" , ~bzone2_limit, ""  , bzone2_limit - bzone2_end
 PRINT " bzone3 :", ~bzone3, " ", ~bzone3_end, "" , ~bzone3_limit, ""  , bzone3_limit - bzone3_end
 PRINT " bzone4 :", ~bzone4, "" , ~bzone4_end, "" , ~bzone4_limit, ""
 PRINT " bzone5 :", ~bzone5, " ", ~bzone5_end, " ", ~bzone5_limit, " " , bzone5_limit - bzone5_end
 PRINT "                              ",  total_free_space
 PRINT "            >     <"
 PRINT " scores   :",  ~high_scores_save_start, ~high_scores_save_end
 PRINT " settings :",  ~service_block_start,    ~service_block_end
