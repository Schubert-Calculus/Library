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
	if ((fullcycle == true) and (fullminusonecycle == true) and (primecycle == true)) then break;
   );
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
	if (twocycle == true) then break;
   );
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
	if ((threecycle == true) and (fourcycle == true)) then break;
   );
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
	if (twothreecycle == true) then break;
   );
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
	if ((twothreecycle == true) and (fivecycle == true)) then break;
   );
    frequencytable := {};
    for cycle in unique(datastuff) do(
        frequencytable = append(frequencytable,(cycle,number(datastuff,i->i==cycle))));
    return(twothreecycle,fivecycle,frequencytable)
 )

---------------------------------------------------------------------------------------------------

f = openOutAppend "output1-F246.txt";
problem = {{{2, 4, 6}, {{1, 2, 3, 5, 4, 6}, {1, 2, 3, 5, 4, 6}, {1, 3, 2, 4, 5, 6}, {1, 2, 3, 6, 4, 5}, {1, 2, 3, 6, 4, 5}, {1, 4, 2, 3, 5, 6}, {2, 4, 1, 3, 5, 6}}}, 3};
i = 0;

if problem#1 >= 7 then(
    (fullcycle,fullminusonecycle,primecycle,frequencytable) = frobeniusAlgorithm(problem#0,10009,problem#1,12*problem#1);
    if ((fullcycle == false) or (fullminusonecycle == false) or (primecycle == false)) then(
        i = 1;
	f << problem << endl << frequencytable << endl << endl));
if problem#1 == 3 then(
    (twocycle,frequencytable) = frobeniusDegreeThree(problem#0,10009,problem#1,12*problem#1);
    if (twocycle == false) then(
	i = 1;
	f << problem << endl << frequencytable << endl << endl));
if problem#1 == 4 then(
    (threecycle,fourcycle,frequencytable) = frobeniusDegreeFour(problem#0,10009,problem#1,12*problem#1);
    if ((threecycle == false) or (fourcycle == false)) then(
	i = 1;
	f << problem << endl << frequencytable << endl << endl));
if problem#1 == 5 then(
    (twothreecycle,frequencytable) = frobeniusDegreeFive(problem#0,10009,problem#1,12*problem#1);
    if (twothreecycle == false) then(
	i = 1;
	f << problem << endl << frequencytable << endl << endl));
if problem#1 == 6 then(
    (twothreecycle,fivecycle,frequencytable) = frobeniusDegreeSix(problem#0,10009,problem#1,12*problem#1);
    if ((twothreecycle == false) or (fivecycle == false)) then(
	i = 1;
	f << problem << endl << frequencytable << endl << endl));

quit();
