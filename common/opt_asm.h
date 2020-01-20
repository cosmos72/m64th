/**
 * This file is part of m4th.
 *
 * m4th is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3
 * of the License, or (at your option) any later version.
 *
 * m4th is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with m4th.  If not, see <https://www.gnu.org/licenses/>.
 */

#define OPT1_BODY(x, _) x((noop), _)

#define OPT2_BODY(x, _)                                  /* note: '_' represents noop      */      \
    x((minus_one, star), (negate))                       /* -1 *           => negate       */      \
        x((minus_one, plus), (one_minus))                /* -1 +           => 1-           */      \
        x((minus_one, minus), (one_plus))                /* -1 -           => 1+           */      \
        x((minus_one, slash), (negate))                  /* -1 /           => negate       */      \
        x((minus_one, and), _)                           /* -1 and         =>              */      \
        x((minus_one, mod), (slash))                     /* -1 mod         => drop 0       */      \
        x((minus_one, or), (drop, minus_one))            /* -1 or          => drop -1      */      \
        x((minus_one, xor), (invert))                    /* -1 xor         => invert       */      \
        x((zero, star), (drop, drop, zero))              /*  0 *           => drop 0       */      \
        x((zero, minus), _)                              /*  0 -           =>              */      \
        x((zero, plus), _)                               /*  0 +           =>              */      \
        x((zero, less_than), (zero_less_than))           /*  0 <           => 0<           */      \
        x((zero, less_equals), (zero_less_equals))       /*  0 <=          => 0<=          */      \
        x((zero, not_equals), (zero_not_equals))         /*  0 <>          => 0<>          */      \
        x((zero, equals), (zero_equals))                 /*  0 =           => 0=           */      \
        x((zero, greater_than), (zero_greater_than))     /*  0 >           => 0>           */      \
        x((zero, greater_equals), (zero_greater_equals)) /*  0 >=          => 0>=          */      \
        x((zero, and), (drop, zero))                     /*  0 and         => drop 0       */      \
        x((zero, lshift), _)                             /*  0 lshift      =>              */      \
        x((zero, or), _)                                 /*  0 or          =>              */      \
        x((zero, rshift), _)                             /*  0 rshift      =>              */      \
        x((zero, xor), _)                                /*  0 xor         =>              */      \
        x((one, star), _)                                /*  1 *           =>              */      \
        x((one, plus), (one_plus))                       /*  1 +           => 1+           */      \
        x((one, minus), (one_minus))                     /*  1 -           => 1-           */      \
        x((one, slash), _)                               /*  1 /           =>              */      \
        x((one, slash_mod), (slash))                     /*  1 /mod        => drop 0       */      \
        x((one, lshift), (two_star))                     /*  1 lshift      => 2*           */      \
        x((one, mod), _)                                 /*  1 mod         => drop 0       */      \
        x((two, star), (two_star))                       /*  2 *           => 2*           */      \
        x((two, plus), (two_plus))                       /*  2 +           => 2+           */      \
        x((two, minus), (two_minus))                     /*  2 -           => 2-           */      \
        x((two, slash), (two_slash))                     /*  2 /           => 2/           */      \
        x((slash_mod, drop), (slash))                    /* /mod drop      => /            */      \
        x((slash_mod, nip), (mod))                       /* /mod nip       => mod          */      \
        x((star, negate), (negate, star))                /* *    negate    => negate *     */      \
        x((less_than, invert), (greater_equals))         /* <    invert    => >=           */      \
        x((less_equals, invert), (greater_than))         /* <=   invert    => >            */      \
        x((not_equals, invert), (equals))                /* <>   invert    => =            */      \
        x((equals, invert), (not_equals))                /* =    invert    => <>           */      \
        x((greater_than, invert), (less_equals))         /* >    invert    => <=           */      \
        x((greater_equals, invert), (less_than))         /* >=   invert    => <            */      \
        x((to_r, from_r), _)                             /* >r   r>        =>              */      \
        x((fetch, drop), (drop))                         /* @    drop      => drop         */      \
        x((abs, abs), (abs))                             /* abs  abs       => abs          */      \
        x((abs, squared), (squared))                     /* abs  squared   => squared      */      \
        x((dup, star), (squared))                        /* dup  *         => squared      */      \
        x((dup, plus), (two_star))                       /* dup  +         => 2*           */      \
        x((dup, minus), (drop, zero))                    /* dup  -         => drop 0       */      \
        x((dup, slash), (drop, one))                     /* dup  /         => drop 1       */      \
        x((dup, less_than), (drop, false))               /* dup  <         => drop false   */      \
        x((dup, less_equals), (drop, true))              /* dup  <=        => drop true    */      \
        x((dup, not_equals), (drop, false))              /* dup  <>        => drop false   */      \
        x((dup, equals), (drop, true))                   /* dup  =         => drop true    */      \
        x((dup, greater_than), (drop, false))            /* dup  >         => drop false   */      \
        x((dup, greater_equals), (drop, true))           /* dup  >=        => drop true    */      \
        x((dup, and), _)                                 /* dup  and       =>              */      \
        x((dup, drop), _)                                /* dup  drop      =>              */      \
        x((dup, max), _)                                 /* dup  max       =>              */      \
        x((dup, min), _)                                 /* dup  min       =>              */      \
        x((dup, mod), (drop, zero))                      /* dup  mod       => drop 0       */      \
        x((dup, nip), _)                                 /* dup  nip       =>              */      \
        x((dup, or), _)                                  /* dup  or        =>              */      \
        x((dup, xor), (drop, zero))                      /* dup  xor       => drop 0       */      \
        x((dup, swap), _)                                /* dup  swap      => dup          */      \
        x((c_fetch, drop), (drop))                       /* c@   drop      => drop         */      \
        x((i, drop), _)                                  /* i    drop      =>              */      \
        x((i, star), (i_star))                           /* i    *         => i*           */      \
        x((i, plus), (i_plus))                           /* i    +         => i+           */      \
        x((i, minus), (i_minus))                         /* i    -         => i-           */      \
        x((invert, invert), _)                           /* invert invert  =>              */      \
        x((invert, negate), (one_plus))                  /* invert negate  => 1+           */      \
        x((negate, plus), (minus))                       /* negate +       => -            */      \
        x((negate, minus), (plus))                       /* negate -       => +            */      \
        x((negate, abs), (abs))                          /* negate abs     => abs          */      \
        x((negate, negate), _)                           /* negate negate  =>              */      \
        x((negate, invert), (one_minus))                 /* negate invert  => 1-           */      \
        x((negate, squared), (squared))                  /* negate squared => squared      */      \
        x((over, drop), _)                               /* over drop      =>              */      \
        x((over, nip), (swap))                           /* over nip       => swap         */      \
        x((from_r, to_r), _)                             /* r>   >r        =>              */      \
        x((swap, star), (star))                          /* swap *         => *            */      \
        x((swap, plus), (plus))                          /* swap +         => +            */      \
        x((swap, minus), (minus, negate))                /* swap -         => - negate     */      \
        x((swap, less_than), (greater_than))             /* swap <         => >            */      \
        x((swap, less_equals), (greater_equals))         /* swap <=        => >=           */      \
        x((swap, not_equals), (not_equals))              /* swap <>        => <>           */      \
        x((swap, equals), (equals))                      /* swap =         => =            */      \
        x((swap, greater_than), (less_equals))           /* swap >         => <            */      \
        x((swap, greater_equals), (less_equals))         /* swap >=        => <=           */      \
        x((swap, and), (and))                            /* swap and       => and          */      \
        x((swap, drop), (nip))                           /* swap drop      => nip          */      \
        x((swap, max), (max))                            /* swap max       => max          */      \
        x((swap, min), (min))                            /* swap min       => min          */      \
        x((swap, nip), (drop))                           /* swap nip       => drop         */      \
        x((swap, or), (or))                              /* swap or        => or           */      \
        x((swap, swap), _)                               /* swap swap      =>              */      \
        x((swap, xor), (xor))                            /* swap xor       => xor          */

#define OPT3_BODY(x, _) x((rot, rot, rot), _) /* rot rot rot    =>              */
