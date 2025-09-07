cls
@call config.cmd
@if not exist ..\libq64.a (
    echo create ..\libq64.a as per https://code.kx.com/q/interfaces/using-c-functions/#windows-mingw-64
    exit /b 1
)
g++ -shared imgk.cpp -I%KX_KDB_PATH%/c/c -L.. -lq64 -o ../img_w64.dll -static
