# This file is part of m4th.
#
# m4th is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License
# as published by the Free Software Foundation, either version 3
# of the License, or (at your option) any later version.
#
# m4th is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with m4th.  If not, see <https://www.gnu.org/licenses/>.

#
# this file adds command z to gdb, printing the status of forth virtual machine.
#
# installation: add the line
#   source /FULL/PATH/TO/gdb_helper.py
# to the file $HOME/.gdbinit
#

class PrintDataStack(gdb.Command):
    def __init__(self):
        gdb.Command.__init__(self, "z", gdb.COMMAND_DATA, gdb.COMPLETE_SYMBOL, True)
        self.sz = 8
        self.szt = 2
    def invoke(self, arg, from_tty):
        inf = gdb.selected_inferior()
        frame = gdb.selected_frame()
        dtop = int(frame.read_register("rbx"))
        rtop = int(frame.read_register("r12"))
        dstk = int(frame.read_register("rdi"))
        rstk = int(frame.read_register("rsi"))
        m4th = int(frame.read_register("r13"))
        ip   = int(frame.read_register("r15"))
        dend = int(gdb.parse_and_eval("((m4th *)%d)->dstack.end" % m4th))
        rend = int(gdb.parse_and_eval("((m4th *)%d)->rstack.end" % m4th))
        dn = int((dend - dstk) / self.sz) + 1
        rn = int((rend - rstk) / self.sz) + 1
        self.stack_print(inf, "dstack", dtop, dstk, dn)
        self.stack_print(inf, "rstack", rtop, rstk, rn)
        self.code_print(inf, "code   ", ip)
    def stack_print(self, inf, label, top, stk, n):
        gdb.write("%s <%d> " % (label, n))
        if n > 0:
            if n > 1:
                self.slice_reverse_print(inf, stk, n - 1)
            self.number_print(top)
        gdb.write("\n")
    def slice_reverse_print(self, inf, addr, n):
        for i in range(n):
            self.mem_cell_print(inf, addr + (n - i - 1) * self.sz)
    def mem_cell_print(self, inf, addr):
        self.mem_print(inf, addr, self.sz)
    def mem_print(self, inf, addr, size):
        val = 0
        shift = 0
        for b in inf.read_memory(addr, size):
            val |= (b[0] << shift)
            shift += 8
        self.number_print(val)
    def number_print(self, val):
        if val < -1000 or val > 1000:
            gdb.write("%s " % hex(val))
        else:
            gdb.write("%d " % val)
    def code_print(self, inf, label, addr):
        gdb.write(label)
        for _ in range(10):
            tok = self.token_at(inf, addr)
            gdb.write(tok)
            gdb.write(" ")
            if tok == "bye" or tok == "m4bye":
                break
            addr += self.szt
        gdb.write("\n")
    def token_at(self, inf, addr):
        s = str(gdb.parse_and_eval("(enum m4_token_e)*(m4token*)%d" % addr))
        if len(s) > 2 and s[:2] == "m4":
            s = s[2:]
        return s

PrintDataStack()
