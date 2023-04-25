int main() {
    int n = 6;
    
    int fst = 0, scd = 1;
    for(int i = 2; i < n; ++i) {
        int tmp = fst;
        fst = scd;
        scd = tmp + fst;
    }

    asm("ecall");    
}