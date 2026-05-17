.worker.mirror:{[vars] //copy functions from parent
    (ts;vals):h({[vars]
        vals:value each vars;ts:type each vals;
        fni:where 100h=ts;
        vals[fni]:-4#/:value each vals fni;
        (ts;vals)};vars);
    notfn:where ts<>100h;
    vars[notfn]set'vals notfn;
    fdef:vals where ts=100h;
    fnames:fdef[;0];
    fnames:@[fnames;where fnames like "..*";2_];
    fdef[;3]:(fnames,\:":"),'fdef[;3];
    "q"each 1_/:fdef;
    };
h:hopen `$"::",.z.x 0;
task:h".worker.fetchTask[]";
-2"task: ",.Q.s1 task;
res:.Q.trp[{(1b;x[])};task;(0b;;)];
h(`.worker.postResult;res);
hclose h;
exit 0;
