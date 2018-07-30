#lang brag

; This is the grammar that defines the language.
; The / operator removes the following symbol from the parse tree.
; The @ operator removes the following rule from the parse tree and splices its children in its parent node.
; This grammar silently exports a parse function.
; As secd-instruction is preceded by an @ operator, the parser will never contain this node,
; therefore, our expander needs only provide bindings for the remaining rules.
secd-program: secd-instruction-list
secd-instruction-list: /"(" secd-instruction* /")" 
@secd-instruction: /"(" (secd-int-const | secd-add | secd-sub | secd-fun | secd-apply | secd-if0) /")"
secd-int-const: /"INT_CONST" INTEGER
secd-add: /"ADD"
secd-sub: /"SUB"
secd-fun: /"FUN" secd-instruction* /"(" secd-return /")"    ; Every function needs a return statement as its last instruction. This rule enforces that.
secd-return: /"RETURN"
secd-apply: /"APPLY"
secd-if0: /"IF0" secd-instruction-list secd-instruction-list