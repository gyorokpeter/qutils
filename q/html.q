.z.ph:{
    qry:x[0];
    1 "get ",.Q.s qry;
    cmdpar:"?"vs qry;
    par:.html.topar "?"sv 1_cmdpar;
    .html.genZPHPP[first cmdpar;par]};

.z.pp:{
    qry:x[0];
    cmdp:" "vs qry;
    cmdroot:cmdp 0;
    1 "post ",.Q.s cmdroot;
    cmdpar:" "sv 1_cmdp;
    ct:x[1;`$"Content-Type"];
    par:$[ct like "multipart/form-data*";
        [
            bound:last"boundary="vs ct;
            parts:first(("--",bound,"--\r\n") vs cmdpar);
            parts2:-2_/:(("--",bound,"\r\n") vs parts)except enlist"";
            parts3:{p:"\r\n\r\n"vs x;({first"\""vs@[;1]"name=\""vs first x where x like "*name=*"}"\r\n"vs p[0];p[1])}each parts2;
            (`$parts3[;0])!parts3[;1]
        ];
        .html.topar last "?"vs cmdpar
    ];
    .html.genZPHPP[cmdroot;par]};

.html.try:{-105!(x;y;{[z;e;bt]z e,"\n",.Q.sbt bt}[z])};
.html.tryDebug:{[x;y;z].[x;y]}; //.html.try:.html.tryDebug

.html.commandHandlers:()!();

.html.genZPHPP:{[cmd0;par]
    cmd:`$cmd0;
    if[not cmd in key .html.commandHandlers; :"wtf"];
    res:.html.try[{(1b;.html.commandHandlers[x][y])};(cmd;par);{(0b;x)}];
    if[not first res; :.h.hy[`htm].h.htc[`pre]["'",last res]];
    last res};

.html.topar:{{(`$x[;0])!.h.uh each ssr[;"+";" "]each x[;1]}"="vs/:("&"vs x)except enlist""};

.html.page:{[title;body]
    :.h.hy[`htm;"<!DOCTYPE html>",.h.htc[`html].h.htc[`head;.h.htc[`title;title],
        "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"],
        .h.htc[`body;body]];
    };

.html.table:{[t]
    t:0!t;
    .h.htac[`table;enlist[`border]!enlist enlist"1";
        .h.htc[`tr;raze .h.htc[`th]each string cols t]
        ,raze {.h.htc[`tr;raze .h.htc[`td]each {$[10h=type x;x;.Q.s1 x]}each value x]}each t
    ]};

.html.fastredirect:{.html.page["Redirecting...";.h.htc[`script;"window.location='",x,"'"]]};

.html.es:{ssr/[x;"&<>";("&amp;";"&lt;";"&gt;")]};
.html.unes:{ssr[;"&amp;";"&"]ssr[;"&apos;";"'"]ssr[x;"&quot;";"\""]};

.http.priv.common:{[url;data;method]
    urlp:"/"vs url;
    host:urlp[2];
    qhost:hsym`$"/"sv 3#urlp;
    doc:"/","/"sv 3_urlp;
    res:qhost "\r\n"sv ("GET ",doc," HTTP/1.1";"Host: ",host;"Connection: close";
        "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:69.0) Gecko/20100101 Firefox/69.0";""),data,(enlist"");
    };

.http.get:{[url]
    .http.priv.common[url;();"GET"]};

.http.post:{[url;data]
    .http.priv.common[url;$[10h=type data; enlist data;data];"POST"]};

{
    temp:ssr[;"\\";"/"]getenv`TEMP;
    .http.priv.tempFile:`$":",temp,"/q/wgettmp.html";
    .http.priv.postTempFile:`$":",temp,"/q/wgetpost.txt";
    .http.priv.cookieFile:`$":",temp,"/q/wgetcookies.txt";
    .http.priv.tempFile 0: ();
    }[];

.http.wget:{[url]
    cookies:1_string .http.priv.cookieFile;
    if[not ()~key .http.priv.tempFile; hdel .http.priv.tempFile];
    cmd:"--content-on-error=on --no-check-certificate --timeout=60 -O ",(1_string .http.priv.tempFile)," --load-cookies ",cookies," --save-cookies ",cookies," \"",url,"\"";
    res:.qutils.runProc["wget";cmd];
    if[not 0=first res;{'x}"wget failed"];
    `char$read1 .http.priv.tempFile};

.http.wgetIgnoreError:{[url]
    cookies:1_string .http.priv.cookieFile;
    if[not ()~key .http.priv.tempFile; hdel .http.priv.tempFile];
    cmd:"wget -q --content-on-error=on --no-check-certificate --timeout=60 -O ",(1_string .http.priv.tempFile)," --load-cookies ",cookies," --save-cookies ",cookies," \"",url,"\"";
    @[system;cmd;{}];
    `char$read1 .http.priv.tempFile};

.http.wgetWithHeaders:{[url]
    cookies:1_string .http.priv.cookieFile;
    if[not ()~key .http.priv.tempFile; hdel .http.priv.tempFile];
    system cmd:"wget -q --save-headers --content-on-error=on --no-check-certificate -O ",(1_string .http.priv.tempFile)
        ," --load-cookies ",cookies," --save-cookies ",cookies," \"",url,"\"";
    `char$read1 .http.priv.tempFile};

.http.wgetPostWithHeaders:{[url;postdata;contentType]
    .http.priv.postTempFile 0: enlist postdata;
    cookies:1_string .http.priv.cookieFile;
    if[not ()~key .http.priv.tempFile; hdel .http.priv.tempFile];
    system cmd:"wget -q --save-headers --content-on-error=on --no-check-certificate -O ",(1_string .http.priv.tempFile)
        ," --load-cookies ",cookies," --save-cookies ",cookies," --post-file=",(1_string .http.priv.postTempFile)," "
        ," --header=\"Content-Type: ",contentType,"\" \"",url,"\"";
    hdel .http.priv.postTempFile;
    `char$read1 .http.priv.tempFile};

.http.clearCookies:{
    @[hdel;.http.priv.cookieFile;{x}]};

.http.curlRaw:{[url;opts]
    cmd:"-is ",url;
    res:.qutils.runProc["curl";cmd];
    res};

.http.curlResp:{[res]
    respart:"\r\n\r\n"vs res 1;
    hdrpart:"\r\n"vs respart 0;
    codeLineInd:last where hdrpart like "HTTP/*";
    code:"J"$(" "vs hdrpart codeLineInd)1;
    hdrLines:(1+codeLineInd)_hdrpart;
    hdrLineParts:": "vs/:hdrLines;
    headers:(`,`$ssr[;"-";"_"]each hdrLineParts[;0])!enlist[hdrpart codeLineInd],": "sv/:1_/:hdrLineParts;
    bodypart:"\r\n\r\n"sv 1_respart;
    `code`headers`body!(code;headers;bodypart)};

.http.curl:{[url;opts]
    res:.http.curlRaw[url;opts];
    if[0<>first res;
        -2 last res;
        {'x}"curl failed";
    ];
    .http.curlResp res};

.http.curlIgnoreError:{[url;opts]
    res:.http.curlRaw[url;opts];
    .http.curlResp res};
