#lang br

; When someone uses the secd language by writing #lang secd, Racket looks for a reader module
; in the secd package and requires a read-syntax function from it.
(module reader br
  (require "reader.rkt")
  (provide read-syntax))