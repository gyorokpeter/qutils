setlocal

set "OLDPATH=%PATH%

@call config.cmd

@set "PATH=%MINGW32_PATH%;%OLDPATH%"
@call b32.cmd || exit /b 1

@set "PATH=%MINGW64_PATH%;%OLDPATH%"
@call b64.cmd
