\c 2000 2000

\l poly2tri.q

//show .p2t.poly2tri[(0 0.;0 1.;1 1.;1 0.);()]
//show .p2t.poly2tri[(0 0.;0 3.;3 3.;3 0.);enlist(1 1.;2 1.;2 2.;1 2.)]
//`:triangles.svg 0: enlist
//    .h.htac[`svg;`xmlns`xmlns:xlink`width`height`viewBox!("http://www.w3.org/2000/svg";"http://www.w3.org/1999/xlink";"1024";"1024";" "sv string 0 0 512 512)]
//    "\n"sv {.h.htac[`path;(`fill;`stroke;`$"stroke-width";`d)!("none";"red";"0.1";"M ",(" "sv string x 0)," L "," "sv " "sv/:string 1 rotate x);""]}each res 0;
//
//-1"color map:";
cmap:.p2t.colorMap[(
    0x0101010101010000;
    0x0100000101010100;
    0x0100000101010101;
    0x0101010101010101;
    0x0101010101010101;
    0x0101010000010101;
    0x0101010000010101;
    0x0001010101010101;
    0x0000010101010101
    )]
//show cmap;

data:(0x0101010101;
      0x0102020201;
      0x0102020201;
      0x0102020201;
      0x0101010101;
      0x0101010101;
      0x0101020101;
      0x0102010201;
      0x0101010101
     );
cont:.p2t.getContour[data;0x02];

data:(0x01020202;
      0x02010102;
      0x02010102;
      0x02020202);
.p2t.setWallSize 0f;
conts1:enlist .p2t.getContour[data;0x02];
.p2t.setWallSize 0.1;
conts2:enlist .p2t.getContour[data;0x02];
//`:contour.svg 0: enlist
//    .h.htac[`svg;`xmlns`xmlns:xlink`width`height`viewBox!("http://www.w3.org/2000/svg";"http://www.w3.org/1999/xlink";"1024";"1024";" "sv string -1 -1,(1+count[first data]),(1+count[data]))]
//    ("\n" sv "\n"sv/:{.h.htac[`path;(`fill;`stroke;`$"stroke-width";`d)!("none";"black";"0.1";"M ",(" "sv string x 0)," L "," "sv " "sv/:string 1 rotate x);""]}each/:conts1),
//    ("\n" sv "\n"sv/:{.h.htac[`path;(`fill;`stroke;`$"stroke-width";`d)!("none";"red";"0.1";"M ",(" "sv string x 0)," L "," "sv " "sv/:string 1 rotate x);""]}each/:conts2);
if[not conts1~enlist enlist(0.5 -0.5;0.5 0.25;0.75 0.5;2.5 0.5;2.5 2.5;0.5 2.5;0.5 0.75;0.25 0.5;-0.5 0.5;-0.5 3.5;3.5 3.5;3.5 -0.5);'"failed"];
if[not conts2~enlist enlist(0.6 -0.4;0.6 0.2;0.8 0.4;2.6 0.4;2.6 2.6;0.4 2.6;0.4 0.8;0.2 0.6;-0.4 0.6;-0.4 3.4;3.4 3.4;3.4 -0.4);'"failed"];

data:(0x02020202;
      0x02010102;
      0x02010102;
      0x01020202);
.p2t.setWallSize 0f;
conts1:enlist .p2t.getContour[data;0x02];
.p2t.setWallSize 0.1;
conts2:enlist .p2t.getContour[data;0x02];
//`:contour.svg 0: enlist
//    .h.htac[`svg;`xmlns`xmlns:xlink`width`height`viewBox!("http://www.w3.org/2000/svg";"http://www.w3.org/1999/xlink";"1024";"1024";" "sv string -1 -1,(1+count[first data]),(1+count[data]))]
//    ("\n" sv "\n"sv/:{.h.htac[`path;(`fill;`stroke;`$"stroke-width";`d)!("none";"black";"0.1";"M ",(" "sv string x 0)," L "," "sv " "sv/:string 1 rotate x);""]}each/:conts1),
//    ("\n" sv "\n"sv/:{.h.htac[`path;(`fill;`stroke;`$"stroke-width";`d)!("none";"red";"0.1";"M ",(" "sv string x 0)," L "," "sv " "sv/:string 1 rotate x);""]}each/:conts2);
if[not conts1~enlist enlist(-0.5 -0.5;-0.5 2.5;0.25 2.5;0.5 2.25;0.5 0.5;2.5 0.5;2.5 2.5;0.75 2.5;0.5 2.75;0.5 3.5;3.5 3.5;3.5 -0.5);'"failed"];
if[not conts2~enlist enlist(-0.4 -0.4;-0.4 2.4;0.2 2.4;0.4 2.2;0.4 0.4;2.6 0.4;2.6 2.6;0.8 2.6;0.6 2.8;0.6 3.4;3.4 3.4;3.4 -0.4);'"failed"];


data:(
    0x01020201;
    0x02010102;
    0x01020201);
.p2t.setWallSize 0f;
cont:.p2t.getContour[data;0x02]
//`:contour.svg 0: enlist
//    .h.htac[`svg;`xmlns`xmlns:xlink`width`height`viewBox!("http://www.w3.org/2000/svg";"http://www.w3.org/1999/xlink";"1024";"1024";" "sv string -1 -1,(1+count[first data]),(1+count[data]))]
//    "\n" sv {.h.htac[`path;(`fill;`stroke;`$"stroke-width";`d)!("none";"black";"0.1";"M ",(" "sv string x 0)," L "," "sv " "sv/:string 1 rotate x);""]}each cont;
if[not cont~((0.5 -0.5;0.5 0.25;0.75 0.5;2.25 0.5;2.5 0.25;2.5 -0.5);(-0.5 0.5;-0.5 1.5;0.25 1.5;0.5 1.25;0.5 0.75;0.25 0.5);(3.5 0.5;2.75 0.5;2.5 0.75;2.5 1.25;2.75 1.5;3.5 1.5);(0.5 1.75;0.5 2.5;2.5 2.5;2.5 1.75;2.25 1.5;0.75 1.5));'"failed"];
if[1 in count each cont; '"failed"];
