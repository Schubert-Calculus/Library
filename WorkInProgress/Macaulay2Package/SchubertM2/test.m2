
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
secantFlag(List,ZZ):=(F,p)->(
	p=promote(p,QQ);
	return(secantFlag(F,p))
)

F= 

