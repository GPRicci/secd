#lang br
(require brag/support)

; To keep the lexing rules tidy, two abbreviations are defined.
; The first one contains all the reserved terms of the language. These are the identifiers of the supported functions and (since we are parsing S-expressions) the parentheses "(" and ")".
; The second one, defines a sequence of one or more digits, which will help us define an integer.
(define-lex-abbrev reserved-terms (:or "INT_CONST" "ADD" "SUB" "(" ")"))
(define-lex-abbrev digits (:+ (char-set "0123456789")))

(define secd-lexer
  (lexer-srcloc
   [(:or whitespace "\n") (token lexeme #:skip? #t)] ; We are going to ignore whitespace and line-breaks.
   [reserved-terms (token lexeme lexeme)]            ; Lexing the reserved terms is our top priority.
   [digits (token 'INTEGER (string->number lexeme))] ; An integer is the numeric value of a sequence of digits.
   ))
(provide secd-lexer)