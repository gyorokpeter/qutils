cls
@call config.cmd
@if not exist ..\libq64.a (
    echo create ..\libq64.a as per https://code.kx.com/q/interfaces/using-c-functions/#windows-mingw-64
    exit /b 1
)
g++ -o ../poly2tri_w64.dll -shared poly2tri_k.cpp ^
    %POLY2TRI_PATH%/poly2tri/common/shapes.cc ^
    %POLY2TRI_PATH%/poly2tri/sweep/cdt.cc ^
    %POLY2TRI_PATH%/poly2tri/sweep/sweep.cc ^
    %POLY2TRI_PATH%/poly2tri/sweep/sweep_context.cc ^
    %POLY2TRI_PATH%/poly2tri/sweep/advancing_front.cc ^
    -I.. -I%POLY2TRI_PATH%/poly2tri -I%KX_KDB_PATH%/c/c -L.. -lq64 -static
