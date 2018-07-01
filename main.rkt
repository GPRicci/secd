#lang br/quicklang
(require "tokenizer.rkt" "parser.rkt")

; Every language needs to provide a reader module from which racket can get the read-syntax function.
; Once found, racket calls read-syntax passing the path to the source file and a port from which the function can read
; the contents.
; read-syntax returns a syntax object with a single module containing the parse tree. The module also declares the expander
; which will provide the necessary bindings to evaluate the parse tree as if it were a Racket program.
(define (read-syntax path port)
  (define parse-tree (parse path (make-tokenizer port path)))
  (strip-bindings
  #`(module secd-mod secd/expander ; The module can be given any name (like secd-mod). The expander however is very important. In our case, it's the secd/expander.
      #,parse-tree))
  )

(module+ reader (provide read-syntax))