-- NOTE: Requires Version of 1.21 of Macaulay2 to Work
path = {"../../../WorkInProgress/Macaulay2Package/SchubertM2/"} | path 
recursionLimit=10000
loadPackage("SchubertIdeals", Reload => true)
loadPackage("RealRoots")

smartFactor = method()
smartFactor(RingElement) := (F) ->(
    P:=factor(F);
    L1:=new List from(P);
    L2:=for p in L1 list(new List from p);
    return(L2)
    )

-- Heuristic: numiterations = 6*numsols
frobeniusAlgorithm = method()
frobeniusAlgorithm(List,ZZ,ZZ,ZZ) := (L,p,numsols,numiterations) -> (
    flagtype := L_(0);
    n := last(flagtype);
    conditions := L_(1);
    l := length(conditions);
    P := ZZ/p;
    datastuff := {};
    fullcycle := false;
    fullminusonecycle := false;
    primecycle := false;
    for i from 1 to numiterations do(
	flags := {};
	for j from 1 to (l-1) do(
	    flags = append(flags,random(P^n,P^n)));
	if det(product(flags)) == 0 then continue;
	I := typeASchubertIdeal(flagtype,conditions,flags,P);
	f := smartFactor univariateEliminant(sum(gens ring(I)),I);
	degreecyclelist := sort(flatten for fac in f list(degree(fac#0)));
	if sum(degreecyclelist) != numsols then continue;
        if sum(degreecyclelist) == numsols then datastuff = append(datastuff,degreecyclelist);
	if degreecyclelist == {numsols} then fullcycle = true;
	if degreecyclelist == {1,numsols-1} then fullminusonecycle = true;
	for k in degreecyclelist do(
	     if (k > numsols/2) and (k <= numsols-2) and (isPrime(k)==true) then primecycle = true); 
	if ((fullcycle == true) and (fullminusonecycle == true) and (primecycle == true)) then (print("Full Symmetric Group") and break);
   );
    if ((fullcycle == false) or (fullminusonecycle == false) or (primecycle == false)) then print("Needs Further Study");
    frequencytable := {};
    for cycle in unique(datastuff) do(
        frequencytable = append(frequencytable,(cycle,number(datastuff,i->i==cycle))));
    return(fullcycle,fullminusonecycle,primecycle,frequencytable)
 )

frobeniusDegreeThree = method()
frobeniusDegreeThree(List,ZZ,ZZ,ZZ) := (L,p,numsols,numiterations) -> (
    flagtype := L_(0);
    n := last(flagtype);
    conditions := L_(1);
    l := length(conditions);
    P := ZZ/p;
    datastuff := {};
    twocycle := false;
    for i from 1 to numiterations do(
	flags := {};
	for j from 1 to (l-1) do(
	    flags = append(flags,random(P^n,P^n)));
	if det(product(flags)) == 0 then continue;
	I := typeASchubertIdeal(flagtype,conditions,flags,P);
	f := smartFactor univariateEliminant(sum(gens ring(I)),I);
	degreecyclelist := sort(flatten for fac in f list(degree(fac#0)));
	if sum(degreecyclelist) != numsols then continue;
        if sum(degreecyclelist) == numsols then datastuff = append(datastuff,degreecyclelist);
	if degreecyclelist == {1,2} then twocycle = true;
	if (twocycle == true) then (print("Full Symmetric Group") and break);
   );
    if (twocycle == false) then print("Needs Further Study");
    frequencytable := {};
    for cycle in unique(datastuff) do(
        frequencytable = append(frequencytable,(cycle,number(datastuff,i->i==cycle))));
    return(twocycle,frequencytable)
 )

frobeniusDegreeFour = method()
frobeniusDegreeFour(List,ZZ,ZZ,ZZ) := (L,p,numsols,numiterations) -> (
    flagtype := L_(0);
    n := last(flagtype);
    conditions := L_(1);
    l := length(conditions);
    P := ZZ/p;
    datastuff := {};
    threecycle := false;
    fourcycle := false;
    for i from 1 to numiterations do(
	flags := {};
	for j from 1 to (l-1) do(
	    flags = append(flags,random(P^n,P^n)));
	if det(product(flags)) == 0 then continue;
	I := typeASchubertIdeal(flagtype,conditions,flags,P);
	f := smartFactor univariateEliminant(sum(gens ring(I)),I);
	degreecyclelist := sort(flatten for fac in f list(degree(fac#0)));
	if sum(degreecyclelist) != numsols then continue;
        if sum(degreecyclelist) == numsols then datastuff = append(datastuff,degreecyclelist);
	if degreecyclelist == {1,3} then threecycle = true;
	if degreecyclelist == {4} then fourcycle = true;
	if ((threecycle == true) and (fourcycle == true)) then (print("Full Symmetric Group") and break);
   );
    if ((threecycle == false) or (fourcycle == false)) then print("Needs Further Study");
    frequencytable := {};
    for cycle in unique(datastuff) do(
        frequencytable = append(frequencytable,(cycle,number(datastuff,i->i==cycle))));
    return(threecycle,fourcycle,frequencytable)
 )

frobeniusDegreeFive = method()
frobeniusDegreeFive(List,ZZ,ZZ,ZZ) := (L,p,numsols,numiterations) -> (
    flagtype := L_(0);
    n := last(flagtype);
    conditions := L_(1);
    l := length(conditions);
    P := ZZ/p;
    datastuff := {};
    twothreecycle := false;
    for i from 1 to numiterations do(
	flags := {};
	for j from 1 to (l-1) do(
	    flags = append(flags,random(P^n,P^n)));
	if det(product(flags)) == 0 then continue;
	I := typeASchubertIdeal(flagtype,conditions,flags,P);
	f := smartFactor univariateEliminant(sum(gens ring(I)),I);
	degreecyclelist := sort(flatten for fac in f list(degree(fac#0)));
	if sum(degreecyclelist) != numsols then continue;
        if sum(degreecyclelist) == numsols then datastuff = append(datastuff,degreecyclelist);
	if degreecyclelist == {2,3} then twothreecycle = true;
	if (twothreecycle == true) then (print("Full Symmetric Group") and break);
   );
    if (twothreecycle == false) then print("Needs Further Study");
    frequencytable := {};
    for cycle in unique(datastuff) do(
        frequencytable = append(frequencytable,(cycle,number(datastuff,i->i==cycle))));
    return(twothreecycle,frequencytable)
 )

frobeniusDegreeSix = method()
frobeniusDegreeSix(List,ZZ,ZZ,ZZ) := (L,p,numsols,numiterations) -> (
    flagtype := L_(0);
    n := last(flagtype);
    conditions := L_(1);
    l := length(conditions);
    P := ZZ/p;
    datastuff := {};
    twothreecycle := false;
    fivecycle := false;
    for i from 1 to numiterations do(
	flags := {};
	for j from 1 to (l-1) do(
	    flags = append(flags,random(P^n,P^n)));
	if det(product(flags)) == 0 then continue;
	I := typeASchubertIdeal(flagtype,conditions,flags,P);
	f := smartFactor univariateEliminant(sum(gens ring(I)),I);
	degreecyclelist := sort(flatten for fac in f list(degree(fac#0)));
	if sum(degreecyclelist) != numsols then continue;
        if sum(degreecyclelist) == numsols then datastuff = append(datastuff,degreecyclelist);
	if degreecyclelist == {1,2,3} then twothreecycle = true;
	if degreecyclelist == {1,5} then fivecycle = true;
	if ((twothreecycle == true) and (fivecycle == true)) then (print("Full Symmetric Group") and break);
   );
    if ((twothreecycle == false) or (fivecycle == false)) then print("Needs Further Study");
    frequencytable := {};
    for cycle in unique(datastuff) do(
        frequencytable = append(frequencytable,(cycle,number(datastuff,i->i==cycle))));
    return(twothreecycle,fivecycle,frequencytable)
 )

---------------------------------------------------------------------------------------------------

inputfile = get "F25data.txt";
filelist = lines(inputfile);
problems = {};
for file in filelist do(
	problems = append(problems, value(file)));
f = "frobenius_outputF25.txt" << "";
for problem in problems do(
	f << problem << endl;
	if problem#1 >= 7 then(
	    f << frobeniusAlgorithm(problem#0,10009,problem#1,6*problem#1) << endl << endl);
	if problem#1 == 3 then(
	    f << frobeniusDegreeThree(problem#0,10009,problem#1,6*problem#1) << endl << endl);
	if problem#1 == 4 then(
	    f << frobeniusDegreeFour(problem#0,10009,problem#1,6*problem#1) << endl << endl);
	if problem#1 == 5 then(
	    f << frobeniusDegreeFive(problem#0,10009,problem#1,6*problem#1) << endl << endl);
	if problem#1 == 6 then(
	    f << frobeniusDegreeSix(problem#0,10009,problem#1,6*problem#1) << endl << endl);
	quit;
	);

quit();
