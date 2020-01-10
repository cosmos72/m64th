        .file "arith_amd64.S"
        
#include "asm_amd64.h"
        
        .text

FUNC(m4th_at, /* @ */
        LOAD(DTOP, DTOP)
)

FUNC(m4th_drop,
        DPOP(DTOP)
)

FUNC(m4th_dup,
        DPUSH(DTOP)
)

FUNC(m4th_literal,
        ADD2($SZ, RTOP)
        DPUSH(DTOP)
        LOAD(RTOP, DTOP)
)

FUNC(m4th_minus, /* - */
        DPOP(REG1)
#ifdef SUB3
        SUB3(REG1, DTOP, DTOP)
#else
        NEG1(DTOP)
        ADD2(REG1, DTOP)
#endif
)

/* mod is unsigned remainder */
FUNC(m4th_mod,
        DPOP(%rax)
        ZERO(%rdx)
        div DTOP;
        MOV(%rdx, DTOP) /* remainder */
)

FUNC(m4th_noop,
)

FUNC(m4th_over,
        DPUSH(DTOP)
        movq SZ(DSTK), DTOP;
)

FUNC(m4th_plus, /* + */
        DPOP(REG1)
        ADD2(REG1, DTOP)
)


FUNC(m4th_rot,
        movq (DSTK),   REG1;
        movq DTOP,     (DSTK);
        movq SZ(DSTK), DTOP;
        movq REG1,     SZ(DSTK);
)

FUNC(m4th_slash, /* / */
#ifdef DIV3
        DPOP(REG1)
        DIV3(REG1, DTOP, DTOP)
#else
        DPOP(%rax)
        cqto; /* sign-extend %rax into %rdx */
        idiv DTOP;
        MOV(%rax, DTOP)
#endif
)

/* /mod is unsigned divide & remainder */
FUNC(m4th_slash_mod,
        LOAD(DSTK, %rax)
        ZERO(%rdx)
        div DTOP;
        STORE(%rdx, DSTK) /* remainder */
        MOV(%rax, DTOP)   /* quotient */
)

FUNC(m4th_star, /* * */
        DPOP(REG1)
        MUL2(REG1, DTOP)
)

FUNC(m4th_swap,
        xchg (DSTK), DTOP;
)

        .ident "m4th 0.0.0"
        .section .note.GNU-stack,"",@progbits
