/**
 * Copyright (C) 2020 Massimiliano Ghilardi
 *
 * This file is part of m64th.
 *
 * m64th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m64th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m64th.  If not, see <https://www.gnu.org/licenses/>.
 */

#include "../../include/asm.mh"
#include "../../include/dict.mh"
#include "../../include/hashmap.mh"
#include "../../include/m64th/dict.mh"

/* clang-format off */

/* ---------------------------------------------------------------------------------------------- */
/* --- m64th-user -------------------------------------------------------------------------------- */
/* ---------------------------------------------------------------------------------------------- */

/*
 * FORTH_ROOT_LASTWORD is the last word in 'forth-root' wordlist:
 * link to it to include the whole wordlist also into this 'm64th-user' wordlist
 */

/* show return stack */
WORD_START(dot_rs, FORTH_ROOT_LASTWORD)
    WORD_STACK_NONE()
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        dup_to_r,                               /* push RTOP to return stack  */
        rp_fetch, rdepth, one_minus, minus_one, /* ( rstk rdepth -1 )         */
        _c_locals_save_,
            _c_arg_3_, _c_call_, CELL(m6slice_print_stdout), _c_ret_0_,
        _c_locals_load_,
        r_from_drop, exit                       /* pop RTOP from return stack */
    )
WORD_END(dot_rs)
WORD(less_equal,       dot_rs,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(more_equal,       less_equal,     DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(zero_less_equal,  more_equal,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(zero_more_equal, zero_less_equal, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_plus,        zero_more_equal, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_minus,        two_plus,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_du_to_2u_q,   two_minus,      DSTACK(4,-1),RSTACK(0,0), WORD_PURE)
WORD(two_dup_two_to_r, two_du_to_2u_q, DSTACK(2,2), RSTACK(0,2), WORD_R_PURE)
WORD(two_nip,         two_dup_two_to_r,DSTACK(4,2), RSTACK(0,0), WORD_PURE)
WORD(two_pick,         two_nip,        DSTACK(1,2), RSTACK(0,0), WORD_IMPURE) /* DSTACK(x+1,x+2) */
WORD(two_r_from_two_drop, two_pick,    DSTACK(0,0), RSTACK(2,0), WORD_R_PURE)
WORD_START(two_roll,   two_r_from_two_drop)
    WORD_DSTACK(1,0) /* DSTACK(x+1,x) */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* uses %rip-relative TOKEN_CALL_NOTHROW */
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(two_roll, exit)
WORD_END(two_roll)
WORD_START(minus_two_roll,   two_roll)
    WORD_DSTACK(1,0) /* DSTACK(x+1,x) */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* uses %rip-relative TOKEN_CALL_NOTHROW */
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(minus_two_roll, exit)
WORD_END(minus_two_roll)
WORD(minus_two_rot,    minus_two_roll, DSTACK(6,6), RSTACK(0,0), WORD_PURE)
WORD(two_sm_div,       minus_two_rot,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(two_tuck,         two_sm_div,     DSTACK(4,6), RSTACK(0,0), WORD_PURE)
WORD(four_times,       two_tuck,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(four_plus,        four_times,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(four_minus,       four_plus,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(four_div,         four_minus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(four_sm_div,      four_div,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_times,      four_sm_div,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_plus,       eight_times,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_minus,      eight_plus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_div,        eight_minus,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(eight_sm_div,     eight_div,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* 8lshift ( u -- u<<8 ) left shift by 8 */
WORD(eight_lshift,     eight_sm_div,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* 8rshift ( u -- u>>8 ) unsigned right shift by 8 */
WORD(eight_rshift,     eight_lshift,   DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(atomic_plus_store,eight_rshift,   DSTACK(2,1), RSTACK(0,0), WORD_IMPURE|M6FLAG_MEM_FETCH|M6FLAG_MEM_STORE)
WORD(atomic_one_plus_store,     atomic_plus_store,
                                       DSTACK(1,1), RSTACK(0,0), WORD_IMPURE|M6FLAG_MEM_FETCH|M6FLAG_MEM_STORE)
WORD(bounds,    atomic_one_plus_store, DSTACK(2,2), RSTACK(0,0), WORD_PURE)
WORD_START(break,      bounds)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_JUMP | M6FLAG_INLINE | M6FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_jump_lit_, _break_, _break_, exit
    )
WORD_END(break)
WORD(breakpoint,        break,         DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
/* ( a b flag -- a|b ) if flags is nonzero return a, otherwise b */
WORD(choose,            breakpoint,    DSTACK(3,0), RSTACK(0,0), WORD_PURE)
/**
 * cmove/count ( src dst u -- src+u dst+u ) forward copy u bytes from src..src+u-1 to dst..dst+u-1
 * and return updated addresses
 */
WORD(cmove_count,       choose,        DSTACK(3,2), RSTACK(0,0), WORD_IMPURE)
/**
 * -cmove/count ( src dst u -- src+u dst+u ) backward copy u bytes from src..src+u-1 to dst..dst+u-1
 * and return updated addresses
 */
WORD(minus_cmove_count, cmove_count,   DSTACK(3,2), RSTACK(0,0), WORD_IMPURE)
/* crc-cell ( x u -- crc32 ) compute CRC32c of a cell  */
WORD_START(crc_cell, minus_cmove_count)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* uses %ip-relative TOKEN_CALL_NOTHROW() - cannot inline in native code */
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_FETCH)
    WORD_CODE(crc_cell, exit)
WORD_END(crc_cell)
/* crc-string ( c-addr u -- crc32 ) compute CRC32c of a string  */
WORD_START(crc_string, crc_cell)
    WORD_DSTACK(2,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* on x86-64 used %ip-relative LEA m64th_crctable(%rip) - cannot inline in native code */
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_FETCH)
    WORD_CODE(crc_string, exit)
WORD_END(crc_string)
WORD_START(continue,   crc_string)
    WORD_STACK_NONE()  /* stack effect if not jumping */
    WORD_DSTACK(0,0)   /* stack effect if jumping */
    WORD_RSTACK(0,0)
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_JUMP | M6FLAG_INLINE | M6FLAG_IMMEDIATE)
    WORD_CODE(
        _compile_jump_lit_, _continue_, _continue_, exit
    )
WORD_END(continue)
WORD_START(minus_cs_roll,   continue)
    WORD_DSTACK(1,0) /* DSTACK(x+1,x) */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* uses %rip-relative TOKEN_CALL_NOTHROW */
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(minus_cs_roll, exit)
WORD_END(minus_cs_roll)
/* ( d -- x ) extract high half from double width number */
WORD(d_to_hi,           minus_cs_roll, DSTACK(2,1), RSTACK(0,0), WORD_PURE)
/* defer>validate ( xt -- xt ) throw if XT was not created by DEFER */
WORD_START(defer_to_validate, d_to_hi)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        xt_to_validate,                                          /* ( xt                  ) */
        dup, xt_to_name, dup, name_to_flags,                     /* ( xt nt m6flags       ) */
        _lit_, T(M6FLAG_OPT_MASK), and,                        /* ( xt nt m6flags'      ) */
        _lit_, T(M6FLAG_DEFER), ne,                              /* ( xt nt t|f           ) */
        _if_, T(6),                                              /* ( xt nt               ) */
            name_to_string, ex_message_store,                    /* ( xt                  ) */
            _lit_, T(M6ERR_NOT_DEFER), throw,                    /* ( xt                  ) */
        then,                                                    /* ( xt nt               ) */
        drop, exit                                               /* ( xt                  ) */
   )
WORD_END(defer_to_validate)
WORD_START(disassemble, defer_to_validate)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        CALL(parse_name), two_dup, CALL(string_to_name),        /* ( c-addr u nt|0 wid|0 -1|0|1 ) */
        two_drop,                                               /* ( c-addr u nt|0 ) */
        _q_if0_, T(6),                                          /* ( c-addr u nt|0 ) */
            drop, ex_message_store,                             /* (               ) */
            _lit_, T(M6ERR_UNDEFINED_WORD), throw,              /* (               ) */
        then,                                                   /* ( c-addr u nt   ) */
        nip, nip,                                               /* ( nt            ) */
        CALL(disassemble_name), exit                         /* (               ) */
    )
WORD_END(disassemble)
/* disassemble-name ( nt -- ) disassemble nt in machine-readable format */
WORD_START(disassemble_name, disassemble)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        one,                                           /* ( nt 1          ) */
        _c_locals_save_,
            _c_arg_2_, _c_call_, CELL(m6word_print_stdout), _c_ret_0_,
        _c_locals_load_, exit
    )
WORD_END(disassemble_name)
/* do-i+-loop  native-compiled version of do i+ loop */
WORD(do_i_plus_loop, disassemble_name, DSTACK(2,1), RSTACK(0,0), WORD_IMPURE)
/**
 * du/mod ( du du-divisor -- du-rem du-quo ) unsigned remainder & quotient
 * of double-width unsigned division.
 * returned remainder and quotient are double-width unsigned numbers
 */
WORD_START(du_div_mod, do_i_plus_loop)
    WORD_DSTACK(4,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_PURE)
    WORD_CODE(
        two_du_to_2u_q,                                   /* ( ud1 ud2 f | u1 u2 t  ) */
        _if_, T(7),    /* 64bit division */            /* ( u1 u2                ) */
            u_div_mod,                                 /* ( rem quo              ) */
            swap, u_to_d, rot, u_to_d, exit,           /* ( du-rem du-quo        ) */
        then,                                          /* ( ud1 ud2              ) */
        sp_fetch, dup,                                 /* ( ud1 x=ud2 &x &x      ) */
        cell_plus, cell_plus, swap,                    /* ( y=ud1 x=ud2 &y &x    ) */

        _c_locals_save_,
            _c_arg_2_, _c_call_, CELL(m64th_ud_div_mod), _c_ret_0_,
        _c_locals_load_, exit                            /* ( du-rem du-quo        ) */
    )
WORD_END(du_div_mod)
WORD(du_to_u_q,        du_div_mod,     DSTACK(2,-1),RSTACK(0,0), WORD_PURE)
WORD(dup_to_r,         du_to_u_q,      DSTACK(1,1), RSTACK(0,1), WORD_R_PURE)
WORD(ex_message_store, dup_to_r,       DSTACK(2,0), RSTACK(0,0), WORD_IMPURE)
WORD(ex_message_fetch,ex_message_store,DSTACK(0,2), RSTACK(0,0), WORD_IMPURE)
/* ( ex -- c-addr u ) get exception name */
WORD_START(ex_to_string, ex_message_fetch)
    WORD_DSTACK(1,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        dup, zero_more_equal, _if_, T(5),              /* ( ex                 ) */
            drop, zero, dup, exit,                     /* ( 0 0                ) */
        then,                                          /* ( ex                 ) */
        dup, two_plus, zero_more_equal,
        _if_, T(4+nSTRt(5)),                           /* ( ex t|f             ) */
            drop, LIT_STRING(5, "abort"), exit,        /* ( c-addr u           ) */
        then,                                          /* ( ex                 ) */
        dup, _lit_, T(-3), equal, _if_, T(4+nSTRt(14)),/* ( ex t|f             ) */
            drop, LIT_STRING(14, "stack overflow"),    /* ( c-addr u           ) */
            exit,
        then,
        /* TODO */
        drop, LIT_STRING(9, "exception"), exit         /* ( c-addr u           ) */
    )
WORD_END(ex_to_string)
/* jump to next 'of' inside a 'case'. */
/* can appear only as last statement inside 'of' i.e. instead of 'endcase' */
WORD_START(fallthrough,      ex_to_string)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_COMPILE_ONLY | M6FLAG_IMMEDIATE)
    WORD_CODE(
        _check_lit_tok_, _of_,                            /* ( of-sys                    ) */
        _compile_jump_lit_, _fallthrough_, _fallthrough_, /* ( of-sys fallthrough-sys    ) */
        cs_swap,                                          /* ( fallthrough-sys of-sys    ) */
        CALL(_resolve_jump_here_),                        /* ( fallthrough-sys           ) */
        exit                                              /* ( fallthrough-sys           ) */
    )
WORD_END(fallthrough)
/* replace first wordlist in search order with forth_root wordlist ( SO: wid -- forth_root ) */
WORD_START(forth_root, fallthrough)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        _lit_cell_, CELL(m6wordlist_forth_root),       /* ( wid              ) */
        searchorder_store_0, exit                      /* (                  ) */
    )
WORD_END(forth_root)
WORD(flip,             forth_root,     DSTACK(3,3), RSTACK(0,0), WORD_PURE)
/* hashmap-find/cell ( map key -- key' &val|0 ) find entry in hashmap/cell  */
WORD_START(hashmap_find_cell, flip)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        dup_to_r, over,                                /* ( map key map         ) ( R: key     ) */
#if M6HASHMAP_OFF_VEC_CELL == SZ2
        cell_fetch_2,                                  /* ( map key vec         ) ( R: key     ) */
#else
        _lit_, T(M6HASHMAP_OFF_VEC_CELL), plus, fetch, /* ( map key vec         ) ( R: key     ) */
#endif
        to_r,                                          /* ( map key             ) ( R: key vec ) */
        CALL(_hashmap_indexof_cell_),                  /* ( pos                 ) ( R: key vec ) */
        begin,                                         /* ( pos                 ) ( R: key vec ) */
            r_fetch, swap,                             /* ( vec pos             ) ( R: key vec ) */
            CALL(_hashmap_entry_fetch_cell_),          /* ( key' &val next      ) ( R: key vec ) */
            dup, one_plus, /* 0 if no entry */         /* ( key' &val next flag ) ( R: key vec ) */
        _while_, T(18),                                /* ( key' &val next      ) ( R: key vec ) */
            hop, r2nd_fetch, equal,                    /* ( key' &val next t|f  ) ( R: key vec ) */
            _if_, T(4),                                /* ( key' &val next      ) ( R: key vec ) */
                two_r_from_two_drop, drop, exit,       /* ( key' &val           )               */
            then,                                      /* ( key' &val next      ) ( R: key vec ) */
            dup, two_plus, /* 0 if no next entry */    /* ( key' &val next flag ) ( R: key vec ) */
        _while_, T(4),                                 /* ( key' &val next      ) ( R: key vec ) */
            nip, nip,                                  /* ( next                ) ( R: key vec ) */
        _repeat_, T(-24-nCALLt),                       /* ( key' &val next      ) ( R: key vec ) */
        then,              /* matches 1st 'while' */   /* ( key' &val next      ) ( R: key vec ) */
        two_drop, r_from_drop, r_from,                 /* ( key' key            )               */
        nip, zero, exit                                /* ( key  0              )               */
    )
WORD_END(hashmap_find_cell)
/* hashmap-find/int ( map key -- key' &val|0 ) find entry in hashmap/int  */
WORD_START(hashmap_find_int, hashmap_find_cell)
    WORD_DSTACK(2,2)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_MEM_FETCH)
    WORD_CODE(
        dup_to_r, over,                                /* ( map key map         ) ( R: key     ) */
#if M6HASHMAP_OFF_VEC_INT == SZ
        cell_fetch_1,                                  /* ( map key vec         ) ( R: key     ) */
#elif M6HASHMAP_OFF_VEC_INT == 8
        eight_plus, fetch                              /* ( map key vec         ) ( R: key     ) */
#else
        _lit_, T(M6HASHMAP_OFF_VEC_INT), plus, fetch,  /* ( map key vec         ) ( R: key     ) */
#endif
        to_r,                                          /* ( map key             ) ( R: key vec ) */
        CALL(_hashmap_indexof_int_),                   /* ( pos                 ) ( R: key vec ) */
        begin,                                         /* ( pos                 ) ( R: key vec ) */
            r_fetch, swap,                             /* ( vec pos             ) ( R: key vec ) */
            CALL(_hashmap_entry_fetch_int_),           /* ( key' &val next      ) ( R: key vec ) */
            dup, one_plus, /* 0 if no entry */         /* ( key' &val next flag ) ( R: key vec ) */
        _while_, T(18),                                /* ( key' &val next      ) ( R: key vec ) */
            hop, r2nd_fetch, equal,                    /* ( key' &val next t|f  ) ( R: key vec ) */
            _if_, T(4),                                /* ( key' &val next      ) ( R: key vec ) */
                two_r_from_two_drop, drop, exit,       /* ( key' &val           )               */
            then,                                      /* ( key' &val next      ) ( R: key vec ) */
            dup, two_plus, /* 0 if no next entry */    /* ( key' &val next flag ) ( R: key vec ) */
        _while_, T(4),                                 /* ( key' &val next      ) ( R: key vec ) */
            nip, nip,                                  /* ( next                ) ( R: key vec ) */
        _repeat_, T(-24-nCALLt),                       /* ( key' &val next      ) ( R: key vec ) */
        then,              /* matches 1st 'while' */   /* ( key' &val next      ) ( R: key vec ) */
        two_drop, r_from_drop, r_from,                 /* ( key' key            )               */
        nip, zero, exit                                /* ( key  0              )               */
    )
WORD_END(hashmap_find_int)
WORD(hop,            hashmap_find_int, DSTACK(3,4), RSTACK(0,0), WORD_PURE)
WORD(i_times,          hop,            DSTACK(1,1), RSTACK(1,1), WORD_R_PURE)
WORD(i_plus,           i_times,        DSTACK(1,1), RSTACK(1,1), WORD_R_PURE)
WORD(i_minus,          i_plus,         DSTACK(1,1), RSTACK(1,1), WORD_R_PURE)
WORD(i_prime,          i_minus,        DSTACK(0,1), RSTACK(2,2), WORD_R_PURE)
WORD(i_byte_fetch,     i_prime,        DSTACK(0,1), RSTACK(1,1), M6FLAG_INLINE|M6FLAG_COMPILE_ONLY)
WORD(i_char_fetch,     i_byte_fetch,   DSTACK(0,1), RSTACK(1,1), M6FLAG_INLINE|M6FLAG_COMPILE_ONLY)
WORD(i_short_fetch,    i_char_fetch,   DSTACK(0,1), RSTACK(1,1), M6FLAG_INLINE|M6FLAG_COMPILE_ONLY)
WORD(i_ushort_fetch,   i_short_fetch,  DSTACK(0,1), RSTACK(1,1), M6FLAG_INLINE|M6FLAG_COMPILE_ONLY)
WORD(i_int_fetch,      i_ushort_fetch, DSTACK(0,1), RSTACK(1,1), M6FLAG_INLINE|M6FLAG_COMPILE_ONLY)
WORD(i_uint_fetch,     i_int_fetch,    DSTACK(0,1), RSTACK(1,1), M6FLAG_INLINE|M6FLAG_COMPILE_ONLY)
WORD(i_fetch,          i_uint_fetch,   DSTACK(0,1), RSTACK(1,1), M6FLAG_INLINE|M6FLAG_COMPILE_ONLY)
/*
 * classic forth interpreter/compiler iteration:
 *    read a name i.e. a non-blank string from IN,
 *    execute STRING>NAME which searches the current search order for name,
 *    and, if a name is found:
 *       if interpreting, perform the interpretation semantics of the name
 *       otherwise, perform the compilation semantics of the name
 *    otherwise, execute STRING>NUMBER which attempts to convert string to a number and,
 *    if successful:
 *       place the number on the data stack
 *       if compiling, execute the name LITERAL, which pops the number and compiles code
 *         that when executed will place the number on the data stack
 *    otherwise, throw
 */
WORD_START(interpret,  i_fetch)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(-1,-1)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* parse-name                                   ( c-addr u                 )
         * ?if0                                         ( c-addr u                 )
         *    2drop exit                                (                          )
         * then                                         ( c-addr u                 )
         * 2dup string>local                            ( c-addr u idx t|f         )
         * if                       ( is a local )      ( c-addr u idx             )
         *    nip nip [compile-local] exit              (                          )
         * else                                         ( c-addr u idx             )
         *    drop                                      ( c-addr u                 )
         * then                                         ( c-addr u                 )
         * 2dup string>name nip                         ( c-addr u nt|0 -1|0|1     )
         * ?if                      ( is a word )       ( c-addr u nt  -1|1        )
         *    2nip (eval-name) (check-stacks) exit      (                          )
         * then                                         ( c-addr u 0 0             )
         * 2drop 2dup string>number                     ( c-addr u x t|f           )
         * if                       ( is a number )     ( c-addr u x               )
         *    nip nip (eval-number) exit                (                          )
         * then                     ( neither )         ( c-addr u x               )
         * drop ex-message!                             (                          )
         * M6ERR_UNDEFINED_WORD throw                   (                          )
         */
        CALL(parse_name),
        _q_if0_, T(3),
            two_drop, exit,
        then,
        two_dup, CALL(string_to_local),
        _if_, T(6+nCALLt),
            nip, nip, CALL(_compile_local_), exit,
        _else_, T(2),
            drop,
        then,
        two_dup, CALL(string_to_name), nip,
        _q_if_, T(5+2*nCALLt),
            two_nip, CALL(_eval_name_), CALL(_check_stacks_), exit,
        then,
        two_drop, two_dup, CALL(string_to_number),
        _if_, T(5+nCALLt),
            nip, nip, CALL(_eval_number_), exit,
        then,
        drop, ex_message_store,
        _lit_, T(M6ERR_UNDEFINED_WORD), throw, exit
    )
WORD_END(interpret)
/* ( c-addr u ch -- u' ) get position of given char or CR/LF in string, whatever comes first */
WORD(line_find_char,   interpret,      DSTACK(3,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_MEM_FETCH)
/* replace first wordlist in search order with m64th_asm wordlist ( SO: wid -- m64th_asm ) */
WORD_START(m64th_asm,   line_find_char)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        _lit_cell_, CELL(m6wordlist_m64th_asm),         /* ( wid                ) */
        searchorder_store_0, exit                      /* (                    ) */
    )
WORD_END(m64th_asm)
/* replace first wordlist in search order with m64th_c wordlist ( SO: wid -- m64th_c ) */
WORD_START(m64th_c,     m64th_asm)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        _lit_cell_, CELL(m6wordlist_m64th_c),           /* ( wid                ) */
        searchorder_store_0, exit                      /* (                    ) */
    )
WORD_END(m64th_c)
/* replace first wordlist in search order with m64th_core wordlist ( SO: wid -- m64th_core ) */
WORD_START(m64th_core,  m64th_c)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        _lit_cell_, CELL(m6wordlist_m64th_core),        /* ( wid                ) */
        searchorder_store_0, exit                      /* (                    ) */
    )
WORD_END(m64th_core)
/* replace first wordlist in search order with m64th_impl wordlist ( SO: wid -- m64th_impl ) */
WORD_START(m64th_impl,  m64th_core)
    WORD_DSTACK(0,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        _lit_cell_, CELL(m6wordlist_m64th_impl),        /* ( wid                ) */
        searchorder_store_0, exit                      /* (                    ) */
    )
WORD_END(m64th_impl)
WORD(noop,             m64th_impl,     DSTACK(0,0), RSTACK(0,0), WORD_PURE)
WORD(n_to_drop,        noop,           DSTACK(-1,0),RSTACK(0,0), WORD_PURE)
WORD(r_one_plus,       n_to_drop,      DSTACK(0,0), RSTACK(1,1), WORD_R_PURE)
WORD(r_one_minus,      r_one_plus,     DSTACK(0,0), RSTACK(1,1), WORD_R_PURE)
WORD(r_store,          r_one_minus,    DSTACK(1,0), RSTACK(1,1), WORD_R_PURE)
WORD(r_plus_store,     r_store,        DSTACK(1,0), RSTACK(1,1), WORD_R_PURE)
WORD(r_from_drop,      r_plus_store,   DSTACK(0,0), RSTACK(1,0), WORD_R_PURE)
WORD(rdepth,           r_from_drop,    DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/**
 * forth interpreter/compiler loop:
 *    call INTERPRET repeatedly until I/O error reading input
 */
WORD_START(repl,  rdepth)
    WORD_DSTACK(-1,-1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        /* begin                                       ( ...           )
         *    out>obuf obuf-flush drop                 ( ...           )
         *    in>ibuf ibuf-refill-if-empty             ( ... err|0     )
         * while0                                      ( ...           )
         *    ' interpret catch                        ( ...' ex|0     )
         *    dup 0=                                   ( ... ex|0 t|f  )
         *    in>ibuf ibuf-skip-blanks                 ( ... ex|0 t|f  )
         *    in>ibuf iobuf-empty? and                 ( ... ex|0 t|f  )
         *    if                                       ( ... 0         )
         *       drop (repl-type-ack)                  ( ...           )
         *    else                                     ( ... ex|0      )
         *       ?dup if                               ( ... ex        )
         *          type-exception                     ( ...           )
         *          compiler-abort                     ( ...           )
         *       then                                  ( ...           )
         *    then                                     ( ...           )
         * repeat                                      ( ...           )
         */
        begin,
            out_to_obuf, CALL(obuf_flush), drop,
            in_to_ibuf, CALL(ibuf_refill_if_empty),
        _while0_, T(25+5*nCALLt),
            _lit_xt_, XT(interpret), _catch_beg_, _catch_end_,
            dup, zero_equal,
            in_to_ibuf, CALL(ibuf_skip_blanks),
            in_to_ibuf, iobuf_empty_query, and,
            _if_, T(4+nCALLt),
                drop, CALL(_repl_type_ack_),
            _else_, T(7+2*nCALLt),
                question_dup,
                _if_, T(3+2*nCALLt),
                    CALL(type_exception),
                    /* also unconditionally stops compiling */
                    CALL(compiler_abort),
                then,
            then,
        _repeat_, T(-32-7*nCALLt), exit
    )
WORD_END(repl)
WORD(r2nd_fetch,       repl,           DSTACK(0,1), RSTACK(2,2), WORD_R_PURE)
WORD(r3rd_fetch,       r2nd_fetch,     DSTACK(0,1), RSTACK(3,3), WORD_R_PURE)
/* sp@ ( x -- x addr-of-x ) get current data stack address */
WORD(sp_fetch,         r3rd_fetch,     DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
WORD(squared,          sp_fetch,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(sub,              squared,        DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD_START(minus_roll, sub)
    WORD_DSTACK(1,0) /* DSTACK(x+1,x)   */
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE() /* uses %rip-relative TOKEN_CALL_NOTHROW, cannot inline in native code */
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(minus_roll, exit)
WORD_END(minus_roll)
WORD(minus_rot,        minus_roll,     DSTACK(3,3), RSTACK(0,0), WORD_PURE)
/* ( ex|0 -- ) write '\n' exception and ex-message@ to current output */
WORD_START(type_exception,   minus_rot)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0)
    WORD_CODE(
        /* ?if0                                        ( 0             )
         *    drop exit                                (               )
         * then                                        ( ex            )
         * s\" \n exception " type                     (               )
         * .                                           (               )
         * ex-message@ type cr                         (               )
         */
        _q_if0_, T(3),
            drop, exit,
        then,
        LIT_STRING(11, "\nexception "), type,
        CALL(dot),
        ex_message_fetch, type,
        _lit_, T('\n'), emit, exit
    )
WORD_END(type_exception)
WORD(div_byte,         type_exception, DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_char,         div_byte,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_short,        div_char,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_ushort,       div_short,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_int,          div_ushort,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_uint,         div_int,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(div_cell,         div_uint,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(byte_plus,        div_cell,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* char_plus already in forth 'core' word set */
WORD(short_plus,       byte_plus,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(ushort_plus,      short_plus,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(int_plus,         ushort_plus,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(uint_plus,        int_plus,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* cell_plus already in forth 'core' word set */
WORD(bytes,            uint_plus,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* chars     already in forth 'core' word set */
WORD(shorts,           bytes,          DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(ushorts,          shorts,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(ints,             ushorts,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(uints,            ints,           DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* cells     already in forth 'core' word set */

DEF_WORD_FETCH(uints)

DEF_WORD_STORE(cell_fetch_8)

WORD(one_byte,         cell_store_8,   DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* 1 i.e. sizeof(byte)   */
WORD(one_char,         one_byte,       DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* 1 i.e. sizeof(char)   */
WORD(one_short,        one_char,       DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* 2 i.e. sizeof(short)  */
WORD(one_ushort,       one_short,      DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* 2 i.e. sizeof(ushort) */
WORD(one_int,          one_ushort,     DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* 4 i.e. sizeof(int)    */
WORD(one_uint,         one_int,        DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* 4 i.e. sizeof(uint)   */
WORD(one_cell,         one_uint,       DSTACK(0,1), RSTACK(0,0), WORD_PURE) /* 8 i.e. sizeof(cell)   */
WORD(short_comma,      one_cell,       DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
WORD(int_comma,        short_comma,    DSTACK(1,0), RSTACK(0,0), WORD_IMPURE)
/* ( c-addr u -- ) store 1-byte u then string data at HERE */
WORD_NOASM(countedstring_comma,     int_comma,   DSTACK(2,0), RSTACK(0,0), WORD_IMPURE)
/* ( c-addr u -- ) store string data at HERE */
WORD_NOASM(string_comma,    countedstring_comma, DSTACK(2,0), RSTACK(0,0), WORD_IMPURE)
WORD(short_align,      string_comma,   DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
WORD(int_align,        short_align,    DSTACK(0,0), RSTACK(0,0), WORD_IMPURE)
WORD(short_aligned,    int_align,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(int_aligned,      short_aligned,  DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_byte,          int_aligned,    DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_char,          to_byte,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_short,         to_char,        DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_ushort,        to_short,       DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_int,           to_ushort,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD(to_uint,          to_int,         DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* see-name ( nt -- ) show definition of nt */
WORD_START(see_name,   to_uint)
    WORD_DSTACK(1,0)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE)
    WORD_CODE(
        zero,                                                  /* ( nt 0          ) */
        _c_locals_save_,
            _c_arg_2_, _c_call_, CELL(m6word_print_stdout), _c_ret_0_,
        _c_locals_load_, exit
    )
WORD_END(see_name)
WORD(state_fetch,          see_name,           DSTACK(0,1), RSTACK(0,0), WORD_IMPURE)
/**
 * string-find-blank ( c-addr u -- u' ) return index of first blank (i.e. char <= 32) in string.
 * return string length if not found.
 */
WORD(string_find_blank,    state_fetch,        DSTACK(2,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_MEM_FETCH)
/**
 * string-find-char ( c-addr u ch -- u' ) return index of first ch in string.
 * return string length if not found.
 */
WORD(string_find_char,     string_find_blank,  DSTACK(3,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_MEM_FETCH)
/**
 * string-find-nonblank ( c-addr u -- u' ) return index of first non-blank (i.e. char > 32) in string.
 * return string length if not found.
 */
WORD(string_find_nonblank, string_find_char,   DSTACK(2,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_MEM_FETCH)
/*
 * string>lower ( c-addr-src c-addr-dst u -- c-addr-dst u )
 * copy a string converting it to lower case
 */
WORD(string_to_lower,  string_find_nonblank,   DSTACK(3,2), RSTACK(0,0), WORD_IMPURE | M6FLAG_MEM_FETCH | M6FLAG_MEM_STORE)
/**
 * string>number ( c-addr u -- x t|f )
 * convert string to number, recognizing base prefixes # $ % and sign prefix '-'
 * Also convert any single-quoted char 'x' to ASCII code of x
 */
WORD_START(string_to_number, string_to_lower)
    WORD_DSTACK(2,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(0) /* multiple exits => cannot inline */
    WORD_CODE(
        /* ?if0
         *    nip false exit               ( 0 false             )
         * then
         * string>char dup invert          ( caddr n c flag      )
         * if
         *    nip nip true exit            ( c true              )
         * then                            ( caddr n -1          )
         * drop string>base -rot           ( base caddr n        )
         * string>sign over                ( base caddr n sign n )
         * if0                             ( base caddr n sign   )
         *    2drop drop false exit        ( 0 false             ) \ no digits
         * then                            ( base caddr n sign   )
         * >r rot                          ( caddr n base        ) ( R: sign )
         * string&base>u                   ( caddr n u           ) ( R: sign )
         * rot drop                        ( n u                 ) ( R: sign )
         * r> * swap                       ( x n                 )
         * 0=                              ( x t|f               )
         */
        _q_if0_, T(4),
            nip, false, exit,
        then,
        CALL(string_to_char), dup, invert,
        _if_, T(5),
            nip, nip, true, exit,
        then,
        drop, CALL(string_to_base), minus_rot,
        CALL(string_to_sign), over,
        _if0_, T(5),
            two_drop, drop, false, exit,
        then,
        to_r, rot,
        CALL(string_base_to_u),
        rot, drop, r_from, times, swap,
        zero_equal, exit
    )
WORD_END(string_to_number)
/* string= ( addr1 addr2 u -- addr1 addr2 u t|f ) t if the two strings have the same content */
WORD(string_equal, string_to_number, DSTACK(3,4), RSTACK(0,0), M6FLAG_INLINE | M6FLAG_MEM_FETCH)
/* string-ci= ( addr1 addr2 u -- addr1 addr2 u t|f ) t if the two strings have the same content, ignoring case */
WORD(string_ci_equal,  string_equal, DSTACK(3,4), RSTACK(0,0), M6FLAG_INLINE | M6FLAG_MEM_FETCH)
WORD_START(string_ci_ne,  string_ci_equal)
    WORD_DSTACK(3,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_FETCH)
    /* "string-ci= 0=" optimizes better than "string-ci= invert" */
    WORD_CODE(string_ci_equal, zero_equal, exit)
WORD_END(string_ci_ne)
WORD_START(string_ne,  string_ci_ne)
    WORD_DSTACK(3,4)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_FETCH)
    /* "string= 0=" optimizes better than "string= invert" */
    WORD_CODE(string_equal, zero_equal, exit)
WORD_END(string_ne)
WORD(trail,            string_ne,      DSTACK(2,3), RSTACK(0,0), WORD_PURE)
WORD(u_less_equal,     trail,          DSTACK(2,1), RSTACK(0,0), WORD_PURE)
WORD(u_more_equal,     u_less_equal,   DSTACK(2,1), RSTACK(0,0), WORD_PURE)
/* u>d ( u -- du ) extend unsigned number to double width */
WORD(u_to_d,           u_more_equal,   DSTACK(1,2), RSTACK(0,0), WORD_PURE)
/* u/ ( u1 u2 -- u1/u2 ) unsigned divide */
WORD(u_div,            u_to_d,         DSTACK(2,1), RSTACK(0,0), WORD_PURE)
/* u/mod ( u1 u2 -- u1%u2 u1/u2 ) unsigned remainder & divide */
WORD(u_div_mod,        u_div,          DSTACK(2,2), RSTACK(0,0), WORD_PURE)
/* u2/ ( u -- u/2 ) unsigned divide by two */
WORD(u_two_div,        u_div_mod,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* u4/ ( u -- u/4 ) unsigned divide by four */
WORD(u_four_div,       u_two_div,      DSTACK(1,1), RSTACK(0,0), WORD_PURE)
/* u8/ ( u -- u/8 ) unsigned divide by eight */
WORD(u_eight_div,      u_four_div,     DSTACK(1,1), RSTACK(0,0), WORD_PURE)
WORD_START(valid_base_q, u_eight_div)
    WORD_DSTACK(1,1)
    WORD_RSTACK(0,0)
    WORD_STACK_NONE()
    WORD_ASM_NONE()
    WORD_FLAGS(M6FLAG_INLINE | M6FLAG_MEM_FETCH)
    WORD_CODE(
        two, _lit_, T(37),             /* base 2 37                    */
        within,                        /* caddr n base                 */
        exit
    )
WORD_END(valid_base_q)
WORD(xt_to_validate,      valid_base_q,   DSTACK(1,1), RSTACK(0,0), WORD_IMPURE | M6FLAG_MEM_FETCH)

#undef LASTWORD
#define LASTWORD xt_to_validate
