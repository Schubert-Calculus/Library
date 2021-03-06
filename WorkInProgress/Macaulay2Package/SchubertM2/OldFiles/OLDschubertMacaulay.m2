
restart

newPackage(
  "SchubertForMacaulay",
  Version => "0.2.0", 
  Date => "Novmeber 14, 2016",
  Authors => {
    {Name => "Revised from Singular Code by: Taylor Brysiewicz"}
  },
  Headline => "Schubert Calculus",
  DebuggingMode => false
)

export{
"lengthOfPermutation",
"myRing",
"nIndets",
"flagRing",
"localCoordMatrix",
"randomCondition"
}
--this next line is dumb. it gets frobenius' location by going up one directory and then down
load( (concatenate for i from 0 to #(currentDirectory())-12 list (currentDirectory())#i)|"FrobAlgM2/Frobenius.m2")

--------------------------------------------------------
--Input: permutation word (as a list)
--Output: length of the permutation
--------------------------------------------------------
lengthOfPermutation = method()
lengthOfPermutation(List):=(L) ->(
    len:=0;
    for i from 0 to #L-1 do(
	for j from i+1 to #L-1 do(
	    if((L#i)>(L#j)) then len=len+1;--tally length for each descent
	    ),
	),
    return(len)
    )
lengthOfPermutation({4,3,2,1})


----------------------------------------------------------------------------------------------------------------------
--Input: A number, n, and a list [ringField,varName,monomOrder] of types
--        [number corresponding to finite field, symbol 'some character', MonomialOrder] (no single quotes on the character)
--Output: a polynomial ring in n indeterminants, with variable names varName_i, over the field Field, with monomial order monomOrder.
---------default value QQ, x, GRevLex. variable name for finite field is "a". if 0 is given as number corr. finite field, we use QQ
---------Consider making 3 options instead of one List option
-------------------------------------------------------------------------------------------------------------------------
myRing = method(Options => {L=>{0,symbol x, GRevLex}})
myRing(ZZ) := o -> (n) ->(
    ringField:=QQ;
    varName:=symbol x;
    monomOrder:=GRevLex;
    if #(o.L)>=1 and (o.L)#0 != 0 then ringField=GF((o.L)#0,Variable=>a);
    if #(o.L)>=2 then varName=(o.L)#1;
    if #(o.L)>=3 then monomOrder=(o.L)#2;
    myRng:=ringField[varName_1..varName_n,MonomialOrder=>monomOrder];
    return(myRng)
    )
myRing(3,L=>{0,symbol y})

-----------------------------------------------------------------------------
---Input: flag dimensions, n as in Gr(k,n), two large schubert conditions
--            given as permutations in a list
---Output: number of indeterminates in local coord matrix
-----------------------------------------------------------------------------
nIndets = method()
nIndets(List,ZZ,List):=(a,n,L) ->(
    i:=0;
    s:=#a;
    d:=a#0*(n-a#0);
    for i from 2 to  s do(
	d=d+(a#(i-1)-a#(i-2))*(n-a#(i-1));
	),
    if #L==0 or #L>=3 then return(d);
    if #L==1 then return(d - lengthOfPermutation(L#0));
    if #L==2 then return(d - lengthOfPermutation(L#0) - lengthOfPermutation(L#0));
    )
nIndets({2,3},5,{{1,3,2,4},{1,3,2,4}})
----------------------------------------------------------------------------------------------------------------------
--Input: flag dimensions, n as in Gr(k,n) and two large schubert conditions
--          given as permutations in a list
--Output: ring with with the number of indeterminates specified by a given flag variety
--Question: is there any reason to have nIndets if the onlyl thing we use it for is to pipe this function through?
----------------------------------------------------------------------------------------------------------------------
flagRing = method()
flagRing(List, ZZ, List):=(a,n,L) ->(
    d:=nIndets(a,n,L);
    return(myRing(d))
    )
flagRing(ZZ, ZZ, List):=(a,n,L) ->(
    return(myRing(a))
    )
flagRing({2,3},4,{{1,3,2,4},{1,3,2,4}})

--------------------------------------------------------------------------------------------------
--Input: flag dimensions, n as in Gr(k,n), and two large schubert conditions in a pair
--Output: a matrix which assumes flags are coordinate flags (forwards and backards) with indeterminates
--          such that any completion of the flag results in the two schubert conditions being
--          satisfied
--double check when there is only 1 or 0 conditions(there were complications with index values)
----------------------------------------------------------------------------------------------------
localCoordMatrix = method()
localCoordMatrix (List, ZZ, List):=(a,n,L) ->(
    w:=for i from 1 to n list(i);
    fRing:=flagRing(a,n,L);
    E:=mutableMatrix(fRing,a#(#a-1),n);
    if(#L>=1) then w=L#0;
    if(#L>=2) then(
	if #a>1 then return(new Matrix from E);
	v:=L#1;	
	k:=0;
	for i from 0 to (a#0)-1 do(
	    E_(i,(w#i)-1)=1;
	    for j from w#(i) to n-v#(a#0-i-1) do(
		E_(i,j)=(gens(fRing))#(k);
		k=k+1;
	    	),
	    ),
        return(new Matrix from E);
    	),
    pivotRows:={};
    for i from 0 to (a#0)-1 do(
	E_(i,(w#i)-1)=1;
	pivotRows=append(pivotRows,(w#i)-1);
        ),
    k:=0;
    for i from 0 to (a#0)-1 do(
	for j from w#(i) to n-1 do(
	    if((isSubset({j},pivotRows))==false) then(
	    	E_(i,j)=(gens(fRing))#k;
	    	k=k+1;
	    	),
	    ),
	),
    return(new Matrix from E)    
    )
localCoordMatrix({2},4,{{1,3,2,4},{1,3,2,4}})


-------------------------------------------------------------------------------------------------------------------------------
--Input: a single schubert condition, flag dimensions, vsdim (width of local coord matrix I think) and the local coord matrix
--Output: a polynomial whose solutions correspond to satisfying the schubert condition for a random flag
---Note: we probably don't need vsdim if we have E. Which might give us room to chooose random range again
-------------------------------------------------------------------------------------------------------------------------------
randomCondition = method()
randomCondition (List,List,ZZ,Matrix):=(cond,flag,vsdim,E) ->(---don't give the two largest conditions. Just make he matrix before calling
    rand:=1000;--this was originally a parameter passed to the method, but M2 only likes 1-4 parameters????
    fRing:=ring(source E);
    F := mutableMatrix(fRing,vsdim,vsdim);
    for i from 0 to vsdim-1 do(for j from 0 to vsdim-1 do(F_(i,j)=random(-rand,rand)));
    F = new Matrix from F;
    M := transpose(E)|F;
    m := numgens source M;    
    cols = flag#0+vsdim;
    prevVal = 1;
    use fRing;
    I = ideal(0);
    for i from 1 to flag#0 do(
	cols=cols-cond#(i-1)+prevVal;
	prevVal = cond#(i-1);
	if(cond#(i-1) > i) then I=I+(minors(vsdim-cond#(i-1)+i+1,submatrix(M,0..vsdim-1,0..cols-1))),print(submatrix(M,0..vsdim-1,0..cols-1)),print(vsdim-cond#(i-1)+i+1),print(minors(vsdim-cond#(i-1)+i+1,submatrix(M,0..vsdim-1,0..cols-1)));
	), 
    return(trim I)
    )
testMatrix:=localCoordMatrix({2},4,{{1,3,2,4},{1,3,2,4}})
randomCondition({1,3,2,4},{2},4,testMatrix)


--------------------------------------------------------------
--Input: Schubert conditions in vert/horiz path notation
--Output: Schubert conditions in single descent notation
--------------------------------------------------------------
translateCondition=method()
translateCondition(List):=cond->(
    space:=cond#(#cond-1);
    diagramSize:= for i from 0 to #cond-1 list(space-cond#(#cond-1-i)-i);
    finishedCondition:= for i from 0 to #diagramSize-1 list(diagramSize#i+i+1);
    for i from 1 to space do(
	if isSubset({i},finishedCondition)==false then finishedCondition=append(finishedCondition,i);
	),
    return(finishedCondition)
    )
translateCondition({4,6,7})



----------------------------------------------------------------------------------------
--Input: List of conditions in vert/horiz notation (largest two being last)
--Output: An ideal whose solutions correspond to solutions to the schubert problem
--   This ideal is random in the sense that #conditions-2 polys came from random flags
-------------------------------------------------------------------------------------------
schubertIdeal=method()
schubertIdeal(List):=(conditions)->(
    k:=#(conditions#0);
    n:=(conditions#0)#(#(conditions#0)-1);
    conditions = for c in conditions list(translateCondition(c));
    fRing:=flagRing({k},n,{conditions#(#conditions -1),conditions#(#conditions-2)});
    use fRing;
    M:=localCoordMatrix({k},n,{conditions#(#conditions -1),conditions#(#conditions-2)});
    J:=ideal(0);
    for i from 0 to #conditions-3 do(
	J=J+(randomCondition(conditions#i,{k},n,M));--this is dumb we shouldn't compute localCoordMatrix every time we add a condition. We should pass this info along.
	);
    return(J)
    )

--schI:=schubertIdeal({{4,6,8},{3,7,8},{3,7,8},{3,7,8},{3,7,8}})
--dim schI
--degree schI
--frobeniusForIdeal(schI,0,8,20);--obviously running frobforIdeal won't work because you aren't changing your ideal. You need to make anew fobAlg with the 
---random conditions in it.
----thaaaat being said. It seems like changing the prime randomly does the trick
-----this way we don't have to run randomCondition a bajilion times.
--schI2:=schubertIdeal({{5, 7, 8, 9}, {5, 7, 8, 9}, {5, 7, 8, 9}, {5, 7, 8, 9}, {5, 6, 8, 9}, {5, 6, 7, 9}, {5, 6, 7, 9}, {2, 7, 8, 9}, {2, 7, 8, 9}})

