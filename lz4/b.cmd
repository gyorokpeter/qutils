setlocal

set "OLDPATH=%PATH%

@set "PATH=D:\msys64\mingw32\bin;%OLDPATH%"
@call b32.cmd || exit /b 1

@set "PATH=D:\msys64\mingw64\bin;%OLDPATH%"
@call b64.cmd
