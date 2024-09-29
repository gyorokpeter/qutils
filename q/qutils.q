{
    path:"/"sv -2_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    .qutils.priv.lib:`$":",path,"/qutils";
    .qutils.setReplaceDict:.qutils.priv.lib 2:(`setReplaceDict;1);
    .qutils.textReplace:.qutils.priv.lib 2:(`textReplace;1);
    .qutils.setFileTime:.qutils.priv.lib 2:(`winSetFileTime;2);
    .qutils.getFileTime:.qutils.priv.lib 2:(`winGetFileTime;1);
    .qutils.splitToLayers:.qutils.priv.lib 2:(`splitToLayers;1);
    .qutils.filetimeToTs:.qutils.priv.lib 2:(`filetimeToTsK;1);
    .qutils.xorDecode:.qutils.priv.lib 2:(`xorDecode;2);
    .qutils.utf8toANSI:.qutils.priv.lib 2:(`utf8toANSI;1);
    .qutils.runProc:.qutils.priv.lib 2:(`runProc;2);
    .qutils.runCoProc:.qutils.priv.lib 2:(`runCoProc;2);
    .qutils.sleep:.qutils.priv.lib 2:(`sleep;1);
    }[]

.qutils.getFileTimeTs:{[path]
    .qutils.filetimeToTs .qutils.getFileTime path};

try2:{-105!(x;y;{[z;e;bt] -1 .Q.sbt bt; z[e]}[z])};
try3:{-105!(x;y;{[z;e;bt]z[e;bt]}[z])};

.qutils.thousandsSep:{if[null x;:""];s:string x;c:count[s];" "sv(0,(1+(c-1) mod 3)+3*til (c-1)div 3)cut s};

.qutils.openWebSocket:{[url]
    if[not any url like/:("ws://*";"wss://*"); '"url must start with \"ws://\""];
    p:"/"vs url;
    hostport:p[2];
    connhandle:`$":","/"sv 3#p;
    resource:"/","/"sv 3_p;
    r:connhandle"GET ",resource," HTTP/1.1\r\nHost: ",hostport,"\r\n\r\n";
    if[null first r; 'last r];
    first r};

//key value e.g. kv[`a;1;`b;2]
.qutils.kv0:{(!). flip 2 cut x};
.qutils.listarg:{(')[x;enlist]};
kv:.qutils.listarg[.qutils.kv0];
.qutils.kvarg:{(')[x;kv]};
.qutils.dictKeyAsc:{asc[key x]#x};
.qutils.setDictKeyAsc:{[vn]vn set dictKeyAsc get vn};
