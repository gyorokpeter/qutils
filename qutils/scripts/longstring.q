longstring:{
    t:type x;
    if[t in 100 101 102 105h; :string[x]];
    if[t=0h; :$[1=count x;"enlist[",.z.s[first x],"]";"(",(";"sv .z.s each x),")"]];
    if[t=-1h; :string[x],"b"];
    if[t=-4h; :"0x",string[x]];
    if[t in -5 -6 -7 -17 -19h; :$[null x;"0N";string[x]],.Q.t[abs t]];
    if[t in -8 -9h; :$[null x;"0n";string[x]],.Q.t[abs t]];
    if[t=-11h; :"`",string[x]];
    if[t=-12h; :string[x],"p"];
    if[t=-14h; :string[x],"d"];
    if[t=-18h; :string[x],"v"];
    if[t in 1 5 6 7 12 16 19h;
        :$[0=count x;"`",string[key x],"$()";
           1=count x;"enlist[",string[first x],.Q.t[t],"]";(" "sv {$[null x;"0N";string[x]]}each x),.Q.t[t]];
    ];
    if[t in 8 9h;
        :$[1=count x;"enlist[",string[first x],.Q.t[t],"]";(" "sv {$[null x;"0n";string[x]]}each x),.Q.t[t]];
    ];
    if[t=4h; :"0x",raze string x];
    if[t=-10h; :.Q.s1[x]];
    if[t=10h; :"\"",ssr[x;"\"";"\\\""],"\""];
    if[t=11h;
        if[0=count x; :"(`$())"];
        :$[1=count x;"enlist[",.z.s[first x],"]";raze"`",/:string[x]]
    ];
    if[t=98h;
        if[0<count cols[x] inter .Q.res,key`.q; :"flip[",.z.s[flip x],"]"];
        :"([]",(";"sv string[cols x],'":",/:.z.s each value flip x),")"
    ];
    if[t=99h; :.z.s[key x],"!",.z.s[value x]];
    if[t=104h; v:value x; :.z.s[first v],"[",(";"sv .z.s each 1_v),"]"];
    '"nyi type ",string t};
