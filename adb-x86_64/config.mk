#ymt_fast_build := 1

DECLARE_LOCAL_MODULE = $(eval LOCAL_OBJ_DIR := .objs) \
    $(eval LOCAL_MODULE := libs/lib$1.a) \
	$(eval LOCAL_STATIC_LIBRARIES += libs/lib$1.a)

#adb_version := $(shell git -C $(LOCAL_PATH) rev-parse --short=12 HEAD 2>/dev/null)-android
adb_version := ruochen-porting

#OS_TYPE := windows
OS_TYPE := linux

on_windows = $(call seq,$(OS_TYPE),windows)
on_linux   = $(call seq,$(OS_TYPE),linux)

MY_GCC_PREFIX := $(if $(on_windows),x86_64-w64-mingw32-)

ADB_COMMON_CFLAGS := \
    -Wall -Wextra -Werror \
    -Wno-unused-parameter \
    -Wno-missing-field-initializers \
    -Wvla \
    -DADB_HOST=1 \
    -DADB_REVISION='"$(adb_version)"' \
	-include "src/yunz.h"

ADB_COMMON_linux_CFLAGS := \
##    -Wexit-time-destructors \

# Define windows.h and tchar.h Unicode preprocessor symbols so that
# CreateFile(), _tfopen(), etc. map to versions that take wchar_t*, breaking the
# build if you accidentally pass char*. Fix by calling like:
#   std::wstring path_wide;
#   if (!android::base::UTF8ToWide(path_utf8, &path_wide)) { /* error handling */ }
#   CreateFileW(path_wide.c_str());
ADB_COMMON_windows_CFLAGS := \
	-D_WIN32_WINNT=0x0600 \
    -Wno-misleading-indentation -DUNICODE=1 -D_UNICODE=1

ADB_CFLAGS := \
    $(ADB_COMMON_CFLAGS) \
	$(ADB_COMMON_$(OS_TYPE)_CFLAGS)

ADB_CXXFLAGS := \
    $(ADB_COMMON_CFLAGS) \
	$(ADB_COMMON_$(OS_TYPE)_CFLAGS) \
	-std=gnu++1y

# libcutils
# =========================================================
$(call CLEAR_VARS)

$(call DECLARE_LOCAL_MODULE,cutils)

LOCAL_PATH := src/libcutils
LOCAL_GCC_PREFIX := $(MY_GCC_PREFIX)
LOCAL_SRC_EXTS := c cpp

LOCAL_CFLAGS := $(ADB_CFLAGS)
LOCAL_SRC_FILES := load_file.c
LOCAL_SRC_FILES += $(if $(on_windows),socket_inaddr_any_server_windows.c socket_network_client_windows.c)
LOCAL_SRC_FILES += $(if $(on_linux),\
  socket_inaddr_any_server_unix.c  socket_local_server_unix.c     socket_loopback_server_unix.c \
  socket_local_client_unix.c       socket_loopback_client_unix.c  socket_network_client_unix.c)

LOCAL_SRC_FILES := $(addprefix $(LOCAL_PATH)/,$(LOCAL_SRC_FILES))

LOCAL_C_INCLUDES := src/adb src/libcutils

$(call BUILD_STATIC_LIBRARY)

# libbase
# =========================================================
$(call CLEAR_VARS)

$(call DECLARE_LOCAL_MODULE,base)
LOCAL_GCC_PREFIX := $(MY_GCC_PREFIX)
LOCAL_SRC_EXTS := c cpp

LOCAL_PATH     := src/base
LOCAL_CFLAGS   := $(ADB_CFLAGS)
LOCAL_CXXFLAGS := $(ADB_CXXFLAGS)
LOCAL_SRC_FILES := $(addprefix $(LOCAL_PATH)/,\
	$(if $(on_windows),errors_windows.cpp utf8.cpp) \
    logging.cpp strings.cpp stringprintf.cpp file.cpp parsenetaddress.cpp)

LOCAL_C_INCLUDES := src/adb src/base/include src/libcutils src/development/host/windows/usb/api

$(call BUILD_STATIC_LIBRARY)

# libcrypto_static
# =========================================================
$(call CLEAR_VARS)

$(call DECLARE_LOCAL_MODULE,crypto_static)
LOCAL_GCC_PREFIX := $(MY_GCC_PREFIX)

ifeq (windows,$(OS_TYPE))
LOCAL_SRC_EXTS := c asm
LOCAL_ASM_EXTS := asm
LOCAL_CMD_AS := yasm -fwin64 -o $$@ $$<
else
LOCAL_SRC_EXTS := c S
endif

LOCAL_PATH := src/boringssl
LOCAL_CFLAGS := $(if $(on_windows),-D__WINCRYPT_H__ -Wno-sign-compare -Wno-unknown-pragmas -Wno-attributes \
	-include "winsock2.h") $(ADB_CFLAGS)
LOCAL_SRC_FILES :=  $(shell ls $(LOCAL_PATH)/*.c) $(shell find $(LOCAL_PATH)/src -name '*.c') \
    $(if $(on_linux),$(shell find $(LOCAL_PATH)/linux-x86_64 -name '*.[cS]')) \
    $(if $(on_windows),$(shell find $(LOCAL_PATH)/win-x86_64 -name '*.c' -o -name '*.asm'))
LOCAL_C_INCLUDES := src/base/include $(LOCAL_PATH)/src/include $(LOCAL_PATH)/src/crypto  #libcutils

$(call BUILD_STATIC_LIBRARY)

# libadb
# =========================================================
$(call CLEAR_VARS)

LOCAL_GCC_PREFIX := $(MY_GCC_PREFIX)
$(call DECLARE_LOCAL_MODULE,adb)
LOCAL_SRC_EXTS := c cpp

LOCAL_PATH := src/adb
LOCAL_CFLAGS := -D__WINCRYPT_H__ $(ADB_CXXFLAGS)

LOCAL_SRC_FILES := \
    adb.cpp \
    adb_auth.cpp \
    adb_io.cpp \
    adb_listeners.cpp \
    adb_trace.cpp \
    adb_utils.cpp \
    transport.cpp \
    transport_local.cpp \
    transport_usb.cpp \
    adb_auth_host.cpp \
    fdevent.cpp \
    sockets.cpp
LOCAL_SRC_FILES := $(addprefix $(LOCAL_PATH)/,$(LOCAL_SRC_FILES))
LOCAL_C_INCLUDES := src/adb src/base/include src/libcutils
LOCAL_CFLAGS_adb/usb_windows.cpp := -include "adb.h"

$(call BUILD_STATIC_LIBRARY)

# libdiagnose_usb
# =========================================================
$(call CLEAR_VARS)

$(call DECLARE_LOCAL_MODULE,diagnose_usb)
LOCAL_GCC_PREFIX := $(MY_GCC_PREFIX)
LOCAL_SRC_EXTS := c cpp
LOCAL_CFLAGS := $(ADB_CXXFLAGS)
LOCAL_SRC_FILES := src/adb/diagnose_usb.cpp
LOCAL_C_INCLUDES := src/adb src/base/include src/libcutils

$(call BUILD_STATIC_LIBRARY)

# adb host tool
# =========================================================
$(call CLEAR_VARS)

LOCAL_GCC_PREFIX := $(MY_GCC_PREFIX)
LOCAL_MODULE := bin/adb.exe
LOCAL_OBJ_DIR  := .objs
LOCAL_SRC_EXTS := c cpp
LOCAL_LDLIBS_linux := -lrt -ldl -lpthread

# Use wmain instead of main
LOCAL_LDFLAGS_windows := -municode
LOCAL_LDLIBS_windows := -lws2_32 -lgdi32
LOCAL_STATIC_LIBRARIES_windows := AdbWinApi
LOCAL_REQUIRED_MODULES_windows := AdbWinApi AdbWinUsbApi

LOCAL_PATH := src/adb
LOCAL_SRC_FILES := \
    adb_client.cpp \
    bugreport.cpp \
    client/main.cpp \
    console.cpp \
    commandline.cpp \
    file_sync_client.cpp \
    line_printer.cpp \
    services.cpp \
    shell_service_protocol.cpp \
    usb_$(OS_TYPE).cpp \
    $(if $(on_windows),sysdeps_win32.cpp sysdeps/win32/stat.cpp) \
    $(if $(on_linux),get_my_path_linux.cpp sysdeps_unix.cpp)

LOCAL_SRC_FILES := $(addprefix $(LOCAL_PATH)/,$(LOCAL_SRC_FILES)) src/yunz.cpp
LOCAL_C_INCLUDES_windows := src/development/host/windows/usb/api/
LOCAL_C_INCLUDES := src/adb src/base/include src/libcutils $(LOCAL_C_INCLUDES_$(OS_TYPE))
LOCAL_CFLAGS_adb/services.cpp := $(if $(on_windows),-D_WIN32)

LOCAL_CFLAGS := \
    $(ADB_CXXFLAGS) \
	-D_GNU_SOURCE -Wno-format

LOCAL_LDLIBS := \
    adb diagnose_usb base cutils crypto_static
LOCAL_LDLIBS := $(foreach i,$(LOCAL_LDLIBS),libs/lib$(i).a) \
 $(if $(on_windows),\
    src/development/host/windows/prebuilt/AdbWinUsbApi.dll \
	src/development/host/windows/prebuilt/AdbWinApi.dll \
	-lws2_32 -municode) \
 $(if $(on_linux),-lpthread) \
 -static-libgcc ##-static-libstdc++

LOCAL_REQUIRED_LIBS := $(LOCAL_STATIC_LIBRARIES)

$(call BUILD_EXECUTABLE)
