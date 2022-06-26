.base64.b64encode:{
    c:count[x] mod 3;
    if[c<>0; c:3-c];
    s:(`byte$x),c#0x00;
    s2:raze "A"^-4$.Q.b6 64 vs/:0x00 sv/:0x00,/:3 cut s;
    (neg[c]_s2),c#"="};

.base64.b64decode:{
    c:sum x="=";
    s:(neg[c]_x),c#"A";
    `char$neg[c]_raze -3#/:0x00 vs/:64 sv/:.Q.b6?4 cut s};
