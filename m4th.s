	.arch armv8-a
	.file	"m4th.c"
	.text
	.align	2
	.p2align 3,,7
	.type	m4th_round_to_page, %function
m4th_round_to_page:
.LFB24:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -16
	.cfi_offset 20, -8
	adrp	x20, .LANCHOR0
	mov	x19, x0
	ldr	x0, [x20, #:lo12:.LANCHOR0]
	cbz	x0, .L5
	sub	x19, x19, #1
	add	x19, x19, x0
	udiv	x19, x19, x0
	mul	x0, x19, x0
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L5:
	.cfi_restore_state
	sub	x19, x19, #1
	mov	w0, 30
	bl	sysconf
	add	x19, x19, x0
	str	x0, [x20, #:lo12:.LANCHOR0]
	udiv	x19, x19, x0
	mul	x0, x19, x0
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE24:
	.size	m4th_round_to_page, .-m4th_round_to_page
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align	3
.LC0:
	.string	"failed to allocate %lu bytes: %s\n"
	.text
	.align	2
	.p2align 3,,7
	.type	m4th_oom, %function
m4th_oom:
.LFB22:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	adrp	x1, :got:stderr
	mov	x29, sp
	ldr	x1, [x1, #:got_lo12:stderr]
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -16
	.cfi_offset 20, -8
	mov	x19, x0
	ldr	x20, [x1]
	bl	__errno_location
	ldr	w0, [x0]
	bl	strerror
	mov	x3, x0
	mov	x2, x19
	adrp	x1, .LC0
	add	x1, x1, :lo12:.LC0
	mov	x0, x20
	bl	fprintf
	mov	w0, 1
	bl	exit
	.cfi_endproc
.LFE22:
	.size	m4th_oom, .-m4th_oom
	.align	2
	.p2align 3,,7
	.type	m4th_mmap.part.0, %function
m4th_mmap.part.0:
.LFB39:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -16
	.cfi_offset 20, -8
	bl	m4th_round_to_page
	mov	w3, 34
	mov	x1, x0
	mov	x19, x0
	movk	w3, 0x2, lsl 16
	mov	x5, 0
	mov	w4, -1
	mov	w2, 3
	mov	x0, 0
	bl	mmap
	cmn	x0, #1
	beq	.L11
	mov	x20, x0
	mov	x2, x19
	mov	w1, 255
	bl	memset
	mov	x0, x20
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L11:
	.cfi_restore_state
	mov	x0, x19
	bl	m4th_oom
	.cfi_endproc
.LFE39:
	.size	m4th_mmap.part.0, .-m4th_mmap.part.0
	.align	2
	.p2align 3,,7
	.type	m4stack_free, %function
m4stack_free:
.LFB30:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	str	x19, [sp, 16]
	.cfi_offset 19, -16
	ldr	x19, [x0]
	ldr	x0, [x0, 16]
	sub	x0, x0, x19
	asr	x0, x0, 3
	add	x0, x0, 1
	cmp	x0, 7
	bhi	.L15
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_def_cfa_offset 0
	ret
	.p2align 2,,3
.L15:
	.cfi_restore_state
	lsr	x0, x0, 3
	bl	m4th_round_to_page
	mov	x1, x0
	mov	x0, x19
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_def_cfa_offset 0
	b	munmap
	.cfi_endproc
.LFE30:
	.size	m4stack_free, .-m4stack_free
	.align	2
	.p2align 3,,7
	.type	m4th_alloc.part.0, %function
m4th_alloc.part.0:
.LFB41:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -16
	.cfi_offset 20, -8
	mov	x20, x0
	bl	malloc
	cbz	x0, .L19
	mov	x19, x0
	mov	x2, x20
	mov	w1, 255
	bl	memset
	mov	x0, x19
	ldp	x19, x20, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_remember_state
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	ret
.L19:
	.cfi_restore_state
	mov	x0, x20
	bl	m4th_oom
	.cfi_endproc
.LFE41:
	.size	m4th_alloc.part.0, .-m4th_alloc.part.0
	.align	2
	.p2align 3,,7
	.global	m4th_mmap
	.type	m4th_mmap, %function
m4th_mmap:
.LFB25:
	.cfi_startproc
	cbz	x0, .L21
	b	m4th_mmap.part.0
	.p2align 2,,3
.L21:
	ret
	.cfi_endproc
.LFE25:
	.size	m4th_mmap, .-m4th_mmap
	.align	2
	.p2align 3,,7
	.global	m4th_munmap
	.type	m4th_munmap, %function
m4th_munmap:
.LFB26:
	.cfi_startproc
	cbnz	x1, .L27
	ret
	.p2align 2,,3
.L27:
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	str	x19, [sp, 16]
	.cfi_offset 19, -16
	mov	x19, x0
	mov	x0, x1
	bl	m4th_round_to_page
	mov	x1, x0
	mov	x0, x19
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_def_cfa_offset 0
	b	munmap
	.cfi_endproc
.LFE26:
	.size	m4th_munmap, .-m4th_munmap
	.align	2
	.p2align 3,,7
	.global	m4th_alloc
	.type	m4th_alloc, %function
m4th_alloc:
.LFB27:
	.cfi_startproc
	cbz	x0, .L29
	b	m4th_alloc.part.0
	.p2align 2,,3
.L29:
	ret
	.cfi_endproc
.LFE27:
	.size	m4th_alloc, .-m4th_alloc
	.align	2
	.p2align 3,,7
	.global	m4th_free
	.type	m4th_free, %function
m4th_free:
.LFB28:
	.cfi_startproc
	b	free
	.cfi_endproc
.LFE28:
	.size	m4th_free, .-m4th_free
	.align	2
	.p2align 3,,7
	.global	m4th_new
	.type	m4th_new, %function
m4th_new:
.LFB35:
	.cfi_startproc
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x0, 136
	mov	x29, sp
	str	x19, [sp, 16]
	.cfi_offset 19, -16
	bl	m4th_alloc.part.0
	mov	x19, x0
	mov	x0, 2048
	bl	m4th_mmap.part.0
	mov	x1, x0
	add	x2, x1, 2040
	mov	x0, 512
	stp	x1, x2, [x19]
	str	x2, [x19, 16]
	bl	m4th_mmap.part.0
	str	x0, [x19, 24]
	add	x0, x0, 504
	stp	x0, x0, [x19, 32]
	mov	x0, 8192
	bl	m4th_alloc.part.0
	mov	x1, x0
	add	x0, x0, 8192
	stp	x1, x1, [x19, 48]
	stp	x0, x1, [x19, 64]
	mov	x0, 1024
	str	xzr, [x19, 80]
	bl	m4th_alloc.part.0
	add	x1, x0, 1024
	stp	x0, x0, [x19, 88]
	mov	x0, 1024
	str	x1, [x19, 104]
	bl	m4th_alloc.part.0
	mov	x1, x0
	add	x2, x1, 1024
	stp	x1, x1, [x19, 112]
	mov	x0, x19
	str	x2, [x19, 128]
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE35:
	.size	m4th_new, .-m4th_new
	.align	2
	.p2align 3,,7
	.global	m4th_del
	.type	m4th_del, %function
m4th_del:
.LFB36:
	.cfi_startproc
	cbz	x0, .L33
	stp	x29, x30, [sp, -32]!
	.cfi_def_cfa_offset 32
	.cfi_offset 29, -32
	.cfi_offset 30, -24
	mov	x29, sp
	str	x19, [sp, 16]
	.cfi_offset 19, -16
	mov	x19, x0
	ldr	x0, [x0, 112]
	bl	free
	ldr	x0, [x19, 88]
	bl	free
	ldr	x0, [x19, 48]
	bl	free
	add	x0, x19, 24
	bl	m4stack_free
	mov	x0, x19
	bl	m4stack_free
	mov	x0, x19
	ldr	x19, [sp, 16]
	ldp	x29, x30, [sp], 32
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 19
	.cfi_def_cfa_offset 0
	b	free
	.p2align 2,,3
.L33:
	ret
	.cfi_endproc
.LFE36:
	.size	m4th_del, .-m4th_del
	.align	2
	.p2align 3,,7
	.global	m4th_clear
	.type	m4th_clear, %function
m4th_clear:
.LFB37:
	.cfi_startproc
	ldr	x1, [x0, 16]
	str	x1, [x0, 8]
	ldr	x1, [x0, 40]
	str	x1, [x0, 32]
	ldr	x1, [x0, 48]
	str	x1, [x0, 56]
	str	x1, [x0, 72]
	ldr	x2, [x0, 88]
	str	xzr, [x0, 80]
	ldr	x1, [x0, 112]
	str	x2, [x0, 96]
	str	x1, [x0, 120]
	ret
	.cfi_endproc
.LFE37:
	.size	m4th_clear, .-m4th_clear
	.section	.rodata.str1.8
	.align	3
.LC1:
	.string	"<%ld> "
	.align	3
.LC2:
	.string	"%ld "
	.text
	.align	2
	.p2align 3,,7
	.global	m4th_stack_print
	.type	m4th_stack_print, %function
m4th_stack_print:
.LFB38:
	.cfi_startproc
	stp	x29, x30, [sp, -48]!
	.cfi_def_cfa_offset 48
	.cfi_offset 29, -48
	.cfi_offset 30, -40
	mov	x2, x0
	mov	x0, x1
	mov	x29, sp
	stp	x19, x20, [sp, 16]
	.cfi_offset 19, -32
	.cfi_offset 20, -24
	mov	x20, x1
	adrp	x1, .LC1
	stp	x21, x22, [sp, 32]
	.cfi_offset 21, -16
	.cfi_offset 22, -8
	add	x1, x1, :lo12:.LC1
	ldp	x21, x19, [x2, 8]
	sub	x2, x19, x21
	asr	x2, x2, 3
	bl	fprintf
	cmp	x21, x19
	beq	.L40
	adrp	x22, .LC2
	add	x22, x22, :lo12:.LC2
	.p2align 3,,7
.L41:
	ldr	x2, [x19, -8]!
	mov	x1, x22
	mov	x0, x20
	bl	fprintf
	cmp	x21, x19
	bne	.L41
.L40:
	mov	x1, x20
	mov	w0, 10
	ldp	x19, x20, [sp, 16]
	ldp	x21, x22, [sp, 32]
	ldp	x29, x30, [sp], 48
	.cfi_restore 30
	.cfi_restore 29
	.cfi_restore 21
	.cfi_restore 22
	.cfi_restore 19
	.cfi_restore 20
	.cfi_def_cfa_offset 0
	b	fputc
	.cfi_endproc
.LFE38:
	.size	m4th_stack_print, .-m4th_stack_print
	.bss
	.align	3
	.set	.LANCHOR0,. + 0
	.type	m4th_page, %object
	.size	m4th_page, 8
m4th_page:
	.zero	8
	.ident	"GCC: (Debian 9.2.1-19) 9.2.1 20191109"
	.section	.note.GNU-stack,"",@progbits
