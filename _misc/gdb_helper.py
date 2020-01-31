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
        dend = int(gdb.parse_and_eval("((m4th *)%d)->dstack.end" % m4th))
        rend = int(gdb.parse_and_eval("((m4th *)%d)->rstack.end" % m4th))
        dn = int((dend - dstk) / self.sz) + 1
        rn = int((rend - rstk) / self.sz) + 1
        self.stack_print(inf, "dstack", dtop, dstk, dn)
        self.stack_print(inf, "rstack", rtop, rstk, rn)
    def stack_print(self, inf, label, top, stk, n):
        gdb.write("%s <%d> " % (label, n))
        if n > 0:
            gdb.write("%d " % top)
            if n > 1:
                for i in range(n-1):
                    self.m4cell_print(inf, stk)
        gdb.write("\n")
    def m4cell_print(self, inf, addr):
        self.mem_print(inf, addr, self.sz)
    def mem_print(self, inf, addr, size):
        val = 0
        shift = 0
        for b in inf.read_memory(addr, size):
            val |= (b[0] << shift)
            shift += 8
        gdb.write("%d " % val)

PrintDataStack()
