
restart
load ((currentDirectory())|"Test.m2")


w = {1,2,5,3,6,4,7}
flagType = {3,5,7}
H=stiefelCoordinates({w},flagType)
F=randomFlag(7)
G=randomFlag(7)
r = {1,4,6,2,3,5,7}
s = {4,5,7,1,2,3,6}
isCondition(s,flagType)

getEquations(H,{{r,F},{s,G}},flagType)

flagType


help select

greaterOrEqual = method()
greaterOrEqual(List,List):=(w,v) ->(
    wIsBigger:=true;
    for i from 0 to #w-1 do(
	if w#i>v#i then return(true)
	),
    return(false)
    )
greaterOrEqual({1,2,3,4,5},{2,3,4,5,6})

netList select(subsets({1,2,3,4,5,6,7,8,9},5),f:=(p)->greaterOrEqual({2,4,5,6,7},p))



allNotGreaterOrEqual = method()
allNotGreaterOrEqual(List,ZZ):=(w,n) ->(
    allPartialPerms:=subsets(for i from 1 to n list i, #w);
    allSmallPerms:=select(allPartialPerms,f:=(p)->greaterOrEqual(w,p));
    return(allSmallPerms)       
    )

allNotGreaterOrEqual({1,3,4,5,6},7)


getEquations(H,{{{1,2,5,3,6,4,7},F},{{1,4,6,2,7,3,5},F},{{1,5,6,2,7,3,4},G}},{3,5,7})


getEquations = method()
getEquations(Matrix,List,List):=(H,conditions,flagType) ->(
    n:=last(flagType);
    --check: the conditions are actually conditions for the flagType
    	    --That flags were given (otherwise compute random flags)
	    --That the stiefel matrix is the correct size
    perms:=for c in conditions list completePermutation(c#0,n);
    flagInverses:=for c in conditions list inverse(c#1);
    
    --Since equations are gotten from equations for projections onto grassmannians, 
    ----we first index each relevant grassmannian condition w/ pointers to their
    ----corresponding flags
    grassmannianPerms:={};
    for i from 0 to #perms-1 do(
	for k in getDescents(perms#i) do(
	    gPerm:=makeGrassmannianPermutation(perms#i,k,n);
	    vSet:=allNotGreaterOrEqual(gPerm,n);
	    grassmannianPerms=append(grassmannianPerms,{gPerm,vSet,i});
	    ),
	),
    
    --Now, for each grassmannianPermutation w corresponding to a flag F, we want the plucker coordinates
    ----p_v(F^{-1}H) for each v which is not greater than or equal to w.
    ----Using Cauchy-Binet, this means we are in need of all plucker coordinates of H w/ columns indexedd by v
    ----And all plucker coordinates of F w/ rows indexed by v.
    print("A");
    --so here we pull all the possible v that could (and will) occur.
    vCollection:=flatten for p in grassmannianPerms list p#1;
    
    --we populate a hashtable which holds data corresponding to relevant plucker coordinates of H
    hMinors:=new MutableHashTable;
    print("B");
    for v in vCollection do(
	betaList:=subsets(for i from 1 to n list i,#v);
        for beta in betaList do(
	    vMinus:= for c in v list c-1;
	    betaMinus:=for b in beta list b-1;
	    hMinors#(beta,v)=determinant(submatrix(H,betaMinus,vMinus));
	    ), 
	),
    print("C");
    equations:={};
    --we now scroll through each grassmannianPermutation
    for w in grassmannianPerms do(
	--and each v which is not greater than or equal to w
	for v in w#1 do(
	    print("D");
	    print(flagInverses);
	    newEquation:=cauchyBinet(flagInverses#(w#2),hMinors,v,n);
	    equations=append(equations,newEquation);
	    ),	
	),
    return(equations)
    )
    
    
cauchyBinet=method()
cauchyBinet(Matrix,HashTable,List,ZZ):=(Finv,hMinors,v,n) ->(--DO I NEED TO ASK FOR N? can I just pull from matrix?
    betas:=subsets(for i from 1 to n list i,#v);
    print(netList betas);
    summands:={};
    print("a");
    for beta in betas do(
	betaMinus:=for j in beta list j-1;
	vMinus:=for j in v list j-1;
	print({beta,v});
	newSummand:=(determinant(submatrix(Finv,betaMinus,vMinus)))*(hMinors#(beta,v));
	summands=append(summands,newSummand);
	),
    print("b");
    minorOfProduct:=sum(summands);
    print("c");
    return(minorOfProduct)
    )    
    
    
    
    
    
    
    
    
    
    
    
    








w={2,8,3,4,7}
u={1,3,5,7,2,4,6,8}
completePermutation(w,8)
completePermutation(u,8)

getDescents(w)
getDescents(u)


isCondition(w,{2,5,8})
isCondition(w,{2,8})
lengthOfPermutation(w)
lengthOfPermutation({1,2,3,4,20})
lengthOfPermutation(completePermutation({1,2,3,4,20},100))

w = {1,2,5,3,6,4,7}
getDescents(w)
flagType = {1,3,4,5,6,9}
stiefelCoordinates({w},flagType)


makeGP({3,5,1,6,2,7},4,8)

w = {1,3,6}
v = {1,2,5}
flagType={3,8}
stiefelCoordinates({w,v},flagType,MonomOrder=>Lex)


sum for i from 0 to 100 list trulyRandom(QQ)
sum for i from 0 to 100 list random(QQ)


randomFlag(5,FieldChoice=>QQ)
QQ[t]
F={t^4+t^3+t^2+t+1,t+t^3+3*t,t^7-t^4+t^2}
osculatingFlag(F,3,1/2)





(sum for i from 0 to 100 list trulyRandom(CC))/100.0


for f in F list diff(t,f)    
    QQ[t]
F=t^2+t^3
diff(t,F)


R=CC[x]
random(R,3,3)
random(QQ^5,QQ^5)
help random

getStiefelCoordinates({{1,2,5,3,6,4,7}},{3,5,7})
M=getStiefelCoordinates({{1,3,6},{1,2,5}},{3,8})


restrictRing(M)


M=matrix{{1,2,3,4,5,6},{6,5,4,3,2,1}}    
M_{0,5}
    
    
    
    
    
    
    
    
    
    
    
    
    
L:={1,2,5,3,6,4,7}
reverse L
L=join({0},getDescents(L))
for i from 0 to 7 list ({1,4,6}#(position({1,4,6},d->d>i)))
for i from 0 to 7 list(max(positions(L,d->d<i)))
for i from 0 to 6 list ({i,L#(position(L,d-> d>i))})    
help first

    
w={5,1,4,2,3}    
scan(w,k->print(position(w,i->i==k),5-k))    


	for j from 0 to n-1 do(
	    --for each column, list the rows that are smaller than that column's "1" and (1) haven't been occupied by 1's yet
	    rows:=select(for i from 0 to n-w#j-1 list i,k->isSubset({k},for i from 0 to j list n-w#i)==false);	   
	    for i in rows do(
		genMat_(i,j)=x_(i+1,j+1)
		),
	    genMat_(n-w#j,j)=1
	    );
	print(genMat);
	)
    
    


    help isSubset
    
    scan({1,2,3},k->position(k,{1,2,3}))
help position
getStiefelCoordinates({1,2,4,3,5},{1,3,5})
Check=new List from (1,1)..(5,5)
apply(Check,k->(k_0+1,k_1+1))
scan(Check,k->if k==(1,1)then k)	
	D:=(1,1)
D_0
NC:=infinity
FFF:=QQ
makeLocalCoordinates = method(TypicalValue => MutableMatrix)
makeLocalCoordinates Array := blackred ->(
  blackposition := first blackred;
  redposition := last blackred;
  VAR := symbol VAR;
  print("hey");
  print(redposition);
  n := #redposition; -- n is the size of the board
  -- we find how many black checkers are in northwest to a given red
  print("test");
  rowsred := sort select(redposition, r->r=!=NC);
  print("asdf");
  colsred := apply(rowsred, r -> position(redposition, j-> j == r));
  print("hi");
  E := new MutableHashTable;
    for r to #rowsred-1 do(
      E#(rowsred#r,r) = 1;
      variablerows := take(blackposition,colsred#r+1);
      variablerows = select(variablerows, b-> b< rowsred#r);
      scan(variablerows, j->(
        if member(j,rowsred) and position(redposition, i-> i == j) < colsred#r then
	  variablerows = delete(j,variablerows);
      ));
      scan(variablerows, col-> (
        E#(col,r)=VAR;
      ));
   );
   return(E)
   )
   x:= symbol x;
   R:=FFF[apply(select(sort keys E, k-> E#k===VAR), k-> x_k)];
   X := mutableMatrix(R,n,#rowsred);
   scan(keys E, k-> X_k = if E#k === 1 then 1 else x_k);
   matrix X
)

restart
R=QQ[x_1..x_20]

X:=mutableMatrix(R,2,2)
L={1,3,4,5}
x
scan(L,k->X_k=if L#k===1 then 1 else x_k)

    keys E

 blackCheckers = {0,1,3,4,5,2};
NC=infinity
 redCheckers = {0, NC, NC, 4, NC, NC};

E= makeLocalCoordinates [blackCheckers, redCheckers]

peek E
sort keys E
sort keys  E
help select
select({1,2,3,4,4,4,4,4,4,5},k->even(k))
apply(select(sort keys E,k->E#k===VAR),k->x_k)


restart
load ((currentDirectory())|"Test.m2")
load ((currentDirectory())|"Schubert.m2")
myRing(3)
makeRing(3)

value("x")_{1,2}
help String

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

flagType:={2,5,8};
w = {2,8, 3,4,7, 1,5,6};
getStiefelCoordinates(w,flagType)

help Variable
R=makeRing(6,VarName=>symbol K,Characteristic=>7,MonomOrder=>Lex)

makeRing(4)
ring(genericMatrix(R,6,6))


gens R
J=CC[x_{1,1},x_{2,1},x_{1,2},x_{2,2}]
genericMatrix(J,2,2)
genericMatrix(R,5,5)

makeRing=method(Options=>{MonomOrder=>GRevLex,VarName=>x,Characteristic=>0})
makeRing(ZZ):= o -> (n) ->(
	Rfield:=QQ;
	a:=symbol a;
	V:=symbol o.VarName;
	if o.Characteristic !=0 then Rfield = GF(Characteristic,Variable=>a);
	R:=Rfield[V_{1,1}..V_{n,n},MonomialOrder=>o.MonomOrder];
	return(R)	
	)



testRing:=QQ[x,y,z]
F:=x^2+y^2-1
restrictRing(F)
restrictRing(F,MonomOrder=>Lex)
x>y

symbol e
makeRing(11)
help baseName

myFlagType = {2,5,8};
w = {2,8, 3,4,7, 1,5,6};
v = {2,4, 5,7,8};
u = {1,3,5,7, 2,4,6,8};
x = {2,8};

lengthOfPermutation(w)
lengthOfPermutation(v)
lengthOfPermutation(u)
lengthOfPermutation(x)

getDescents(w)
getDescents(v)
getDescents(u)
getDescents(x)


isCondition(w,myFlagType)
isCondition(v,myFlagType)
isCondition(u,myFlagType)
isCondition(x,myFlagType)

