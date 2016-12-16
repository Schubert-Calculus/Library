----    Code that Frank is using to understand the Macaulay2 package
restart
uninstallPackage "SchubertIdeals"
installPackage "SchubertIdeals"
viewHelp

--   Makes a secant flag
secantFlag=method(TypicalValue=>Matrix)
secantFlag(List,QQ):=(F,p)->(
	if numgens ring(F#0) > 1 then error "Too many variables in the ring. Doesn't parametrize a curve in affine space";
	if (coefficientRing(ring(F#0)) === QQ)==false then error "Ring not over QQ";
	n:=#F;
	rows:={F};
	for i from 1 to n-1 do(
		newRow:={};		
		for f in F do(
			for j from 1 to i do(
				f=diff((gens ring f)#0,f);
			),
		newRow=append(newRow,f);
		),
	rows=append(rows,newRow);
	),
  M:=transpose sub(matrix rows,{(gens ring F#0)#0=>p});
  return(M)
)
osculatingFlag(List,ZZ):=(F,p)->(
	p=promote(p,QQ);
	return(osculatingFlag(F,p))
)







quit;



w = {1,2,4,3,5,6,7}
v = {1,3,5,2,4,6,7}
u = {1,3,4,2,5,6,7}
flagType = {3,7}
numberOfSolutions = 61;
H=stiefelCoordinates({v,v},flagType, Characteristic => 1009)
Eqs = apply( # gens ring H , i -> {w,randomFlag(#w)} );
I = ideal(getEquations(H,Eqs,flagType));
dim I
degree I
Indets = gens ring I
for var in Indets do (
    time G = eliminate(I, delete(var, Indets) );
    print((degree G_0)_0 == numberOfSolutions)
    )


flagType = {2,3,7}
w={1,4,3,2,5,6,7}
u={1,3,2,4,5,6,7}
v={1,2,4,3,5,6,7}
H=stiefelCoordinates({w},flagType, Characteristic => 1009)
Eqs = { {u,randomFlag(#u)},{u,randomFlag(#u)},{u,randomFlag(#u)},{u,randomFlag(#u)}, 
        {v,randomFlag(#v)},{v,randomFlag(#v)},{v,randomFlag(#v)},{v,randomFlag(#v)},
	{v,randomFlag(#v)},{v,randomFlag(#v)},{v,randomFlag(#v)} };
I = ideal(getEquations(H,Eqs,flagType));
dim I
degree I
numberOfSolutions = 420;
Indets = gens ring I
for var in Indets do (
    time G = eliminate(I, delete(var, Indets) );
    print((degree G_0)_0 == numberOfSolutions)
