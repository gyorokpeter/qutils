\c 2000 2000

\l img.q

`:../simple.bmp 1: .img.imgToBmp[(2130706687 2130771712 2147418112 0Wi;-16776961 -16711936 -65536 -1i)]
`:../rgba.bmp 1: .img.imgToBmp .img.ddsToImg[read1`:testImg/rgba.dds]
`:../dxt1.bmp 1: .img.imgToBmp .img.ddsToImg[read1`:testImg/dxt1.dds]
`:../dxt3.bmp 1: .img.imgToBmp .img.ddsToImg[read1`:testImg/dxt3.dds]
`:../dxt5.bmp 1: .img.imgToBmp .img.ddsToImg[read1`:testImg/dxt5.dds]
`:../dxt5_2.bmp 1: .img.imgToBmp .img.ddsToImg[read1`:testImg/dxt5_2.dds]
`:../tga_example.bmp 1: .img.imgToBmp .img.tgaToImg[read1`:testImg/example.tga]
if[not (.img.bmpToImg read1`:testImg/simple.bmp)~(2130706687 2130771712 2147418112 0Wi;-16776961 -16711936 -65536 -1i); '"failed"];
if[not (.img.bmpToImg read1`:testImg/simple24.bmp)~(8421631 8454016 16744576 16777215i;255 65280 16711680 16777215i); '"failed"];
//.img.bmpToImg read1`:../my2gn.bmp

//img:150>=avg each/:1_/:/:0x00 vs/:/:.img.bmpToImg read1`:../myg2n.bmp;

thinCore:{[img]
    p1:img;
    p0:img<>img;
    p2:-1 rotate img;
    p4:1 rotate/:img;
    p6:1 rotate img;
    p8:-1 rotate/:img;

    p3:-1 rotate p4;
    p5:1 rotate p4;
    p7:1 rotate p8;
    p9:-1 rotate p8;

    a:1=sum 1=p0 -':(p2;p3;p4;p5;p6;p7;p8;p9);
    b:sum[(p2;p3;p4;p5;p6;p7;p8;p9)] within 2 6;
    c:0=p2*p4*p6;
    d:0=p4*p6*p8;

    img:img and not (a and b and c and d);

    p1:img;
    p0:img<>img;
    p2:-1 rotate img;
    p4:1 rotate/:img;
    p6:1 rotate img;
    p8:-1 rotate/:img;

    p3:-1 rotate p4;
    p5:1 rotate p4;
    p7:1 rotate p8;
    p9:-1 rotate p8;

    a:1=sum 1=p0 -':(p2;p3;p4;p5;p6;p7;p8;p9);
    b:sum[(p2;p3;p4;p5;p6;p7;p8;p9)] within 2 6;
    c:0=p2*p4*p8;
    d:0=p2*p6*p8;

    img:img and not (a and b and c and d);
    img};
thin:{[img]thinCore/[img]};
thinAndSave:{[path]`:../thinned.bmp 1: .img.imgToBmp 16777215i*1i-thin 150>=avg each/:1_/:/:0x00 vs/:/:.img.bmpToImg read1 path};

where2d:{raze til[count x],/:'where each x}

skeleton:thin 150>=avg each/:1_/:/:0x00 vs/:/:.img.bmpToImg read1`:../myg2n.bmp;
`:../thinned.bmp 1: .img.imgToBmp 16777215i*1i-skeleton;

queue:enlist first where2d skeleton;
