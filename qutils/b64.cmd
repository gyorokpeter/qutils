setlocal
cls
call config.cmd
@if not exist ..\libq64.a (
    echo create ..\libq64.a using ..\make_libq.cmd
    exit /b 1
)
g++ -shared qutils.cpp qutilsk.cpp -I%KX_KDB_PATH%/c/c -L.. -lq64 -o ../qutils_w64.dll -static
