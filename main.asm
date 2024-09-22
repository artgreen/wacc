
            list    on
            gen     on
            65816   on
            mcopy   2:ORCAInclude:m16.ORCA
            mcopy   2:ORCAInclude:m16.Tools
            mcopy   m16.utils.asm

main        start
            using   input_area
            using   common
            memory  long
            index   long

            phk
            plb
            jsr     init
            bcs     abort

;            per     buffer
;            jsl     next

exit        anop
            jsr     shutdown
            lda     #0              ; return 0
            rtl
abort       lda     #1
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
            jsl     ~MM_INIT        ; initialize the heap manager
            ph2     0
            lda     max_input
            pha
            jsl     ~NEW            ; ask for it
            bcs     failed
            stx     bufferbank
            sta     bufferptr

            trace   off
            putcr
            puts    #'Input buffer: '
            put2    bufferbank,#1,
            puts    #'/'
            put2    bufferptr,#1,CR=T
            putcr
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
            rts

            end     ; main

common      data
max_input   dc      i2'1024'
userid      dc      i2'0'
bufferbank  dc      i2'0'
bufferptr   dc      a'0'
            end

input_area  data
buffer      anop
            dc      c'  123456789  int main(void) { return 0; }',i1'0'
            end     ; input_area

