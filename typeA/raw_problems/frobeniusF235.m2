restart
path = {"../../WorkInProgress/Macaulay2Package/SchubertM2/"} | path 
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
        if sum(degreecyclelist) == numsols then datastuff = append(datastuff,degreecyclelist));
	if degreecyclelist == {numsols} then fullcycle = true;
	if degreecyclelist == {1,numsols-1} then fullminusonecycle = true;
	for k in degreecyclelist do(
	     if (k > numsols/2) and (k < numsols-2) and (isPrime(k)==true) then primecycle = true); 
	if ((fullcycle == true) and (fullminusonecycle == true) and (primecycle == true)) then (print("Full Symmetric Group") and break);
    if ((fullcycle == false) or (fullminusonecycle == false) or (primecycle == false)) then print("Needs Further Study"); 
    frequencytable := {};
    for cycle in unique(datastuff) do(
        frequencytable = append(frequencytable,(cycle,number(datastuff,i->i==cycle))));
    return(fullcycle,fullminusonecycle,primecycle,frequencytable))

frobeniusFrequencies = method()
frobeniusFrequencies(List,ZZ,ZZ,ZZ) := (L,p,numsols,numiterations) -> (
    flagtype := L_(0);
    n := last(flagtype);
    conditions := L_(1);
    l := length(conditions);
    P := ZZ/p;
    datastuff := {};
    for i from 1 to numiterations do(
	flags := {};
	for j from 1 to (l-1) do(
	    flags = append(flags,random(P^n,P^n)));
	if det(product(flags)) == 0 then continue;
	I := typeASchubertIdeal(flagtype,conditions,flags,P);
	f := smartFactor univariateEliminant(sum(gens ring(I)),I);
	degreecyclelist := sort(flatten for fac in f list(degree(fac#0)));
	if sum(degreecyclelist) == numsols then datastuff = append(datastuff,degreecyclelist));
    frequencytable := {};
    for cycle in unique(datastuff) do(
	frequencytable = append(frequencytable,(cycle,number(datastuff,i->i==cycle))));
    return(frequencytable))

frobeniusAlgorithmLessThanEightSolutions = method()
frobeniusAlgorithmLessThanEightSolutions(List,ZZ,ZZ,ZZ) := (L,p,numsols,numiterations) -> (
    frequencytable = frobeniusFrequencies(L,p,numsols,numiterations);
    if length(frequencytable) == length(partitions numsols) then print("Full Symmetric Group");
    if length(frequencytable) != length(partitions numsols) then print("Needs Further Study"))

---------------------------------------------------------------------------------------------------

inputfile = get "F235modified.txt";
filelist = lines(inputfile);
problems = {};
for file in filelist do(
	problems = append(problems, value(file)));
f = "frobenius_output.txt" << "";
for problem in problems do(
	f << problem << endl;
	f << frobeniusAlgorithm(problem#0,10009,problem#1,100) << endl;
--	f << frobeniusFrequencies(problem#0,10009,problem#1,100) << endl);
	print(problem));
--	frobeniusAlgorithm(problem#0,10009,problem#1,100));
--	if problem#1 < 7 then frobeniusAlgorithmLessThanEightSolutions(problem#0,1009,problem#1,6*problem#1);
--	if problem#1 >=8 then frobeniusAlgorithm(problem#0,1009,problem#1,6*problem#1));

quit();
