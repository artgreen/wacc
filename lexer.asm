
            list    on
            gen     on
            65816   on
            mcopy   2:ORCAInclude:m16.ORCA
            mcopy   2:ORCAInclude:m16.Tools
            mcopy   m16.utils.asm

            list    off
            copy    tokens.inc.asm
            copy    common.inc.asm
            list    off
            trace   off

;
; get next token from the buffer
;
next        start
p_input     equ     1                   ; ptr to current place in input
p_start     equ     3                   ; ptr to start of token

            using   lexer_data

            csub    ,6
            stz     status              ; set result to a-ok
;             jsl     prnstate
            jsl     advance             ; go find the start of the next lexem
;             jsl     prnstate
            lda     inputptr            ; p_input = inputptr
            sta     p_input
            jsr     getch               ; get next char of input
            cmp     #0                  ; end of input?
            bne     isdigit             ; nope!
            brl     EOI                 ; yep!
; does this lexem start with a number?
isdigit     cmp     #'0'
            blt     isunder             ; < '0'
            cmp     #':'
            bge     isunder             ; > '9'
            jsr     getnum              ; go get us some numbers, boys!
            brl     done
; does this lexem start with an underscore?
; if so, this has to be an identifier
isunder     anop
            cmp     #'_'                ; is it an _
            beq     isword              ; yes, has to be an identifier
; does this lexem start with an alpha?
isalpha     anop
            cmp     #'A'
            blt     isop                ; is it less than A?
            cmp     #'Z'+1              ; is it less than or equal to Z?
            blt     isword              ; yes, tis a word
            cmp     #'a'                ; is it less than a
            blt     isop                ; nope, is it a punct?
            cmp     #'z'                ; less than z?
            bgt     isop                ; fall through if less than z
isword      anop
            jsr     getalphanum
            brl     done
; is this an operator
isop        anop
            cmp1 ';',#T_SEMI
            cmp1 '(',#T_LPAREN
            cmp1 ')',#T_RPAREN
            cmp1 '{',#T_LCURLY
            cmp1 '}',#T_RCURLY
            cmp4 '-','-','=','>',#T_DASH,#T_DASHDASH,#T_DASHEQUAL,#T_DEREF
            cmp3 '+','+','=',#T_PLUS,#T_PLUSPLUS,#T_PLUSEQUAL
            cmp3 '&','&','=',#T_AND,#T_ANDAND,#T_ANDEQUAL
            cmp3 '|','|','=',#T_BAR,#T_BARBAR,#T_BAREQUAL
            cmp3 '<','<','=',#T_LESSTHAN,#T_LSHIFT,#T_LTEQUAL
            cmp3 '>','>','=',#T_GREATER,#T_RSHIFT,#T_GTEQUAL
            cmp2 '%','=',#T_MOD,#T_MODEQUAL
            cmp2 '*','=',#T_STAR,#T_STAREQUAL
            cmp2 '/','=',#T_DIV,#T_DIVEQUAL
            cmp2 '!','=',#T_BANG,#T_NOTEQUAL
            cmp2 '=','=',#T_EQUAL,#T_EQEQ
            cmp2 '^','=',#T_CARET,#T_CARETEQ
            cmp1 '.',#T_DOT
            cmp1 '~',#T_TILDE
            cmp1 ',',#T_COMMA
            cmp1 ':',#T_COLON
            cmp1 '?',#T_TERNARY
            cmp1 '[',#T_LBRACKET
            cmp1 ']',#T_RBRACKET
            cmp1 '#',#T_HASH
            cmp  #39            ; can't get ' to work with the cmp1 macro
            bne  isstring
            lda  #T_SNGQUOTE
            brl  punctdone
; is this a string
isstring    anop
; set status to unknown char
            ldx     #E_UNKNOWN
            stx     status
            bra     iseoi
; fix pointers because we sucked up an extra char
; note: column number gets repaired in advance()
fixinput    anop
            inc     p_input             ; advance input ptr
            inc     t_end_ptr           ; adjust the end of the token
; advance pointer, store type and exit
punctdone   anop
            inc     p_input             ; advance input ptr
            sta     t_type              ; save the token type
            brl     done
;
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
            ble     getalphanum         ; yep, eat more
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
            ldx     #E_FATAL
            stx     status
            bra     iseoi
            brk
worddone    anop
; look up if this is a keyword or not
            jsl     iskeyword
            rts
;
; finish up this round of scanning
; return result of scanning in X
;
done        anop
            lda     p_input             ; inputptr = p_input
            sta     inputptr
            lda     status              ; get lexer status
            cmp     #E_EOI              ; are we at the end of input?
            beq     iseoi               ; yup
            cmp     #0                  ; status is ok?
            bne     iseoi               ; nope, preserve status code
            lda     inputptr            ; if inputptr == startptr, we're jammed
            cmp     t_start_ptr
            beq     jammed
iseoi       anop
            ldx     status              ; otherwise return current status
            bra     bye
; scanner is jammed
jammed      anop
            ldx     #E_JAMMED           ; signal that the scanner is jammed
            stx     status
bye         anop
            ret
;
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
;
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
            lda     #E_EOI
            sta     status
            brl     done
            end     ; next
;
; Advance the input pointer
; Input: None
; Output: Leaves the input pointer at the next non-whitespace char
;
advance     start
p_input     equ     1
last_nl     equ     3

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

;
; iskeyword()
;
; returns code or T_IDENT
;
iskeyword   start
p_index     equ     1                   ; pointer to the base of the index
p_keyword   equ     3                   ; pointer to the current keyword
index_y     equ     5                   ; current index into the index
token_len   equ     7                   ; current keyword length
token_code  equ     11                  ; token code for the current keyword
t_size      equ     13                  ; size of the input string
p_input     equ     15
            using   lexer_data

            csub    ,20

; calculate the size of the string in question
            lda     t_end_ptr
            sec
            sbc     t_start_ptr
            inc     a
            sta     t_size
; set up the index loop
            lda     #keyindex           ; save a pointer to the index
            sta     p_index             ; in p_index
            ldy     #0                  ; index_y = 0
            sty     index_y
; start down the index
next_i      anop
            ldy     index_y             ; y = index_y
            lda     (p_index),y         ; get next token len
            bne     next_i1
            brl     end_i               ; we're done if it is zero
next_i1     anop
            sta     token_len           ; remember the token length
            ldy     index_y             ; y = index_y
            iny                         ; point y at the keyword ptr
            iny
            lda     (p_index),y         ; get the keyword addr
            sta     p_keyword           ; save it in p_keyword
            iny                         ; point y at the token code
            iny
            lda     (p_index),y         ; get the token code
            sta     t_type              ; and store in token_code
            iny                         ; move Y to point to the start
            iny                         ; of the next keyword index
            sty     index_y             ; and remember it for later
; compare lengths
            lda     token_len           ; get keyword length
            cmp     t_size              ; compare to the input's length
            bne     next_i
            ldy     #0
            lda     t_start_ptr
            sta     p_input
next_k      lda     (p_keyword),y
            and     #$7f
            memory short
            cmp     (p_input),y
            memory long
            bne     next_i
            iny
            cpy     token_len
            beq     bye
            bne     next_k
done_k      anop

end_i       anop
            lda     #T_IDENT
            sta     t_type
bye         anop
            ret
            end     ; iskeyword


;
; Initialize the lexer
; Input: pointer to input area on stack
; Output: None
;
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
            stz     status              ; status = OK
            pea     2
            lda     #keyindex
            pha
            pea     48
            jsl     hexdump

            pea     2
            lda     inputptr
            pha
            pea     64
            jsl     hexdump
            ret
            end     ; lexer_init

;
; prnkeyindex()
;
; prints out the keyword table
;
prnkeyindex start
p_index     equ     1
p_keyword   equ     3
index_y     equ     5
output      equ     7
token_len   equ     9
token_code  equ     11
            using   lexer_data

            csub    ,15

            lda     #keyindex           ; save a pointer to the index
            sta     p_index             ; in p_index
            ldy     #0                  ; index_y = 0
            sty     index_y

next_i      anop
            ldy     index_y             ; y = index_y
            lda     (p_index),y         ; get next token len
            bne     next_i1
            brl     endindex            ; we're done if it is zero

next_i1     sta     token_len           ; remember the token length

            sta     output              ; print length
            put2    output,#4
            putc    #':'

            ldy     index_y             ; y = index_y
            iny                         ; point y at the keyword ptr
            iny
            lda     (p_index),y         ; get the keyword addr
            sta     p_keyword           ; save it in p_keyword
            iny                         ; point y at the token code
            iny
            lda     (p_index),y         ; get the token code
            sta     token_code          ; and store in token_code
            iny                         ; move Y to point to the start
            iny
            sty     index_y             ; and remember it for later
; print the keyword
            ldy     #0
next_k      lda     (p_keyword),y
            and     #$7f
            pha
            jsl     SysCharOut
            iny
            cpy     token_len
            beq     done_k
            bra     next_k
done_k      anop
            putc    #' '
            put2    token_code,#2
            putcr
            brl     next_i
endindex    anop
            ret
            end     ;prnkeyindex

;
; prntoken()
;
; print the string pointed to by t_start_ptr
;
prntoken    start
p_input     equ     0
p_end       equ     2

            using   lexer_data
            csub    ,4

            puts    #'Token: '
            put2    t_type,#2
            put2    linenum,#2
            putc    #','
            put2    colnum,#2
            puts    #' Value: '
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
            end     ; prntoken

;
; prnstate()
;
; Prints the lexer's current state
;
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
;
; lexer state
;
status      dc      i2'0'               ; the lexer's current status
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
            token   'int',3
            token   'for',3
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


