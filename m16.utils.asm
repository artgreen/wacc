
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
