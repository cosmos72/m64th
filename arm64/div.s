	.arch armv8-a
	.file	"div.c"
	.text
	.align	2
	.p2align 3,,7
	.global	zero
	.type	zero, %function
zero:
.LFB0:
	.cfi_startproc
	mov	x0, 0
	ret
	.cfi_endproc
.LFE0:
	.size	zero, .-zero
	.align	2
	.p2align 3,,7
	.global	neg
	.type	neg, %function
neg:
.LFB1:
	.cfi_startproc
	neg	x0, x0
	ret
	.cfi_endproc
.LFE1:
	.size	neg, .-neg
	.align	2
	.p2align 3,,7
	.global	sub
	.type	sub, %function
sub:
.LFB2:
	.cfi_startproc
	sub	x0, x1, x0
	ret
	.cfi_endproc
.LFE2:
	.size	sub, .-sub
	.align	2
	.p2align 3,,7
	.global	mul
	.type	mul, %function
mul:
.LFB3:
	.cfi_startproc
	mul	x0, x0, x1
	ret
	.cfi_endproc
.LFE3:
	.size	mul, .-mul
	.align	2
	.p2align 3,,7
	.global	umul
	.type	umul, %function
umul:
.LFB4:
	.cfi_startproc
	mul	x0, x0, x1
	ret
	.cfi_endproc
.LFE4:
	.size	umul, .-umul
	.align	2
	.p2align 3,,7
	.global	div
	.type	div, %function
div:
.LFB5:
	.cfi_startproc
	sdiv	x0, x0, x1
	ret
	.cfi_endproc
.LFE5:
	.size	div, .-div
	.align	2
	.p2align 3,,7
	.global	udiv
	.type	udiv, %function
udiv:
.LFB6:
	.cfi_startproc
	udiv	x0, x0, x1
	ret
	.cfi_endproc
.LFE6:
	.size	udiv, .-udiv
	.align	2
	.p2align 3,,7
	.global	udiv_rem
	.type	udiv_rem, %function
udiv_rem:
.LFB7:
	.cfi_startproc
	mov	x2, x0
	udiv	x0, x0, x1
	msub	x1, x0, x1, x2
	ret
	.cfi_endproc
.LFE7:
	.size	udiv_rem, .-udiv_rem
	.align	2
	.p2align 3,,7
	.global	push
	.type	push, %function
push:
.LFB8:
	.cfi_startproc
	str	x1, [x0, -8]!
	ret
	.cfi_endproc
.LFE8:
	.size	push, .-push
	.align	2
	.p2align 3,,7
	.global	pop
	.type	pop, %function
pop:
.LFB9:
	.cfi_startproc
	ldr	x2, [x0], 8
	str	x2, [x1]
	ret
	.cfi_endproc
.LFE9:
	.size	pop, .-pop
	.align	2
	.p2align 3,,7
	.global	get1
	.type	get1, %function
get1:
.LFB10:
	.cfi_startproc
	ldr	x0, [x0, 8]
	ret
	.cfi_endproc
.LFE10:
	.size	get1, .-get1
	.ident	"GCC: (Debian 9.2.1-8) 9.2.1 20190909"
	.section	.note.GNU-stack,"",@progbits
