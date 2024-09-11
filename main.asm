
            list    on
            gen     on
            65816   on
            mcopy   m16.ORCA

main        start
            phk
            plb
            jsr     init

            puts    #'Hello, world.',cr=t
            pea     $1234
            jsl     next
            puts    #'Shutting down...',cr=t
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
            end     ; input_area

