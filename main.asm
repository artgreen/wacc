
            list    off
            gen     on
            65816   on
            mcopy   2:ORCAInclude:m16.ORCA
            mcopy   2:ORCAInclude:m16.Tools
            mcopy   2:ORCAInclude:m16.GS.OS
            mcopy   m16.utils.asm

            copy    common.inc.asm

main        start
            using   test_data
            using   common
            memory  long
            index   long

            phk
            plb
            jsr     init
            bcs     abort

            pea     test_input
            jsl     lexer_init
            bcs     abort
            jsr     openfile
            bcs     openfail
;             jsl     prnkeyindex
again       jsl     next
            cpx     #E_EOI
            beq     exit
            cpx     #0
            bne     abort
            jsl     prntoken
            bra     again
exit        anop
            jsl     prntoken
            puts    #'All done',CR=T
            jsr     shutdown
            lda     #0              ; return 0
            rtl
openfail    anop
            puts    #'File open failed',CR=T
abort       anop
            puts    #'Abort...',CR=T
            lda     #1
            rtl

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
            ph2     0               ; low word of size
            lda     max_input       ; high word of size (<=$ffff total)
            pha                     ; push onto stack
            jsl     ~NEW            ; ask for it
            bcs     failed          ; ruh-roh
            stx     bufferbank      ; remember where our
            sta     bufferptr       ; memory is

failed      anop
            rts

;
; dump input area
;
dumpinput   anop

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
            open    open_pbc
            rts
            end     ; openfile

common      data
open_pbc    anop
o_ref_num   ds      2
o_path_name dc      i4'filename'
o_io_buf    ds      4


filename    dw      'test1.c'            ; test input file

io_buffer   dc      i4'0'

max_input   dc      i2'1024'            ; max input size
userid      dc      i2'0'               ; our user id
bufferbank  dc      i2'0'               ; address of input area
bufferptr   dc      a'0'
            end

test_data   data
test_input  dc      c'int main(void)',i1'13',c'{ int var123; p = ''a''; int *p; printf("%s\n", "string here"); // Foo line',i1'13',c'p->v = 1; var123++; var123 = 12345; /*hi*/ return 0; } // Fin',i1'0'
            end     ; input_area

