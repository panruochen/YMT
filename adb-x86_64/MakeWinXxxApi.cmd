
if %BUILD_ALT_DIR% == "" (
    echo WinDDK not install >&2
	exit -b 1
)

set TOP_DIR=%CD%\src\development\host\windows
set OBJ_DIR=obj%BUILD_ALT_DIR%\amd64

cd %TOP_DIR%\usb\api
del /S /Q %OBJ_DIR%
build
copy /y %OBJ_DIR%\AdbWinApi.dll %TOP_DIR%\prebuilt\

cd %TOP_DIR%\usb\winusb
del /S /Q %OBJ_DIR%
build
copy /y %OBJ_DIR%\AdbWinUsbApi.dll %TOP_DIR%\prebuilt\
copy /y %OBJ_DIR%\AdbWinUsbApi.lib %TOP_DIR%\prebuilt\

cd %TOP_DIR%\..\..\..
