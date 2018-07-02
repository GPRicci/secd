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
 (INT_CONST 5)
 (INT_CONST -25)
 (INT_CONST 10)
 (ADD)
 (SUB)
 )
}|

The resulting ARM Assembler program will be:

@verbatim|{
.data
	fstr: .asciz "%d\n"

.text
.global main
.extern printf

main:

	stmfd sp!, {fp, ip, lr}

	ldr r0, =5
	stmfd sp!, {r0}

	ldr r0, =-25
	stmfd sp!, {r0}

	ldr r0, =10
	stmfd sp!, {r0}

	ldmfd sp!, {r0, r1}
	add r0, r1
	stmfd sp!, {r0}

	ldmfd sp!, {r0, r1}
	sub r0, r1
	stmfd sp!, {r0}

	ldmfd sp!, {r1}
	ldr r0, =fstr
	bl printf

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
-20
}|

@section{Instruction Set}

As explained in the introduction, this implementation provides only a small subset of the instructions available in the SECD language. Moreover, the names of the instructions differ from the real ones.
Only the following instructions are available in the current release. This instruction set will be expanded in the near future.

@defproc[(INT_CONST [value (integer?)])
         void]{
  Pushes @tt{value} to the stack, @tt{value} must be an integer.
}

@defproc[(ADD)
         void]{
  Pops the top two values in the stack, adds them and pushes the result to the stack.
}

@defproc[(SUB)
         void]{
  Pops the top two values in the stack, subtracts them and pushes the result to the stack.
  @bold{Note:} If @tt{first} is the element at the top of the stack before executing @tt{(SUB)} and @tt{second} is the following element, then the subtraction performed is @tt{first - second}.
}