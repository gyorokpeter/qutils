{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    .img.priv.lib:`$":",path,"/../img";
    .img.imgToBmp:.img.priv.lib 2:(`k_imgToBmp;1);
    .img.ddsToImg:.img.priv.lib 2:(`k_ddsToImg;1);
    .img.bmpToImg:.img.priv.lib 2:(`k_bmpToImg;1);
    }[]
