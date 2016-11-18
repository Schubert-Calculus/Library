restart



load ((currentDirectory())|"Test.m2")
load ((currentDirectory())|"Schubert.m2")


restrictRing:=method(Options=>{MonomOrder=>GRevLex})
restrictRing(RingElement):= o->(f)->(
    print(f);
    print(ring(f));
    newF:=sub(f,coefficientRing(ring f)[support(f),MonomialOrder=>o.MonomOrder]);
    return(newF)    
    )

help MonomialOrder
QQ[x,y,z,MonomialOrder=>Lex]
f=x+y+x*y-x^2
restrictRing(f,MonomOrder=>Lex)

peek ring(f)
peek ring(restrictRing(f))

M=coefficientRing(ring f)[support(f)]
sub(f,M)
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

