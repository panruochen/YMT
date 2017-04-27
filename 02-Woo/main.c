#include <stdio.h>

extern int c_foo1(void);
extern int cxx_foo1();
extern const char *cxx_foo2();
extern const char *cxx_variable1;

int main() {
    printf("c_foo1() = %d\n", cxx_foo1());
    printf("cxx_foo1() = %d\n", cxx_foo1());
    printf("cxx_foo2() = %s\n", cxx_foo2());
    printf("cxx_variable1 = %s\n", cxx_variable1);
    printf("Hello world\n");
    return 0;
}
