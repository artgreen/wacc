
            list    on
            gen     on
            65816   on
            mcopy   m16.ORCA

            copy    tokens.inc.asm

*
* next
*
next        start
            using   input_area
            using   lexer_data

            ldx     #$0             ; start at bye 0
loop        lda     buffer,x        ; get a byte from buffer
            beq     bye             ; if null, bail
            pha                     ; save C
            pha                     ; push C for print
            jsl     SysCharOut      ; print
            pla                     ; pull C
            xba                     ; swap bytes in C
            beq     bye             ; if null, bail
            pha                     ; push C
            jsl     SysCharOut      ; print
            inx                     ; x += 2
            inx
            bne     loop            ; unless we've wrapped, loop
bye         lda     #$0D            ; load ^M
            pha                     ; push C
            jsl     SysCharOut      ; print
            rtl                     ; return to caller
            end     ; next

lexer_data  data
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


