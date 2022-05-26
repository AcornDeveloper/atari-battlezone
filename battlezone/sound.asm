; sound
; maintain sound channels to provide full use for multiple effects, original sounds
; have been re-created, as close as possible, by using the data from the roms
;
; 10 ENVELOPE 1,1, 1,1,1, 4,4,4,126,0,0,-32,126,0
; 20 SOUND 1,1,145,6
; 
; n, t, pi1, p12, pi3, pn1, pn2, pn3, aa, ad, as, ar, ala, ald
; 
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
;
; bbc noise channel
; p = 0 periodic noise high pitch
; p = 1 periodic noise medium pitch
; p = 2 periodic noise low pitch
; p = 3 periodic noise related to channel 1 pitch
; p = 4 white noise high pitch
; p = 5 white noise medium pitch
; p = 6 white noise low pitch
; p = 7 white noise related to channel 1 pitch
;
; atari sound duration resolution is 1/250 or 0.004 seconds
; bbc   sound duration resolution is 1/20  or 0.050 seconds on non-envelope sounds
;                                    1/100 or 0.010 seconds on envelope sounds
;
; taken from andy mcfadden's site https://6502disassembly.com/ ...
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; pokey audio has four channels, with two 8-bit i/o locations per channel (audfn
; and audcn) the sound effects defined by this data are played on channels 1 and 2
;
; the audfn setting determines frequency, larger value == lower pitch
;
; the audcn value is nnnfvvvv, where
; n is a noise / distortion setting
; f is "forced volume-only output" enable
; v is the volume level
;
; the sound specified by the value is played until the duration reaches zero
; if the repetition count is non-zero, the value is increased or decreased by the
; increment, and the duration is reset
; when the repetition count reaches zero the next chunk is loaded
; if the chunk has the value $00, the sequence ends the counters are updated by the 250hz nmi
;
; because audfn and audcn are specified by different chunks, care must be taken
; to ensure the durations run out at the same time
;
; initiates a sound effect on audio channel 1 and/or 2
;
; &01: channel 1     : radar ping
; &02: channel 1     : collided with object
; &04: channel 2     : quiet "merp"
; &08: channel 2     : extra life notification (4 high-pitched beeps)
; &10: channel 2     : new enemy alert (three boops)
; &20: channel 1     : saucer hit (played in a loop while saucer fades out)
; &40: channel 1     : saucer sound (played in a loop while saucer alive)
; &80: channel 1 & 2 : nine notes from 1812 overture
;
; in the sound table below, each chunk has 4 values
;  +00 initial value
;  +01 duration
;  +03 increment
;  +04 repetition count
;
; >> sound table, reproduced below <<
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; sfx_audio_data
; .bulk   $40,$02,$ff,$18   ;sound $10 F2 (three-boop new enemy alert)
; .bulk   $40,$02,$ff,$18   ;($02 * $18) * $03 = $90
; .bulk   $40,$02,$ff,$18
; .bulk   $00,$00
; .bulk   $a3,$30,$00,$03   ;sound $10 C2 ($30 * $03 = $90)
; .bulk   $00,$00
; .bulk   $23,$10,$00,$01   ;sound $01 F2 (radar ping)
; .bulk   $00,$00
; .bulk   $a3,$10,$00,$01   ;sound $01 C2
; .bulk   $00,$00
; .bulk   $10,$01,$00,$20   ;sound $04 F1 (quiet "merp")
; .bulk   $00,$00
; .bulk   $c1,$10,$ff,$02   ;sound $04 C1
; .bulk   $00,$00
; .bulk   $c0,$01,$f6,$06   ;sound $02 F1 (vehicular collision)
; .bulk   $84,$01,$09,$0c
; .bulk   $f0,$01,$f8,$0c
; .bulk   $90,$01,$07,$0c
; .bulk   $e4,$01,$fa,$0c
; .bulk   $9c,$01,$05,$0c
; .bulk   $d8,$01,$fc,$0c
; .bulk   $a8,$01,$03,$0c
; .bulk   $cc,$01,$fe,$0c
; .bulk   $b4,$01,$01,$0c
; .bulk   $00,$00
; .bulk   $ab,$04,$ff,$09   ;sound $02 C1
; .bulk   $a2,$27,$ff,$02
; .bulk   $00,$00
; .bulk   $10,$70,$00,$02   ;sound $08 F2 (four-beep extra life)
; .bulk   $00,$00
; .bulk   $a2,$20,$00,$01   ;sound $08 C2
; .bulk   $a0,$20,$00,$01
; .bulk   $a2,$20,$00,$01
; .bulk   $a0,$20,$00,$01
; .bulk   $a2,$20,$00,$01
; .bulk   $a0,$20,$00,$01
; .bulk   $a2,$20,$00,$01
; .bulk   $00,$00
; .bulk   $30,$01,$fc,$0c   ;sound $20 F1 (saucer hit)
; .bulk   $30,$01,$fc,$0c
; .bulk   $00,$00
; .bulk   $a3,$02,$00,$0c   ;sound $20 C2
; .bulk   $00,$00
; .bulk   $40,$01,$fe,$10   ;sound $40 F1 (saucer alive)
; .bulk   $20,$01,$02,$10
; .bulk   $40,$01,$fe,$10
; .bulk   $20,$01,$02,$10
; .bulk   $00,$00
; .bulk   $a1,$10,$00,$04   ;sound $40 C1
; .bulk   $00,$00
; .bulk   $d9,$30,$00,$01   ;sound $80 F1 (1812 Overture)
; .bulk   $a2,$30,$00,$01
; .bulk   $90,$30,$00,$01
; .bulk   $80,$30,$00,$01
; .bulk   $90,$30,$00,$01
; .bulk   $a2,$30,$00,$01
; .bulk   $90,$30,$00,$01
; .bulk   $80,$30,$00,$02
; .bulk   $a2,$30,$00,$04
; .bulk   $00,$00
; .bulk   $a7,$30,$00,$0d   ;sound $80 C1/C2 (13 steps, same as F1/F2)
; .bulk   $00,$00
; .bulk   $6c,$30,$00,$01   ;sound $80 F2
; .bulk   $51,$30,$00,$01
; .bulk   $48,$30,$00,$01
; .bulk   $40,$30,$00,$01
; .bulk   $48,$30,$00,$01
; .bulk   $51,$30,$00,$01
; .bulk   $48,$30,$00,$01
; .bulk   $40,$30,$00,$02
; .bulk   $51,$30,$00,$04
; .bulk   $00,$00
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; bbc sound note/value table
; note 	octave
;       1    2    3    4    5    6    7
; b 	1 	 49   97   145  193  241
; a# 	0 	 45   93   141  189  237
; a 	  	 41   89   137  185  233
; g# 	  	 37   85   133  181  229
; g 	  	 33   81   129  177  225
; f# 	  	 29   77   125  173  221
; f 	  	 25   73   121  169  217
; e 	  	 21   69   117  165  213
; d# 	  	 17   65   113  161  209
; d 	  	 13   61   109  157  205  253
; c# 	  	  9   57   105  153  201  249
; c 	  	  5   53   101  149  197  245
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; atari sound note/value table
; note            octave
;                 3    4    5    6    7
; c               &F3  &79  &3C  &1E  &0E
; c#              &E6  &72  &39  &1C
; d               &D9  &6C  &35  &1A
; d#              &CC  &66  &32  &19
; e               &C1  &60  &2F  &17
; f               &B6  &5B  &2D  &16
; f#              &AC  &55  &2A  &15
; g               &A2  &51  &28  &13
; g#              &99  &4C  &25  &12
; a               &90  &48  &23  &11
; a#              &88  &44  &21  &10
; b               &80  &40  &1F  &0F
; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.sound_flag_block                       ;initialise to 0, increment to activate

.sound_enemy_alert                      EQUB &00
.sound_enemy_radar                      EQUB &00
.sound_bump                             EQUB &00
.sound_tank_shot_soft                   EQUB &00
.sound_tank_shot_loud                   EQUB &00
.sound_explosion_soft                   EQUB &00
.sound_explosion_loud                   EQUB &00
.sound_motion_blocked                   EQUB &00
.sound_saucer_in_motion                 EQUB &00
.sound_saucer_shot                      EQUB &00
.sound_extra_life                       EQUB &00
.sound_key_click                        EQUB &00

.sound_flag_block_end

.sound_repeat_work
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00
 EQUB &00

.sound_sound_flag_block_work_end        ;flag and work area end

.sound_channel
 EQUB &03                               ;01 enemy alert
 EQUB &12                               ;02 enemy radar
 EQUB &12                               ;03 bump
 EQUB &10                               ;04 tank shot soft
 EQUB &10                               ;05 tank shot loud
 EQUB &10                               ;06 explosion soft
 EQUB &10                               ;07 explosion loud
 EQUB &10                               ;08 motion blocked
 EQUB &03                               ;09 saucer in motion
 EQUB &12                               ;0A saucer shot
 EQUB &13                               ;0B extra life
 EQUB &11                               ;0C key click

.sound_amplitude_envelope
 EQUW &01                               ;01 enemy alert
 EQUW &02                               ;02 enemy radar
 EQUW &03                               ;03 bump
 EQUW &04                               ;04 tank shot soft
 EQUW &05                               ;05 tank shot loud
 EQUW &06                               ;06 explosion soft
 EQUW &07                               ;07 explosion loud
 EQUW &F6                               ;08 motion blocked
 EQUW &08                               ;09 saucer in motion
 EQUW &09                               ;0A saucer shot
 EQUW &F6                               ;0B extra life
 EQUW &F6                               ;0C key click

.sound_data_pitch
 EQUB &75                               ;01 enemy alert
 EQUB &89                               ;02 enemy radar
 EQUB &00                               ;03 bump
 EQUB &06                               ;04 tank shot soft
 EQUB &06                               ;05 tank shot loud
 EQUB &06                               ;06 explosion soft
 EQUB &06                               ;07 explosion loud
 EQUB &01                               ;08 motion blocked
 EQUB &A0                               ;09 saucer in motion
 EQUB &A0                               ;0A saucer shot
 EQUB &ED                               ;0B extra life
 EQUB &A0                               ;0C key click

.sound_data_duration
 EQUB &0C                               ;01 enemy alert
 EQUB &14                               ;02 enemy radar
 EQUB &10                               ;03 bump
 EQUB &0C                               ;04 tank shot soft
 EQUB &0C                               ;05 tank shot loud
 EQUB &10                               ;06 explosion soft
 EQUB &10                               ;07 explosion loud
 EQUB &01                               ;08 motion blocked
 EQUB &20                               ;09 saucer in motion
 EQUB &14                               ;0A saucer shot
 EQUB &02                               ;0B extra life
 EQUB &04                               ;0C key click

.sound_data_repeat
 EQUB &00                               ;01 enemy alert
 EQUB &00                               ;02 enemy radar
 EQUB &00                               ;03 bump
 EQUB &00                               ;04 tank shot soft
 EQUB &00                               ;05 tank shot loud
 EQUB &00                               ;06 explosion soft
 EQUB &00                               ;07 explosion loud
 EQUB &00                               ;08 motion blocked
 EQUB &00                               ;09 saucer in motion
 EQUB &00                               ;0A saucer shot
 EQUB &04                               ;0B extra life
 EQUB &00                               ;0C key click

.sound_flush_buffers                    ;flush all sounds and reset sound flags
 LDX #&04
.flush_all_sounds
 STX workspace
 LDA #21
 JSR osbyte
 LDX workspace
 INX
 CPX #&08
 BNE flush_all_sounds
.sound_clear_flags
 LDX #sound_sound_flag_block_work_end - sound_flag_block - &01
 LDA #&00                               ;clear sound control block
.clear_sound_control
 STA sound_flag_block,X                 ;clear flags
 DEX
 BPL clear_sound_control
.sound_leave
 RTS
 
.sound_saucer_on_field                  ;saucer moving, only makes sound when in view
 BIT saucer_state                       ;saucer in view?  
 BPL saucer_absent                      ;no
.saucer_absent
 RTS

.sound_engine_movement
 EQUB &00

.sound_engine_missile_control           ;keep engine sound in sync with movement
 RTS
 LDA tank_or_super_or_missile           ;branch if missile active as this requires priority over engine sound
 CMP #object_x07_missile                ;do not use missile_flag as status is preserved until new unit created
 BEQ sound_missile_sound_control
 BIT m_tank_status                      ;alive?
 BMI sound_leave                        ;no
 LDA clk_mode                           ;second clock used to control engine sound
 BPL sound_leave                        ;not ready for an engine update yet
 LDX #LO(sound_osword_noise)            ;channel 0
 LDY #HI(sound_osword_noise)
 LDA #&07
 JSR osword
 LDA sound_engine_movement              ;get current engine sound
 CLC
 ADC #&10
 STA sound_one_pitch
 LDX #LO(sound_osword_channel_one)      ;channel 1
 LDY #HI(sound_osword_channel_one)
 LDA #&07
 JMP osword

.sound_osword_noise                     ;parameter block for channel 0

.sound_noise_channel
 EQUW &10
.sound_noise_adsr
 EQUW -&0F
.sound_noise_pitch
 EQUW &03
.sound_noise_duration
 EQUW &05

.sound_osword_channel_one               ;parameter block for channel 1

.sound_one_channel
 EQUW &11
.sound_one_adsr
 EQUW &00
.sound_one_pitch
 EQUW &00
.sound_one_duration
 EQUW &05

.sound_missile_sound_control
 RTS
 LDA enemy_dist_hi                      ;missile distance
 LDX #LO(sound_osword_channel_one)
 LDY #HI(sound_osword_channel_one)
 LDA #&07
 JMP osword

.sound_when_dead                        ;call when my tank destroyed
 JSR sound_flush_buffers                ;flush all sounds/clear flags
 DEC m_tank_status                      ;kill player
 INC enemy_score                        ;enemy score +1
 INC sound_explosion_loud               ;make large explosion sound

.sound_control                          ;scan sound flags and action any requests
 BIT sound_gate                         ;if muted sound then exit
 BMI sound_exit                         ;exit
.sound_control_bypass
 LDX #sound_flag_block_end - sound_flag_block - &01
.sound_control_loop
 LDA sound_flag_block,X                 ;x = index into sound
 BNE sound_make                         ;sound required
 LDA sound_repeat_work,X                ;repeat sound?
 BEQ sound_next                         ;no
 DEC sound_repeat_work,X                ;decrease and make sound again?
 BEQ sound_next                         ;repeat finished
 BNE sound_repeat                       ;always, repeat the sound
.sound_make
 LDA #&00                               ;clear this sound flag
 STA sound_flag_block,X
 LDA sound_data_repeat,X                ;load repeat sound counter
 STA sound_repeat_work,X
.sound_repeat
 STX workspace                          ;save index
 TXA
 ASL A
 TAY
 LDA sound_amplitude_envelope,Y         ;amplitude/envelope
 STA sound_envelope_adsr
 LDA sound_amplitude_envelope + &01,Y
 STA sound_envelope_adsr + &01
 LDA sound_data_pitch,X                 ;pitch
 STA sound_envelope_pitch
 LDA sound_data_duration,X              ;duration
 STA sound_envelope_duration
 LDA sound_channel,X                    ;channel to use
 STA sound_envelope_channel
 LDX #LO(sound_osword)
 LDY #HI(sound_osword)
 LDA #&07
 JSR osword
 LDX workspace
.sound_next
 DEX
 BPL sound_control_loop
.sound_exit
 RTS

.sound_osword                           ;parameter block for general sounds

.sound_envelope_channel
 EQUW &00
.sound_envelope_adsr
 EQUW &00
.sound_envelope_pitch
 EQUW &00
.sound_envelope_duration
 EQUW &00

.sound_music                            ;bit 7 = 1 music on,  = 0 music off
 EQUB &00
.sound_gate                             ;bit 7 = 1 sound off, = 0 sound on
 EQUB 00
.sound_note_index                       ;sound note counter 0 to 8
 EQUB &00

.sound_tchaikovsky                      ;play tchaikovsky's 1812 overture e flat major
 BIT sound_music                        ;&FB (-&05) sound output buffer 0
 BPL sound_tchaikovsky_leave            ;&FA (-&06) sound output buffer 1
.sound_read_buffer                      ;&F9 (-&07) sound output buffer 2
 LDA #&80                               ;&F8 (-&08) sound output buffer 3
 LDX #LO(-&07)                          ;read sound buffer channel 2, 2&3 synchronised
 LDY #&FF
 JSR osbyte
 CPX #&04                               ;maximum 4 in buffer allowed
 BCC sound_tchaikovsky_leave            ;buffer full, come back next time
 LDY sound_note_index
 LDA sound_music_channel_02_notes,Y
 BEQ sound_music_finished               ;all notes played, turn off music
 STA sound_music_channel_02_pitch
 LDA sound_music_channel_03_notes,Y
 STA sound_music_channel_03_pitch
 LDA sound_music_length,Y
 STA sound_music_channel_02_duration
 STA sound_music_channel_03_duration
 LDX #LO(sound_music_channel_02_osword)
 LDY #HI(sound_music_channel_02_osword)
 LDA #&07
 JSR osword
 LDX #LO(sound_music_channel_03_osword)
 LDY #HI(sound_music_channel_03_osword)
 LDA #&07
 JSR osword
 INC sound_note_index                   ;onto next note
 BNE sound_read_buffer                  ;always, check to see if more space in buffer/finished
.sound_music_finished                   ;reset counter for next use
 CPX #&0F                               ;a=&00
 BNE sound_tchaikovsky_leave            ;allow last note to finish
 LDA #&00
 STA sound_note_index                   ;reload music for next time
 STA sound_music                        ;turn music off
 STA sound_gate                         ;turn sound on
 INC sound_explosion_loud               ;music over so loud explosion sound required
.sound_tchaikovsky_leave
 RTS

.sound_music_channel_02_osword          ;parameter block for channel 02

.sound_music_channel_02_channel         ;sound_music &hsfn, h=hold current sound_music, s=synchronise, f=flush, n=channel
 EQUW &0102                             ;synchronise both channels
.sound_music_channel_02_adsr            ;use envelope 12
 EQUW &0A
.sound_music_channel_02_pitch
 EQUW &00
.sound_music_channel_02_duration
 EQUW &00

.sound_music_channel_03_osword          ;parameter block for channel 03

.sound_music_channel_03_channel
 EQUW &0103
.sound_music_channel_03_adsr
 EQUW &0A
.sound_music_channel_03_pitch
 EQUW &00
.sound_music_channel_03_duration
 EQUW &00

.sound_music_channel_02_notes
 EQUB 061                               ;pokey D - &D9  bbc 061
 EQUB 081                               ;      G - &A2      081
 EQUB 089                               ;      A - &90      089
 EQUB 097                               ;      B - &80      097
 EQUB 089                               ;      A - &90      089
 EQUB 081                               ;      G - &A2      081
 EQUB 089                               ;      A - &90      089
 EQUB 097                               ;      B - &80      097
 EQUB 081                               ;      G - &A2      081
 EQUB 000                               ;end music flag

.sound_music_channel_03_notes
 EQUB 109                               ;pokey D - &6C  bbc 109
 EQUB 129                               ;      G - &51      129
 EQUB 137                               ;      A - &48      137
 EQUB 145                               ;      B - &40      145
 EQUB 137                               ;      A - &48      137
 EQUB 129                               ;      G - &51      129
 EQUB 137                               ;      A - &48      137
 EQUB 145                               ;      B - &40      145
 EQUB 129                               ;      G - &51      129

.sound_music_length
 EQUB &04
 EQUB &04
 EQUB &04
 EQUB &04
 EQUB &04
 EQUB &04
 EQUB &04
 EQUB &08
 EQUB &10

.sound_gate_mode                        ;sound control per mode/set music counter
 LDX game_mode
 LDA #%01100110                         ;sound bit mask
;       |||||||
;       |||||||mode 00 main game
;       ||||||mode 01 attract mode
;       |||||mode 02 high score table
;       ||||mode 03 service menu
;       |||mode 04 new high score
;       ||mode 05 battlezone text
;       |mode 06 model test
.sound_get_flag                         ;shift right into carry
 LSR A
 DEX
 BPL sound_get_flag                     ;on exit carry has sound status for mode
 ROR sound_gate                         ;put carry in bit 7 of sound flag
 INX                                    ;x=0
 STX sound_note_index                   ;set music counter
 RTS
