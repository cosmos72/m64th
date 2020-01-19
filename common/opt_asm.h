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

#define OPT1_BODY(x, _) x((noop), ())

#define OPT2_BODY(x, _)                                                                            \
    x((minus_one, star), (negate))            /* -1 *          => negate                    */     \
        x((minus_one, plus), (one_minus))     /* -1 +          => 1-                        */     \
        x((minus_one, minus), (one_plus))     /* -1 -          => 1+                        */     \
        x((minus_one, slash), (negate))       /* -1 /          => negate                    */     \
        x((minus_one, and), ())               /* -1 and        =>                           */     \
        x((minus_one, mod), (slash))          /* -1 mod        => drop 0                    */     \
        x((minus_one, or), (drop, minus_one)) /* -1 or         => drop -1                   */     \
        x((minus_one, xor), (invert))         /* -1 xor        => invert                    */     \
        x((zero, star), (drop, drop, zero))   /*  0 *          => drop 0                    */     \
        x((zero, minus), ())                  /*  0 -          =>                           */     \
        x((zero, plus), ())                   /*  0 +          =>                           */     \
        x((zero, and), (drop, zero))          /*  0 and        => drop 0                    */     \
        x((zero, lshift), ())                 /*  0 lshift     =>                           */     \
        x((zero, or), ())                     /*  0 or         =>                           */     \
        x((zero, rshift), ())                 /*  0 rshift     =>                           */     \
        x((zero, xor), ())                    /*  0 xor        =>                           */     \
        x((one, star), ())                    /*  1 *          =>                           */     \
        x((one, plus), (one_plus))            /*  1 +          => 1+                        */     \
        x((one, minus), (one_minus))          /*  1 -          => 1-                        */     \
        x((one, slash), ())                   /*  1 /          =>                           */     \
        x((one, slash_mod), (slash))          /*  1 /mod       => drop 0                    */     \
        x((one, lshift), (two_star))          /*  1 lshift     => 2*                        */     \
        x((one, mod), ())                     /*  1 mod        => drop 0                    */     \
        x((two, star), (two_star))            /*  2 *          => 2*                        */     \
        x((two, plus), (two_plus))            /*  2 +          => 2+                        */     \
        x((two, minus), (two_minus))          /*  2 -          => 2-                        */     \
        x((two, slash), (two_slash))          /*  2 /          => 2/                        */     \
        x((slash_mod, drop), (slash))         /* /mod drop     => /                         */     \
        x((slash_mod, nip), (mod))            /* /mod nip      => mod                       */     \
        x((to_r, from_r), ())                 /* >r   r>       =>         TODO: comparisons */     \
        x((fetch, drop), (drop))              /* @    drop     => drop                      */     \
        x((abs, abs), (abs))                  /* abs  abs      => abs                       */     \
        x((abs, squared), (squared))          /* abs  squared  => squared                   */     \
        x((dup, star), (squared))             /* dup  *        => squared                   */     \
        x((dup, plus), (two_star))            /* dup  +        => 2*                        */     \
        x((dup, minus), (drop, zero))         /* dup  -        => drop 0                    */     \
        x((dup, slash), (drop, one))          /* dup  /        => drop 1                    */     \
        x((dup, and), ())                     /* dup  and      =>                           */     \
        x((dup, drop), ())                    /* dup  drop     =>                           */     \
        x((dup, max), ())                     /* dup  max      =>                           */     \
        x((dup, min), ())                     /* dup  min      =>                           */     \
        x((dup, mod), (drop, zero))           /* dup  mod      => drop 0                    */     \
        x((dup, nip), ())                     /* dup  nip      =>                           */     \
        x((dup, or), ())                      /* dup  or       =>                           */     \
        x((dup, xor), ())                     /* dup  xor      => drop 0                    */     \
        x((dup, swap), ())                    /* dup  swap     => dup                       */     \
        x((c_fetch, drop), (drop))            /* c@   drop     => drop                      */     \
        x((i, drop), ())                      /* i    drop     =>                           */     \
        x((i, star), (i_star))                /* i    *        => i*                        */     \
        x((i, plus), (i_plus))                /* i    +        => i+                        */     \
        x((i, minus), (i_minus))              /* i    -        => i-                        */     \
        x((invert, invert), ())               /* invert invert =>                           */     \
        x((invert, negate), (one_plus))       /* invert negate => 1-                        */     \
        x((negate, abs), (abs))               /* negate abs    => abs                       */     \
        x((negate, negate), ())               /* negate negate =>                           */     \
        x((negate, invert), (one_minus))      /* invert negate => 1+                        */     \
        x((negate, squared), (squared))       /* negate squared => squared                  */     \
        x((over, drop), ())                   /* over drop     =>                           */     \
        x((over, nip), (swap))                /* over nip      => swap                      */     \
        x((from_r, to_r), ())                 /* r>   >r       =>                           */     \
        x((swap, drop), (nip))                /* swap drop     => nip                       */     \
        x((swap, nip), (drop))                /* swap nip      => drop                      */     \
        x((swap, swap), ())                   /* swap swap     =>                           */

#define OPT3_BODY(x, _) x((rot, rot, rot), ()) /* rot rot rot   =>                           */
