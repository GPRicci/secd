#lang br/quicklang
(require racket)
(require data/gvector)

; As explained in the main module, the reader prepares a syntax object containing a single module with the parse tree.
; The job of the expander is to provide all the necessary bindings so that the parse tree can be evaluated as a Racket program.
; Since the parse tree is an S-Expression, Racket is perfectly capable of evaluating it as long as the first element of every parenthesized
; expression is a bound procedure indentifier. (Bound is Racket lingo meaning "a defined identifier")
; For example, the following SECD program ((INT_CONST 4) (INT_CONST 5) (ADD)) will be parsed as
; (secd-program (secd-instruction-list (secd-int-const 4) (secd-int-const 5) (secd-add)))
; a perfectly valid Racket S-Expression, therefore, bindings need to be provided for the secd-program, secd-instruction-list, secd-int-const and secd-add
; procedure identifiers (and of course for all the other instruction identifiers).
; We do so by defining functions. Every one of these functions returns a string which contains the Assembler source code to include in the final file.

; Whenever secd-fun is called, a new function will be defined. Its body will be stored in this vector so that later we can include those definitions
; at the top of the file containing the Assembler source code. As the number of function definitions is not known, we will use gvector, an implementation of a growable vector,
; with an initial capacity of 20 items. 
(define funDefs (make-gvector #:capacity 20))

; This function will generate the function definitions from the bodies stored in funDefs.
(define (makeFunDefs)
  (for/fold ([defs ""]
             #:result defs)
            ([i (in-range (gvector-count funDefs))])
    ; For every function body stored in funDefs, we will prepend a label fun<i> and the function preamble, and we will append
    ; the function epilogue.
    ; All the definitions will be accumulated in the string defs, which will be returned as the result.
    (string-append defs
                   "fun" (number->string i) ":\n\tstmfd sp!, {fp, ip, lr}\n\tmov fp, sp\n\n\tstmfd sp!, {r0}\n\n\t"
                   (gvector-ref funDefs i)
                   "mov sp, fp\n\tldmfd sp!, {fp, ip, pc}\n\n")))

; The IF0 instruction will be implemented using conditional branches, for that we will need labels. Each label will have a final numerical identifier
; which relates it to its respective IF0 instruction. This measure is needed to prevent the program from jumping to random labels.
(define ifZIdent 0)

; Every expander needs to export a #%module-begin macro, which is its entry point.
; To prevent naming conflicts, we'll temporarily call this macro secd-mb, and we'll rename it as we export it.
; This macro will match the syntax pattern (secd-program INSTR ...), this will handle the secd-program identifier and it will also
; group the program instructions in the INSTR ... pattern variable. The value of this variable will be replaced at run-time.
(define-macro (secd-mb (secd-program INSTR ...))
  #'(#%module-begin
     
     ; If the program contains functions, it is very important to execute those instructions so that the funDefs vector gets populated.
     ; We do that here and store the resulting Assembler source code in mainBody.
     (define mainBody INSTR ...)

     ; The final program's assembler source code is produced here.
     ; It starts with a .data section where the format string "%d\n" is declared. This will be used to show the result of the program.
     ; A .text section follows, declaring the .global main function and declaring the use of an .extern function called printf.
     ; All that is followed by the function definitions returned by makeFunDefs.
     ; After that, we include the label and preamble for the main function, followed by its body and epilogue, which includes a call to printf
     ; using the format string defined in the .data section and the value at the top of the stack as an argument.
     (define programAssemblerSource
       (string-append ".data\n\tfstr: .asciz \"%d\\n\"\n\n.text\n.global main\n.extern printf\n\n"
                      (makeFunDefs)
                      "main:\n\n\tstmfd sp!, {fp, ip, lr}\n\tmov fp, sp\n\n\t"
                      mainBody
                      "ldmfd sp!, {r1}\n\tldr r0, =fstr\n\tbl printf\n\n\tmov sp, fp\n\tldmfd sp!, {fp, ip, pc}\n"))
     
     ; Finally, we write the source code to a file called program.s, replacing it if it already exists.
     ; NOTE: This file will be saved in the same location where your SECD source is stored. If you compile code from an unsaved file using DrRacket,
     ; the file will be stored in your user folder. In Windows this looks something like C:\Users\<user_name>\ and in Linux it will be /home/<user_name>/ (or ~/).
     (display-to-file
      programAssemblerSource
      "program.s"
      #:mode 'text
      #:exists 'replace)

     ; Some feedback telling the user that we are done compiling.
     (displayln "Code compiled to file program.s")))
(provide (rename-out [secd-mb #%module-begin])) ; Rename secd-mb to #%module-begin and export it.

; This function binds the secd-instruction-list identifier. Since functions are executed inside out, the instructions argument
; will contain a list with the assembler code produced by the execution of each instruction.
(define (secd-instruction-list . instructions)
  (for/fold ([instrsAsmCode ""]
             #:result instrsAsmCode)
            ([currInstr instructions])
    ; We accumulate all the resulting code in a single string and return it.
    (string-append instrsAsmCode currInstr)))
(provide secd-instruction-list)

; This function binds the secd-int-const identifier.
(define (secd-int-const value)
  ; The numerical value of "value" is loaded to R0 and then R0 is pushed to the stack using STMFD.
  (string-append "ldr r0, =" (number->string value) "\n\tstmfd sp!, {r0}\n\n\t"))
(provide secd-int-const)

; This function binds the secd-add identifier.
(define (secd-add)
  ; The top two values stored in the stack are loaded to R0 and R1, then they are added with ADD R0, R1 which stores the result in R0.
  ; The result (in R0) is then pushed to the stack using STMFD.
  "ldmfd sp!, {r0, r1}\n\tadd r0, r1\n\tstmfd sp!, {r0}\n\n\t")
(provide secd-add)

; This function binds the secd-sub identifier.
(define (secd-sub)
  ; The top two values stored in the stack are loaded to R0 and R1, then they are subtracted with SUB R0, R1 which stores the result in R0.
  ; The result (in R0) is then pushed to the stack using STMFD.
  "ldmfd sp!, {r0, r1}\n\tsub r0, r1\n\tstmfd sp!, {r0}\n\n\t")
(provide secd-sub)

; This function binds the secd-fun identifier.
(define (secd-fun . instructions)
  ; The code produced by the instructions in the function definition is accumulated and stored in funDefBody.
  (define funDefBody (for/fold ([instrsAsmCode ""]
                                #:result instrsAsmCode)
                               ([currInstr instructions])
                       (string-append instrsAsmCode currInstr)))
  ; Store the function body in the funDefs vector.
  (gvector-add! funDefs funDefBody)

  ; This function needs only return the code that pushes the address of the label that identifies the defined function.
  (string-append "ldr r0, =fun" (number->string (- (gvector-count funDefs) 1)) "\n\tstmfd sp!, {r0}\n\n\t"))
(provide secd-fun)

; This function binds the secd-return identifier.
(define (secd-return)
  ; Pop the value at the top of the stack to the register R0. The function calling convention in ARM specifies that function return values should be stored in R0.
  "ldmfd sp!, {r0}\n\n\t")
(provide secd-return)

; This function binds the secd-apply identifier.
(define (secd-apply)
  ; The element at the top of the stack is the function argument. Pop it to R0. The next element is the address to the function's label, pop it to R7.
  ; Call the function using BLX and then push the returned value (in R0) to the stack.
  "ldmfd sp!, {r0, r7}\n\tblx r7\n\tstmfd sp!, {r0}\n\n\t")
(provide secd-apply)

; This function binds the secd-if0 identifier.
(define (secd-if0 trueInstructions falseInstructions)
  (define ifZIStr (number->string ifZIdent))
  ; The value at the top of the stack is used as argument. We check if its value is 0 using TST.
  ; If its value is 0, then the Z flag will be set to 1, meaning that the EQ (Equal) condition is true.
  ; Otherwise, Z=0 and the condition NE (Not-Equal) is true.
  ; So, if the value is not 0 we branch off to the label "ifnz<ident>", executing the instructions of the false branch. Otherwise the execution continues
  ; sequentially, executing the instruction of the true branch and then branches of to the "endifz<ident>" label.
  (string-append "ldmfd sp!, {r0}\n\ttst r0, r0\n\tbne ifnz" ifZIStr "\n\n\t"
                 trueInstructions
                 "b endifz" ifZIStr "\n\n\tifnz" ifZIStr ":\n\n\t"
                 falseInstructions
                 "endifz" ifZIStr ":\n\n\t"))
(provide secd-if0)