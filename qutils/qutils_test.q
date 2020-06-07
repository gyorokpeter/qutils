\c 2000 2000

\l qutils.q

rd:enlist["é"]!enlist"ee";
rd["ű"]:"ueue";
.qutils.setReplaceDict rd;
//-1 .qutils.textReplace"abcdef";
//-1 .qutils.textReplace"éaéaé";
//-1 .qutils.textReplace"aűaűa";

//-1 .qutils.textReplace"听起来不错";
//-1 .qutils.textReplace 3332#"a";
show .qutils.splitToLayers(1 1 1i;2 2 2i);
