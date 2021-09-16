--Notes for dan.
--It yells at me if my website doesn't have http:// in it
--I need to install in order for documentation examples to actually evaluate
--Example on key:restrictRing was only allowing me two lines. This seems to be due to something disallowing me from assigning names to any more than two things?
--
--
--THINGS TO DO STILL
--check the assertion at the end of stiefel coordinates
--get VarName to work
--make lifting coordinates
--
--Allow osculatingFlag to work over other characteristic zero base fields (e.g. CC or RR)(it does now, as long as the point is given by an element of QQ or RR. I have to figure out how to let the function take a general 'number' as its second argument)
--Code secantFlag 
--Allow secantFlag to work over any field 

newPackage(
  "SchubertIdeals",
  Version => "0.0.1", 
  Date => "December 18, 2020",
  Authors => {
    {Name => "Taylor Brysiewicz", Email => "tbrysiewicz@math.tamu.edu", HomePage => "http://www.math.tamu.edu/~tbrysiewicz"},
     {Name => "Frank Sottile"},
     {Name => "C.J. Bott"}
     {Name => "Nathaniel Welty"}
  },
  HomePage => "<FIX>",
  Headline => "computating ideals of Schubert varieties on flag manifolds",
  DebuggingMode => false
)

export{
  --Options
  "Characteristic",
  "VarName",
  "FieldChoice",

  --Functions
  "isCondition",
  "completePermutation",
  "stiefelCoordinates",
  "randomFlag",
  "osculatingFlag",
  "getEquations"
}


------------------------------------
-- checkFlagType
------------------------------------
-- This checks that the flagType as entered by a user is actually a 
-- flagType; i.e. an increasing sequence of positive integers which
-- is not the trivial flagType (just one number).
------------------------------------
checkFlagType = method()
checkFlagType(List):=(flagType) ->(
--check that the flag is not trivial
	if #flagType <2 then error("This flag manifold is trivial");
--check that each elt of the list is a positive integer
	for s in flagType do(
		if (class(s)=!=ZZ) then error(toString(flagType)|" does not describe a flag manifold since not all elements are integers");
		-- =!= is the opposite of ===, which checks “true” or “false” for classes. == and != don’t work for classes in Macaulay2.
		if s<1 then error(toString(flagType)|" does not describe a flag manifold because not all numbers are greater or equal to one");
		),
--checks that the numbers are strictly increasing (implicitely checks for repeated entries)
	if sort(unique(flagType))!=flagType then error(toString(flagType)|" does not describe a flag manifold because the numbers are not strictly increasing");
)



------------------------------------
-- checkPermutation
------------------------------------
-- This checks that a permutation entered
-- by a user is actually a permutation (potentially partial)
-- i.e. a list of positive integers with no repeats
------------------------------------

checkPermutation = method()
checkPermutation(List):=(w) ->(
	--checks that each elt of w is an integer, and that it is positive.
	for s in w do(
		if (class(s)=!=ZZ) then error(toString(w)|" is not a permutation (not all integers)");
		if s<1 then error(toString(w)|" is not a permutation because not all numbers in it are greater than or equal to one");
		),
	if unique(w)!=w then error(toString(w)|" is not a permutation because a number was repeated");
)


------------------------------------
-- isCondition
------------------------------------
-- This checks that a permutation is an admissable 
-- condition for a given flagType.
-- i.e. the descent set of the permutation is a subset
-- of the 'flagType'-list.
-- Prior to this check, this function
-- checks that the permutation and flagType given
-- are valid as well.
------------------------------------
isCondition = method(TypicalValue=>Boolean)
isCondition(List,List):=(w,flagType) ->(
	--Check w is a permutation and flagType is a flagType
	checkPermutation(w);
	checkFlagType(flagType);

	--Check that the descent set of w is a subset of flagType
	descents:=getDescents(w);
	return(isSubset(descents,flagType))
)




------------------------------------
-- completePermutation
------------------------------------
-- Completes a partial permutation, w
--  to S_n by appending the missing numbers
--  (in order) to the end of w.
------------------------------------
completePermutation = method(TypicalValue=>List)
completePermutation(List,ZZ):=(w,n) ->(
	--Check permutation is valid and that n is larger than any of the elements of w.
	checkPermutation(w);
	if n<max(w) then error("You cannot complete the permutation "|toString(w)|" to S_"|toString(n));
	-- If w is already complete, then just return w.
	if n=max(w) then return(w);

	--append, in order, any missing integers 1...n to w.
	for i from 1 to n do(
		if isSubset({i},w)==false then w=append(w,i);
	),
  return(w)
)



------------------------------------
-- getDescents
------------------------------------
-- Given a (partial)permutation w, return
--  a list of its descents. If w is partial
--  this will first complete w to a permutation
--  on S_{max(w)}.
------------------------------------
getDescents = method(TypicalValue=>List)
getDescents(List):=(w) ->(
	w=completePermutation(w,max(w));
	descents:={};
	for i from 0 to #w-2 do(
		if((w#i)>(w#(i+1))) then descents=append(descents,i+1);
	),
return(descents)
)


------------------------------------
-- notGreaterOrEqual
------------------------------------
-- returns true if the permutation 
--  v is not greater than or equal to w
-- Expects partial permutations of the same size
--  with no descents in their partial descriptions
--  (the permutation they correspond to has at most
--  one descent)
------------------------------------
notGreaterOrEqual = method(TypicalValue=>Boolean)
notGreaterOrEqual(List,List):=(w,v) ->(
	--if any element of w is larger than the corresponding element of v
	--	then we know that v is not greater than or equal to w.
	for i from 0 to #w-1 do(
		if w#i>v#i then return(true)
	),
	--however, if every element of w is smaller or equal to  the corresponding
	--element of v, then we know that v is indeed larger or equal to w.
  return(false)
)




------------------------------------
-- allNotGreaterOrEqual
------------------------------------
-- This function lists all partial permutatations
--	of S_n that are NOT greater than or equal to w.
------------------------------------
allNotGreaterOrEqual = method(TypicalValue=>List)
allNotGreaterOrEqual(List,ZZ):=(w,n) ->(
	--First get a list of all partial permutations.
  allPartialPerms:=subsets(for i from 1 to n list i, #w);
	--Then select all of those that are not greater than or equal to w
  allSmallPerms:=select(allPartialPerms,f:=(p)->notGreaterOrEqual(w,p));
  return(allSmallPerms)       
)





------------------------------------
-- cauchyBinet
------------------------------------
-- This function implements the cauchyBinet formula
-- to find the minor p_v(F^{-1}*H)
-- Input includes F^{-1} =: Finv and
-- hMinors is a hashTable of minors of H which may
-- not include all minors, but perhaps just the relevant
-- ones for Cauchy binet (This is useful for us because
-- this hashTable is precomputed for a particular H and
-- cauchyBinet is called repeatedly for H)
------------------------------------
cauchyBinet=method(TypicalValue=>RingElement)
cauchyBinet(Matrix,HashTable,List,ZZ):=(Finv,hMinors,v,n) ->(
	--Create indexing set for Cauchy-Binet sum
	betas:=subsets(for i from 1 to n list i,#v);
	summands:={};
	--For each elt in the indexing set, multiply the corresponding minors
	-- of F^{-1} and H
	for beta in betas do(
		betaMinus:=for j in beta list j-1;
		vMinus:=for j in v list j-1;
		newSummand:=(determinant(submatrix(Finv,betaMinus,vMinus)))*(hMinors#(beta,v));
		summands=append(summands,newSummand);
	),
	--Add all the summands together and return
  minorOfProduct:=sum(summands);
  return(minorOfProduct)
)    
    




------------------------------------
-- trulyRandom
------------------------------------
-- Macaulay2 creates positive random numbers
-- (in CC, both real & imaginary parts are positive)
-- so this function randomly choses a sign for
-- numbers over RR or QQ.
-- For CC, it multiplies the number by a random power
-- of ii.
------------------------------------
trulyRandom=method()
--For rational/real
trulyRandom(Ring):=(F)->(
	k:=(-1)^(random(ZZ));
	return(k*random(F))
)
--For complex
trulyRandom(InexactFieldFamily):=(F)->(
 	k:=ii^(random(ZZ));
	return(k*random(F))
)




------------------------------------
-- randomFlag
------------------------------------
-- Creates a random flag over a field in the
--  form of a matrix.
------------------------------------
randomFlag=method(TypicalValue=>Matrix,Options=>{FieldChoice=>QQ})
randomFlag(ZZ):=o->(n)->(
	M:=matrix for i from 0 to n-1 list for j from 0 to n-1 list (trulyRandom(o.FieldChoice));
	return(M)
)





------------------------------------
-- osculatingFlag
------------------------------------
-- Creates an osculating flag to a rational
--  curve at a point. 
------------------------------------
osculatingFlag=method(TypicalValue=>Matrix)
osculatingFlag(List,QQ):=(F,p)->(
	--First check that the dimension of the source space is 1 so we have a curve.
	if numgens ring(F#0) > 1 then error "Too many variables in the ring. Doesn't parametrize a curve in affine space";
	--Check that the field choice is appropriate
	if ((coefficientRing(ring(F#0)) === QQ)==false and (coefficientRing(ring(F#0)) === RR)==false and (coefficientRing(ring(F#0)) === CC)==false and (coefficientRing(ring(F#0)) === CC_53)==false and (coefficientRing(ring(F#0)) === RR_53)==false) then error "Ring not over QQ,RR, or CC.";
	--Pull some information regarding the input	
	n:=#F;
	--The first row is the point chosen.
	rows:={F};
	--The subsequent rows are gotten by taking derivatives. Here we create them one by one.
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
	--Output the transpose since our flags are given by column space.
  M:=transpose sub(matrix rows,{(gens ring F#0)#0=>p});
  return(M)
)
osculatingFlag(List,ZZ):=(F,p)->(
	p=promote(p,QQ);
	return(osculatingFlag(F,p))
)




------------------------------------
-- restrictRing
------------------------------------
-- Used to restrict the ring of a polynomial or a matrix.
--  to only the relevant variables. This fixes codimension problems
--  after substitutions are made.
------------------------------------
restrictRing = method(TypicalValue => RingElement, Options => {MonomialOrder=>GRevLex})
restrictRing(RingElement):= o-> (f) ->(
	newF:=sub(f,coefficientRing(ring f)[support(f),MonomialOrder=>o.MonomialOrder]);
	return(newF)    
)
restrictRing(Matrix):= o-> (f) ->(
	newF:=sub(f,coefficientRing(ring f)[support(f),MonomialOrder=>o.MonomialOrder]);
	return(newF)    
)




------------------------------------
-- makeGrassmannianPermutation
------------------------------------
-- From a permutation w on a flag manifold in n-space, produce
--  a permutation with a single descent at k. This is outputted
--  as a partial permutation with no descents in its 'partial 
--  description'.
------------------------------------
makeGrassmannianPermutation = method(TypicalValue=>List)
makeGrassmannianPermutation(List,ZZ,ZZ):=(w,k,n) ->(
	w=completePermutation(w,n);
 	beg:=for i from 0 to k-2 list(w#i);
 	fin:=for i from k to #w-1 list (w#i);
 	return(append(sort(beg),w#(k-1)));
)




------------------------------------
-- lengthOfPermutation
------------------------------------
-- Given a (partial)permutation, outputs the length of the permutation.
------------------------------------
lengthOfPermutation = method(TypicalValue=>ZZ)
lengthOfPermutation(List):=(w) ->(
	len:=0;
	--It is enough to complete w to a permutation on S_{max(w)}
	w=completePermutation(w,max(w));
	--For each elt of w, check the remaining elts to see if they are bigger. 
	-- If so, increment descents by one.
  for i from 0 to #w-1 do(
		for j from i+1 to #w-1 do(
	    if((w#i)>(w#j)) then len=len+1;--tally length for each descent
    ),
	),
return(len)
)



------------------------------------
-- stiefelCoordinates
------------------------------------
-- Produces Stiefel coordinates for one (or two) Schubert conditions on a flagType (or Grassmannian)
------------------------------------
stiefelCoordinates=method(TypicalValue=>Matrix,Options=>{MonomialOrder=>GRevLex,VarName=>"x",Characteristic=>0})
stiefelCoordinates(List,List):=o->(conditions,flagType)->(
	--Check input given
	-- i.e. Check that the flagType is an actual flagType, that the conditions are valid on the flagType,
	-- that we are given one or two non-trivial conditions, and that if we are given two, the flagType is a Grassmannian.
	checkFlagType(flagType);
	if #conditions==0 then error("No conditions given");
	if #conditions>2 then error("Too many conditions given. Maximum:2. Make sure that if you have one condition, it is nested in another list.");
	if #conditions==2 and #flagType>2 then error("You can only give two conditions if the flag manifold is the Grassmannian, not "|toString(flagType));
	for c in conditions do(
		if #c ==0 then error("A condition is trivial");
		if isCondition(c,flagType)==false then error(toString(c)|" is not a condition on "|toString(flagType));
		),

--Pull input given
	n:=last(flagType);
  m:=flagType#(#flagType-2);
	w:=completePermutation(conditions#0,n);


--Perform function
--Create a list of the coordinates that are not a priori 1 or 0 
	E:=select((1,1)..(n,n),p->isSubset({p_0-1},for i from 0 to p_1-1 list n-w#i)==false and p_0-1<(n-w#(p_1-1)));

--Make the ring
	x:=symbol x; a:=symbol a;
	Rfield:=QQ;
	if o.Characteristic !=0 then Rfield = GF(o.Characteristic,Variable=>a);
	R:=Rfield[apply(E,k->x_k)];

--make a matrix of zeros. Put variables in the places that aren't 1's or SouthEast zeros, then put 1's in the pivots
	genMat:=mutableMatrix(R,n,n);
	scan(E,k->genMat_(k_0-1,k_1-1)=x_k);
	scan(w,i->genMat_(n-i,position(w,k->k==i))=1);
------------------------------------------------------
--If there is one Schubert condition given, do this
------------------------------------------------------
	if #conditions==1 then(
		--pull the descents [corresponding to flagType](as we will be able to push zeros to the west up to these marks)
		descents:=join({0},flagType);
		descentFloor:=for i from 0 to n-1 list(max(positions(descents,d->d<=i)));

		--get the biggest space (in the flagType) that the i-th column doesn't belong to
	  for j from 0 to n-1 do(

		--for each column with a pivot in it (all of them)
	  	for J from descents#(descentFloor#j) to j-1 do(
		
		--put zeros to the West up to the descent mark
		  genMat_(n-w#j,J)=0;
		  ),
		),
	),	
------------------------------------------------------
--If there are two Schubert conditions given, do this
------------------------------------------------------
	if #conditions>1 then(
		v:=reverse for i from 0 to m-1 list((completePermutation(conditions#1,n))#i);
    for j from 0 to m-1 do(
			--		assert(v#i-1<n-w#i);
			for i from 0 to v#j-2 do genMat_(i,j)=0;
		),	         
	),
	localMatrix:=restrictRing(new Matrix from genMat_(for i from 0 to m-1 list i),MonomialOrder=>o.MonomialOrder);
	return(localMatrix);
	)





------------------------------------
-- getEquations
------------------------------------
-- Gets equations in Stiefel coordinates for a Schubert variety.
--  Conditions are pairs {(partial)permutation, flag}, but are accepted
--  as singletons as well, in which case we complete the singleton to a
--  pair by choosing random flags.
------------------------------------
getEquations = method(TypicalValue=>List)
getEquations(Matrix,List,List):=(H,conditions,flagType) ->(
	--Check input given
	checkFlagType(flagType);
  n:=last(flagType);
	m:=flagType#(#flagType-2);
	for c in conditions do(
		if #c>2 then error("Remember that conditions need to be pairs: a permutation and a flag. You gave "|toString(c));
		if isCondition(c#0,flagType)==false then error(toString(c#0)|" is not a condition on the flag "| toString(flagType));
	),
	launderedConditions:={};
	for c in conditions do(
		if #c==1 then launderedConditions=append(launderedConditions,{c#0,randomFlag(n)}) else launderedConditions=append(launderedConditions,c);
		if #c==2 then if (numgens(source(c#1)) != n or numgens(target(c#1)) != n) then error("The flag "|toString(c#1)| " is not "|toString(n)|" by "|toString(n));
	),
	conditions=launderedConditions;
	if (numgens(source(H)) < m or numgens(target(H)) != n) then error("Stiefel coordinate matrix is not "|toString(n)|" by something at least "|toString(m));


	--Organize input. Invert flags.
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
  --so here we pull all the possible v that could (and will) occur.
  vCollection:=flatten for p in grassmannianPerms list p#1;
  
  --we populate a hashtable which holds data corresponding to relevant plucker coordinates of H
  hMinors:=new MutableHashTable;
  for v in vCollection do(
		betaList:=subsets(for i from 1 to n list i,#v);
    for beta in betaList do(
	    vMinus:= for c in v list c-1;
	    betaMinus:=for b in beta list b-1;
	    hMinors#(beta,v)=determinant(submatrix(H,betaMinus,vMinus));
    ), 
	),
  equations:={};
  --we now scroll through each grassmannianPermutation
  for w in grassmannianPerms do(
		--and each v which is not greater than or equal to w
		for v in w#1 do(
	    newEquation:=cauchyBinet(flagInverses#(w#2),hMinors,v,n);
	    equations=append(equations,newEquation);
    ),	
	),
  return(equations)
)




beginDocumentation()
multidoc get (currentFileDirectory | "doc.m2")





