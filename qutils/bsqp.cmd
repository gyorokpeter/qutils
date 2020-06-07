g++ sqpk.cpp -c -Wall
:: explode.c is: https://github.com/ladislav-zezula/StormLib/blob/master/src/pklib/explode.c
g++ -shared sqpk.cpp ../sqp/explode.c -L. -lq -lz -o sqpk.dll
