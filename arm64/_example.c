typedef unsigned char uchar;
typedef unsigned long ulong;

typedef struct upair_s {
    ulong first, second;
} upair;

typedef struct m4th_s {
    void *data;
} m4th;

typedef struct instruction_s instruction;

struct instruction_s {
    long (*f)(long dtop, long *dstk, long rtop, long *rstk, const instruction *ip, m4th *m);
};

long m4equal(long dtop, long *dstk, long rtop, long *rstk, const instruction *ip, m4th *m) {
    long a = *dstk++;
    dtop = (a == dtop) ? 1 : 0;
    ++ip;
    return ip->f(dtop, dstk, rtop, rstk, ip, m);
}

long equal(long a, long b) {
    return a == b ? -1 : 0;
}

long less_than(long a, long b) {
    return a < b ? -1 : 0;
}

long less_equal_than(long a, long b) {
    return a <= b ? -1 : 0;
}

long greater_than(long a, long b) {
    return a > b ? -1 : 0;
}

long greater_equal_than(long a, long b) {
    return a >= b ? -1 : 0;
}

long zero_equal(long a) {
    return a == 0 ? -1 : 0;
}

long zero_less_than(long a) {
    return a < 0 ? -1 : 0;
}

long zero_greater_than(long a) {
    return a > 0 ? -1 : 0;
}

ulong c_fetch(uchar *addr) {
    return (ulong)*addr;
}

void c_store(uchar value, uchar *addr) {
    *addr = value;
}

long div(long a, long b) {
    return a / b;
}

ulong udiv(ulong a, ulong b) {
    return a / b;
}

upair udiv_rem(ulong a, ulong b) {
    upair ret = {a / b, a % b};
    return ret;
}
