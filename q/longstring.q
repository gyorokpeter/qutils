.qutils.longstringAddSuffixes:1b;
.qutils.longstring41dict:.z.K>=4.1;

longstring:{
    t:type x;
    validsym:{s:string x;
        if[0=count x;:1b];
        if[any not s in"./0123456789:ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz";:0b];
        if["_"=first s;:0b];
        colon:s?":";
        if[any "/"=colon#s;:0b];
        1b};
    validId:{if[x in .Q.res,key`.q;:0b];
        s:string x;
        if[any not s in .Q.an;:0b];
        if[first[s] in "_0123456789";:0b];
        1b};
    if[t in 100 101 102 105h; :string[x]];
    if[t in 0 77h; :$[1=count x;"enlist[",.z.s[first x],"]";"(",(";"sv .z.s each x),")"]];
    if[t=-1h; :string[x],"b"];
    if[t=-2h; $[null x;:"0Ng"; :"\"G\"$\"",string[x],"\""]];
    if[t=-4h; :"0x",string[x]];
    if[t in -5 -6 -13 -19h; :$[null x;"0N";string[x]],.Q.t[abs t]];
    if[t in -12 -14 -15 -16 -17 -18h; :$[null x;"0N";string[x]],$[.qutils.longstringAddSuffixes or null x;.Q.t[abs t];""]];
    if[t=-7h; :$[null x;"0N";string[x]],$[.qutils.longstringAddSuffixes;"j";""]];
    if[t in -8 -9h; :$[null x;"0n";string[x]],.Q.t[abs t]];
    if[t=-11h; :$[validsym x;"`",string[x];"`$",.z.s string x]];
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
        if[1=count x; :"enlist[",.z.s[first x],"]"];
        if[all validsym each x; :raze"`",/:string[x]];
        :"(",(";"sv .z.s each x),")"
    ];
    if[t=98h;
        cs:cols x;
        if[not all validId each cs; :"flip[",.z.s[flip x],"]"];
        :"([]",(";"sv string[cols x],'":",/:.z.s each value flip x),")"
    ];
    if[t=99h;
        if[all 98h=type each (xk:key x;xv:value x);
            cs:cols[x];
            if[all validId each cs;
                :"([",(";"sv string[cols xk],'":",/:.z.s each value flip xk),"]"
                    ,(";"sv string[cols xv],'":",/:.z.s each value flip xv),")";
            ]
        ];
        if[.qutils.longstring41dict;
            if[11h=type[key x];if[all validId each key x;
                :"([",(";"sv string[key x],'":",/:.z.s each value x),"])";
            ]];
        ];
        :.z.s[key x],"!",.z.s[value x]];
    if[t=103h; :string x];
    if[t=104h; v:value x; :.z.s[first v],"[",(";"sv .z.s each 1_v),"]"];
    '"nyi type ",string t};

longstringTest:{
    fail:{'"failed"};
    if[not longstring[0Ng]~"0Ng";fail[]];
    if[not longstring["G"$"12345678-abcd-1234-abcd-123456789abc"]~"\"G\"$\"12345678-abcd-1234-abcd-123456789abc\"";fail[]];
    if[not longstring[`guid$()]~"`guid$()";fail[]];
    if[not longstring[enlist 0Ng]~"enlist[0Ng]";fail[]];
    if[not longstring[0N 0Ng]~"0N 0Ng";fail[]];
    if[not longstring[0N 0N 0Ng]~"0N 0N 0Ng";fail[]];
    if[not longstring[enlist"G"$"12345678-abcd-1234-abcd-123456789abc"]~"enlist[\"G\"$\"12345678-abcd-1234-abcd-123456789abc\"]";fail[]];
    if[not longstring["G"$("12345678-abcd-1234-abcd-123456789abc";"87654321-dcba-4321-dcba-cba987654321")]~
        "\"G\"$(\"12345678-abcd-1234-abcd-123456789abc\";\"87654321-dcba-4321-dcba-cba987654321\")";fail[]];
    if[not longstring[0101b]~"0101b";fail[]];
    if[not longstring[enlist 0Ni]~"enlist[0Ni]";fail[]];
    if[not longstring[([]a:enlist 0Ni)]~"([]a:enlist[0Ni])";fail[]];
    if[not longstring[/]~enlist"/";fail[]];
    if[not longstring["\\w"]~"\"\\\\w\"";fail[]];

    .qutils.longstringAddSuffixes:0b;
    if[not longstring[(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~
        "(1;2001.01m;2000.01.01D02:00:00.000000000;2000.01.04T00:00:00.000;2000.01.04;0D04:00:00.000000000;04:00;05:00:00)";fail[]];
    if[not longstring[(0N;0Np;0Nz;0Nm;0Nd;0Nn;0Nu;0Nv)]~"(0N;0Np;0Nz;0Nm;0Nd;0Nn;0Nu;0Nv)";fail[]];
    if[not longstring[(0N 0N;0N 0Nm;0N 0Np;0N 0Nz;0N 0Nd;0N 0Nn;0N 0Nu;0N 0Nv)]~"(0N 0N;0N 0Nm;0N 0Np;0N 0Nz;0N 0Nd;0N 0Nn;0N 0Nu;0N 0Nv)";fail[]];
    if[not longstring[enlist each(0N;0Nm;0Np;0Nz;0Nd;0Nn;0Nu;0Nv)]~"(enlist[0N];enlist[0Nm];enlist[0Np];enlist[0Nz];enlist[0Nd];enlist[0Nn];"
        ,"enlist[0Nu];enlist[0Nv])";fail[]];
    if[not longstring[enlist each(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~"(enlist[1];enlist[2001.01m];enlist[2000.01.01D02:00:00.000000000];"
        ,"enlist[2000.01.04T00:00:00.000];enlist[2000.01.04];enlist[0D04:00:00.000000000];enlist[04:00];enlist[05:00:00])";fail[]];
    if[not longstring[2#/:(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~"(1 1;2001.01 2001.01m;2000.01.01D02:00:00.000000000 2000.01.01D02:00:00.000000000;"
        ,"2000.01.04T00:00:00.000 2000.01.04T00:00:00.000;2000.01.04 2000.01.04;0D04:00:00.000000000 0D04:00:00.000000000;04:00 04:00;"
        ,"05:00:00 05:00:00)";fail[]];

    .qutils.longstringAddSuffixes:1b;
    if[not longstring[(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~"(1j;2001.01m;2000.01.01D02:00:00.000000000p;2000.01.04T00:00:00.000z;"
        ,"2000.01.04d;0D04:00:00.000000000n;04:00u;05:00:00v)";fail[]];
    if[not longstring[(0N 0N;0N 0Nm;0N 0Np;0N 0Nz;0N 0Nd;0N 0Nn;0N 0Nu;0N 0Nv)]~"(0N 0Nj;0N 0Nm;0N 0Np;0N 0Nz;0N 0Nd;0N 0Nn;0N 0Nu;0N 0Nv)";fail[]];
    if[not longstring[enlist each(0N;0Nm;0Np;0Nz;0Nd;0Nn;0Nu;0Nv)]~"(enlist[0Nj];enlist[0Nm];enlist[0Np];enlist[0Nz];enlist[0Nd];enlist[0Nn];enlist[0Nu];"
        ,"enlist[0Nv])";fail[]];
    if[not longstring[enlist each(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~"(enlist[1j];enlist[2001.01m];enlist[2000.01.01D02:00:00.000000000p];"
        ,"enlist[2000.01.04T00:00:00.000z];enlist[2000.01.04d];enlist[0D04:00:00.000000000n];enlist[04:00u];enlist[05:00:00v])";fail[]];
    if[not longstring[2#/:(1;2001.01m;2p;2000.01.04T;2000.01.04;4n;4u;5v)]~"(1 1j;2001.01 2001.01m;2000.01.01D02:00:00.000000000 2000.01.01D02:00:00.000000000p;"
        ,"2000.01.04T00:00:00.000 2000.01.04T00:00:00.000z;2000.01.04 2000.01.04d;0D04:00:00.000000000 0D04:00:00.000000000n;04:00 04:00u;"
        ,"05:00:00 05:00:00v)";fail[]];

    if[not longstring[flip`a`b`:c!(1 2;3 4;5 6)]~"flip[`a`b`:c!(1 2j;3 4j;5 6j)]";fail[]];
    if[not longstring[([a:1 2]b:1 2)]~"([a:1 2j]b:1 2j)";fail[]];
    if[not longstring[`any xcol([]a:1 2)!([]b:1 2)]~"flip[enlist[`any]!enlist[1 2j]]!([]b:1 2j)";fail[]];
    if[not longstring[([]a:1 2)!`any xcol([]b:1 2)]~"([]a:1 2j)!flip[enlist[`any]!enlist[1 2j]]";fail[]];
    if[not longstring[`abc]~"`abc";fail[]];
    if[not longstring[`]~enlist"`";fail[]];
    if[not longstring[`$"hello world"]~"`$\"hello world\"";fail[]];
    if[not longstring[`$"hello\"world"]~"`$\"hello\\\"world\"";fail[]];
    if[not longstring[`$"_"]~"`$\"_\"";fail[]];
    if[not longstring[`$"/"]~"`$\"/\"";fail[]];
    if[not longstring[`$":/"]~"`:/";fail[]];
    if[not longstring[`$"a/:/"]~"`$\"a/:/\"";fail[]];
    if[not longstring[`$"a:/:/"]~"`a:/:/";fail[]];
    if[not longstring[`a`b`c]~"`a`b`c";fail[]];
    if[not longstring[enlist`$"a/:/"]~"enlist[`$\"a/:/\"]";fail[]];
    if[not longstring[enlist`$"a:/:/"]~"enlist[`a:/:/]";fail[]];
    if[not longstring[(`a;`b;`$"hello world";`;`$"a/:/";`$"a:/:/")]~"(`a;`b;`$\"hello world\";`;`$\"a/:/\";`a:/:/)";fail[]];
    if[not longstring[(`$"hello world")xcol([]a:1 2)]~"flip[enlist[`$\"hello world\"]!enlist[1 2j]]";fail[]];
    if[not longstring[(`$"hello world")xcol([]a:1 2)!([]b:1 2)]~"flip[enlist[`$\"hello world\"]!enlist[1 2j]]!([]b:1 2j)";fail[]];

    orig41dict:.qutils.longstring41dict;
    .qutils.longstring41dict:1b;
    if[not longstring[`a`b`c!1 2 3]~"([a:1j;b:2j;c:3j])";fail[]];
    if[not longstring[`a`b`count!1 2 3]~"`a`b`count!1 2 3j";fail[]];
    if[not longstring[`a`b`:c!1 2 3]~"`a`b`:c!1 2 3j";fail[]];
    if[not longstring[(`a;`b;`$"hello world")!1 2 3]~"(`a;`b;`$\"hello world\")!1 2 3j";fail[]];
    if[not longstring[1 2 3!`a`b`c]~"1 2 3j!`a`b`c";fail[]];
    .qutils.longstring41dict:0b;
    if[not longstring[`a`b`c!1 2 3]~"`a`b`c!1 2 3j";fail[]];
    .qutils.longstring41dict:orig41dict;
    };
//longstringTest[];
