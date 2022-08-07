//the entire reason for this existing is that the below returns false:
//1471220573128024107=`long$.j.k"1471220573128024107"

.json.parse:{
    tokens:-4!x;
    tokens:tokens where not all each tokens in " \t\r\n";
    first .json.parseTokens[tokens;0]};

.json.parseTokens:{[tokens;offset]
    //offset:0
    f:tokens offset;
    if[f~"true"; :(1b;offset)];
    if[f~"false"; :(0b;offset)];
    if[f~"null"; :(0n;offset)];
    if[f[0] in "-0123456789";
        if["." in f; :("F"$f;offset)];
        :("J"$f;offset);
    ];
    if[f[0]="\""; :(.json.parseString[f];offset)];
    if[f~enlist"[";
        r:enlist(::);
        state:`value;
        while[not null state;
            offset+:1;
            if[offset>=count tokens; {'"unterminated object"}];
            f:tokens offset;
            $[state=`value; $[f~enlist"]"; state:`;[val:.json.parseTokens[tokens;offset]; offset:last val; r:r,enlist first val; state:`comma]];
              state=`comma; $[f~enlist"]"; state:`; f~enlist","; state:`value; {'x}"expected comma or ], found ",f];
            {'x}"unexpected token ",f];
        ];
        :(1_r; offset);
    ];
    if[f~enlist"{";
        r:enlist[`]!enlist(::);
        state:`id;
        while[not null state;
            offset+:1;
            if[offset>=count tokens; {'"unterminated object"}];
            f:tokens offset;
            $[state=`id; $[f~enlist"}"; state:`;[id:`$.json.parseString f; state:`colon]];
              state=`colon; [if[not f~enlist":"; {'x}"expected colon, found ",f]; state:`value];
              state=`value; [val:.json.parseTokens[tokens;offset]; offset:last val; r[id]:first val; state:`comma];
              state=`comma; $[f~enlist"}"; state:`; f~enlist","; state:`id; {'x}"expected comma or }, found ",f];
            {'x}"unexpected token ",f];
        ];
        :(` _ r; offset);
    ];
    {'x}"nyi";
    };

.json.parseString:{[token]
    if[not all (first[token];last[token])="\""; {'x}"string must be quoted: ",token];
    1_-1_token};

.json.unitTest:{
    if[not 1~.json.parse"  1  ";{'x}"failed"];
    if[not -1~.json.parse"-1";{'x}"failed"];
    if[not 9.0~.json.parse"9.0";{'x}"failed"];
    if[not 0n~.json.parse"null";{'x}"failed"];
    if[not enlist["M"]~.json.parse"\"M\"";{'x}"failed"];
    if[not 1471220573128024107~.json.parse"1471220573128024107";{'x}"failed"];
    if[not ()~.json.parse"[]";{'x}"failed"];
    if[not enlist[1]~.json.parse"[1]";{'x}"failed"];
    if[not 1 2~.json.parse"[1,2]";{'x}"failed"];
    if[not ((`$())!())~.json.parse"{}";{'x}"failed"];
    if[not (enlist[`1]!enlist 2)~.json.parse"{\"1\":2}";{'x}"failed"];
    if[not (`1`2!3 4)~.json.parse"{\"1\":3, \"2\":4}";{'x}"failed"];
    if[not enlist[(`1`2!3 4)]~.json.parse"[{\"1\":3, \"2\":4}]";{'x}"failed"];
    };
