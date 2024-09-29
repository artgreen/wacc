
        MACRO
&LAB    token   &t,&l
        dc      i2'&l'
        dc      i2'k_&t'
        dc      i2't_&t'
        mexit

        macro
&lab    settrace &v
        pea     &v
        ldx     #$11ff
        jsl     $e10000
        mexit

        macro
&lab    toff
        pea     0
        ldx     #$11ff
        jsl     $e10000
        mexit

        macro
&lab    ton
        pea     1
        ldx     #$11ff
        jsl     $e10000
        mexit

        MACRO
&LAB    INDEX   &L
        LCLC    &R
&R      AMID    &L,1,2
        AIF     "&R"="SH",.A
        AIF     "&R"="sh",.A
&LAB    REP     #%00010000
        LONGA   ON
        MEXIT
.A
&LAB    SEP     #%00010000
        LONGA   OFF
        MEND

        MACRO
&LAB    MEMORY  &L
        LCLC    &R
&R      AMID    &L,1,2
        AIF     "&R"="SH",.A
        AIF     "&R"="sh",.A
&LAB    REP     #%00100000
        LONGA   ON
        MEXIT
.A
&LAB    SEP     #%00100000
        LONGA   OFF
        MEND
