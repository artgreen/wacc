
            list    off
            gen     on
            65816   on
            mcopy   2:ORCAInclude:m16.ORCA
            mcopy   2:ORCAInclude:m16.Tools
            mcopy   2:ORCAInclude:m16.GS.OS
            mcopy   m16.utils.asm

            copy    common.inc.asm

main        start
            using   common
            memory  long
            index   long

            phk
            plb

            jsr     init
            bcc     main0
            brl     abort
main0       anop
            ph4     io_ptr
            jsl     lexer_init
            bcc     main1
            brl     abort
main1       jsr     openfile
            bcs     openfail
            jsl     l_dumpinput
;             jsl     prnkeyindex
again       anop
            jsl     prnstate

            jsl     next
            cpx     #E_EOI
            beq     exit
            cpx     #0
            beq     again1
            brl     abort
again1      jsl     prntoken
            bra     again
exit        anop
            jsl     prntoken
            puts    #'All done',CR=T
            jsr     shutdown
            lda     #0              ; return 0
            rtl
openfail    anop
            and     #$7f
            jsl     binhex
            sta     openmsgend-2
            stx     openmsgend-1
            puts    openmsg-1,CR=T
abort       anop
            txa
            jsl     binhex
            sta     abortmsgend-2
            stx     abortmsgend-1
            puts    abortmsg-1,CR=T
            lda     #1
            rtl
openmsg     dw      'File open failed: $00'
openmsgend  anop
abortmsg    dw      'Abort... $00'
abortmsgend anop

init        anop
; start up IO
            jsl     SystemEnvironmentInit
            jsl     SysIOStartup
; set up memory manager
            pea     0               ; save space on stack for user ID
            ~MMStartup
            pla                     ; get user id
            ora     #$0100          ; set aux id field to 1
            sta     ~USER_ID        ; save this user id
            sta     userid

; init the heap and get us some ram for input
            jsl     ~MM_INIT        ; initialize the heap manager
            malloc  max_input
            bcs     failed          ; ruh-roh
            sta     io_ptr          ; remember where our
            sta     r_buffer
            stx     io_ptr+2        ; memory is
            stx     r_buffer+2
failed      anop
            ldx     #E_NOMEM
            rts
shutdown    anop
; shut down heap (probably not necessary)
            jsl     ~MM_DISPOSEALL
; shut down memory manager
; this is a work around until i can figure out why ~MMShutdown won't assemble
            ph2     ~USER_ID
            ldx     #$0302
            jsl     $E10000
; shut down system IO
            jsl     SysIOShutDown
; sleepy time
            rts
            end     ; main

;
; open a file
;
openfile    start
            using   common
            open    open_pcb
            bcs     exit

            lda     o_ref_num
            sta     r_ref_num
            read    read_pcb
            bcs     exit
            close   open_pcb
exit        anop
            rts
            end     ; openfile

common      data
open_pcb    anop
o_ref_num   ds      2                   ; reference number
o_path_name dc      i4'filename'
o_io_buf    ds      4                   ; I/O buffer

read_pcb    anop
r_ref_num   ds      2                   ; reference number
r_buffer    dc      i4'0'
r_want      dc      i4'1024'
r_got       dc      i4'0'

filename    dw      'test.c'            ; test input file name
hexstring   dw      '0000'
io_ptr      dc      i4'$FFFFffff'       ; pointer to malloc'ed i/o area
max_input   dc      i2'1024'            ; max input size
userid      dc      i2'0'               ; our user id
            end

