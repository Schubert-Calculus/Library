restart
load ((currentDirectory())|"Test.m2")
load ((currentDirectory())|"Schubert.m2")


R=makeRing(6,VarName=>symbol K,Characteristic=>7,MonomOrder=>Lex)
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

