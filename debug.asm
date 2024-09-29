
            list    on
            gen     on
            65816   on
            mcopy   2:ORCAInclude:m16.ORCA
            mcopy   m16.utils.asm

hexdump     start
            sub     (4:address,2:count),0
            pei     address+2
            pei     address
            pei     count
            ldx     #$0fff
            jsl     $e10000
            ret
            end     ; hexdump