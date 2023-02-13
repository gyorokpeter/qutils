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

.k2q.join:{[left;right]
    needSpace:0b;
    break:.Q.an,".`";
    if[last[left] in break;if[first[right] in break,"-"; needSpace:1b]];
    $[needSpace;left," ",right;left,right]};

.k2q.isVersus:{
    if[not 0h=type x; :0b];
    if[not first[x] in (/:;\:); :0b];
    tlx:type last x;
    (tlx<>0) and tlx<100};

.k2q.isHole:{
    if[not 101h=type x; :0b];
    0xff=last first -8!/:enlist x};

.k2q.unparse0:{[mode;x]
    if[";"~first x; :";"sv .k2q.unparse0[`free]each 1_x];
    t:type x;
    if[-11h=t; :string x];
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
    if[enlist~first x;
        r:.k2q.unparse0[`free] each 1_x;
        r[holes-1]:count[holes]#enlist"";
        :"(",(";"sv r),")";
    ];
    if[100h=t;
        if[not null c:.q?x; :string c];
        if[string[x] like "k)*";
            :string k2q x;
        ];
    ];
    if[2=count x;
        if[(::)~last x;:.k2q.unparse0[`indexable;first x],"[]"];
        tfx:type first x;
        if[tfx=101h;
            if[first[x]~(,:); x[0]:`enlist];
        ];
        if[-10h=tfx;
            if[first[x] in ":'";
                if[2=count x; :first[x],.k2q.unparse0[`free;last x]];
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
            if[isIter; :.k2q.join[.k2q.unparse0[`iterable;last x];.k2q.unparse0[`constant;first x]]];
        ];
        needBrackets:0b;
        if[0h=tfx;
            tfxx:type first first x;    //e.g. ((/;&);`j) -> and/[j]
            if[103h=tfxx;
                needBrackets:1b;
                if[.k2q.isVersus[first x];  //rephrase as q, since k parses /: \: as iterators even when used as sv/vs
                    :.k2q.unparse0[mode;(((/:;\:)!(sv;vs))first first x;last first x;last x)];
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
                .k2q.join[.k2q.unparse0[`indexable;last x];.k2q.unparse0[`free;first x]];
                .k2q.join[.k2q.unparse0[`indexable;first x];.k2q.unparse0[`projectionRightArg;last x]]
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
            if[103h=tffx; infix:1b];
        ];
        if[tfx in 101 102h; infix:1b];
        if[100h=tfx;
            if[first[x] in value .q;
                infix:2=count value[first x][1];
            ];
        ];
        if[count holes; infix:0b];
        if[infix;
            r:.k2q.join/[(.k2q.unparse0[`projectionLeftArg;x 1];.k2q.unparse0[`binaryOperator;first x];.k2q.unparse0[`projectionRightArg;last x])];
            if[mode in `indexable`projectionLeftArg; r:"(",r,")"];
            :r;
        ];
    ];
    if[2<=count x;
        r:.k2q.unparse0[`free]each 1_x;
        r[holes-1]:count[holes]#enlist"";
        f:.k2q.unparse0[`indexable;first x];
        if[(')~first x; if[3=count x; f:"(')"]];
        :f,"[",(";"sv r),"]";
    ];
    longstring[x]};

.k2q.unparse:{.k2q.unparse0[`free;x]};

.k2q.parseFunction:{
    s:string x;
    isK:s like "k)*";
    s2:-1_(1+2*isK)_s;
    if["["=first s2; s2:(1+first where"]"=s2)_s2];
    parse$[isK;"k)";""],s2};

k2q:{
    if[100h=t:type x;
        params:value[x]1;
        str:.k2q.unparse .k2q.parseFunction x;
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

.k2q.unittest1:{
    if[not .k2q.unparse[1 2 3]~"1 2 3j"; {'x}"failed"];
    if[not .k2q.unparse[(";";1;2)]~"1j;2j"; {'x}"failed"];
    if[not .k2q.unparse[(|;`x;-1h)]~"x or -1h"; {'x}"failed"];
    if[not .k2q.unparse[(/;&)]~"and/"; {'x}"failed"];
    if[not .k2q.unparse[(,:;`x;())]~"x,:()";{'x}"failed"];
    if[not .k2q.unparse[(!;0;`z)]~"0j!z";{'x}"failed"];
    if[not .k2q.unparse[&:]~"where"; {'x}"failed"];
    if[not .k2q.unparse[(&:;`x)]~"where x"; {'x}"failed"];
    if[not .k2q.unparse0[`indexable;::]~"::"; {'x}"failed"];
    if[not .k2q.unparse0[`projectionLeftArg;::]~"(::)"; {'x}"failed"];
    if[not .k2q.unparse0[`projectionRightArg;::]~"(::)"; {'x}"failed"];
    if[not .k2q.unparse[(~;::;`x)]~"(::)~x"; {'x}"failed"];
    if[not .k2q.unparse[(~;`x;::)]~"x~(::)"; {'x}"failed"];
    if[not .k2q.unparse[(bin;(#;`x;`z);`x)]~"(x#z)bin x"; {'x}"failed"];
    if[not .k2q.unparse[(_;`x;`y)]~"x _ y"; {'x}"failed"];
    if[not .k2q.unparse[($;`x;`y;`z)]~"$[x;y;z]"; {'x}"failed"];
    if[not .k2q.unparse[($;`x;`y;`z;`a)]~"$[x;y;z;a]"; {'x}"failed"];
    if[not .k2q.unparse[($;`x;`y;`z;`a;`b)]~"$[x;y;z;a;b]"; {'x}"failed"];
    if[not .k2q.unparse[(enlist;:;^)]~"(:;^)"; {'x}"failed"];
    if[not .k2q.unparse[((enlist;:;^);`f)]~"(:;^)f"; {'x}"failed"];
    if[not .k2q.unparse[((/;&);`j)]~"and/[j]"; {'x}"failed"];
    if[not .k2q.unparse[`d`i]~"d i"; {'x}"failed"];
    if[not .k2q.unparse[`d`i`j]~"d[i;j]"; {'x}"failed"];
    if[not .k2q.unparse[parse"y d i"]~"y d i"; {'x}"failed"];
    if[not .k2q.unparse[(.;`x;`y)]~"x . y"; {'x}"failed"];
    if[not .k2q.unparse[((`x;`y);`z)]~"x[y]z"; {'x}"failed"];
    if[not .k2q.unparse[((`x;`y);`z;`a)]~"x[y][z;a]"; {'x}"failed"];
    if[not .k2q.unparse[parse"x[y]z"]~"x[y]z"; {'x}"failed"];
    if[not .k2q.unparse[enlist `int]~"`int"; {'x}"failed"];
    if[not .k2q.unparse[($;enlist `int;3)]~"`int$3j"; {'x}"failed"];
    if[not .k2q.unparse[parse"\"\\\\w\""]~"\"\\\\w\""; {'x}"failed"];
    if[not .k2q.unparse[enlist `a`b]~"`a`b"; {'x}"failed"];
    if[not .k2q.unparse[(!;enlist `a`b;(enlist;`c;`d))]~"`a`b!(c;d)"; {'x}"failed"];
    if[not .k2q.unparse[($;enlist `)]~"`$"; {'x}"failed"];
    if[not .k2q.unparse[(';`f;`g)]~"(')[f;g]"; {'x}"failed"];
    if[not .k2q.unparse[(`x;(';`f;`g))]~"x(')[f;g]"; {'x}"failed"];
    if[not .k2q.unparse[((';(';`f;`g));`x;`y)]~"x(')[f;g]'y"; {'x}"failed"];
    if[not .k2q.unparse[(';(';*:;$:))]~"(')[first;string]'"; {'x}"failed"];
    if[not .k2q.unparse[((';(';*:;$:));`x)]~"(')[first;string]'[x]"; {'x}"failed"];
    if[not .k2q.unparse[((';_);`x;`y)]~"x _'y"; {'x}"failed"];
    if[not .k2q.unparse[((';`f);`x;`y)]~"x f'y"; {'x}"failed"];
    if[not .k2q.unparse[((';`f);`y;(`d;`i))]~"y f'd i"; {'x}"failed"];
    if[not .k2q.unparse[parse"k){x+y}"]~"{[x;y]x+y}"; {'x}"failed"];
    if[not .k2q.unparse[parse"k){x+y}'"]~"{[x;y]x+y}'"; {'x}"failed"];
    if[not .k2q.unparse[parse"k){x+y}z"]~"{[x;y]x+y}z"; {'x}"failed"];
    if[not .k2q.unparse[parse"k){x+y}[z;a]"]~"{[x;y]x+y}[z;a]"; {'x}"failed"];
    if[not .k2q.unparse[((_;`f;`y);(#:;`x))]~"(f _ y)count x"; {'x}"failed"];
    if[not .k2q.unparse[(,:;`x)]~"enlist x"; {'x}"failed"];
    if[not .k2q.unparse[(`f;::)]~"f[]"; {'x}"failed"];
    if[not .k2q.unparse[parse"if[x;y]"]~"if[x;y]"; {'x}"failed"];
    };

.k2q.unittest:{
    .k2q.unittest1[];
    if[not .k2q.unparse[("'";enlist `type)]~"'`type"; {'x}"failed"];
    if[not .k2q.unparse[("'";"type")]~"'\"type\""; {'x}"failed"];
    if[not .k2q.unparse[parse"f[;]"]~"f[;]"; {'x}"failed"];
    if[not .k2q.unparse[parse"(;)"]~"(;)"; {'x}"failed"];
    if[not .k2q.unparse[parse"f[;::;x]"]~"f[;::;x]"; {'x}"failed"];
    if[not .k2q.unparse[parse"@[;@]"]~"@[;@]"; {'x}"failed"];
    if[not .k2q.unparse[(::;`x;`y)]~"x::y"; {'x}"failed"];
    if[not .k2q.unparse[(":";`x)]~":x"; {'x}"failed"];
    if[not .k2q.unparse[(@:;`a;1)]~"a@:1j"; {'x}"failed"];
    if[not .k2q.unparse[(/:;#)]~"#/:"; {'x}"failed"];
    if[not .k2q.unparse[((/:;#);1;`x)]~"1j#/:x"; {'x}"failed"];
    if[not .k2q.unparse[((/:;$);(*;`x;`y);`y)]~"(x*y)$/:y"; {'x}"failed"];
    if[not .k2q.unparse[(';(';#:))]~"count''"; {'x}"failed"];
    if[not .k2q.unparse[((';(';#:));`y)]~"count''[y]"; {'x}"failed"];
    if[not .k2q.unparse[(?;enlist `a`b`c;`d)]~"`a`b`c?d"; {'x}"failed"];
    if[not .k2q.unparse[((&:;`x);`y)]~"where[x]y"; {'x}"failed"];
    if[not .k2q.unparse[("ABCD";`x)]~"\"ABCD\"x"; {'x}"failed"];
    if[not .k2q.unparse[parse "value[y][;1]"]~"value[y][;1j]"; {'x}"failed"];
    if[not .k2q.unparse[(enlist`.q;enlist`string)]~"`.q `string"; {'x}"failed"];
    if[not .k2q.unparse[(enlist`.;`x)]~"`. x"; {'x}"failed"];
    if[not .k2q.unparse[(.;?;`x)]~"(?). x"; {'x}"failed"];
    if[not .k2q.unparse[(<:;3 2 1)]~"iasc 3 2 1j"; {'x}"failed"];
    if[not .k2q.unparse[(';(`f;`x))]~"f[x]'"; {'x}"failed"];
    if[not .k2q.unparse0[`projectionLeftArg;parse"P[i]"]~"P[i]"; {'x}"failed"];
    if[not .k2q.unparse[parse"P[i](;)'y"]~"P[i](;)'y"; {'x}"failed"];
    if[not .k2q.unparse[parse"aj"]~"aj"; {'x}"failed"];
    if[not .k2q.unparse[parse"\" \"sv"]~"\" \"sv"; {'x}"failed"];
    if[not .k2q.unparse[(/:;" ")]~"\" \"sv"; {'x}"failed"];
    if[not .k2q.unparse[parse"` vs f"]~"` vs f"; {'x}"failed"];
    if[not .k2q.unparse[((\:;enlist `);`f)]~"` vs f"; {'x}"failed"];
    if[not .k2q.unparse[parse"` vs"]~"` vs"; {'x}"failed"];
    if[not .k2q.unparse0[`iterable;parse"` vs"]~"(` vs)"; {'x}"failed"];
    if[not .k2q.unparse[(\:;enlist `)]~"` vs"; {'x}"failed"];
    if[not .k2q.unparse[parse"(` vs)'"]~"(` vs)'"; {'x}"failed"];
    if[not .k2q.unparse[(';(\:;enlist `))]~"(` vs)'"; {'x}"failed"];
    if[not .k2q.unparse[parse"(` vs)'[`a.b`a.c]"]~"(` vs)'[`a.b`a.c]"; {'x}"failed"];
    if[not .k2q.unparse[((';(\:;enlist `));enlist `a.b`a.c)]~"(` vs)'[`a.b`a.c]"; {'x}"failed"];
    if[not k2q[{}]~{[x]::};{'x}"failed"];
    if[not k2q[{-1}]~{[x] -1j};{'x}"failed"];
    if[not k2q[{z}[1]]~{[x;y;z]z}[1];{'x}"failed"];
    if[not k2q['[value"k){x}";value"k){x}"]]~(')[{[x]x};{[x]x}];{'x}"failed"];
    if[not k2q['[value"k){x}"]]~(')[{[x]x}];{'x}"failed"];
    if[not k2q[/[value"k){x}"]]~(/)[{[x]x}];{'x}"failed"];
    if[not k2q[\[value"k){x}"]]~(\)[{[x]x}];{'x}"failed"];
    if[not k2q[':[value"k){x}"]]~(':)[{[x]x}];{'x}"failed"];
    if[not k2q[/:[value"k){x}"]]~(/:)[{[x]x}];{'x}"failed"];
    if[not k2q[\:[value"k){x}"]]~(\:)[{[x]x}];{'x}"failed"];
    };

//.k2q.unittest[];

//{@[k2q;x;{"ERROR: ",x}]} each .Q
//{@[k2q;x;{"ERROR: ",x}]} each .h
