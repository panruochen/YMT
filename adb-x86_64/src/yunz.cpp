#ifdef __linux__

#include <unistd.h>
#include <sys/syscall.h>
#include <sys/types.h>

extern "C" pid_t gettid()
{
    pid_t tid;
    tid = syscall(SYS_gettid);
    return tid;
}

#elif defined(__CYGWIN__)

#include <windows.h>

extern "C" pid_t gettid()
{
    return GetCurrentThreadId();
}



#endif


