g++ zlibk.cpp -c
g++ -shared zlibk.cpp -L. -lq -lz -o zlibk.dll
