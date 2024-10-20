
            list    off
            gen     on
            65816   on
            mcopy   2:ORCAInclude:m16.ORCA
            mcopy   m16.utils.asm

            trace off

hexdump     start
            sub     (4:address,2:count),0
            pei     address+2
            pei     address
            pei     count
            ldx     #$0fff
            jsl     $e10000
            ret
            end     ; hexdump

;================================================================================
;
;binhex: CONVERT BINARY BYTE TO HEX ASCII CHARS
;
;   ————————————————————————————————————
;   Preparatory Ops: .A: byte to convert
;
;   Returned Values: .A: MSN ASCII char
;                    .X: LSN ASCII char
;                    .Y: entry value
;   ————————————————————————————————————
; Thanks to BigDumbDinosaur 6502.org
binhex      start
            pha                     ; save
            and     #$0F            ; mask
            tax                     ; save
            pla                     ; recover first
            lsr     a
            lsr     a
            lsr     a
            lsr     a
            pha                     ; save msn
            txa                     ; LSN
            jsl     binhex1
            tax
            pla
binhex1     cmp     #$0a
            bcc     binhex2
            adc     #$66
binhex2     eor     #%00110000
            rtl
            end     ; binhex
