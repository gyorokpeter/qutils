@call config.cmd
@if not exist ..\libq64.a (
    echo create ..\libq64.a as per https://code.kx.com/q/interfaces/using-c-functions/#windows-mingw-64
    exit /b 1
)
g++ -shared lz4k.cpp %LZ4_PATH%/lz4.c -I%KX_KDB_PATH%/c/c -I%LZ4_PATH% -L.. -lq64 -o ../lz4k_w64.dll -static
