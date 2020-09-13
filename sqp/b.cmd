g++ sqpk.cpp -c -Wall
@call config.cmd
@if not exist ..\libq.a (
	echo create ..\libq.a as per https://code.kx.com/q/interfaces/using-c-functions/#windows-mingw-64
	exit 1
)
:: explode.c is: https://github.com/ladislav-zezula/StormLib/blob/master/src/pklib/explode.c
g++ -shared sqpk.cpp %STORMLIB_PATH%/src/pklib/explode.c -I%STORMLIB_PATH%/src/pklib -I%KX_KDB_PATH%/c/c -L.. -lq -lz -o ../sqpk.dll
