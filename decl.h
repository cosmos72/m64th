#ifndef M4TH_ARITH_H
#define M4TH_ARITH_H

/**
 * The following functions use m4th calling convention, not C !
 *
 * Do not attempt to invoke them directly from C - the only useful
 * operation is taking their address and appending it to m4th->code
 */

void m4th_at(void);
void m4th_bye(void);
void m4th_drop(void);
void m4th_dup(void);
void m4th_literal(void);
void m4th_minus(void);
void m4th_mod(void);
void m4th_noop(void);
void m4th_over(void);
void m4th_plus(void);
void m4th_rot(void);
void m4th_slash(void);
void m4th_slash_mod(void);
void m4th_star(void);
void m4th_swap(void);

#endif /* M4TH_ARITH_H */
