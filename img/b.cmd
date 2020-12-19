cls
@call config.cmd
@if not exist ..\libq.a (
	echo create ..\libq.a as per https://code.kx.com/q/interfaces/using-c-functions/#windows-mingw-64
	exit 1
)
g++ -shared imgk.cpp -I%KX_KDB_PATH%/c/c -L.. -lq -o ../img.dll -static
