
int fib(int n) {
    int fst = 1;
    int scd = 1;

    for (int i = 1; i < n; ++i) {
        int tmp = fst;
        fst = scd;
        scd = tmp + fst;
    }

    return fst;
}


int main() {
    int res = fib(10);
    asm("ecall");
}