#
# Copyright (C) 2020 Massimiliano Ghilardi
#
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
# this file adds command z to gdb, for printing the status of m4th forth virtual machine.
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
        (dtop,rtop,dstk,rstk,m4th,ip) = self.read_registers(inf)
        dend = int(gdb.parse_and_eval("((m4th *)%d)->dstack.end" % m4th))
        rend = int(gdb.parse_and_eval("((m4th *)%d)->rstack.end" % m4th))
        dn = int((dend - dstk) / self.sz) + 1
        rn = int((rend - rstk) / self.sz) + 1
        self.stack_print(inf, "dstack", dtop, dstk, dn)
        self.stack_print(inf, "rstack", rtop, rstk, rn)
        self.ip_print("ip    ", ip)
        self.code_print(inf, "code   ", ip)
    def read_registers(self, inf):
        frame = gdb.selected_frame()
        regs = ()
        arch_name = inf.architecture().name()
        if arch_name == "i386:x86-64":
            regs = ("rbx", "rbp", "rdi", "rsi", "r13", "r15")
        elif arch_name == "aarch64":
            regs = ("x20", "x22", "x21", "x23", "x24", "x27")
        return (
            int(frame.read_register(regs[0])), # dtop
            int(frame.read_register(regs[1])), # rtop
            int(frame.read_register(regs[2])), # dstk
            int(frame.read_register(regs[3])), # rstk
            int(frame.read_register(regs[4])), # m4th
            int(frame.read_register(regs[5])) - self.szt) # ip
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
        gdb.write("%s " % self.number_to_str(val))
    def number_to_str(self, val):
        if val < -1024 or val > 1024:
            return hex(val)
        else:
            return str(val)
    def ip_print(self, label, ip):
        gdb.write("%s %s\n" % (label, self.number_to_str(ip)))
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
