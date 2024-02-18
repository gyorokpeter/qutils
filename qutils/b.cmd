setlocal
cls
call config.cmd
@if not exist ..\libq.a (
    echo create ..\libq.a using ..\make_libq.cmd
    exit /b 1
)
g++ -shared qutils.cpp qutilsk.cpp -I%KX_KDB_PATH%/c/c -L.. -lq -o ../qutils.dll -static
