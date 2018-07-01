#lang br/quicklang
(require racket)

; As explained in the main module, the reader prepares a syntax object containing a single module with the parse tree.
; The job of the expander is to provide all the necessary bindings so that the parse tree can be evaluated as a Racket program.
; Since the parse tree is an S-Expression, Racket is perfectly capable of evaluating it as long as the first element of every parenthesized
; expression is a bound procedure indentifier.
; For example, the following SECD program ((INT_CONST 4) (INT_CONST 5) (ADD)) will be parsed as
; (secd-program (secd-int-const 4) (secd-int-const 5) (secd-add))
; a perfectly valid Racket S-Expression, therefore, bindings need to be provided for the secd-program, secd-int-const, secd-add (and secd-sub)
; procedure identifiers.
; We do so by defining macros.

; Every expander needs to export a #%module-begin macro, which is its entry point.
; To prevent naming conflicts, we'll temporarily call this macro secd-mb, and we'll rename as we export it.
; This macro will match the syntax pattern (secd-program INSTR ...), this will handle the secd-program identifier and it will also
; group the program instructions in the INSTR ... pattern variable. The value of this variable will be replaced at run-time.
(define-macro (secd-mb (secd-program INSTR ...))
  #'(#%module-begin
     ; The macro opens and writes on a file called "program.s" (replacing it if it exists).
     ; The file starts with a .data section where the format string "%d\n" is declared. This will be used to show the result of the program.
     ; A .text section follows, declaring the .global main function and declaring the use of an .extern function called printf.
     ; The main function starts by storing the FP, IP and LR in the full-descending stack using STMFD.
     (display-to-file
      ".data\n\tfstr: .asciz \"%d\\n\"\n\n.text\n.global main\n.extern printf\n\nmain:\n\n\tstmfd sp!, {fp, ip, lr}\n\n\t"
      "program.s"
      #:mode 'text
      #:exists 'replace)

     ; After writing the preamble for the Assembler program, the rest of the instructions are executed.
     INSTR ...

     ; Once all the instructions are done, the main function will load the top element of the stack (the result of the program)
     ; in the R1 register, and the format string in fstr will be loaded to the R0 register. This will be the arguments for printf
     ; which is called using BL printf.
     ; Finally, the main function ends by restoring the values of FP, IP and LR onto FP, IP and PC.
     (display-to-file
      "ldmfd sp!, {r1}\n\tldr r0, =fstr\n\tbl printf\n\n\tldmfd sp!, {fp, ip, pc}\n"
      "program.s"
      #:mode 'text
      #:exists 'append))) ; From here on, all the macros append content to the already existing "program.s" file.
(provide (rename-out [secd-mb #%module-begin])) ; Rename secd-mb to #%module-begin and export it.

; This macro matches the secd-int-const identifier and the integer value that follows. Represented by the pattern variable VAL.
(define-macro (secd-int-const VAL)
  ; The numerical value of VAL is loaded to R0 and then R0 is pushed to the stack using STMFD.
  #'(display-to-file
     (string-append "ldr r0, =" (number->string VAL) "\n\tstmfd sp!, {r0}\n\n\t")
     "program.s"
     #:mode 'text
     #:exists 'append))
(provide secd-int-const)

; This macro matches the secd-add identifier.
(define-macro (secd-add)
  ; The top two values stored in the stack are loaded to R0 and R1, then they are added with ADD R0, R1 which stores the result in R0.
  ; The result (in R0) is then pushed to the stack using STMFD.
  #'(display-to-file
     "ldmfd sp!, {r0, r1}\n\tadd r0, r1\n\tstmfd sp!, {r0}\n\n\t"
     "program.s"
     #:mode 'text
     #:exists 'append))
(provide secd-add)

; This macro matches the secd-sub identifier.
(define-macro (secd-sub)
  ; The top two values stored in the stack are loaded to R0 and R1, then they are subtracted with SUB R0, R1 which stores the result in R0.
  ; The result (in R0) is then pushed to the stack using STMFD.
  #'(display-to-file
     "ldmfd sp!, {r0, r1}\n\tsub r0, r1\n\tstmfd sp!, {r0}\n\n\t"
     "program.s"
     #:mode 'text
     #:exists 'append))
(provide secd-sub)