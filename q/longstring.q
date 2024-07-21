.qutils.longstringAddSuffixes:1b;

longstring:{
    t:type x;
    if[t in 100 101 102 105h; :string[x]];
    if[t=0h; :$[1=count x;"enlist[",.z.s[first x],"]";"(",(";"sv .z.s each x),")"]];
    if[t=-1h; :string[x],"b"];
    if[t=-2h; $[null x;:"0Ng"; '"nyi GUID literal"]];
    if[t=-4h; :"0x",string[x]];
    if[t in -5 -6 -17 -19h; :$[null x;"0N";string[x]],.Q.t[abs t]];
    if[t in -12 -14 -16 -18h; :$[null x;"0N";string[x]],$[.qutils.longstringAddSuffixes or null x;.Q.t[abs t];""]];
    if[t=-7h; :$[null x;"0N";string[x]],$[.qutils.longstringAddSuffixes;"j";""]];
    if[t in -8 -9h; :$[null x;"0n";string[x]],.Q.t[abs t]];
    if[t=-11h; :"`",string[x]];
    if[t in 1 5 6 7 12 14 16 18 19h;
        :$[0=count x;"`",string[key x],"$()";
           1=count x;"enlist[",.z.s[first x],"]";
         ($[t=1;"";" "]sv {$[null x;"0N";string[x]]}each x),$[$[.qutils.longstringAddSuffixes;1b;(t=1)or(7<>t)and all null x];.Q.t[t];""]];
    ];
    if[t in 8 9h;
        :$[1=count x;"enlist[",string[first x],.Q.t[t],"]";(" "sv {$[null x;"0n";string[x]]}each x),.Q.t[t]];
    ];
    if[t=4h; :"0x",raze string x];
    if[t=-10h; :.Q.s1[x]];
    if[t=10h; :"\"",ssr/[x;("\\";"\"";"\r";"\n";"\t");("\\\\";"\\\"";"\\r";"\\n";"\\t")],"\""];
    if[t=11h;
        if[0=count x; :"(`$())"];
        :$[1=count x;"enlist[",.z.s[first x],"]";raze"`",/:string[x]]
    ];
    if[t=98h;
        if[0<count cols[x] inter .Q.res,key`.q; :"flip[",.z.s[flip x],"]"];
        :"([]",(";"sv string[cols x],'":",/:.z.s each value flip x),")"
    ];
    if[t=99h; :.z.s[key x],"!",.z.s[value x]];
    if[t=103h; :string x];
    if[t=104h; v:value x; :.z.s[first v],"[",(";"sv .z.s each 1_v),"]"];
    '"nyi type ",string t};

longstringTest:{
    if[not longstring[0101b]~"0101b"; {'x}"failed"];
    if[not longstring[enlist 0Ni]~"enlist[0Ni]"; {'x}"failed"];
    if[not longstring[([]a:enlist 0Ni)]~"([]a:enlist[0Ni])"; {'x}"failed"];
    if[not longstring[/]~enlist"/"; {'x}"failed"];
    if[not longstring["\\w"]~"\"\\\\w\""; {'x}"failed"];
    .qutils.longstringAddSuffixes:0b;
    if[not longstring[(1;2p;2000.01.04;4n;5v)]~"(1;2000.01.01D02:00:00.000000000;2000.01.04;0D04:00:00.000000000;05:00:00)"; {'x}"failed"];
    if[not longstring[(0N;0Np;0Nd;0Nn;0Nv)]~"(0N;0Np;0Nd;0Nn;0Nv)"; {'x}"failed"];
    if[not longstring[(0N 0N;0N 0Np;0N 0Nd;0N 0Nn;0N 0Nv)]~"(0N 0N;0N 0Np;0N 0Nd;0N 0Nn;0N 0Nv)"; {'x}"failed"];
    if[not longstring[enlist each(0N;0Np;0Nd;0Nn;0Nv)]~"(enlist[0N];enlist[0Np];enlist[0Nd];enlist[0Nn];enlist[0Nv])"; {'x}"failed"];
    if[not longstring[enlist each(1;2p;2000.01.04;4n;5v)]~"(enlist[1];enlist[2000.01.01D02:00:00.000000000];enlist[2000.01.04];"
        ,"enlist[0D04:00:00.000000000];enlist[05:00:00])"; {'x}"failed"];
    if[not longstring[2#/:(1;2p;2000.01.04;4n;5v)]~"(1 1;2000.01.01D02:00:00.000000000 2000.01.01D02:00:00.000000000;"
        ,"2000.01.04 2000.01.04;0D04:00:00.000000000 0D04:00:00.000000000;05:00:00 05:00:00)"; {'x}"failed"];
    .qutils.longstringAddSuffixes:1b;
    if[not longstring[(1;2p;2000.01.04;4n;5v)]~"(1j;2000.01.01D02:00:00.000000000p;2000.01.04d;0D04:00:00.000000000n;05:00:00v)"; {'x}"failed"];
    if[not longstring[(0N 0N;0N 0Np;0N 0Nd;0N 0Nn;0N 0Nv)]~"(0N 0Nj;0N 0Np;0N 0Nd;0N 0Nn;0N 0Nv)"; {'x}"failed"];
    if[not longstring[enlist each(0N;0Np;0Nd;0Nn;0Nv)]~"(enlist[0Nj];enlist[0Np];enlist[0Nd];enlist[0Nn];enlist[0Nv])"; {'x}"failed"];
    if[not longstring[2#/:(1;2p;2000.01.04;4n;5v)]~"(1 1j;2000.01.01D02:00:00.000000000 2000.01.01D02:00:00.000000000p;"
        ,"2000.01.04 2000.01.04d;0D04:00:00.000000000 0D04:00:00.000000000n;05:00:00 05:00:00v)"; {'x}"failed"];
    if[not longstring[enlist each(1;2p;2000.01.04;4n;5v)]~"(enlist[1j];enlist[2000.01.01D02:00:00.000000000p];enlist[2000.01.04d];"
        ,"enlist[0D04:00:00.000000000n];enlist[05:00:00v])"; {'x}"failed"];
    };
//longstringTest[];
