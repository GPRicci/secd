#lang br/quicklang
(require "tokenizer.rkt" "parser.rkt")

; This module defines a dialect for the secd language. It can be used with the lang line #lang secd/parse-only
; and it will show the produced parse tree in the output.
(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
   #`(module secd-parset-mod secd/parse-only
       #,parse-tree)))
(module+ reader (provide read-syntax))

; The expander just passes the parse tree as a datum to prevent it from being evaluated.
(define-macro (parse-only-mb PARSE-TREE)
  #'(#%module-begin
     'PARSE-TREE))
(provide (rename-out [parse-only-mb #%module-begin]))