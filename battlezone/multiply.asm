; multiplication/division/distance
;
; square table must be aligned on a page boundary

.square1_lo_16
 FOR number, 0, 511                               ;low  ( sqr(x)=x^2/4 )
   EQUB LO(number * number DIV 4)
 NEXT
.square1_hi_16
 FOR number, 0, 511                               ;high ( sqr(x)=x^2/4 )
   EQUB HI(number * number DIV 4)
 NEXT
.square2_lo_16
 FOR number, 0, 511
   EQUB LO((255 - number) * (255 - number) DIV 4) ;low  ( negsqr(x)=(255-x)^2/4 )
 NEXT
.square2_hi_16
 FOR number, 0, 511
   EQUB HI((255 - number) * (255 - number) DIV 4) ;high ( negsqr(x)=(255-x)^2/4 )
 NEXT

.multiply_16_signed
 LDA multiplicand_16 + &01
 EOR multiplier_16 + &01
 STA result_sign_16
 BIT multiplicand_16 + &01
 BPL multiplicand_16_positive_b
 LDA #&00
 SEC
 SBC multiplicand_16
 STA multiplicand_16
 LDA #&00
 SBC multiplicand_16 + &01
 STA multiplicand_16 + &01
.multiplicand_16_positive_b
 BIT multiplier_16 + &01
 BPL multiplier_16_positive_b
 LDA #&00
 SEC
 SBC multiplier_16
 STA multiplier_16
 LDA #&00
 SBC multiplier_16 + &01
 STA multiplier_16 + &01
.multiplier_16_positive_b
 LDA multiplicand_16                    ;compute (x0 * y0) + (x0 * y1) + (x1 * y0) + (x1 *y1)
 STA square1_lo
 STA square1_hi
 EOR #&FF
 STA square2_lo
 STA square2_hi
 LDY multiplier_16
 LDA (square1_lo),Y
 SEC
 SBC (square2_lo),Y
 STA product_16                         ;product_16          = low  (x0 * y0) z0
 LDA (square1_hi),Y
 SBC (square2_hi),Y
 STA product_16 + &01                   ;product_16 + &01    = high (x0 * y0) c1a
 LDY multiplier_16 + &01
 LDA (square1_lo),Y
 SEC
 SBC (square2_lo),Y
 STA product_16_t1                      ;product_16_t1       = low  (x0 * y1) c1b
 LDA (square1_hi),Y
 SBC (square2_hi),Y
 STA product_16_t1 + &01                ;product_16_t1 + &01 = high (x0 * y1) c2a
 LDA multiplicand_16 + &01
 STA square1_lo
 STA square1_hi
 EOR #&FF
 STA square2_lo
 STA square2_hi
 LDY multiplier_16
 LDA (square1_lo),Y
 SEC
 SBC (square2_lo),Y
 STA product_16_t2                      ;product_16_t2       = low  (x1 * y0) c1c
 LDA (square1_hi),Y
 SBC (square2_hi),Y
 STA product_16_t2 + &01                ;product_16_t2 + &01 = high (x1 * y1) c2b
 LDY multiplier_16 + &01
 LDA (square1_lo),Y
 SEC
 SBC (square2_lo),Y
 STA product_16 + &03                   ;product_16 + &03    = low  (x1 * y1) c2c
 LDA (square1_hi),Y
 SBC (square2_hi),Y
 TAY                                    ;y                   = high (x1 * y1)
 LDA product_16 + &01
 CLC
 ADC product_16_t1
 STA product_16 + &01
 LDA product_16_t1 + &01
 ADC product_16_t2 + &01
 TAX
 BCC no_inc_hi_y_00
 CLC
 INY
.no_inc_hi_y_00
 LDA product_16_t2
 ADC product_16 + &01
 STA product_16 + &01
 TXA
 ADC product_16 + &03
 BCC no_inc_hi_y_01
 INY
.no_inc_hi_y_01
 STA product_16 + &02
 STY product_16 + &03
 BIT result_sign_16
 BPL multiply_16_exit_b
 LDA #&00
 SEC
 SBC product_16
 STA product_16
 LDA #&00
 SBC product_16 + &01
 STA product_16 + &01
 LDA #&00
 SBC product_16 + &02
 STA product_16 + &02
 LDA #&00
 SBC product_16 + &03
 STA product_16 + &03
.multiply_16_exit_b
 RTS

.division_24_view_signed                ;24bit division, note this is optimised for a 16 bit result
 LDX #&00	                            ;clear remainder
 STX division_remainder_24
 STX division_remainder_24 + &01
 STX dividend_24                        ;create lsb dividend
 LDA dividend_24 + &02                  ;result sign
 EOR divisor_24 + &01
 STA division_result_sign_24
 BIT dividend_24 + &02
 BPL dividend_24_positive
 TXA                                    ;x = 0
 SEC
 SBC dividend_24 + &01
 STA dividend_24 + &01
 TXA
 SBC dividend_24 + &02
 STA dividend_24 + &02
.dividend_24_positive
 BIT divisor_24 + &01
 BPL divisor_24_positive
 TXA                                    ;x = 0
 SEC
 SBC divisor_24
 STA divisor_24
 TXA
 SBC divisor_24 + &01
 STA divisor_24 + &01
.divisor_24_positive
 LDX #&18 	                            ;repeat for each bit
.divide_24_loop
 ASL dividend_24	                    ;dividend lb & hb * 2, msb -> carry
 ROL dividend_24 + &01
 ROL dividend_24 + &02
 ROL division_remainder_24	            ;remainder lb & hb * 2 + msb from carry
 ROL division_remainder_24 + &01
 LDA division_remainder_24
 SEC
 SBC divisor_24	                        ;subtract divisor to see if it fits in
 TAY
 LDA division_remainder_24 + &01
 SBC divisor_24 + &01
 BCC division_24_bypass
 STA division_remainder_24 + &01	    ;save substraction result as new remainder
 STY division_remainder_24
 INC dividend_24 	                    ;increment result as divisor fits in once
.division_24_bypass
 DEX
 BNE divide_24_loop
 BIT division_result_sign_24
 BPL divide_24_exit
 TXA                                    ;x = 0
 SEC
 SBC dividend_24
 STA dividend_24
 TXA
 SBC dividend_24 + &01
 STA dividend_24 + &01
.divide_24_exit
 RTS
 
.division_24_clip_signed                ;24bit division, note this is optimised for a 16 bit result
 LDX #&00	                            ;clear remainder
 STX division_remainder_24
 STX division_remainder_24 + &01
 LDA dividend_24 + &02                  ;result sign
 EOR divisor_24 + &01
 STA division_result_sign_24
 BIT dividend_24 + &02
 BPL dividend_24_positive_clip
 TXA                                    ;x = 0
 SEC
 SBC dividend_24
 STA dividend_24
 TXA
 SBC dividend_24 + &01
 STA dividend_24 + &01
 TXA
 SBC dividend_24 + &02
 STA dividend_24 + &02
.dividend_24_positive_clip
 BIT divisor_24 + &01
 BPL divisor_24_positive_clip
 TXA                                    ;x = 0
 SEC
 SBC divisor_24
 STA divisor_24
 TXA
 SBC divisor_24 + &01
 STA divisor_24 + &01
.divisor_24_positive_clip
 LDX #&18 	                            ;repeat for each bit
.divide_24_loop_clip
 ASL dividend_24	                    ;dividend lb & hb * 2, msb -> carry
 ROL dividend_24 + &01
 ROL dividend_24 + &02
 ROL division_remainder_24	            ;remainder lb & hb * 2 + msb from carry
 ROL division_remainder_24 + &01
 LDA division_remainder_24
 SEC
 SBC divisor_24	                        ;subtract divisor to see if it fits in
 TAY
 LDA division_remainder_24 + &01
 SBC divisor_24 + &01
 BCC division_24_bypass_clip
 STA division_remainder_24 + &01	    ;save substraction result as new remainder
 STY division_remainder_24
 INC dividend_24 	                    ;increment result as divisor fits in once
.division_24_bypass_clip
 DEX
 BNE divide_24_loop_clip
 BIT division_result_sign_24
 BPL divide_24_exit_clip
 TXA                                    ;x = 0
 SEC
 SBC dividend_24
 STA dividend_24
 TXA
 SBC dividend_24 + &01
 STA dividend_24 + &01
.divide_24_exit_clip
 RTS

.distance_16                            ;distance dx/dz
 BIT distance_dx + &01                  ;convert dx/dz to absolute numbers
 BPL distance_dx_positive               ;approx. distance    = 0.41 * dx + 0.941246 * dz, ~2.5% accuracy
 LDA #&00                               ;battlezone distance = 0.375 * dx + 1.0 * dz
 SEC                                    ;0.375 = 3/8 approx. ~5% accuracy
 SBC distance_dx
 STA distance_dx
 LDA #&00
 SBC distance_dx + &01
 STA distance_dx + &01
.distance_dx_positive
 BIT distance_dz + &01
 BPL distance_dz_positive
 LDA #&00
 SEC
 SBC distance_dz
 STA distance_dz
 LDA #&00
 SBC distance_dz + &01
 STA distance_dz + &01
.distance_dz_positive
 LDY distance_dz                        ;if dz < dx swap over
 CPY distance_dx
 LDA distance_dz + &01
 SBC distance_dx + &01
 BCS z_greater_than_x
 LDA distance_dx                        ;swap x/z distances
 STA distance_dz
 STY distance_dx
 LDA distance_dx + &01
 LDY distance_dz + &01
 STA distance_dz + &01
 STY distance_dx + &01
.z_greater_than_x
 LDA distance_dx                        ;a/x distance x
 LDX distance_dx + &01
 ASL distance_dx                        ;dx * 2
 ROL distance_dx + &01
 CLC
 ADC distance_dx
 STA distance_dx
 TXA
 ADC distance_dx + &01
 ROR A                                  ;dx * 3, catch c and now / 8
 ROR distance_dx
 LSR A
 ROR distance_dx
 LSR A
 ROR distance_dx
 STA distance_dx + &01
 LDA distance_dz                        ;+dz
 CLC
 ADC distance_dx
 STA d_object_distance
 LDA distance_dz + &01
 ADC distance_dx + &01
 STA d_object_distance + &01
 RTS
