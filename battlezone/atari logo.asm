 ORG   &2000
 CLEAR &2000, &2FFF
 GUARD &3000
 
; atari logo
; ----------
; achieved with four frames of animation moving the horizontal
; tubes down screen with screen interrupts held in lock step to
; keep their colour as they move
;
; gap of four scan lines to accomodate colour change timing interrupt
; 256 frames of moving tubes
;
; logical colour, lc, colour value then program all possible
; values x, palette bits being the physical colour eor all bits set
;
; mode       bit 7  bit 6  bit 5  bit 4
; -------------------------------------
; 02 colour  lc     x      x      x
;            bit 0
; -------------------------------------
; 04 colour  lc     x      lc     x
;            bit 1         bit 0
; -------------------------------------
; 16 colour  lc     lc     lc     lc
;            bit 3  bit 2  bit 1  bit 0
; -------------------------------------
; lc = logical colour

 INCLUDE "atari logo sprites.bin.info"  ;logo sprites info

; colour bytes for 6845
MACRO mode_colour_values_2_bits_per_pixel logical_colour, physical_colour
 IF logical_colour = 0
  byte = &00
 ELSE
  byte = &80
 ENDIF
 LDA #byte + &00 + (physical_colour EOR &07)
 STA sheila + &21
 LDA #byte + &10 + (physical_colour EOR &07)
 STA sheila + &21
 LDA #byte + &20 + (physical_colour EOR &07)
 STA sheila + &21
 LDA #byte + &30 + (physical_colour EOR &07)
 STA sheila + &21
 LDA #byte + &40 + (physical_colour EOR &07)
 STA sheila + &21
 LDA #byte + &50 + (physical_colour EOR &07)
 STA sheila + &21
 LDA #byte + &60 + (physical_colour EOR &07)
 STA sheila + &21
 LDA #byte + &70 + (physical_colour EOR &07)
 STA sheila + &21
 LDA interrupt_accumulator
 RTI
ENDMACRO

 black                                  = &00
 red                                    = &01
 green                                  = &02
 yellow                                 = &03
 blue                                   = &04
 magenta                                = &05
 cyan                                   = &06
 white                                  = &07

; build variable
 atari_display                          = FALSE  ;loop control, use to display full logo

; atari constants
 atari_claim_id                         = &28
 atari_screen_row                       = &140
 atari_row                              = &1F0
 atari_timer                            = &EE8

; atari page zero
 atari_colour_copy                      = &90    ;&00 - &7F used by second processor initially
 atari_interrupt_flag                   = &91
 atari_invert                           = &92
 atari_work                             = &93

;atari addresses
 atari_logo_screen_address              = atari_screen_row * 8 + &68
 atari_text_screen_address              = atari_screen_row * 21 + &60

; envelope data
; n is the envelope number
; t is the length of each step in 1/100ths of a second
; pi1, pi2 and pi3 are the changes in pitch per step during sections 1, 2 and 3
; pnl, pn2 and pn3 are the number of steps in sections 1, 2 and 3 respectively
; aa is the rate of change of amplitude during the attack phase
; ad is the rate of change of amplitude during the decay phase
; as is the rate of change of amplitude during the sustain phase
; ar is the rate of change of amplitude during the release phase
; ala is the target amplitude for the attack phase
; ald is the target amplitude for the decay phase

MACRO atari_logo_envelope n, t, pi1, pi2, pi3, pn1, pn2, pn3, aa, ad, as, ar, ala, ald
 EQUB n
 EQUB t
 EQUB pi1
 EQUB pi2
 EQUB pi3
 EQUB pn1
 EQUB pn2
 EQUB pn3
 EQUB aa
 EQUB ad
 EQUB as
 EQUB ar
 EQUB ala
 EQUB ald
ENDMACRO

.bzone0
 JSR atari_logo_machine_test
 JSR atari_logo_clear_screens
 JSR atari_logo_set_mode_four_and_cursor_off
 JSR atari_logo_flush_sound_buffers
 JSR atari_logo_common                  ;common to bbc/electron set up calls
 JSR atari_logo_bbc_or_electron
 JSR atari_logo_set_screen_hidden       ;game specific set up <--- start
 JSR atari_logo_set_up_envelopes        ;game specific set up <--- end
 JSR atari_logo_atari_logo_demo
 JSR atari_logo_find_swr_ram_slot
 PHP
 SEI
 LDX found_a_slot
 BIT machine_flag
 BMI atari_logo_select_electron
 STX paged_rom
 STX bbc_romsel
 PLP                                    ;restore irq status
 RTS
.atari_logo_select_electron
 CPX #&08
 BCS atari_logo_just_select_swr
 LDA #&0C                               ;de-select basic
 STA paged_rom
 STA electron_romsel
.atari_logo_just_select_swr
 STX paged_rom
 STX electron_romsel
 PLP                                    ;restore irq status
 RTS

 EQUS "bbc b,b+, master 128/arm tdmi/1ghz pi copro/electron - battlezone © 1980 atari inc."
 EQUS "version assembled on "
 EQUS TIME$

.atari_logo_set_screen_hidden
 LDA #&30                               ;screen address
 STA screen_hidden
 RTS

.atari_logo_set_mode_four_and_cursor_off
 LDA #&90                               ;turn interlace on
 LDX #&00
 LDY #&00
 JSR osbyte
 LDX #&00
.vdu_bytes
 LDA vdu_codes,X
 JSR oswrch
 INX
 CPX #vdu_codes_end - vdu_codes
 BNE vdu_bytes
 RTS

.vdu_codes
 EQUB 22                                ;set mode 4
 EQUB 4
 EQUB 23                                ;turn cursor off
 EQUB 1
 EQUD &00
 EQUD &00
.vdu_codes_end

.atari_logo_clear_screens
 LDA #HI(screen_start)
 STA clear_screen + &02
 LDA #&00
 TAX
.clear_screen
 STA screen_start,X
 DEX
 BNE clear_screen
 INC clear_screen + &02
 BPL clear_screen
 RTS

.atari_logo_bbc_or_electron
 BIT machine_flag
 BMI atari_logo_electron_only               ;bbc specific
 LDA #16                                ;adc off
 LDX #&00
 LDY #&00
 JSR osbyte
 LDA #181                               ;rs423 off
 LDX #&00
 LDY #&00
 JSR osbyte
 LDA #201                               ;disable keyboard
 LDX #&00
 LDY #&00
 JMP osbyte

.atari_logo_electron_only                   ;electron specific
 LDA #163                               ;disable adc on plus 1
 LDX #&80
 LDY #&01
 JSR osbyte
 LDA #163
 LDX #&80
 LDY #&00
 JSR osbyte
 LDA #&00
 STA electron_plus_1_rom               ;disable plus 1 rom in table
 LDA #178                              ;disable keyboard scanning
 LDX #&00
 LDY #&00
 JSR osbyte
 LDA #178
 LDX #&FF
 LDY #&00
 JSR osbyte
 RTS

.atari_logo_common
 LDA #&09                               ;flashing colour 0
 LDX #&00
 LDY #&00
 JSR osbyte
 LDA #&0A                               ;flashing colour 1
 LDX #&00
 LDY #&00
 JMP osbyte

; some return values for machine type
; x = &00 bbc a/b with os 0.10
; x = &01 acorn electron os
; x = &f4 master 128 mos 3.26
; x = &f5 master compact mos 5
; x = &fb bbc b+ 64/128 (os 2.00)
; x = &fc bbc micro (west german mos)
; x = &fd master 128 mos 3.20/3.50
; x = &fe bbc micro (american os a1.0)
; x = &ff bbc micro os 1.00/1.20/1.23

.atari_logo_machine_test
 SED                                    ;bbc model a/b and electron use 6502, b+ and master use 65c02
 LDA #&20                               ;processor check
 SEC
 SBC #&0F                               ;result &1B on the 6502 or &0B on a 65c02
 CLD
 EOR #&1B                               ;a=0 6502 else 65c02 reflected in z flag
 LDA #&81                               ;which machine are we running on?
 LDX #&00
 LDY #&FF
 STX machine_flag                       ;clear machine type flag
 JSR osbyte
 CPX #&01                               ;if x=1 electron else other machines
 BNE atari_logo_not_electron
 SEC                                    ;ignore tube flag as this is an electron
 ROR machine_flag                       ;set bit 7 for electron
.atari_logo_not_electron
 LDA #&83                               ;read os high water mark
 JSR osbyte
 CPY #HI(page)                          ;page must be at &0e00 to activate disk use for save/load
 BNE atari_no_disk_access               ;primarily for &0e00 dfs disk systems
 LDA machine_flag                       ;bit 7 machine type/bit 6 disk enabled
 ORA #&40                               ;enable disk use
 STA machine_flag
.atari_no_disk_access
 RTS

.atari_logo_find_swr_ram_slot
 BIT machine_flag
 BMI atari_logo_find_electron_swr_ram_slot
 LDX #&0D
.atari_logo_bbc_swr_loop
 STX bbc_romsel
 LDA bzone2
 INC bzone2
 CMP bzone2
 BEQ atari_logo_next_slot
 LDY #swr_test_end - swr_self_write_test - &01
.transfer_test
 LDA swr_self_write_test,Y
 STA bzone2,Y
 DEY
 BPL transfer_test
 JSR bzone2                             ;z = result
 BNE atari_logo_found_a_swr_slot
.atari_logo_next_slot
 DEX
 BPL atari_logo_bbc_swr_loop
 LDA paged_rom                          ;restore basic
 STA bbc_romsel
.atari_logo_brk
 BRK
 EQUB &FF
 EQUS "sideways ram bank not found", &00
.atari_logo_found_a_swr_slot
 STX found_a_slot
 RTS

.swr_self_write_test                    ;try to increment memory
 INC bzone2 + (swr_test_location - swr_self_write_test)
 LDA bzone2 + (swr_test_location - swr_self_write_test)
 RTS                                    ;z = 1 no change z = 0 can use

.swr_test_location
 EQUB &00
.swr_test_end

.atari_logo_find_electron_swr_ram_slot
 LDX #&0D
.atari_logo_swr_electron_loop
 CPX #&08
 BCS atari_logo_just_select_rom
 LDA #&0C                               ;de-select basic
 STA electron_romsel
.atari_logo_just_select_rom
 STX electron_romsel                    ;now select rom
 LDA bzone2
 INC bzone2
 CMP bzone2
 BNE atari_logo_found_a_swr_slot
 DEX
 BPL atari_logo_swr_electron_loop
 LDA paged_rom                          ;restore basic
 STA electron_romsel
 JMP atari_logo_brk

.atari_logo_flush_sound_buffers
 LDX #&04                               ;clear out all sounds
.atari_logo_flush_all_sounds
 TXA
 PHA
 LDA #21
 JSR osbyte
 PLA
 TAX
 INX
 CPX #&08
 BNE atari_logo_flush_all_sounds
 RTS

.atari_logo_set_up_envelopes                ;sound atari_logo_envelopes
 LDY atari_logo_envelope_index
 LDX atari_logo_envelope_data_address_start,Y
 LDA atari_logo_envelope_data_address_start + &01,Y
 INY
 INY
 STY atari_logo_envelope_index
 TAY
 LDA #&08                               ;define an atari_logo_envelope
 JSR osword
 DEC atari_logo_envelope_counter
 BNE atari_logo_set_up_envelopes
 RTS

.atari_logo_envelope_counter
 EQUB (atari_logo_envelope_data_address_end - atari_logo_envelope_data_address_start) DIV 2
.atari_logo_envelope_index
 EQUB &00
.atari_logo_envelope_data_address_start
 EQUW atari_logo_envelope_01
 EQUW atari_logo_envelope_02
 EQUW atari_logo_envelope_03
 EQUW atari_logo_envelope_04
 EQUW atari_logo_envelope_05
 EQUW atari_logo_envelope_06
 EQUW atari_logo_envelope_07
 EQUW atari_logo_envelope_08
 EQUW atari_logo_envelope_09
 EQUW atari_logo_envelope_10
.atari_logo_envelope_data_address_end

.atari_logo_envelope_01
 atari_logo_envelope 1,1,1,0,0,18,0,0,126,0,0,-32,126,0     ;* enemy alert
.atari_logo_envelope_02
 atari_logo_envelope 2,1,0,0,0,0,0,0,64,-32,0,0,64,0        ;* enemy radar
.atari_logo_envelope_03
 atari_logo_envelope 3,1,0,0,0,2,16,2,127,-3,0,0,99,0       ;* bump
.atari_logo_envelope_04
 atari_logo_envelope 4,1,0,0,0,0,0,0,126,-1,0,-20,64,30     ;* tank soft shot
.atari_logo_envelope_05
 atari_logo_envelope 5,1,0,0,0,0,0,0,126,-1,0,-20,126,30    ;* tank loud shot
.atari_logo_envelope_06
 atari_logo_envelope 6,3,0,0,0,0,0,0,96,-1,0,-2,96,50       ;* explosion soft
.atari_logo_envelope_07
 atari_logo_envelope 7,3,0,0,0,0,0,0,126,-1,0,-2,125,100    ;* explosion loud
.atari_logo_envelope_08
 atari_logo_envelope 8,1,8,4,-12,4,4,4,100,0,0,0,100,100    ;* saucer in motion
.atari_logo_envelope_09
 atari_logo_envelope 9,1,5,-9,7,3,3,3,126,0,0,-126,127,127  ;* saucer shot
.atari_logo_envelope_10
 atari_logo_envelope 10,1,0,0,0,0,0,0,50,0,0,-50,126,126    ;* music

.atari_logo_atari_logo_demo
 JSR atari_mathbox
 JSR atari_irq_and_event_vector_set_up
 JSR atari_enable_vertical_event
.atari_logo
 JSR atari_flip_screen
 JSR atari_logo_animation
.atari_wait_for_it
 LDA atari_wait_counter                 ;even out animation
 CMP #&02
 BCC atari_wait_for_it
 LDA #&00
 STA atari_wait_counter
 DEC atari_frames_displayed             ;number of animation frames

 IF atari_display                       ;only display logo on full game
   BNE atari_logo
 ENDIF

 JSR atari_disable_vertical_event
 LDA #19                                ;need to let all interrupts finish
 JSR osbyte

 IF NOT(debug)
   JSR atari_colour_off                 ;roll into routine below
 ENDIF

.atari_restore_interrupt_vector
 PHP
 SEI
 BIT machine_flag
 BMI atari_electron_restore_event
 LDA atari_irq_vector
 STA irq1v
 LDA atari_irq_vector + &01
 STA irq1v + &01
 LDA #&C2                               ;restore system via, enable timer 1 and vertical sync
 STA system_via_ier_reg
.atari_electron_restore_event
 LDA atari_event_vector                 ;restore event vector
 STA eventv
 LDA atari_event_vector + &01
 STA eventv + &01
 PLP                                    ;restore irq status
 RTS

.atari_colour_off                       ;logical colour 1 to physical colour 0
 LDX #&00
.atari_colour_bytes
 LDA colour_one,X
 JSR oswrch
 INX
 CPX #colour_one_end - colour_one
 BNE atari_colour_bytes
 RTS

.colour_one
 EQUB &13
 EQUB &01
 EQUD &00
.colour_one_end

.atari_print_logo
 LDA atari_frames_displayed
 BEQ atari_logo_exit
 CMP #&E0
 BCS atari_logo_exit
 LDX atari_frame_counter
 INX
 TXA
 AND #&03
 ASL A
 TAX
 LDA atari_logo_logo_addresses,X
 STA atari_logo_sprite_address_01
 STA atari_logo_sprite_address_02
 LDA atari_logo_logo_addresses + &01,X
 STA atari_logo_sprite_address_01 + &01
 STA atari_logo_sprite_address_02 + &01
 LDA #LO(atari_logo_screen_address)
 STA atari_logo_sprite_block_01
 LDA #LO(atari_logo_screen_address + 56)
 STA atari_logo_sprite_block_02
 LDA #HI(atari_logo_screen_address)
 STA atari_logo_sprite_block_01 + &01
 LDA #HI(atari_logo_screen_address + 56)
 STA atari_logo_sprite_block_02 + &01
 LDA atari_bars
 CMP #&0B << &02
 BCS atari_no_inc_bars
 INC atari_bars
.atari_no_inc_bars
 AND #&FC
 LSR A
 LSR A
 TAX
.atari_print
 TXA
 PHA
 LDX #LO(atari_logo_sprite_block_01)
 LDY #HI(atari_logo_sprite_block_01)
 JSR atari_logo_multiple_row_sprite
 LDX #LO(atari_logo_sprite_block_02)
 LDY #HI(atari_logo_sprite_block_02)
 JSR atari_logo_multiple_row_sprite
 LDA atari_logo_sprite_block_01
 CLC
 ADC #LO(atari_screen_row)
 STA atari_logo_sprite_block_01
 LDA atari_logo_sprite_block_01 + &01
 ADC #HI(atari_screen_row)
 STA atari_logo_sprite_block_01 + &01
 LDA atari_logo_sprite_block_02
 CLC
 ADC #LO(atari_screen_row)
 STA atari_logo_sprite_block_02
 LDA atari_logo_sprite_block_02 + &01
 ADC #HI(atari_screen_row)
 STA atari_logo_sprite_block_02 + &01
 PLA
 TAX
 DEX
 BPL atari_print
.atari_logo_exit
 RTS

.atari_logo_sprite_block_01
 EQUW atari_logo_screen_address
.atari_logo_sprite_address_01
 EQUW atari_logo_sprites + atari_logo_00_offset
 EQUB &01
 EQUB 56

.atari_logo_sprite_block_02
 EQUW atari_logo_screen_address + 56
.atari_logo_sprite_address_02
 EQUW atari_logo_sprites + atari_logo_00_offset
 EQUB &01
 EQUB 56

.atari_logo_logo_addresses
 EQUW atari_logo_sprites + atari_logo_00_offset
 EQUW atari_logo_sprites + atari_logo_01_offset
 EQUW atari_logo_sprites + atari_logo_02_offset
 EQUW atari_logo_sprites + atari_logo_03_offset

.atari_text_parameters
 EQUW atari_text_screen_address
 EQUW atari_logo_sprites + atari_text_large_offset
 EQUB &05
 EQUB &78

.atari_logo_mask                        ;mask display with atari logo
 LDA #LO(atari_logo_screen_address + atari_screen_row * &06)
 STA screen_work
 LDA #HI(atari_logo_screen_address + atari_screen_row * &06)
 CLC
 ADC screen_hidden
 STA screen_work + &01
 LDA #LO(atari_logo_sprites + atari_logo_02_a_offset)
 STA sprite_work
 LDA #HI(atari_logo_sprites + atari_logo_02_a_offset)
 STA sprite_work + &01
 LDX #&06
.atari_logo_loop_01
 LDY #111
.atari_logo_row_01
 LDA (screen_work),Y
 AND (sprite_work),Y
 STA (screen_work),Y
 DEY
 BPL atari_logo_row_01
 LDA screen_work
 CLC
 ADC #LO(atari_screen_row)
 STA screen_work
 LDA screen_work + &01
 ADC #HI(atari_screen_row)
 STA screen_work + &01
 LDA sprite_work
 CLC
 ADC #112
 STA sprite_work
 BCC atari_logo_no_inc_01
 INC sprite_work + &01
.atari_logo_no_inc_01
 DEX
 BNE atari_logo_loop_01
 LDA #LO(atari_logo_screen_address + 32)
 STA screen_work
 LDA #HI(atari_logo_screen_address + 32)
 CLC
 ADC screen_hidden
 STA screen_work + &01
 LDA #LO(atari_logo_sprites + atari_logo_01_a_offset)
 STA sprite_work
 LDA #HI(atari_logo_sprites + atari_logo_01_a_offset)
 STA sprite_work + &01
 LDX #&06
.atari_logo_loop_02
 LDY #47
.atari_logo_row_02
 LDA (screen_work),Y
 AND (sprite_work),Y
 STA (screen_work),Y
 DEY
 BPL atari_logo_row_02
 LDA screen_work
 CLC
 ADC #LO(atari_screen_row)
 STA screen_work
 LDA screen_work + &01
 ADC #HI(atari_screen_row)
 STA screen_work + &01
 LDA sprite_work
 CLC
 ADC #48
 STA sprite_work
 BCC atari_logo_no_inc_02
 INC sprite_work + &01
.atari_logo_no_inc_02
 DEX
 BNE atari_logo_loop_02
 RTS

.atari_clear_cells                      ;use a list to clear screen objects
 STA clear_counter                      ;number of entries to clear
 STX list_access                        ;list pointer
 STY list_access + &01
 LDY #&00
.atari_more_blocks
 LDA (list_access),Y
 STA atari_access + &01                 ;self modify address for speed
 INY
 LDA (list_access),Y
 CLC
 ADC screen_hidden                      ;hidden screen address
 STA atari_access + &02
 INY
 LDA (list_access),Y
 TAX                                    ;number of bytes to clear
 INY
 LDA #&00                               ;write byte
.atari_access
 STA atari_access,X
 DEX
 BNE atari_access
 DEC clear_counter                      ;number of blocks to clear
 BNE atari_more_blocks
 RTS

.atari_offset_lo
 EQUB LO(atari_timer)
 EQUB LO(atari_timer + (atari_row * 0.25))
 EQUB LO(atari_timer + (atari_row * 0.50))
 EQUB LO(atari_timer + (atari_row * 0.75))
.atari_offset_hi
 EQUB HI(atari_timer)
 EQUB HI(atari_timer + (atari_row * 0.25))
 EQUB HI(atari_timer + (atari_row * 0.50))
 EQUB HI(atari_timer + (atari_row * 0.75))

.atari_irq_and_event_vector_set_up
 PHP
 SEI
 BIT machine_flag
 BMI atari_logo_electron_set_up
 LDA #&7D                               ;disable all system via interrupts except vertical sync
 STA system_via_ier_reg
 LDA irq1v
 STA atari_irq_vector
 LDA irq1v + &01
 STA atari_irq_vector + &01
 LDA #LO(atari_timer_interrupt)
 STA irq1v
 LDA #HI(atari_timer_interrupt)
 STA irq1v + &01
.atari_logo_electron_set_up
 LDA eventv
 STA atari_event_vector
 LDA eventv + &01
 STA atari_event_vector + &01
 LDA #LO(atari_wait_event)
 STA eventv
 LDA #HI(atari_wait_event)
 STA eventv + &01
 PLP
 RTS

.atari_wait_event
 PHP
 CMP #event_vertical_sync
 BNE atari_exit_event
 INC atari_wait_counter
 BIT machine_flag
 BMI atari_exit_event
 PHA
 TXA
 PHA
 LDA #user_via_aux_timer_1_one_shot     ;auxillary register set for timer 1 one shot
 STA user_via_aux_reg
 LDX atari_frame_counter
 LDA atari_offset_lo,X
 STA user_via_timer_1_latch_lo
 LDA atari_offset_hi,X
 STA user_via_timer_1_latch_hi
 LDA #user_via_ier_timer_1              ;enable user via timer interrupt
 STA user_via_ier_reg
 LDA #&00                               ;flag to differentiate interrupts
 STA atari_interrupt_flag
 LDA #&11                               ;number of interrupts down screen required
 STA atari_number_free_running
 PLA
 TAX
 PLA
 PLP
 RTS
.atari_exit_event
 PLP
 JMP (atari_event_vector)

.atari_timer_interrupt
 BIT user_via_ifr_reg                   ;bit 7 is set if interrupt was from user 6522
 BPL exit_atari_timer_interrupt         ;only source of user via interrupts is timer 1
 BIT atari_interrupt_flag               ;test if free running
 BMI atari_free_running_interrupt
 DEC atari_interrupt_flag               ;now set up free running interrupts
 LDA #user_via_aux_timer_1_continuous   ;auxillary register set for timer 1 continuous
 STA user_via_aux_reg
 LDA #LO(atari_row)
 STA user_via_timer_1_latch_lo          ;clear interrupt
 LDA #HI(atari_row)
 STA user_via_timer_1_latch_hi
 LDA #user_via_ier_timer_1              ;enable user via timer interrupt
 STA user_via_ier_reg
 LDA atari_colour_start                 ;colour table start
 STA atari_colour_copy                  ;for use by rolling interrupt
 LDA interrupt_accumulator
 RTI
.exit_atari_timer_interrupt
 JMP (atari_irq_vector)

.atari_free_running_interrupt
 TXA
 PHA
 LDA user_via_timer_1_latch_lo          ;clear interrupt
 DEC atari_number_free_running          ;last interrupt?
 BEQ exit_turn_to_last
 LDX atari_colour_copy                  ;increment for next interrupt
 INX
 CPX #&08
 BCC atari_no_black
 LDX #red
.atari_no_black
 STX atari_colour_copy
 LDA colour_table_lo,X                  ;get the address
 STA atari_work
 LDA colour_table_hi,X
 STA atari_work + &01
 PLA
 TAX
 JMP (atari_work)                       ;change colour
.exit_turn_to_last
 LDA #user_via_aux_clear                ;disable user via timer interrupt
 STA user_via_aux_reg
 PLA
 TAX
 LDA interrupt_accumulator
 RTI

.atari_stack_store
 EQUB &00
.atari_irq_vector
 EQUW &00
.atari_event_vector
 EQUW &00
.atari_colour_start
 EQUB &01
.atari_number_free_running
 EQUB &00
.atari_frame_counter
 EQUB &00
.atari_frames_displayed
 EQUB &00
.atari_bars
 EQUB &03
.atari_prynt_text
 EQUB &02
.atari_wait_counter
 EQUB &00

.colour_table_lo
 EQUB LO(black_colour)
 EQUB LO(red_colour)
 EQUB LO(green_colour)
 EQUB LO(blue_colour)
 EQUB LO(yellow_colour)
 EQUB LO(magenta_colour)
 EQUB LO(cyan_colour)
 EQUB LO(white_colour)

.colour_table_hi
 EQUB HI(black_colour)
 EQUB HI(red_colour)
 EQUB HI(green_colour)
 EQUB HI(blue_colour)
 EQUB HI(yellow_colour)
 EQUB HI(magenta_colour)
 EQUB HI(cyan_colour)
 EQUB HI(white_colour)

.black_colour
 mode_colour_values_2_bits_per_pixel 1,black
.red_colour
 mode_colour_values_2_bits_per_pixel 1,red
.green_colour
 mode_colour_values_2_bits_per_pixel 1,green
.yellow_colour
 mode_colour_values_2_bits_per_pixel 1,yellow
.blue_colour
 mode_colour_values_2_bits_per_pixel 1,blue
.magenta_colour
 mode_colour_values_2_bits_per_pixel 1,magenta
.cyan_colour
 mode_colour_values_2_bits_per_pixel 1,cyan
.white_colour
 mode_colour_values_2_bits_per_pixel 1,white

.atari_flip_screen
 LDX atari_frame_counter                ;next logo frame
 INX
 TXA
 AND #&03
 STA atari_frame_counter
 BNE atari_no_start_inc                 ;every four frames pull colour back one
 LDX atari_colour_start
 DEX
 BNE atari_start
 DEX
.atari_start
 TXA
 AND #&07
 STA atari_colour_start
.atari_no_start_inc
 LDA #19
 JSR osbyte
 LDA screen_hidden
 EOR #&68
 STA screen_hidden
 EOR #&68
 LSR A
 BIT machine_flag
 BMI atari_electron_screen_flip
 LDX #&0C
 STX sheila
 LSR A
 LSR A
 STA sheila + &01
 RTS
.atari_electron_screen_flip
 STA sheila + &03
.atari_exit_routine
 RTS

.atari_blank
 EQUW atari_logo_screen_address - &01
 EQUB &20
 EQUW atari_logo_screen_address + atari_screen_row * &01 - &01
 EQUB &20
 EQUW atari_logo_screen_address + atari_screen_row * &02 - &01
 EQUB &20
 EQUW atari_logo_screen_address + atari_screen_row * &03 - &01
 EQUB &20
 EQUW atari_logo_screen_address + atari_screen_row * &04 - &01
 EQUB &20
 EQUW atari_logo_screen_address + atari_screen_row * &05 - &01
 EQUB &20
 EQUW atari_logo_screen_address - &01 + 80
 EQUB &20
 EQUW atari_logo_screen_address + atari_screen_row * &01 - &01 + 80
 EQUB &20
 EQUW atari_logo_screen_address + atari_screen_row * &02 - &01 + 80
 EQUB &20
 EQUW atari_logo_screen_address + atari_screen_row * &03 - &01 + 80
 EQUB &20
 EQUW atari_logo_screen_address + atari_screen_row * &04 - &01 + 80
 EQUB &20
 EQUW atari_logo_screen_address + atari_screen_row * &05 - &01 + 80
 EQUB &20
.atari_blank_end

.atari_logo_animation
 JSR atari_print_logo
 JSR atari_logo_mask
 LDA #(atari_blank_end - atari_blank) DIV &03
 LDX #LO(atari_blank)
 LDY #HI(atari_blank)
 JSR atari_clear_cells
.atari_text                             ;display text just twice
 LDA atari_prynt_text
 BEQ atari_exit_routine
 DEC atari_prynt_text
 LDX #LO(atari_text_parameters)
 LDY #HI(atari_text_parameters)         ;roll into routine below

.atari_logo_multiple_row_sprite
 STX sprite_work
 STY sprite_work + &01
 LDY #&00
 LDA (sprite_work),Y                    ;screen address
 STA atari_logo_fast_store + &01
 INY
 LDA (sprite_work),Y
 CLC
 ADC screen_hidden
 STA atari_logo_fast_store + &02
 INY
 LDA (sprite_work),Y                    ;sprite address
 STA atari_logo_fast_load + &01
 INY
 LDA (sprite_work),Y
 STA atari_logo_fast_load + &02
 INY
 LDA (sprite_work),Y                    ;number of rows
 TAX
 INY
 LDA (sprite_work),Y                    ;number of bytes in row
 STA atari_logo_fast_add + &01
 TAY
 DEY
 STY atari_logo_fast_bytes + &01
.atari_logo_fast_bytes
 LDY #&00
.atari_logo_fast_load
 LDA atari_logo_fast_load,Y
.atari_logo_fast_store
 STA atari_logo_fast_store,Y
 DEY
 BPL atari_logo_fast_load
 LDA atari_logo_fast_store + &01            ;next screen row
 CLC
 ADC #LO(atari_screen_row)
 STA atari_logo_fast_store + &01
 LDA atari_logo_fast_store + &02
 ADC #HI(atari_screen_row)
 STA atari_logo_fast_store + &02
 LDA atari_logo_fast_load + &01
 CLC
.atari_logo_fast_add
 ADC #&00
 STA atari_logo_fast_load + &01
 BCC atari_logo_fast_no_inc
 INC atari_logo_fast_load + &02
.atari_logo_fast_no_inc
 DEX
 BNE atari_logo_fast_bytes
 RTS

.atari_enable_vertical_event
 LDA #&0E                               ;enable vertical sync event
 LDX #&04
 JMP osbyte

.atari_disable_vertical_event
 LDA #&0D                               ;disable vertical sync event
 LDX #&04
 JMP osbyte

.atari_logo_sprites
 INCBIN  "atari logo sprites.bin"

.atari_mathbox                          ;find and initialise arm second processor
 LDA #&EA                               ;read second processor presence
 LDX #&00
 LDY #&FF
 STX mathbox_flag                       ;mathbox absent/mathbox speed
 JSR osbyte
 TXA                                    ;&00 = off, &ff = on
 BEQ tube_status_off                    ;tube enabled
 TSX                                    ;store stack for return
 STX atari_stack_store
 LDX #&FF                               ;flatten stack for second processor initialisation
 TXS
 TXA                                    ;load bzone4, arm mathbox
 LDX #LO(atari_load_bzone_file)
 LDY #HI(atari_load_bzone_file)
 JSR osfile
 LDA eventv                             ;save event vector
 STA atari_event_vector
 LDA eventv + &01
 STA atari_event_vector + &01
 PHP
 SEI
 LDA #LO(atari_timed_out)               ;hook event vector to interval timer code
 STA eventv
 LDA #HI(atari_timed_out)
 STA eventv + &01
 PLP                                    ;restore irq status
 LDA #&04                               ;write interval timer for return to host processor
 LDX #LO(atari_timer_block)
 LDY #HI(atari_timer_block)
 JSR osword
 LDA #&0E                               ;enable interval timer
 LDX #event_interval_timer
 LDY #&00
 STY host_function_code                 ;clear function code
 JSR osbyte
.atari_claim_tube                       ;claim the tube
 LDA #&C0 + atari_claim_id
 JSR tube_code_entry_point
 BCC atari_claim_tube
 LDX #LO(atari_transfer_block)          ;execute arm code in parasite
 LDY #HI(atari_transfer_block)
 LDA #tube_reason_code_04
 JMP tube_code_entry_point              ;implied tube release, does not return here so jump
.tube_status_off
 RTS

.atari_transfer_block
 EQUD mathbox_execute_address

.atari_timed_out
 PHP
 CMP #event_interval_timer
 BNE atari_not_timer                    ;not interval timer event
.atari_disable_event
 LDA #&0D                               ;disable interval timer
 LDX #event_interval_timer
 LDY #&00
 JSR osbyte
 LDA atari_event_vector                 ;restore vector
 STA eventv
 LDA atari_event_vector + &01
 STA eventv + &01
 LDX atari_stack_store                  ;restore temporary stack (ignore push)
 TXS
 CLI
 RTS                                    ;return from mathbox setup
.atari_not_timer
 PLP
 JMP (atari_event_vector)

.atari_load_bzone_file
 EQUW atari_bzone_name
 EQUD &00
 EQUD &FF
 EQUD &00
 EQUD &00
.atari_bzone_name
 EQUS "bzone4", &0D

.atari_timer_block                      ;wait three seconds for mathbox to respond
 EQUW -300
 EQUB -1
 EQUB -1
 EQUB -1

.bzone0_end
 SAVE "bzone0", bzone0, &3000, bzone0 + host_addr, bzone0 + host_addr