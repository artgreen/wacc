
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

*
* get next character from the buffer
*
getchar     start
            using   lexer_data
            rts
            end     ; next

*
* Initialize the lexer
* Input: pointer to input area on stack
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
            ret
            end     ; lexer_init
*
* Advance the input pointer to the next non-whitespace char
*
advance     start
p_input     equ     0
last_nl     equ     2

            using   lexer_data
            csub    ,4
            lda     inputptr
            sta     p_input
; move past whitespace
skipwhite   lda     (p_input)
            and     #$7F
            cmp     #32
            beq     space
            cmp     #9
            beq     space
; wasn't a space
            bra     notwhite
space       inc     p_input
            bra     skipwhite
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
found       lda     t_start_ptr
            sec
            sbc     last_nl
            dec     a
            sta     colnum
 brk
            ret
            end     ; advance


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
t_type      dc      i2'0'
; source position tracking
linenum     dc      i4'1'
colnum      dc      i4'0'
lastnewline dc      i4'0'

*
* token table
*
tokentable  anop
            dw      '+'
            dc      i1'T_PLUS'
            dw      '-'
            dc      i1'T_DASH'
            dw      '*'
            dc      i1'T_STAR'
            dw      '('
            dc      i1'T_LPAREN'
            dw      ')'
            dc      i1'T_RPAREN'
            dw      '/'
            dc      i1'T_DIV'
            dw      '%'
            dc      i1'T_MOD'
            dw      '.'
            dc      i1'T_DOT'
            dw      '='
            dc      i1'T_EQUAL'
            dw      '!'
            dc      i1'T_BANG'
            dw      '&'
            dc      i1'T_AND'
            dw      '|'
            dc      i1'T_BAR'
            dw      '^'
            dc      i1'T_CARET'
            dw      '~'
            dc      i1'T_TILDE'
            dw      ','
            dc      i1'T_COMMA'
            dw      ':'
            dc      i1'T_COLON'
            dw      '?'
            dc      i1'T_TERNARY'
            dw      '['
            dc      i1'T_LBRACKET'
            dw      ']'
            dc      i1'T_RBRACKET'
            dw      '>'
            dc      i1'T_GREATER'
            dw      '<'
            dc      i1'T_LESSTHAN'
            dw      '{'
            dc      i1'T_LCURLY'
            dw      '}'
            dc      i1'T_RCURLY'
            dw      '#'
            dc      i1'T_HASH'
            dw      '++'
            dc      i1'T_PLUSPLUS'
            dw      '--'
            dc      i1'T_DASHDASH'
            dw      '+='
            dc      i1'T_PLUSEQUAL'
            dw      '-='
            dc      i1'T_MINUSEQ'
            dw      '*='
            dc      i1'T_STAREQUAL'
            dw      '/='
            dc      i1'T_DIVEQUAL'
            dw      '%='
            dc      i1'T_MODEQUAL'
            dw      '=='
            dc      i1'T_EQEQ'
            dw      '>='
            dc      i1'T_GTEQUAL'
            dw      '<='
            dc      i1'T_LTEQUAL'
            dw      '&&'
            dc      i1'T_ANDAND'
            dw      '||'
            dc      i1'T_BARBAR'
            dw      '<<'
            dc      i1'T_LSHIFT'
            dw      '>>'
            dc      i1'T_RSHIFT'
            dw      '!='
            dc      i1'T_NOTEQUAL'
            dw      '->'
            dc      i1'T_DEREF'
            dw      'do'
            dc      I1'T_DO'
            dw      'if'
            dc      I1'T_IF'
            dw      'int'
            dc      I1'T_INT'
            dw      'for'
            dc      I1'T_FOR'
            dw      'goto'
            dc      I1'T_GOTO'
            dw      'long'
            dc      I1'T_LONG'
            dw      'auto'
            dc      I1'T_AUTO'
            dw      'case'
            dc      I1'T_CASE'
            dw      'char'
            dc      I1'T_CHAR'
            dw      'else'
            dc      I1'T_ELSE'
            dw      'enum'
            dc      I1'T_ENUM'
            dw      'void'
            dc      I1'T_VOID'
            dw      'union'
            dc      I1'T_UNION'
            dw      'while'
            dc      I1'T_WHILE'
            dw      'break'
            dc      I1'T_BREAK'
            dw      'const'
            dc      I1'T_CONST'
            dw      'float'
            dc      I1'T_FLOAT'
            dw      'short'
            dc      I1'T_SHORT'
            dw      'double'
            dc      I1'T_DOUBLE'
            dw      'extern'
            dc      I1'T_EXTERN'
            dw      'return'
            dc      I1'T_RETURN'
            dw      'signed'
            dc      I1'T_SIGNED'
            dw      'sizeof'
            dc      I1'T_SIZEOF'
            dw      'static'
            dc      I1'T_STATIC'
            dw      'struct'
            dc      I1'T_STRUCT'
            dw      'switch'
            dc      I1'T_SWITCH'
            dw      'default'
            dc      I1'T_DEFAULT'
            dw      'typedef'
            dc      I1'T_TYPEDEF'
            dw      'register'
            dc      I1'T_REGISTER'
            dw      'unsigned'
            dc      I1'T_UNSIGNED'
            dw      'continue'
            dc      I1'T_CONTINUE'
            dw      'volatile'
            dc      I1'T_VOLATILE'
            dc      i2'00'
            end     ; lexer_data


