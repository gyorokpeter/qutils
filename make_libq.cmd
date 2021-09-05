:: based on https://code.kx.com/q/interfaces/using-c-functions/#windows-mingw-64
dlltool -v -l libq.a -d q.def
gcc -shared -DKXVER=3 add.c -L. -lq -o add.dll
