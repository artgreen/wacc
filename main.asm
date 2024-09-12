
            list    on
            gen     on
            65816   on
            mcopy   m16.ORCA

main        start
            using   input_area
            phk
            plb
            jsr     init

;            puts    #'Hello, world.',cr=t
;             pea     buffer
            ldy     #$1001
            jsl     next
            ldy     #$1002
;            puts    #'Shutting down...',cr=t
            jsr     shutdown
            lda     #0
            rtl

init        jsl     SystemEnvironmentInit
            jsl     SysIOStartup
            rts

shutdown    jsl     SysIOShutDown
            rts
            end
            end     ; main

input_area  data
buffer      dc      c'int main(void) { return 0; }'
            dc      i1'0'
nextword    dc      i4'0'
            end     ; input_area

