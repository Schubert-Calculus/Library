restart
path = {"/Home/Documents/Library/WorkInProgress/Macaulay2Package/SchubertM2/"} | path 
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

twentySevenLines = method()
twentySevenLines(Ring) := (k) ->(
    R := k[x,y,z,w];
    f := random(3,R);
    S := k[a,b,c,d,t];
    phi := map(S,R,matrix{{1,t,a+c*t,b+d*t}});
    X := phi(f);
    T := k[a,b,c,d];
    I := sub(ideal((coefficients(X,Variables=>{t}))_(1)),T);
    return I)

I = twentySevenLines(ZZ/1009)
(dim I, degree I)
primaryDecomposition I

frobeniusAlgorithmTwentySevenLines = method()
frobeniusAlgorithmTwentySevenLines(Ring,ZZ,ZZ) := (R,numsols,numiterations) -> (
    datastuff := {};
    fullcycle := false;
    fullminusonecycle := false;
    primecycle := false;
    for i from 1 to numiterations do(
	I := twentySevenLines(R);
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

time frobeniusAlgorithmTwentySevenLines(ZZ/1009,27,12*27)

restart
path = {"/Home/Documents/Library/WorkInProgress/Macaulay2Package/SchubertM2/"} | path 
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

--- HOW I GOT THE GENERATORS IN "G" BELOW ---
--S = k[x_0..x_5,a,b,c]
--J = ideal(x_0-a^2,x_1-2*a*b,x_2-2*a*c-b^2,x_3-2*b*c,x_4-c^2)
--G = eliminate(J,{a,b,c})

twentyEightBitangents = method()
twentyEightBitangents(Ring) := (k) -> (
    R := k[x_0..x_4];
    G := {x_3^3-4*x_2*x_3*x_4+8*x_1*x_4^2,x_2*x_3^2-4*x_2^2*x_4+2*x_1*x_3*x_4+16*x_0*x_4^2,x_1*x_3^2-4*x_1*x_2*x_4+8*x_0*x_3*x_4,x_0*x_3^2-x_1^2*x_4,x_1^2*x_3-4*x_0*x_2*x_3+8*x_0*x_1*x_4,x_1^2*x_2-4*x_0*x_2^2+2*x_0*x_1*x_3+16*x_0^2*x_4,x_1^3-4*x_0*x_1*x_2+8*x_0^2*x_3};
    S := k[y,z,w];
    f := random(4,S);
    T := k[a,b,t];
    phi := map(T,S,{1,t,a+b*t});
    X := phi(f);
    U := k[a,b];
    N := sub((coefficients(X,Variables=>{t}))_(1),U);
    psi := map(U,R,transpose(N));
    I := ideal(0_U);
    for g in G do(
    	I = I + ideal(psi(g)));
    return(I))

I = twentyEightBitangents(ZZ/1009)
(dim I, degree I)
primaryDecomposition I

frobeniusAlgorithmTwentyEightBitangents = method()
frobeniusAlgorithmTwentyEightBitangents(Ring,ZZ,ZZ) := (k,numsols,numiterations) -> (
    datastuff := {};
    fullcycle := false;
    fullminusonecycle := false;
    primecycle := false;
    for i from 1 to numiterations do(
	I := twentyEightBitangents(k);
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
    return(fullcycle,fullminusonecycle,primecycle,frequencytable))

time frobeniusAlgorithmTwentyEightBitangents(ZZ/1009,28,12*28)

restart
path = {"/Home/Documents/Library/WorkInProgress/Macaulay2Package/SchubertM2/"} | path 
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
    
quinticThreefoldLines = method()
quinticThreefoldLines(Ring) := (k) ->(
    R := k[x_1..x_5];
    f := random(5,R);
    S := k[a_1,b_1,a_2,b_2,a_3,b_3,t];
    phi := map(S,R,matrix{{1,t,a_1+b_1*t,a_2+b_2*t,a_3+b_3*t}});
    X := phi(f);
    T := k[a_1,b_1,a_2,b_2,a_3,b_3];
    I := sub(ideal((coefficients(X,Variables=>{t}))_(1)),T);
    return I)

I = quinticThreefoldLines(ZZ/1009)
time primaryDecomposition I

frobeniusAlgorithmQuinticThreefoldLines = method()
frobeniusAlgorithmQuinticThreefoldLines(Ring,ZZ,ZZ) := (R,numsols,numiterations) -> (
    datastuff := {};
    fullcycle := false;
    fullminusonecycle := false;
    primecycle := false;
    for i from 1 to numiterations do(
	I := quinticThreefoldLines(R);
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

time frobeniusAlgorithmQuinticThreefoldLines(ZZ/1009,2875,1)
