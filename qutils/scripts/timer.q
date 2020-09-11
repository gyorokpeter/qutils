.timer.list:([id:`long$()]func:();when:`timestamp$();period:`timespan$());
.timer.sq:0;

.timer.reschedule:{
    $[0=count .timer.list; system"t 0";
        system "t ",string max 1,exec min`long$(when-.z.P) div 1000000 from .timer.list
    ];
    };

.timer.convertPeriod:{[period]
    $[type[period] in -7 -18h;
        `timespan$`time$period;
    `timespan$period]};

.timer.addPeriodicTimer:{[func;period]
    period:.timer.convertPeriod[period];
    if[period<=00:00:00.001;'"period too short"];
    id:.timer.sq+:1;
    .timer.list[id]:`func`when`period!(func;.z.P+period;period);
    .timer.reschedule[];
    id};

.timer.addRelativeTimer:{[func;delay]
    if[-12h=type delay; '"*relative* timer doesn't accept a timestamp"];
    delay:.timer.convertPeriod[delay];
    if[delay<0D;'"delay<0"];
    id:.timer.sq+:1;
    .timer.list[id]:`func`when`period!(func;.z.P+delay;0Nn);
    .timer.reschedule[];
    id};

.timer.addAbsoluteTimer:{[func;time]
    id:.timer.sq+:1;
    .timer.list[id]:`func`when`period!(func;time;0Nn);
    .timer.reschedule[];
    id};

.timer.addTimeOfDayTimer:{[func;startTime;period]
    period:.timer.convertPeriod[period];
    id:.timer.sq+:1;
    .timer.list[id]:`func`when`period!(func;(.z.D+$[.z.T<startTime;0;1])+startTime;period);
    .timer.reschedule[];
    id};

.timer.removeTimer:{[id]id0:id;delete from `.timer.list where id=id0;.timer.reschedule[];};
try2:{-105!(x;y;{[z;e;bt] -1 .Q.sbt bt; z[e]}[z])};
try3:{-105!(x;y;{[z;e;bt]z[e;bt]}[z])};
.timer.errorHandler:{[e;bt] -1"timer error: ",e; -1 .Q.sbt bt}
.z.ts:{
    while[0<count toRun:exec id from .timer.list where when<=.z.P;
        nxt:first toRun;
        try3[.timer.list[nxt;`func];enlist[::];{[e;bt].timer.errorHandler[e;bt]}];
        $[null .timer.list[nxt;`period]; .timer.removeTimer nxt; .timer.list[nxt;`when]+:.timer.list[nxt;`period]];
    ];
    .timer.reschedule[];
    };

//.timer.addPeriodicTimer[{-1 .Q.s1(1,.z.P)};1000]
//.timer.addPeriodicTimer[{-1 .Q.s1(2,.z.P)};2000]
//.timer.addRelativeTimer[{-1 .Q.s1(3,.z.P)};5000]
