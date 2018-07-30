#lang scribble/manual

@title{SECD: A reduced version.}
@author{Gaspar Ricci}

@defmodulelang[secd]

@section{Introduction}

This is an implementation of a compiler for a very small subset of the SECD language. The programs written in this language will be compiled to ARM Assembler.
The resulting program will run the instructions and print the result in the standard output.

As an example. If the source SECD program is:

@verbatim|{
#lang secd
(
 (INT_CONST 56)
 (FUN (IF0 ((FUN (INT_CONST 4) (ADD) (RETURN)) (INT_CONST 3) (APPLY))
           ((FUN (INT_CONST 8) (ADD) (RETURN)) (INT_CONST 6) (APPLY)))
      (RETURN))
 (INT_CONST 0)
 (APPLY)
 (ADD))
}|

The resulting ARM Assembler program will be:

@verbatim|{
.data
	fstr: .asciz "%d\n"

.text
.global main
.extern printf

fun0:
	stmfd sp!, {fp, ip, lr}
	mov fp, sp

	stmfd sp!, {r0}

	ldr r0, =4
	stmfd sp!, {r0}

	ldmfd sp!, {r0, r1}
	add r0, r1
	stmfd sp!, {r0}

	ldmfd sp!, {r0}

	mov sp, fp
	ldmfd sp!, {fp, ip, pc}

fun1:
	stmfd sp!, {fp, ip, lr}
	mov fp, sp

	stmfd sp!, {r0}

	ldr r0, =8
	stmfd sp!, {r0}

	ldmfd sp!, {r0, r1}
	add r0, r1
	stmfd sp!, {r0}

	ldmfd sp!, {r0}

	mov sp, fp
	ldmfd sp!, {fp, ip, pc}

fun2:
	stmfd sp!, {fp, ip, lr}
	mov fp, sp

	stmfd sp!, {r0}

	ldmfd sp!, {r0}
	tst r0, r0
	bne ifnz0

	ldr r0, =fun0
	stmfd sp!, {r0}

	ldr r0, =3
	stmfd sp!, {r0}

	ldmfd sp!, {r0, r7}
	blx r7
	stmfd sp!, {r0}

	b endifz0

	ifnz0:

	ldr r0, =fun1
	stmfd sp!, {r0}

	ldr r0, =6
	stmfd sp!, {r0}

	ldmfd sp!, {r0, r7}
	blx r7
	stmfd sp!, {r0}

	endifz0:

	ldmfd sp!, {r0}

	mov sp, fp
	ldmfd sp!, {fp, ip, pc}

main:

	stmfd sp!, {fp, ip, lr}
	mov fp, sp

	ldr r0, =56
	stmfd sp!, {r0}

	ldr r0, =fun2
	stmfd sp!, {r0}

	ldr r0, =0
	stmfd sp!, {r0}

	ldmfd sp!, {r0, r7}
	blx r7
	stmfd sp!, {r0}

	ldmfd sp!, {r0, r1}
	add r0, r1
	stmfd sp!, {r0}

	ldmfd sp!, {r1}
	ldr r0, =fstr
	bl printf

	mov sp, fp
	ldmfd sp!, {fp, ip, pc}
}|

Assuming that the output source file is called @tt{program.s}, programs produced by the SECD language can be compiled using the following commands:
@verbatim|{
  $ gcc -c program.s -o program.o
  $ gcc program.o -o program
  }|

If you compile and run the example above, the result will be
@verbatim|{
   $ ./program
   63
   }|

@section{Instruction Set}

As explained in the introduction, this implementation provides only a small subset of the instructions available in the SECD language. Moreover, the names of the instructions differ from the real ones.
Only the following instructions are available in the current release. This instruction set will be expanded in the near future.

@defproc[#:kind "secd-instruction"
         (INT_CONST [value (integer?)])
         void]{
 Pushes @tt{value} to the current stack, @tt{value} must be an integer.
}

@defproc[#:kind "secd-instruction"
         (ADD)
         void]{
 Pops the top two values off the current stack, adds them and pushes the result back to the current stack.
}

@defproc[#:kind "secd-instruction"
         (SUB)
         void]{
 Pops the top two values in the current stack, subtracts them and pushes the result back to the current stack.
 @bold{Note:} If @tt{first} is the element at the top of the current stack before executing @tt{(SUB)} and @tt{second} is the following element, then the subtraction performed is @tt{first - second}.
}

@defproc[#:kind "secd-instruction"
         (FUN [instruction secd-instruction?] ...
              [return secd-return?])
         void]{
 Defines a function with zero or more @racket[secd-instruction]s followed by a @tt{(RETURN)} instruction. This means that the smallest possible function definition is @tt{(FUN (RETURN))} which,
 when executed, returns the received argument.
 @bold{Note:} The instructions of a function are executed on an independent stack. In other words, a function starts its execution with a stack containing a single value: the received argument,
 and once it returns, its stack is completely discarded. This follows the principle of functional programming, which is the idea behind the abstract SECD machine.
 Once the function is defined, a pointer to it is pushed into the current stack.
}

@defproc[#:kind "secd-instruction"
         (RETURN)
         void]{
 Pops the top value off the function's stack and pushes it into the stack of the function's caller.
}

@defproc[#:kind "secd-instruction"
         (APPLY)
         void]{
 Pops the top two values in the current stack, the first one is the argument that is going to be passed to the function pointed by the second popped element.
}

@defproc[#:kind "secd-instruction"
         (IF0 [trueInstrs secd-instruction-list?]
              [falseInstrs secd-instruction-list?])
         void]{
 Pops the top value in the current stack. If it is zero, the instructions in @tt{trueInstrs} are executed. Otherwise, the instructions in @tt{falseInstrs} are executed.
}