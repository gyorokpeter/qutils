{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    .img.priv.lib:`$":",path,"/../img_",string[.z.o];
    .img.imgToBmp:.img.priv.lib 2:(`k_imgToBmp;1);
    .img.ddsToImg:.img.priv.lib 2:(`k_ddsToImg;1);
    .img.bmpToImg:.img.priv.lib 2:(`k_bmpToImg;1);
    .img.tgaToImg:.img.priv.lib 2:(`k_tgaToImg;1);
    }[]
