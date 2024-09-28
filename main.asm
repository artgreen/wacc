
            list    on
            gen     on
            65816   on
            mcopy   2:ORCAInclude:m16.ORCA
            mcopy   2:ORCAInclude:m16.Tools
            mcopy   m16.utils.asm

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
            jsl     next
            jsl     prntoken
            brk
exit        anop
            jsr     shutdown
            lda     #0              ; return 0
            rtl
abort       anop
            puts    #'Abort...',CR=T
            lda     #1
            rtl

            trace on
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

            trace   off
;             putcr
;             puts    #'Input buffer: '
;             put2    bufferbank
;             cout    #'/'
;             brk
;             put2    bufferptr,#1,CR=T
;             putcr
failed      anop
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

common      data
max_input   dc      i2'1024'            ; max input size
userid      dc      i2'0'               ; our user id
bufferbank  dc      i2'0'               ; address of input area
bufferptr   dc      a'0'
            end

test_data   data
test_input  dc      c'  123456789  int main(void) { return 0; }',i1'0'
;test_input  dc      c'     ',i2'0'
            end     ; input_area

