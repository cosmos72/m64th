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

#ifndef M4TH_M4TH_MACRO_H
#define M4TH_M4TH_MACRO_H

/* macros that are part of m4th public API */

/* m4th flags */
#define M4TH_FLAG_STATUS_MASK 1 /**< mask to extract interpret/compile flag */
#define M4TH_FLAG_INTERPRET 0   /**< m4th is currently interpreting         */
#define M4TH_FLAG_COMPILE 1     /**< m4th is currently compiling            */

/* m4word flags */
#define M4FLAG_COMPILE_ONLY (1 << 0) /**< word cannot interpreted - only compiled     */
#define M4FLAG_IMMEDIATE (1 << 1)    /**< word is executed immediately                */
#define M4FLAG_INLINE_MASK (3 << 2)
#define M4FLAG_INLINE (1 << 2)        /**< forth code of word can be inlined           */
#define M4FLAG_INLINE_ALWAYS (2 << 2) /**< forth code of word *must* always be inlined */
#define M4FLAG_INLINE_NATIVE (3 << 2) /**< both forth & native code of word can be inlined */

#define M4FLAG_JUMP_MASK (3 << 4)
/**
 * word always jumps to some other instruction than the following one.
 * incompatible with M4FLAG_PURE
 */
#define M4FLAG_JUMP (1 << 4)
/**
 * word may jump to some other instruction than the following one.
 * incompatible with M4FLAG_PURE
 */
#define M4FLAG_MAY_JUMP (2 << 4)

#define M4FLAG_PURE_MASK (3 << 4)
/**
 * results are a fixed arithmetic algorithm depending only
 * on numeric value of arguments:
 * the word does not dereference any pointer (not even variables)
 * and does not use the instruction pointer or any other external status or data.
 *
 * incompatible with M4FLAG_CONSUMES_IP_* and M4FLAG_*JUMP
 */
#define M4FLAG_PURE (3 << 4)

#define M4FLAG_CONSUMES_IP_MASK ((3 << 6) | M4FLAG_INLINE_MASK)
/**
 * word must be followed by 1, 2, 4 or 8 bytes, which are used (not modified) and jumped over.
 *
 * implies M4FLAG_INLINE_ALWAYS, incompatible with M4FLAG_PURE.
 */
#define M4FLAG_CONSUMES_IP_2 ((1 << 6) | M4FLAG_INLINE_ALWAYS)
#define M4FLAG_CONSUMES_IP_4 ((2 << 6) | M4FLAG_INLINE_ALWAYS)
#define M4FLAG_CONSUMES_IP_8 ((3 << 6) | M4FLAG_INLINE_ALWAYS)

/** word dereferences some pointer and reads from i */
#define M4FLAG_MEM_FETCH 0 /* FIXME */
/** word dereferences some pointer and writes to it */
#define M4FLAG_MEM_STORE 0 /* FIXME */

#endif /* M4TH_M4TH_MACRO_H */
