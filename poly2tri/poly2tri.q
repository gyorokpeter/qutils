{
    path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    lib:`$":",path,"/../poly2tri2";
    .p2t.poly2tri:lib 2:(`poly2tri;2);
    .p2t.colorMap:lib 2:(`colorMap;1);
    .p2t.getContour:lib 2:(`getContour;2);
    .p2t.setWallSize:lib 2:(`setWallSize;1);
    }[]
