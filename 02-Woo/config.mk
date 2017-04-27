LOCAL_MODULE := Woo.exe
LOCAL_SRC_FILES := c/ cxx/ main.c
LOCAL_SRC_EXTS := c cpp cxx
LOCAL_EXCLUDE_FILES := cxx/3-err.cpp
LOCAL_OBJ_DIR = objs

$(call BUILD_EXECUTABLE)
