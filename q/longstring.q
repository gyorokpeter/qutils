.qutils.longstringAddSuffixes:1b;

longstring:{
    t:type x;
    if[t in 100 101 102 105h; :string[x]];
    if[t in 0 77h; :$[1=count x;"enlist[",.z.s[first x],"]";"(",(";"sv .z.s each x),")"]];
    if[t=-1h; :string[x],"b"];
    if[t=-2h; $[null x;:"0Ng"; :"\"G\"$\"",string[x],"\""]];
    if[t=-4h; :"0x",string[x]];
    if[t in -5 -6 -13 -19h; :$[null x;"0N";string[x]],.Q.t[abs t]];
    if[t in -12 -14 -15 -16 -17 -18h; :$[null x;"0N";string[x]],$[.qutils.longstringAddSuffixes or null x;.Q.t[abs t];""]];
    if[t=-7h; :$[null x;"0N";string[x]],$[.qutils.longstringAddSuffixes;"j";""]];
    if[t in -8 -9h; :$[null x;"0n";string[x]],.Q.t[abs t]];
    if[t=-11h; :"`",string[x]];
    if[t in 1 5 6 7 12 13 14 15 16 17 18 19h;
        :$[0=count x;"`",string[key x],"$()";
           1=count x;"enlist[",.z.s[first x],"]";
         ($[t=1;"";" "]sv {$[null x;"0N";string[x]]}each x),$[$[.qutils.longstringAddSuffixes;1b;(t in 1 13h)or(7<>t)and all null x];.Q.t[t];""]];
    ];
    if[t=2h;
        if[0=count x;:"`guid$()"];
        if[all null x;:$[1=count x;"enlist[0Ng]";(-1_(3*count[x])#"0N "),"g"]];
        if[1=count x;:"enlist[",.z.s[first x],"]"];
        :"\"G\"$(",(";"sv"\"",/:string[x],\:"\""),")";
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
    if[t=99h;
        if[all 98h=type each (xk:key x;xv:value x);
            if[0=count cols[x] inter .Q.res,key`.q;
                :"([",(";"sv string[cols xk],'":",/:.z.s each value flip xk),"]"
                    ,(";"sv string[cols xv],'":",/:.z.s each value flip xv),")";
            ]
        ];
        :.z.s[key x],"!",.z.s[value x]];
    if[t=103h; :string x];
    if[t=104h; v:value x; :.z.s[first v],"[",(";"sv .z.s each 1_v),"]"];
    '"nyi type ",string t};

longstringTest:{
    if[not longstring[0Ng]~"0Ng"; {'x}"failed"];
    if[not longstring["G"$"12345678-abcd-1234-abcd-123456789abc"]~"\"G\"$\"12345678-abcd-1234-abcd-123456789abc\""; {'x}"failed"];
    if[not longstring[`guid$()]~"`guid$()"; {'x}"failed"];
    if[not longstring[enlist 0Ng]~"enlist[0Ng]"; {'x}"failed"];
    if[not longstring[0N 0Ng]~"0N 0Ng"; {'x}"failed"];
    if[not longstring[0N 0N 0Ng]~"0N 0N 0Ng"; {'x}"failed"];
    if[not longstring[enlist"G"$"12345678-abcd-1234-abcd-123456789abc"]~"enlist[\"G\"$\"12345678-abcd-1234-abcd-123456789abc\"]"; {'x}"failed"];
    if[not longstring["G"$("12345678-abcd-1234-abcd-123456789abc";"87654321-dcba-4321-dcba-cba987654321")]~
        "\"G\"$(\"12345678-abcd-1234-abcd-123456789abc\";\"87654321-dcba-4321-dcba-cba987654321\")"; {'x}"failed"];
    if[not longstring[0101b]~"0101b"; {'x}"failed"];
    if[not longstring[enlist 0Ni]~"enlist[0Ni]"; {'x}"failed"];
    if[not longstring[([]a:enlist 0Ni)]~"([]a:enlist[0Ni])"; {'x}"failed"];
    if[not longstring[/]~enlist"/"; {'x}"failed"];
    if[not longstring["\\w"]~"\"\\\\w\""; {'x}"failed"];

    .qutils.longstringAddSuffixes:0b;
    if[not longstring[(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~
        "(1;2001.01m;2000.01.01D02:00:00.000000000;2000.01.04T00:00:00.000;2000.01.04;0D04:00:00.000000000;04:00;05:00:00)"; {'x}"failed"];
    if[not longstring[(0N;0Np;0Nz;0Nm;0Nd;0Nn;0Nu;0Nv)]~"(0N;0Np;0Nz;0Nm;0Nd;0Nn;0Nu;0Nv)"; {'x}"failed"];
    if[not longstring[(0N 0N;0N 0Nm;0N 0Np;0N 0Nz;0N 0Nd;0N 0Nn;0N 0Nu;0N 0Nv)]~"(0N 0N;0N 0Nm;0N 0Np;0N 0Nz;0N 0Nd;0N 0Nn;0N 0Nu;0N 0Nv)"; {'x}"failed"];
    if[not longstring[enlist each(0N;0Nm;0Np;0Nz;0Nd;0Nn;0Nu;0Nv)]~"(enlist[0N];enlist[0Nm];enlist[0Np];enlist[0Nz];enlist[0Nd];enlist[0Nn];"
        ,"enlist[0Nu];enlist[0Nv])"; {'x}"failed"];
    if[not longstring[enlist each(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~"(enlist[1];enlist[2001.01m];enlist[2000.01.01D02:00:00.000000000];"
        ,"enlist[2000.01.04T00:00:00.000];enlist[2000.01.04];enlist[0D04:00:00.000000000];enlist[04:00];enlist[05:00:00])"; {'x}"failed"];
    if[not longstring[2#/:(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~"(1 1;2001.01 2001.01m;2000.01.01D02:00:00.000000000 2000.01.01D02:00:00.000000000;"
        ,"2000.01.04T00:00:00.000 2000.01.04T00:00:00.000;2000.01.04 2000.01.04;0D04:00:00.000000000 0D04:00:00.000000000;04:00 04:00;"
        ,"05:00:00 05:00:00)"; {'x}"failed"];

    .qutils.longstringAddSuffixes:1b;
    if[not longstring[(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~"(1j;2001.01m;2000.01.01D02:00:00.000000000p;2000.01.04T00:00:00.000z;"
        ,"2000.01.04d;0D04:00:00.000000000n;04:00u;05:00:00v)"; {'x}"failed"];
    if[not longstring[(0N 0N;0N 0Nm;0N 0Np;0N 0Nz;0N 0Nd;0N 0Nn;0N 0Nu;0N 0Nv)]~"(0N 0Nj;0N 0Nm;0N 0Np;0N 0Nz;0N 0Nd;0N 0Nn;0N 0Nu;0N 0Nv)"; {'x}"failed"];
    if[not longstring[enlist each(0N;0Nm;0Np;0Nz;0Nd;0Nn;0Nu;0Nv)]~"(enlist[0Nj];enlist[0Nm];enlist[0Np];enlist[0Nz];enlist[0Nd];enlist[0Nn];enlist[0Nu];"
        ,"enlist[0Nv])"; {'x}"failed"];
    if[not longstring[enlist each(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~"(enlist[1j];enlist[2001.01m];enlist[2000.01.01D02:00:00.000000000p];"
        ,"enlist[2000.01.04T00:00:00.000z];enlist[2000.01.04d];enlist[0D04:00:00.000000000n];enlist[04:00u];enlist[05:00:00v])"; {'x}"failed"];
    if[not longstring[2#/:(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~"(1 1j;2001.01 2001.01m;2000.01.01D02:00:00.000000000 2000.01.01D02:00:00.000000000p;"
        ,"2000.01.04T00:00:00.000 2000.01.04T00:00:00.000z;2000.01.04 2000.01.04d;0D04:00:00.000000000 0D04:00:00.000000000n;04:00 04:00u;"
        ,"05:00:00 05:00:00v)"; {'x}"failed"];

    if[not longstring[([a:1 2]b:1 2)]~"([a:1 2j]b:1 2j)"; {'x}"failed"];
    if[not longstring[`any xcol([]a:1 2)!([]b:1 2)]~"flip[enlist[`any]!enlist[1 2j]]!([]b:1 2j)"; {'x}"failed"];
    if[not longstring[([]a:1 2)!`any xcol([]b:1 2)]~"([]a:1 2j)!flip[enlist[`any]!enlist[1 2j]]"; {'x}"failed"];
    };
//longstringTest[];
