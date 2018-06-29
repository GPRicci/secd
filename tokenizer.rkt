#lang br
(require "lexer.rkt" brag/support)

; The tokenizer is an important part of the reader, it consumes characters from an input port (like a source file)
; and using a lexer, it groups those characters into tokens that the parser can use to build the parse tree.
; The tokenizer and the underlying lexer filter out all the patterns of characters that are not relevant to the language
; so that the parser can focus better on its job.

; The parser expects the tokenizer to provide a make-tokenizer function which returns a next-token function
; which can be used by the parser to get the next token to parse from the input port.
(define (make-tokenizer iport [path #f])
  (port-count-lines! iport)
  (lexer-file-path path)
  (define (next-token) (secd-lexer iport))
  next-token)
(provide make-tokenizer)