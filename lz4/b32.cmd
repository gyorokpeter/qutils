@call config.cmd
@if not exist ..\libq.a (
    echo create ..\libq.a as per https://code.kx.com/q/interfaces/using-c-functions/#windows-mingw-64
    exit /b 1
)
g++ -shared -m32 lz4k.cpp %LZ4_PATH%/lz4.c -I%KX_KDB_PATH%/c/c -I%LZ4_PATH% -L.. -lq -o ../lz4k_w32.dll -static
