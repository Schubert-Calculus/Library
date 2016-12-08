----    Code that Frank is using to understand the Macaulay2 package
restart
load ((currentDirectory())|"Test.m2")


w = {1,3,2,4}
flagType = {2,4}
H=stiefelCoordinates({w},flagType)
F=randomFlag(4)
G=randomFlag(4)
GG=randomFlag(4)
isCondition(w,flagType)

I = ideal(getEquations(H,{{w,F},{w,G},{w,GG}},flagType));
gb I
dim I
