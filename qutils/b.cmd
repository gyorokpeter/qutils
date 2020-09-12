cls
call config.cmd
g++ -shared qutils.cpp qutilsk.cpp -I%KX_KDB_PATH%/c/c -L%KX_KDB_PATH%/w32 -lq -o ../qutils.dll
