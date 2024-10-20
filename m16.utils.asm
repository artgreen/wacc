
;
; Create a token index record
;
; token   'volatile',8
;
            MACRO
&LAB        token   &t,&l
            dc      i2'&l'
            dc      i2'k_&t'
            dc      i2't_&t'
            mexit

;
; compare A with &c1. if not equal, go to next compare,
; otherwise load token code &t1 and exit
;
; cmp1 '{',#T_LCURLY
;
            macro
&lab        cmp1 &c1,&t1
~a&SYSCNT   cmp     #'&c1'
            bne     ~z&SYSCNT
            lda     &t1
            brl     punctdone
~z&SYSCNT   anop
            mexit
;
; compare A with &c1. if not equal, go to next compare.
; if equal, compare with &c2:
;   if equal, return &t2
;   else return &t1
;
; cmp2 '^','=',#T_CARET,#T_CARETEQ
;
            macro
&lab        cmp2 &c1,&c2,&t1,&t2
~a&SYSCNT   cmp     #'&c1'
            bne     ~c&SYSCNT
            cpx     #'&c2'
            bne     ~b&SYSCNT
            lda     &t2
            brl     fixinput
~b&SYSCNT   lda     &t1
            brl     punctdone
~c&SYSCNT   anop
            mexit
;
; compare A with &c1. if not equal, go to next compare.
; if equal, compare with &c2:
;   if equal, return &t2
;   else return &t1
;
; cmps '/','/',#T_LINECMT
;
            macro
&lab        cmps    &c1,&c2,&t1
~a&SYSCNT   cmp     #'&c1'
            bne     ~z&SYSCNT
            cpx     #'&c2'
            bne     ~z&SYSCNT
            lda     &t1
            brl     fixinput
~z&SYSCNT   anop
            mexit
;
; Return token code matching a three way compare
;
; cmp3 '+','+','=',#T_PLUS,#T_PLUSPLUS,#T_PLUSEQUAL
;
            macro
&lab        cmp3 &c,&c1,&c2,&t1,&t2,&t3
~a&SYSCNT   anop
; compare A vs c
            cmp     #'&c'
; not a match, move on
            bne     ~z&SYSCNT
; matched. now compare second char
            cpx     #'&c1'
            beq     ~b&SYSCNT
; not a match, try c2
            cpx     #'&c2'
            beq     ~c&SYSCNT
; must be c
            lda     &t1
            brl     punctdone
~b&SYSCNT   anop
            lda     &t2
            brl     fixinput
~c&SYSCNT   anop
            lda     &t3
            brl     fixinput
~z&SYSCNT   anop
            mexit

;
; Return token code matching a three way compare
;
; cmp4 '-','-','=','>',#T_DASH,#T_DASHDASH,#T_DASHEQUAL,#T_DEREF
;
            macro
&lab        cmp4 &c,&c1,&c2,&c3,&t1,&t2,&t3,&t4
~a&SYSCNT   anop
; compare A vs c
            cmp     #'&c'
; not a match, move on
            bne     ~z&SYSCNT
; matched. now compare second char
            cpx     #'&c1'
            beq     ~b&SYSCNT
; not a match, try c2
            cpx     #'&c2'
            beq     ~c&SYSCNT
; not a match, try c3
            cpx     #'&c3'
            beq     ~d&SYSCNT
; must be c
            lda     &t1
            brl     punctdone
~b&SYSCNT   anop
            lda     &t2
            brl     fixinput
~c&SYSCNT   anop
            lda     &t3
            brl     fixinput
~d&SYSCNT   anop
            lda     &t4
            brl     fixinput
~z&SYSCNT   anop
            mexit



; GG trace to screen, 0=off, 1=on
        macro
&lab    settrace &v
        pea     &v
        ldx     #$11ff
        jsl     $e10000
        mexit
; turn tracing display on
        macro
&lab    toff
        pea     0
        ldx     #$11ff
        jsl     $e10000
        mexit
; turn tracing display off
        macro
&lab    ton
        pea     1
        ldx     #$11ff
        jsl     $e10000
        mexit

; set X,Y register width to 8 or 16 bits
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
; set Acc width to 8 or 16 bits
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

;
; compare A with &c1. if not equal, go to next compare,
; otherwise load token code &t1 and exit
;
; cmp1 '{',#T_LCURLY
;
            macro
&lab        dump    &a1,&l1
~a&SYSCNT   lda     #>&a1
            xba
            and     #$7f
            pha
            lda     #<&a1
            pha
            pea     &l1
            jsl     hexdump
~z&SYSCNT   anop
            mexit



