
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

