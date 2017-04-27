# YMT

YMT is a GNU makefile template helpful to set up C/C++ projects quickly and easily
along with gcc.

##### A HelloWorld
Let us begin with a very simple HelloWorld project which includes following files:
  - config.mk
  - Ymt.mk
  - helloworld.c

As you see config.mk has very few lines
```
LOCAL_MODULE := HelloWorld.exe
LOCAL_SRC_FILES := helloworld.c
$(call BUILD_EXECUTABLE)
``` 

Then build the project simply running:
```
cd 01-helloworld
make -f ../Ymt.mk
```

##### Continue to the project Woo 
Things become more complicated.
 - Source files are stored in different directories.
 - Some files are not expected to be compiled.
 - Output object files are expected to be put under directory "objs".

You can easily handle these by creating a simple config.mk
```
LOCAL_MODULE := Woo.exe
LOCAL_SRC_FILES := c/ cxx/ main.c
LOCAL_SRC_EXTS := c cpp cxx
LOCAL_EXCLUDE_FILES := cxx/3-err.cpp
LOCAL_OBJ_DIR = objs
$(call BUILD_EXECUTABLE)
```

The key variables LOCAL_SRC_FILES and LOCAL_SRC_EXTS control how to obtain source
file list automatically, as if YMT executes the follow pesudo code.
```
 foreach DIR in $(LOCAL_SRC_FILES)
   foreach EXT in $(LOCAL_SRC_EXTS)
     sources += $(ls $DIR/*.$EXT)
 sources += $(foreach FILE in $(LOCAL_SRC_FILES))
 sources -= $(LOCAL_EXCLUDE_FILES)
```

##### Multiple modules
Actually you can put multiple modules inside one single config file,
as the project Xee shows:
```
$(call CLEAR_VARS)
LOCAL_MODULE := Xee.exe
LOCAL_SRC_FILES := xee-2.c
LOCAL_OBJ_DIR = objs/xee-2
LOCAL_REQUIRED_LIBS = xee-1.a
$(call BUILD_EXECUTABLE)

$(call CLEAR_VARS)
LOCAL_MODULE := xee-1.a
LOCAL_SRC_FILES := xee-1.c
LOCAL_OBJ_DIR = objs/xee-1
$(call BUILD_STATIC_LIBRARY)
```
$(call CLEAR_VARS) shall be put on the very first line of every module.
LOCAL_REQUIRED_LIBS indicates dependencies between modules so that parallel
compiling can go properly.

Alternatively it is okay to split one single config file into multiple sperate files.
- config-1.mk
```
$(call CLEAR_VARS)
LOCAL_MODULE := Xee.exe
LOCAL_SRC_FILES := xee-2.c
LOCAL_OBJ_DIR = objs/xee-2
LOCAL_REQUIRED_LIBS = xee-1.a
$(call BUILD_EXECUTABLE)
```
- config-2.mk
```
$(call CLEAR_VARS)
LOCAL_MODULE := xee-1.a
LOCAL_SRC_FILES := xee-1.c
LOCAL_OBJ_DIR = objs/xee-1
$(call BUILD_STATIC_LIBRARY)
```
- One top makefile is required
```
LOCAL_PROJECT_CONFIGS := config-1.mk config-2.mk
include ../Ymt.mk
```


##### Working Directory
Since YMT does not change current direcory during the whole build process,
the working directory is always the one where `make' is run.

##### Target Types
<table>
  <tbody align="left">
    <tr>
      <th>Target Type</th>
      <th>Statement</th>
    </tr>
    <tr>
      <td>Executable</td>
      <td>$(call BUILD_EXECUTABLE)</td>
    </tr>
    <tr>
      <td>Static Library</td>
      <td>$(call BUILD_STATIC_LIBRARY)</td>
    </tr>
    <tr>
      <td>Shared Library</td>
      <td>$(call BUILD_SHARED_LIBRARY)</td>
    </tr>
    <tr>
      <td>Raw Binary</td>
      <td>$(call BUILD_RAW_BINARY)</td>
    </tr>
  </tbody>
</table>

##### Key Variables
<table>
  <tbody align="left">
    <tr>
      <th>Variables</th>
      <th>Meanings</th>
      <th>Example usecase</th>
    </tr>
    <tr>
      <td>LOCAL_MODULE</td>
      <td>Path name of the module</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_SRC_FILES</td>
      <td>Source files and directories for this module. Those ending with a splash is taken as directories.
Others are taken as files.</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_SRC_EXTS</td>
      <td>Valid source file extension names of the module</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_CFLAGS</td>
      <td>Basic compiler flags for each C source file</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_CXXFLAGS</td>
      <td>Basic compiler flags for each C++ source file. If not set, identical to $(LOCAL_CFLAGS).</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_C_INCLUDES</td>
      <td>Include paths for C/C++ source files</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_LDFLAGS</td>
      <td>Linker flags for the module</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_LDLIBS</td>
      <td>Libraries for linking the module</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_EXCLUDE_FILES</td>
      <td>Source files ignored while building this module</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_OBJ_DIR</td>
      <td>Output directory for object files</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_MODULE_PRECONDITIONS</td>
      <td>Define the targets which are depened by this module</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_REQUIRED_LIBS</td>
      <td>Libraries required by this module and will be used in linking the executable module</td>
	  <td align="center">***</td>
    </tr>
    <tr>
      <td>LOCAL_ASM_EXTS</td>
      <td>User-defined assembler extension name. By default it is S and s.</td>
      <td>It is usual that assembler files have the extension name asm on Windows.</td>
    </tr>
    <tr>
      <td>LOCAL_CMD_AS</td>
      <td>User-defined command line for compiling assembler files. If LOCAL_ASM_EXTS is set,
      this variable must be set as well.</td>
      <td>It is usual that assembler files with the extension name asm shall be compiled by nams/yasm.</td>
    </tr>
    <tr>
      <td>LOCAL_GCC_PREFIX</td>
      <td>User-defined gcc compiler preifx.</td>
      <td>Set LOCAL_GCC_PREFIX := x86_64-pc-</br> 
          if your gcc compiler is x86_64-pc-gcc.</td>
    </tr>
    <tr>
      <td>LOCAL_MODULE_PRECONDITIONS</td>
      <td>Define preconditions of the module</td>
    </tr>
    <tr>
      <td>LOCAL_CFLAGS_xxx.y</td>
      <td>Extra compiler flags for the very source file xxx.y</td>
      <td>Set LOCAL_CLAGS_dir1/1.c = -DFOO=1</br>
	  if the source file dir1/a.c needs extra flags -DFOO=1</td>
    </tr>
  </tbody>
</table>



