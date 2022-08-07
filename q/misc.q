sleep:{[seconds]
    if[not type[seconds] in -6 -7h; '"seconds must be int/long"];
    system"ping -n ",string[1+seconds]," 127.0.0.1 > nul";
    };
