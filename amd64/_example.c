long equal(long a, long b, long ttrue) {
    return a == b ? ttrue : 0;
}

long zero_equal(long a, long ttrue) {
    return a == 0 ? ttrue : 0;
}

long zero_less_than(long a) {
    return a < 0 ? -1 : 0;
}

long zero_greater_than(long a, long ttrue) {
    return a > 0 ? ttrue : 0;
}
