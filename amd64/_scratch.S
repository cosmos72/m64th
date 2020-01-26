	.text
	
#include "asm.mh"
	
FUNC_START(push_rbx_rdi)
	SUB2(  IMM(SZ), %rdi) 
	STOR(  %rbx,    AT(%rdi))
	ret
FUNC_RAWEND(push_rbx_rdi)


FUNC_START(push_rbx_r12)
	SUB2(  IMM(SZ), %r12) 
	STOR(  %rbx,    AT(%r12))
	ret
FUNC_RAWEND(push_rbx_r12)


FUNC_START(push_rbx_r13)
	SUB2(  IMM(SZ), %r13) 
	STOR(  %rbx,    AT(%r13))
	ret
FUNC_RAWEND(push_rbx_r13)


FUNC_START(push_rbx_r14)
	SUB2(  IMM(SZ), %r14) 
	STOR(  %rbx,    AT(%r14))
	ret
FUNC_RAWEND(push_rbx_r14)


FUNC_START(push_rbx_r15)
	SUB2(  IMM(SZ), %r15) 
	STOR(  %rbx,    AT(%r15))
	ret
FUNC_RAWEND(push_rbx_r15)


FUNC_START(push_r8_rdi)
	SUB2(  IMM(SZ), %rdi) 
	STOR(  %r8,    AT(%rdi))
	ret
FUNC_RAWEND(push_r8_rdi)

	