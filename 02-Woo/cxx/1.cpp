
extern "C"
int cxx_foo1() {
	return 1;
}

extern "C"
const char *cxx_foo2() {
	return __func__;
}
