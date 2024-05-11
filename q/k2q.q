///
// Utilities for converting k code to q
//
// The core function is `k2q`. You can pass in any function in the .Q namespace and it will return
// equivalent code in q.
// Example: k2q .Q.l
// The main goal is to produce functionally identical code, not beautiful code.
// Concessions are made on some points:
// * The composition operator (') sometimes can be used without parentheses in q code, but not
//   always as it tends to parse as the each iterator. Determining if the parentheses can be
//   omitted would require too much context for this simple implementation, so the composition
//   operator is always output with parentheses. Since k syntax allows a condensed way of writing
//   compositions that can't be done in q but will nevertheless appear in the parse trees of k
//   expressions, this means many functions will have lots of this operator which is hard to read.
// * /: \: are an ugly design choice to be an iterator syntactically but also have the ability to
//   act as a function, which also affects the way they are parsed. Therefore there are special
//   cases with heuristics to replace them with `sv` and `vs` that might not catch all scenarios.
// * The <: operator in k can both act as `iasc` and `hopen`. In q `hopen` is a keyword while
//   `iasc` is a wrapper around <: with type checking. But due to its prominence, k2q will rewrite
//   <: as `iasc`. There was no usage of <: as `hopen` in `.Q`. However the same is not done with
//   >: since `hclose` is not a built-in keyword but an alias for >: which has higher priority for
//   being picked up.

.finos.dep.include"longstring.q";

.k2q.convOps:enlist[(';~:;=)]!enlist[<>];
.k2q.convOps[(';~:;>)]:(<=);
.k2q.convOps[(';~:;<)]:(>=);

.k2q.convOpStr:enlist[<>]!enlist"<>";
.k2q.convOpStr[<=]:"<=";
.k2q.convOpStr[>=]:">=";

.k2q.join:{[left;right]
    needSpace:0b;
    break:.Q.an,".`";
    if[last[left] in break;
        if[first[right] in break; needSpace:1b];
        if[first[right]="-";if[1<count right; needSpace:1b]];
    ];
    $[needSpace;left," ",right;left,right]};

.k2q.isVersus:{
    if[not 0h=type x; :0b];
    if[not first[x] in (/:;\:); :0b];
    tlx:type last x;
    (tlx<>0) and tlx<100};

.k2q.isHole:{
    if[not 101h=type x; :0b];
    0xff=last first -8!/:enlist x};

.k2q.resolveVarName:{[ns;locals;v]
    s:string v;
    if[s like ".q.*";:3_s];
    if[v in locals; :s];
    if[null ns; :s];
    ".",string[ns],".",s};

.k2q.unparse0:{[ns;locals;mode;x]
    t:type x;
    if[105h=t;
        if[x in key .k2q.convOpStr;:.k2q.convOpStr x];
    ];
    if[";"~first x;if[0<=t;
        str:";"sv .k2q.unparse0[ns;locals;`free]each 1_x;
        if[mode=`fnParam;str:"[",str,"]"];
        :str;
    ]];
    if[-11h=t; :.k2q.resolveVarName[ns;locals;x]];
    if[11h=t;
        if[1=count x; :longstring first x];
    ];
    if[t in 101 102h;
        if[t=101h; if[mode=`binaryOperator; :string x]];
        r:string x;
        if[not null c:.q?x;
            r:$[c=`get; "value";
              c=`inv; "key";
              not c in`mmu`lsq; string c;
              r];
        ];
        if[x~(<:); r:"iasc"];
        if[mode in`projectionLeftArg`projectionRightArg; r:"(",r,")"];
        :r;
    ];
    if[any t within/:(1 10h;12 20h); :longstring x];
    holes:`int$();
    if[0h=t;
        if[1=count x; :longstring first x];
        holes:where .k2q.isHole each x;
    ];
    if[enlist~first x;if[2<count x;
        r:.k2q.unparse0[ns;locals;`free] each 1_x;
        r[holes-1]:count[holes]#enlist"";
        :"(",(";"sv r),")";
    ]];
    if[100h=t;
        if[not null c:.q?x; :string c];
        if[string[x] like "k)*";
            :string k2q x;
        ];
    ];
    if[2=count x;
        if[(::)~last x;:.k2q.unparse0[ns;locals;`indexable;first x],"[]"];
        tfx:type first x;
        if[tfx=101h;
            if[first[x]~(,:); x[0]:`enlist];
        ];
        if[-10h=tfx;
            if[first[x] in ":'";
                if[2=count x; :first[x],.k2q.unparse0[ns;locals;`free;last x]];
            ];
        ];
        if[103h=tfx;
            isIter:1b;
            if[.k2q.isVersus[x];
                /if[mode=`iterable; :"(",.k2q.join[.k2q.unparse0[`constant;last x];((/:;\:)!("sv";"vs"))[first x]],")"];
                x[0]:((/:;\:)!(sv;vs))first x;
                isIter:0b;
                tfx:100h;
            ];
            if[isIter; :.k2q.join[.k2q.unparse0[ns;locals;`iterable;last x];.k2q.unparse0[ns;locals;`constant;first x]]];
        ];
        needBrackets:0b;
        if[0h=tfx;
            tfxx:type first first x;    //e.g. ((/;&);`j) -> and/[j]
            if[103h=tfxx;
                needBrackets:1b;
                if[.k2q.isVersus[first x];  //rephrase as q, since k parses /: \: as iterators even when used as sv/vs
                    :.k2q.unparse0[ns;locals;mode;(((/:;\:)!(sv;vs))first first x;last first x;last x)];
                ];
            ];
        ];
        if[mode in`indexable`iterable`projectionLeftArg; needBrackets:1b];
        isBinary:102h=tfx;
        if[100h=tfx;
            if[not null c:.q?first x;
                if[c in `sv`vs; needBrackets:0b];
                isBinary:2=count value[first x][1];
            ];
        ];
        if[not needBrackets;
            r:$[isBinary;    //projection
                .k2q.join[.k2q.unparse0[ns;locals;`indexable;last x];.k2q.unparse0[ns;locals;`free;first x]];
                .k2q.join[.k2q.unparse0[ns;locals;`indexable;first x];.k2q.unparse0[ns;locals;`projectionRightArg;last x]]
            ];
            if[mode in`indexable`iterable; r:"(",r,")"];
            :r;
        ];
    ];
    if[3=count x;
        tfx:type first x;
        infix:0b;
        if[tfx=0h;
            tffx:type first first x;
            if[103h=tffx;if[2=count first x; infix:1b]];
        ];
        if[first[x]in key .k2q.convOps;
            x[0]:.k2q.convOps[first x];
            infix:1b;
        ];
        if[tfx in 101 102h; infix:1b];
        if[tfx=-11h; if[x[0] like ".q.*";
            x[0]:value x[0];
            tfx:type first x;
        ]];
        if[100h=tfx;
            if[first[x] in value .q;
                infix:2=count value[first x][1];
            ];
        ];
        if[count holes; infix:0b];
        if[infix;
            r:.k2q.join/[(.k2q.unparse0[ns;locals;`projectionLeftArg;x 1];
                .k2q.unparse0[ns;locals;`binaryOperator;first x];
                .k2q.unparse0[ns;locals;`projectionRightArg;last x])];
            if[mode in `indexable`projectionLeftArg; r:"(",r,")"];
            :r;
        ];
    ];
    if[2<=count x;
        r:.k2q.unparse0[ns;locals;`fnParam]each 1_x;
        r[holes-1]:count[holes]#enlist"";
        f:.k2q.unparse0[ns;locals;`indexable;first x];
        if[(')~first x; if[3=count x; f:"(')"]];
        :f,"[",(";"sv r),"]";
    ];
    longstring[x]};

.k2q.unparse:{.k2q.unparse0[`;`$();`free;x]};

.k2q.parseFunction:{
    s:string x;
    isK:s like "k)*";
    s2:-1_(1+2*isK)_s;
    if["["=first s2; s2:(1+first where"]"=s2)_s2];
    parse$[isK;"k)";""],s2};

k2q:{
    if[100h=t:type x;
        pf:.k2q.parseFunction x;
        v:value[x];
        params:v 1;
        locals:v 2;
        ns:first v 3;
        str:.k2q.unparse0[ns;params,locals;`free;pf];
        :value"{[",(";"sv string params),"]",$["-"=first str;" ";""],str,"}";
    ];
    if[104h=t;
        v:value x;
        :value .z.s each v;
    ];
    if[105h=t;
        :(')..z.s each value x;
    ];
    if[t within 106 111h;
        :(';/;\;':;/:;\:)[t-106h][.z.s value x];
    ];
    x};

.k2q.unittest:{
    fail:{'"failed"};
    if[not .k2q.unparse[1 2 3]~"1 2 3j"; fail[]];
    if[not .k2q.unparse[(";";1;2)]~"1j;2j"; fail[]];
    if[not .k2q.unparse[(|;`x;-1h)]~"x or -1h"; fail[]];
    if[not .k2q.unparse[(/;&)]~"and/"; fail[]];
    if[not .k2q.unparse[(,:;`x;())]~"x,:()";fail[]];
    if[not .k2q.unparse[(!;0;`z)]~"0j!z";fail[]];
    if[not .k2q.unparse[&:]~"where"; fail[]];
    if[not .k2q.unparse[(&:;`x)]~"where x"; fail[]];
    if[not .k2q.unparse0[`;`$();`indexable;::]~"::"; fail[]];
    if[not .k2q.unparse0[`;`$();`projectionLeftArg;::]~"(::)"; fail[]];
    if[not .k2q.unparse0[`;`$();`projectionRightArg;::]~"(::)"; fail[]];
    if[not .k2q.unparse[(~;::;`x)]~"(::)~x"; fail[]];
    if[not .k2q.unparse[(~;`x;::)]~"x~(::)"; fail[]];
    if[not .k2q.unparse[(bin;(#;`x;`z);`x)]~"(x#z)bin x"; fail[]];
    if[not .k2q.unparse[(-;1;0x00)]~"1j-0x00"; fail[]];
    if[not .k2q.unparse[(_;`x;`y)]~"x _ y"; fail[]];
    if[not .k2q.unparse[($;`x;`y;`z)]~"$[x;y;z]"; fail[]];
    if[not .k2q.unparse[($;`x;`y;`z;`a)]~"$[x;y;z;a]"; fail[]];
    if[not .k2q.unparse[($;`x;`y;`z;`a;`b)]~"$[x;y;z;a;b]"; fail[]];
    if[not .k2q.unparse[($;1;(";";2;3);4)]~"$[1j;[2j;3j];4j]"; fail[]];
    if[not .k2q.unparse[(enlist;:;^)]~"(:;^)"; fail[]];
    if[not .k2q.unparse[((enlist;:;^);`f)]~"(:;^)f"; fail[]];
    if[not .k2q.unparse[((/;&);`j)]~"and/[j]"; fail[]];
    if[not .k2q.unparse[`d`i]~"d i"; fail[]];
    if[not .k2q.unparse[`d`i`j]~"d[i;j]"; fail[]];
    if[not .k2q.unparse[parse"y d i"]~"y d i"; fail[]];
    if[not .k2q.unparse[(.;`x;`y)]~"x . y"; fail[]];
    if[not .k2q.unparse[((`x;`y);`z)]~"x[y]z"; fail[]];
    if[not .k2q.unparse[((`x;`y);`z;`a)]~"x[y][z;a]"; fail[]];
    if[not .k2q.unparse[parse"x[y]z"]~"x[y]z"; fail[]];
    if[not .k2q.unparse[enlist `int]~"`int"; fail[]];
    if[not .k2q.unparse[($;enlist `int;3)]~"`int$3j"; fail[]];
    if[not .k2q.unparse[parse"\"\\\\w\""]~"\"\\\\w\""; fail[]];
    if[not .k2q.unparse[enlist `a`b]~"`a`b"; fail[]];
    if[not .k2q.unparse[(!;enlist `a`b;(enlist;`c;`d))]~"`a`b!(c;d)"; fail[]];
    if[not .k2q.unparse[($;enlist `)]~"`$"; fail[]];
    if[not .k2q.unparse[(';`f;`g)]~"(')[f;g]"; fail[]];
    if[not .k2q.unparse[(`x;(';`f;`g))]~"x(')[f;g]"; fail[]];
    if[not .k2q.unparse[((';(';`f;`g));`x;`y)]~"x(')[f;g]'y"; fail[]];
    if[not .k2q.unparse[(';(';*:;$:))]~"(')[first;string]'"; fail[]];
    if[not .k2q.unparse[((';(';*:;$:));`x)]~"(')[first;string]'[x]"; fail[]];
    if[not .k2q.unparse[((';_);`x;`y)]~"x _'y"; fail[]];
    if[not .k2q.unparse[((';`f);`x;`y)]~"x f'y"; fail[]];
    if[not .k2q.unparse[((';`f);`y;(`d;`i))]~"y f'd i"; fail[]];
    if[not .k2q.unparse[parse"k){x+y}"]~"{[x;y]x+y}"; fail[]];
    if[not .k2q.unparse[parse"k){x+y}'"]~"{[x;y]x+y}'"; fail[]];
    if[not .k2q.unparse[parse"k){x+y}z"]~"{[x;y]x+y}z"; fail[]];
    if[not .k2q.unparse[parse"k){x+y}[z;a]"]~"{[x;y]x+y}[z;a]"; fail[]];
    if[not .k2q.unparse[((_;`f;`y);(#:;`x))]~"(f _ y)count x"; fail[]];
    if[not .k2q.unparse[(,:;`x)]~"enlist x"; fail[]];
    if[not .k2q.unparse[(`f;::)]~"f[]"; fail[]];
    if[not .k2q.unparse[parse"if[x;y]"]~"if[x;y]"; fail[]];
    if[not .k2q.unparse[("'";enlist `type)]~"'`type"; fail[]];
    if[not .k2q.unparse[("'";"type")]~"'\"type\""; fail[]];
    if[not .k2q.unparse[parse"f[;]"]~"f[;]"; fail[]];
    if[not .k2q.unparse[parse"(;)"]~"(;)"; fail[]];
    if[not .k2q.unparse[parse"f[;::;x]"]~"f[;::;x]"; fail[]];
    if[not .k2q.unparse[parse"@[;@]"]~"@[;@]"; fail[]];
    if[not .k2q.unparse[(::;`x;`y)]~"x::y"; fail[]];
    if[not .k2q.unparse[(":";`x)]~":x"; fail[]];
    if[not .k2q.unparse[(@:;`a;1)]~"a@:1j"; fail[]];
    if[not .k2q.unparse[(/:;#)]~"#/:"; fail[]];
    if[not .k2q.unparse[((/:;#);1;`x)]~"1j#/:x"; fail[]];
    if[not .k2q.unparse[((/:;$);(*;`x;`y);`y)]~"(x*y)$/:y"; fail[]];
    if[not .k2q.unparse[(';(';#:))]~"count''"; fail[]];
    if[not .k2q.unparse[((';(';#:));`y)]~"count''[y]"; fail[]];
    if[not .k2q.unparse[(?;enlist `a`b`c;`d)]~"`a`b`c?d"; fail[]];
    if[not .k2q.unparse[((&:;`x);`y)]~"where[x]y"; fail[]];
    if[not .k2q.unparse[("ABCD";`x)]~"\"ABCD\"x"; fail[]];
    if[not .k2q.unparse[parse "value[y][;1]"]~"value[y][;1j]"; fail[]];
    if[not .k2q.unparse[(enlist`.q;enlist`string)]~"`.q `string"; fail[]];
    if[not .k2q.unparse[(enlist`.;`x)]~"`. x"; fail[]];
    if[not .k2q.unparse[(.;?;`x)]~"(?). x"; fail[]];
    if[not .k2q.unparse[(<:;3 2 1)]~"iasc 3 2 1j"; fail[]];
    if[not .k2q.unparse[(';(`f;`x))]~"f[x]'"; fail[]];
    if[not .k2q.unparse0[`;`$();`projectionLeftArg;parse"P[i]"]~"P[i]"; fail[]];
    if[not .k2q.unparse[parse"P[i](;)'y"]~"P[i](;)'y"; fail[]];
    if[not .k2q.unparse[parse"aj"]~"aj"; fail[]];
    if[not .k2q.unparse[parse"\" \"sv"]~"\" \"sv"; fail[]];
    if[not .k2q.unparse[(/:;" ")]~"\" \"sv"; fail[]];
    if[not .k2q.unparse[parse"` vs f"]~"` vs f"; fail[]];
    if[not .k2q.unparse[((\:;enlist `);`f)]~"` vs f"; fail[]];
    if[not .k2q.unparse[parse"` vs"]~"` vs"; fail[]];
    if[not .k2q.unparse0[`;`$();`iterable;parse"` vs"]~"(` vs)"; fail[]];
    if[not .k2q.unparse[(\:;enlist `)]~"` vs"; fail[]];
    if[not .k2q.unparse[parse"(` vs)'"]~"(` vs)'"; fail[]];
    if[not .k2q.unparse[(';(\:;enlist `))]~"(` vs)'"; fail[]];
    if[not .k2q.unparse[parse"(` vs)'[`a.b`a.c]"]~"(` vs)'[`a.b`a.c]"; fail[]];
    if[not .k2q.unparse[((';(\:;enlist `));enlist `a.b`a.c)]~"(` vs)'[`a.b`a.c]"; fail[]];
    if[not k2q[{}]~{[x]::};fail[]];
    if[not k2q[{-1}]~{[x] -1j};fail[]];
    if[not k2q[{";"}]~{[x]";"};fail[]];
    if[not k2q[{(";";1;2)}]~{[x](";";1j;2j)};fail[]];
    if[not k2q[{enlist`a}]~{[x]enlist `a};fail[]];
    if[not k2q[{1<>2}]~{[x]1j<>2j};fail[]];
    if[not k2q[{1<=2}]~{[x]1j<=2j};fail[]];
    if[not k2q[{1>=2}]~{[x]1j>=2j};fail[]];
    if[not k2q[{(')[neg;vs][x;y]}]~{[x;y](')[neg;vs][x;y]};fail[]];
    if[not k2q[{z}[1]]~{[x;y;z]z}[1];fail[]];
    if[not k2q['[value"k){x}";value"k){x}"]]~(')[{[x]x};{[x]x}];fail[]];
    if[not k2q['[value"k){x}"]]~(')[{[x]x}];fail[]];
    if[not k2q[/[value"k){x}"]]~(/)[{[x]x}];fail[]];
    if[not k2q[\[value"k){x}"]]~(\)[{[x]x}];fail[]];
    if[not k2q[':[value"k){x}"]]~(':)[{[x]x}];fail[]];
    if[not k2q[/:[value"k){x}"]]~(/:)[{[x]x}];fail[]];
    if[not k2q[\:[value"k){x}"]]~(\:)[{[x]x}];fail[]];
    if[not k2q[value"k){.q.set[`.q.abs;.q.abs]}"]~{[x]`.q.abs set abs};fail[]];
    if[not k2q[value"k){.q.count[x]}"]~{[x]count x};fail[]];
    if[not k2q[value"k){.q.count[x]}"]~{[x]count x};fail[]];
    //-8! of {a:1;x+a+b} in namespace `.evil
    if[not k2q[-9!0x010000001f000000646576696c000a000b0000007b613a313b782b612b627d]~{[x]a:1j;x+a+.evil.b};fail[]];
    };

//.k2q.unittest[];

//{@[k2q;x;{"ERROR: ",x}]} each .Q
//{@[k2q;x;{"ERROR: ",x}]} each .h
