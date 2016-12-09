----    Code that Frank is using to understand the Macaulay2 package
restart
load ((currentDirectory())|"Test.m2")

w = {1,3,2,4,5}

flagType = {2,5}
H=stiefelCoordinates({w,w},flagType)
Eqs = apply( # gens ring H , i -> {w,randomFlag(#w)} );

I = ideal(getEquations(H,Eqs,flagType));
gb I
dim I
time G = eliminate(I,apply( # V -1, i->V_i))
(degree G_0)_0
delete(V_0,V)

for x in V 

time G = eliminate(I,apply( # V -1, i->V_i))

G


S = QQ[apply( # V -1, i->V_i)]
gens S
