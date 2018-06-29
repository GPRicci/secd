#lang brag

; This is the grammar that defines the language.
; The / operator removes the following symbol from the parse tree.
; The @ operator removes the follwing rule from the parse tree and splices its children in its parent node.
secd-program: /"(" secd-instruction* /")"
@secd-instruction: /"(" secd-identifier /")"
@secd-identifier: secd-int-const | secd-add | secd-sub
secd-int-const: /"INT_CONST" INTEGER
secd-add: /"ADD"
secd-sub: /"SUB"