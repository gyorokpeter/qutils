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
    }[]

.qutils.getFileTimeTs:{[path]
    .qutils.filetimeToTs .qutils.getFileTime path};

base64decode:{
    pad:sum x="=";
    c:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    neg[pad]_`char$0b sv/:8 cut raze -6#/:0b vs/:c?x};

.qutils.thousandsSep:{s:string x;c:count[s];" "sv(0,(1+(c-1) mod 3)+3*til (c-1)div 3)cut s};
