#lang br/quicklang
(require brag/support "tokenizer.rkt")

; This module defines a dialect for the secd language. It can be used with the lang line #lang secd/tokenize-only
; and it will show the tokens produced by the lexing rules in the output.
(define (read-syntax path port)
  (define tokens (apply-tokenizer make-tokenizer port))
  (strip-bindings
   #`(module secd-tokens-mod secd/tokenize-only
       #,@tokens)))
(module+ reader (provide read-syntax))

; The expander just arranges the tokens in a list to be displayed in the output.
(define-macro (tokenize-only-mb TOKEN ...)
  #'(#%module-begin
     (list TOKEN ...)))
(provide (rename-out [tokenize-only-mb #%module-begin]))