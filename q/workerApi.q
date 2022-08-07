{
    .worker.priv.path:"/"sv -1_"/"vs ssr[;"\\";"/"]first -3#value .z.s;
    }[];


.worker.taskList:();

.worker.fetchTask:{
    task:first .worker.taskList;
    .worker.taskList:1_.worker.taskList;
    -1".worker.fetchTask returning ",.Q.s1 task;
    task};

.worker.errorHandler:{[e;bt]
    -2"error: ",e;
    -2 .Q.sbt bt;
    };

.worker.postResult:{[res]
    if[not first res;
        .worker.errorHandler[res 1;res 2];
    ];
    };

.worker.start:{[task]
    if[0=system"p";
        system"p 0W";
    ];
    .worker.taskList,:enlist task;
    system "start /B ",.z.X[0]," ",.worker.priv.path,"/worker.q ",string[system"p"]," 1>&2";
    };


.worker.persistentList:`$();

.worker.startPersistent:{[callback]
    if[0=system"p";
        system"p 0W";
    ];
    .worker.persistentList,:enlist callback;
    system "start /B ",.z.X[0]," ",.worker.priv.path,"/workerPersistent.q ",string[system"p"]," <NUL 1>&2";
    };

.worker.persistentStarted:{
    callback:first .worker.persistentList;
    .worker.persistentList:1_.worker.persistentList;
    callback[.z.w];
    };
