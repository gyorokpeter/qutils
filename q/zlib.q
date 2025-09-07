{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    lib:`$":",path,"/../zlib_",string[.z.o];
    .zlib.uncompress:lib 2:(`k_zlib_uncompress;1);
    .zlib.compress:lib 2:(`k_zlib_compress;1);
    }[]
