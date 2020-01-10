#ifndef M4TH_DEFS_AMD64_H
#define M4TH_DEFS_AMD64_H

#define SZ   8    /* width of registers and cells, in bytes */
#define SZ2  16   /* SZ * 2 */
#define SZ3  24   /* SZ * 3 */
#define SZ4  32   /* SZ * 4 */
#define SZ5  40   /* SZ * 5 */

#define REG1 %rax /* scratch register 1 */
#define REG2 %rcx /* scratch register 2 */
#define REG3 %rdx /* scratch register 3 */

#define DTOP %rbx /* value of first data stack element */
#define DSTK %rsp /* pointer to second data stack element */

#define RTOP %rbp /* value of first return stack element */
#define RSTK %r14 /* pointer to second return stack element */

#define M4TH %r15 /* pointer to C struct m4th */

#define DPUSH(val)    pushq     val; /* push val to second data stack element */
#define DPOP(val)     popq      val; /* pop second data stack element into val */

#define RPUSH(val)    subq      $SZ,    RSTK; /* push val to second return stack element */ \
                      movq      val,    (RSTK);

#define RPOP(val)     movq      (RSTK), val; /* pop second return stack element into val */ \
                      addq      $SZ,    RSTK;

#define NEXT()        addq      $SZ,    RTOP; /* jump to next instruction */ \
                      jmp       *(RTOP);


#define FUNC_NEXT(name) \
/* .name.next: */ \
                      NEXT()

#define FUNC_START(name) \
                      .globl    name; \
                      .type     name,   @function; \
name: \
                      .cfi_startproc;

#define FUNC_END(name) \
                      .cfi_endproc; \
                      .size     name,   .-name;

#define FUNC(name, ...) \
                      FUNC_START(name) \
                      __VA_ARGS__ \
                      FUNC_NEXT(name) \
                      FUNC_END(name)

#define ADD2(src,dst)   addq    src,    dst;    /* dst += src     */
#define LOAD(addr,dst)  movq    (addr), dst;    /* dst  = addr[0] */
#define MOV(src,dst)    movq    src,    dst;    /* dst  = src     */
#define MUL2(src,dst)   imulq   src,    dst;    /* dst -= src     */
#define NEG1(dst)       negq    dst;            /* dst  = -dst    */
#define SUB2(src,dst)   subq    src,    dst;    /* dst -= src     */
#define STORE(src,addr) movq    src,    (addr); /* addr[0] = src  */
#define ZERO(dst)       xorq    dst,    dst;    /* dst  = 0       */


#endif /* M4TH_DEFS_AMD64_H */

