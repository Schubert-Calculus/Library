N = 6

allFlags = method()
allFlags(ZZ) := (n) -> (
    allsubs = subsets(toList(1..(n-1)));
    modsubs = delete({},allsubs);
    flaglist = {};
    for sub in modsubs do(
    flaglist = append(flaglist,append(sub,n)));
    return(flaglist))

conflags = method()
conflags(ZZ) := (n) -> (
    flaglist = allFlags(n);
    flags = {};
    for flag in flaglist do(
	conflag = {"F"};
	for i in flag do(
	    conflag = append(conflag,toString(i)));
	flags = append(flags,concatenate(conflag)));
    return(flags))

brackflags = method()
brackflags(ZZ) := (n) -> (
    flaglist = allFlags(n);
    flags = {};
    for flag in flaglist do(
        brackflag = [];
        for i in flag do(
            brackflag = append(brackflag,i));
        flags = append(flags,brackflag));
    return(flags))

f = "allconflags.txt" << ""
for flag in conflags(N) do(
    f << flag << endl)
g = "allbrackflags.txt" << ""
for flag in brackflags(N) do(
    g << flag << endl)

quit()


