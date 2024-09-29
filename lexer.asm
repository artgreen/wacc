
            list    on
            gen     on
            65816   on
            mcopy   2:ORCAInclude:m16.ORCA
            mcopy   2:ORCAInclude:m16.Tools
            mcopy   m16.utils.asm

            list    off
            copy    tokens.inc.asm
            list    on
            trace   off

;
; get next token from the buffer
;
next        start
p_input     equ     0
p_start     equ     2                   ; ptr to start of token
            csub    ,4

            using   lexer_data
            jsl     prnstate
            jsl     advance
            jsl     prnstate

            lda     inputptr            ; p_input = inputptr
            sta     p_input
            jsr     getch
            cmp     #0                  ; end of input?
            bne     isdigit
            brl     EOI
; is number?
isdigit     cmp     #'0'
            blt     isunder
            cmp     #':'
            bge     isunder
            jsr     getnum
            brl     done
; does the next lexem start with an underscore?
; if so, this has to be an identifier
isunder     anop
            cmp     #'_'                ; is it an _
            beq     isword              ; yes, has to be an identifier
; is this a alphabetic word
isalpha     anop
            cmp     #'A'
            blt     ispunct             ; is it less than A?
            cmp     #'Z'+1              ; is it less than or equal to Z?
            blt     isword              ; yes, tis a word
            cmp     #'a'                ; is it less than a
            blt     ispunct             ; nope, is it a punct?
            cmp     #'z'                ; less than z?
            bgt     ispunct             ; fall through if less than z
isword      anop
            jsr     getalphanum
            brl     done
; is this punctuation
ispunct     anop
            cmp     #'+'
            bne     ispunct1
            cpx     #'+'
            bne     ispunct0
            lda     #T_PLUSPLUS
            brl     punctdone
ispunct0    lda     #T_PLUS
            brl     punctdone
ispunct1    anop
            cmp     #'('
            bne     ispunct2
            lda     #T_LPAREN
            brl     punctdone
ispunct2    cmp     #')'
            bne     ispunct3
            lda     #T_RPAREN
            brl     punctdone
ispunct3    cmp     #'{'
            bne     ispunct4
            lda     #T_LCURLY
            brl     punctdone
ispunct4    cmp     #'}'
            bne     ispunct5
            lda     #T_RCURLY
            brl     punctdone
ispunct5    cmp     #';'
            bne     ispunct6
            lda     #T_SEMI
            brl     punctdone
ispunct6    brk
punctdone   anop
            inc     p_input             ; advance input ptr
            sta     t_type              ; save the token type
            brl     done

; getalphanum()
;
; collect alphanums for an ident or keyword
;
getalphanum anop
            ldy     p_input             ; t_end_ptr = inputptr
            sty     t_end_ptr
            inc     p_input             ; inputptr++
; is it a digit
            jsr     getch               ; is the next char a digit?
            cmp     #'0'
            blt     getword1            ; nope, is it an alpha?
            cmp     #'9'
            bgt     getalphanum         ; refactor this to use blt
;            bra              ; yes, eat more
; is it an alpha
getword1    anop
            cmp     #'A'                ; is it less than A?
            blt     worddone            ; no, we're done
            cmp     #'Z'+1              ; is it less than or equal to Z?
            blt     getalphanum            ; yes
            cmp     #'a'                ; is it less than a
            blt     worddone            ; nope
            cmp     #'z'+1
            blt     getalphanum
; we shouldn't get here
            brk
worddone    anop
; set type here
            lda     #T_IDENT
            sta     t_type
            rts

;
; finish up this round of scanning
; return result of scanning in X
;
done        anop
            lda     p_input             ; inputptr = p_input
            sta     inputptr
            jsl     prnstate
            puts    #'Done',CR=T
            lda     inputptr            ; if inputptr == startptr, we're jammed
            cmp     t_start_ptr
            beq     jammed
            ldx     #0                  ; otherwise return OK
            bra     bye
; scanner is jammed
jammed      anop
            ldx     #$ffff
bye         anop
            ret

; getnum()
;
; collect digits to form an integer
;
;
getnum      anop
            lda     p_input             ; t_end_ptr = inputptr
            sta     t_end_ptr
            inc     p_input             ; inputptr++
            jsr     getch               ; is the next char a digit?
            cmp     #'0'
            bcc     getnum1             ; nope, we're done
            cmp     #':'
            bcs     getnum1             ; nope, we're done
            bra     getnum              ; yes, eat more
getnum1     anop
            lda     #T_NUMBER           ; type = T_NUMBER
            sta     t_type
            rts

; getch()
;
; get the next word from the input stream. Increment column number.
;   inputs: none
;   return:         A = byte of input
;                   X = byte of next input char (look ahead)
;   notes:          Y is not preserved
;
getch       anop
            inc     colnum              ; col ++
            lda     (p_input)           ; get char
            tay                         ; save in Y
            xba                         ; swap bytes in C
            and     #$7f                ; clear top 8 bits
            tax                         ; save look ahead in X
            tya                         ; restore C
            and     #$7f                ; clear top 8 bites
            rts
; we've consumed all the input
EOI         anop
            puts    #'End of input',CR=T
            brl     done
            end     ; next

*
* Initialize the lexer
* Input: pointer to input area on stack
* Output: None
*
lexer_init  start
            using   lexer_data

            csub    (2:inptr),0
            lda     inptr               ; get input ptr
            sta     inputptr            ; save it
            dec     a                   ; save lastnewline
            sta     lastnewline         ;
            lda     #1                  ; linenum = 1
            sta     linenum
            stz     colnum              ; col = 0

            pea     2
            lda     inputptr
            pha
            pea     48
            jsl     hexdump
            ret
            end     ; lexer_init
*
* Advance the input pointer
* Input: None
* Output: Leaves the input pointer at the next non-whitespace char
*
advance     start
p_input     equ     0
last_nl     equ     2

            using   lexer_data
            csub    ,4

            lda     inputptr            ; p_input = inputptr
            sta     p_input
            stz     t_type              ; type = 0
; move past whitespace
skipwhite   lda     (p_input)
            and     #$7F
            cmp     #32
            beq     space
            cmp     #9
            beq     space
            cmp     #10
            beq     space
            bra     notwhite            ; not a space
space       inc     p_input             ; was a space
            bra     skipwhite           ; ignore it
notwhite    anop
            lda     p_input             ; startptr = inputptr
            sta     t_start_ptr
            lda     lastnewline         ; last_nl = lastnewline
            sta     last_nl
            lda     (p_input)           ; get current char
            and     #$7f
            cmp     #13                 ; is it a newline?
            bne     found
            inc     linenum             ; yes, linenum++
            lda     t_start_ptr         ; last_nl = startptr
            sta     last_nl
            inc     p_input             ; inputptr++
            bra     notwhite           ; and try again
found       anop
            lda     t_start_ptr         ; calculate column num
            sta     t_end_ptr
            sec
            sbc     last_nl             ; col = startptr - lastnl - 1
            dec     a
            sta     colnum
            lda     last_nl             ; lastnewline = last_nl
            sta     lastnewline
            lda     p_input             ; startptr = inputptr
            sta     inputptr
            ret
            end     ; advance
            trace   off

prntoken    start
p_input     equ     0
p_end       equ     2

            using   lexer_data
            csub    ,4

            puts    #'Token = '
            lda     t_start_ptr
            sta     p_input
            lda     t_end_ptr
            inc     a
            sta     p_end
prn0        lda     (p_input)
            and     #$7f
            pha
            jsl     SysCharOut
            inc     p_input
            lda     p_input
            cmp     p_end
            blt     prn0
            putcr
            ret
            end

prnstate    start
            using   lexer_data
            puts    #'lexer state: ip='
            put2    inputptr,#4
            puts    #' start='
            put2    t_start_ptr,#4
            puts    #' end='
            put2    t_end_ptr,#4
            puts    #' type='
            put2    t_type,#2
            puts    #' line='
            put2    linenum,#4
            puts    #' col='
            put2    colnum,#3
            puts    #' lastnl='
            put2    lastnewline,#4
            putcr
            rtl
            end     ; prnstate

            list    off
            trace   off
lexer_data  data
*
* lexer state
*
; thy input be here
inputptr    dc      i4'0'
; current token info
t_start_ptr dc      i4'0'
t_end_ptr   dc      i4'0'
t_type      dc      i4'0'
; source position tracking
linenum     dc      i4'1'
colnum      dc      i4'0'
lastnewline dc      i4'0'

keyindex    anop
            token   'volatile',8
            token   'continue',8
            token   'unsigned',8
            token   'register',8
            token   'typedef',7
            token   'default',7
            token   'switch',6
            token   'struct',6
            token   'static',6
            token   'sizeof',6
            token   'signed',6
            token   'return',6
            token   'extern',6
            token   'double',6
            token   'short',5
            token   'float',5
            token   'const',5
            token   'break',5
            token   'while',5
            token   'union',5
            token   'void',4
            token   'enum',4
            token   'else',4
            token   'char',4
            token   'case',4
            token   'auto',4
            token   'long',4
            token   'goto',4
            token   'for',3
            token   'int',3
            token   'if',2
            token   'do',2
            dc      i2'0'

            list    off
keywords    anop
k_do        dc c'do'
k_if        dc c'if'
k_int       dc c'int'
k_for       dc c'for'
k_goto      dc c'goto'
k_long      dc c'long'
k_auto      dc c'auto'
k_case      dc c'case'
k_char      dc c'char'
k_else      dc c'else'
k_enum      dc c'enum'
k_void      dc c'void'
k_union     dc c'union'
k_while     dc c'while'
k_break     dc c'break'
k_const     dc c'const'
k_float     dc c'float'
k_short     dc c'short'
k_double    dc c'double'
k_extern    dc c'extern'
k_return    dc c'return'
k_signed    dc c'signed'
k_sizeof    dc c'sizeof'
k_static    dc c'static'
k_struct    dc c'struct'
k_switch    dc c'switch'
k_default   dc c'default'
k_typedef   dc c'typedef'
k_volatile  dc c'volatile'
k_continue  dc c'continue'
k_unsigned  dc c'unsigned'
k_register  dc c'register'

            end     ; lexer_data


