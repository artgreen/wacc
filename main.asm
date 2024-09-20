
            list    on
            gen     on
            65816   on
            mcopy   m16.ORCA

main        start
            using   input_area
            phk
            plb
            jsr     init

            pea     buffer
            jsl     next

            jsr     shutdown
            lda     #0
            rtl

init        anop
            jsl     SystemEnvironmentInit
            jsl     SysIOStartup
            lda     #buffer
            sta     startptr
            rts

shutdown    jsl     SysIOShutDown
            rts

            end     ; main

input_area  data
startptr    dc      i4'0'
buffer      anop
            dc      c'    int main(void) { return 0; }',i1'0'
            end     ; input_area

