#ifndef __PORTING_H
#define __PORTING_H

#ifndef __ASSEMBLER__

# include <string.h>
# include <errno.h>

# define _Nonnull
# define _Nullable

#ifdef __cplusplus
#  include <string>
#  include <condition_variable>
#endif // __cplusplus

#if defined(__MINGW64__)||defined(__MINGW32__)
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <io.h>

#define O_CLOEXEC   O_NOINHERIT
#define O_NOFOLLOW  0
#define DEFFILEMODE 0666

#include <winsock2.h>
#include <windows.h>
#ifdef ERROR
#undef ERROR
#endif

#define PRId64 "lld"
#define PRIu64 "llu"

#endif // __MINGW64__

#endif // __ASSEMBLER__
#endif // __PORTING_H
