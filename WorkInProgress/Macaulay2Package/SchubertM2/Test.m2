
newPackage(
  "SchubertIdealsTest",
  Version => "1.0.0", 
  Date => "Novmeber 17, 2016",
  Authors => {
    {Name => "Taylor Brysiewicz"}
  },
  Headline => "Combuting Ideals for Schubert Varieties",
  DebuggingMode => false
)

export{
--Options
"MonomOrder",
"Characteristic",
"VarName",
--Functions
"restrictRing",
"getDescents",
"isCondition",
"completePermutation",
"lengthOfPermutation",
"makeRing",
"getStiefelCoordinates"
}
--partitionToPermutation
--makeGrassmannianPermutation
----user might get error if monomorder chosen is not ubiquitous for many variables (generic monomial ordeirngs only: lex, grevlex,  etc)
--apply
--scan


---------------------------------------------------------------------------------
----------------------------SCHUBERT IDEALS-(Test)-------------------------------
---------------------------------------------------------------------------------
--  This is for methods that are being tested and developed prior to 
--    committing to the main package file
--
---------------------------------------------------------------------------------





---------------------------------------------------------------------------------
-------------------------------------NOTES---------------------------------------
---------------------------------------------------------------------------------
--  Make sure we are checking all the input (n>k, etc..)
--
---------------------------------------------------------------------------------







---------------------------------------------------------------------------------
-------------------------------CONVENTIONS---------------------------------------
---------------------------------------------------------------------------------
--  flagType is a list {a_1,...,a_s=m,n}={adot,n} with increasing
--    entries. This specifies the type of flag manifold.
--  Example:
--    flagType = (3,6) is the Grassmanian of 3-planes in 6-space
--      here n=6 and m=k=3
--    flagType = (2,3,7) is the manifold of partial flags consisting
--      of a 2-plane in a 3-plane in 7-space. Here n=7,m=3.
---------------------------------------------------------------------------------
--  Schubert conditions are given as partial permutations 
--    for example, w={1,4,6,8,2,9} in flagType={4,6,23}
--  w must have descents only at positions of adot, where
--    where flagType=(adot,n)
---------------------------------------------------------------------------------



---------------------------------------------------------------------------------
----------------------------------METHODS----------------------------------------
---------------------------------------------------------------------------------
--  restrictRing
--     Input:
--          [name=f,dataType=RingElement,mathObject=element of a polynomial ring]
--     Output:
--          [name=newF,dataType=RingElement,mathObject=same element, considered
--           as an element belonging to ring w/o irrelevant variables]
--    Description:
--          Takes a ring element and considers it as an element of a new ring:
--            the same ring w/o irrelevant variables. 
--	      Where irrelevant means that that variable is not in support(f)
---------------------------------------------------------------------------------
--  completePermutation
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--          [name=flagType,dataType=List,mathObject=flagType]
--     Output:
--          [name=w,dataType=List,mathObject=fullPermutation]
--    Description:
--          Takes a partial permutation and completes it by appending the missing
--           numbers in order to the end.
---------------------------------------------------------------------------------
--  getDescents
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--     Output:
--          [name=descents,dataType=List,mathObject=list of descent locations]
--    Description:
--         returns a list of locations of descents for a given permutation
--         
---------------------------------------------------------------------------------
--  isCondition
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--          [name=flagType,dataType=List,mathObject=flagType]
--     Output:
--          boolean
--    Description:
--         decides whether or not a schubert condition is valid for
--         the flagType given
---------------------------------------------------------------------------------
--  lengthOfPermutation
--    Input:
--         [name=w,dataType=List,mathObject=full permutation]
--    Output:
--         [name=len,dataType=integer,mathObject=length of w]
--    Description:
--         returns the length of a permutation
---------------------------------------------------------------------------------
--  makeRing
--     Input:
--          [name=n,dataType=ZZ,mathObject=usually ambient space of flagType]
--     Output:
--          [ring w/ specified characteristic, variable names, & monomial order,
--		also, if a finite field, the field element correpsond to the 
--		symbol 'a']
--     Options:
--	    VarName=>symbol x
--	    Characteristic=>0
--	    MonomOrder=>monomial order
--    Description:
--          Takes the specified data for a ring and returns a ring with variables
--		x_{1,1}..x_{n,n}, of characteristic Characteristic, and monomial
--		order: MonomOrder
---------------------------------------------------------------------------------
--  stiefelCoordinates
--     Input:
--          [name=conditions,
--	     dataType=List,
--	     mathObject=list of 1 or 2 schubert conditions]
--          [name=flagType,
--	     dataType=List,
--	     mathObject=indicates flag manifold]
--     Output:
--          [name=localMatrix,
--	     dataType=Matrix,
--	     mathObject=matrix indicating stiefel coordinates for the situation]
--	    The situation is either (A) one schubert condition for any flag manifold
--			          or(B) two schubert conditions for a Grassmannian
--     Options:
--	    (To be added later) VarName=>symbol x
--	    Characteristic=>0
--	    MonomOrder=>monomial order
--    Description:
--          Takes the specified data for a ring and returns a ring with variables
--		x_{1,1}..x_{n,n}, of characteristic Characteristic, and monomial
--		order: MonomOrder
---------------------------------------------------------------------------------
--  <INSERT METHOD NAME HERE>
--     Input:
--          [name=,dataType=,mathObject=]
--          [name=,dataType=,mathObject=]
--     Output:
--          [name=,dataType=,mathObject=]
--          [name=,dataType=,mathObject=]
--    Description:
--         
---------------------------------------------------------------------------------



---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
----------------------------------CODE----------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------






restrictRing=method(Options=>{MonomOrder=>GRevLex})
---------------------------------------------------------------------------------
--  restrictRing
--     Input:
--          [name=f,dataType=RingElement,mathObject=element of a polynomial ring]
--     Output:
--          [name=newF,dataType=RingElement,mathObject=same element, considered
--           as an element belonging to ring w/o irrelevant variables]
--    Description:
--          Takes a ring element and considers it as an element of a new ring:
--            the same ring w/o irrelevant variables. 
--	      Where irrelevant means that that variable is not in support(f)
--    Options:
--	    MonomOrder: a monomial order for the RESTRICTED RING (if using 
--	      weights this may require the user to anticipate the correct 
--	      number of variables)
--    Notes:
--	    How shall we handle monomialOrderings???? :/ Is there any reasonable
--	      way to induce the monomial order from the order given originally?
--	      That is, is there such a way using M2?
---------------------------------------------------------------------------------
restrictRing(RingElement):= o-> (f) ->(
    newF:=sub(f,coefficientRing(ring f)[support(f),MonomialOrder=>o.MonomOrder]);
    return(newF)    
    )
restrictRing(Matrix):= o-> (f) ->(
    newF:=sub(f,coefficientRing(ring f)[support(f),MonomialOrder=>o.MonomOrder]);
    return(newF)    
    )
---------------------------------------------------------------------------------
--Example:
--	testRing:=QQ[x,y,z,MonomialOrder=>Lex]
--	f:=x^2+y^2-1
--	newF:=restrictRing(f)
--	ring(newF)
--	ring(f)
	--note the monomial order was not preserved (to see this use "peek")
--	newF=restrictRing(f,MonomOrder=>Lex)
--	ring(newF)
--	ring(f)
--	--now the monomial order is Lex
	
---------------------------------------------------------------------------------






completePermutation = method()
---------------------------------------------------------------------------------
--  completePermutation
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--          [name=n,dataType=ZZ,mathObject=ambient space of flag manifold]
--     Output:
--          [name=w,dataType=List,mathObject=fullPermutation]
--    Description:
--          Takes a partial permutation and completes it by appending the missing
--           numbers in order to the end.
---------------------------------------------------------------------------------
completePermutation(List,ZZ):=(w,n) ->(
    for i from 1 to n do(
	if isSubset({i},w)==false then w=append(w,i);
	),
    return(w)
    )
---------------------------------------------------------------------------------
--Example:
	w={2,8,3,4,7,1,5,6}
	u={1,3,5,7,2,4,6,8}
	completePermutation(w,8)
	completePermutation(u,8)
---------------------------------------------------------------------------------









getDescents = method()
---------------------------------------------------------------------------------
--  getDescents
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--     Output:
--          [name=descents,dataType=List,mathObject=list of descent locations]
--    Description:
--         returns a list of locations of descents for a given permutation
--         
---------------------------------------------------------------------------------
getDescents(List):=(w) ->(
    w=completePermutation(w,max(w));
    descents:={};
    for i from 0 to #w-2 do(
	if((w#i)>(w#(i+1))) then descents=append(descents,i+1);
	),
    return(descents)
    )
---------------------------------------------------------------------------------
--Example:
	w={2,8,3,4,7,1,5,6}
	v={2,8}
	getDescents(w)
	getDescents(u)
---------------------------------------------------------------------------------






isCondition = method()
---------------------------------------------------------------------------------
--  isCondition
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--          [name=flagType,dataType=List,mathObject=flagType]
--     Output:
--          boolean
--    Description:
--         decides whether or not a schubert condition is valid for
--         the flagType given
---------------------------------------------------------------------------------
isCondition(List,List):=(w,flagType) ->(
    descents:=getDescents(w);
    return(isSubset(descents,flagType))
    )
---------------------------------------------------------------------------------
--Example:
--	myFlagType = {2,5,8}
--	w = {2,8, 3,4,7, 1,5,6}
--	v = {2,4, 5,7,8}
--	u = {1,3,5,7, 2,4,6,8}
--	x = {2,8}
--	
--	isCondition(w,myFlagType)
--	isCondition(v,myFlagType)
--	isCondition(u,myFlagType)
--	isCondition(x,myFlagType)
---------------------------------------------------------------------------------






lengthOfPermutation = method()
---------------------------------------------------------------------------------
--    Input:
--         [name=w,dataType=List,mathObject=partial or full permutation]
--    Output:
--         [name=len,dataType=integer,mathObject=length of w]
--    Description:
--         returns the length of a permutation
--    Notes:
--         You actually don't need to know the flagType if it is a partial perm
--          in order to compute this. (think about it)
--          if it is a partial perm for a flagType, then "n" must appear in the
--          partial perm. So you know n is the max of w
---------------------------------------------------------------------------------
lengthOfPermutation(List):=(w) ->(
    len:=0;
    w=completePermutation(w,max(w));
    --print("We've completed the permutation to:");
    --print(w);
    for i from 0 to #w-1 do(
	for j from i+1 to #w-1 do(
	    if((w#i)>(w#j)) then len=len+1;--tally length for each descent
	    ),
	),
    return(len)
    )
---------------------------------------------------------------------------------
--Example:
--	w = {2,8, 3,4,7, 1,5,6}
--	v = {2,4, 5,7,8}
--	u = {1,3,5,7, 2,4,6,8}
--	x = {2,8}
--	lengthOfPermutation(w)
--	lengthOfPermutation(v)
--	lengthOfPermutation(u)
--	lengthOfPermutation(x)
---------------------------------------------------------------------------------



makeRing=method(Options=>{MonomOrder=>GRevLex,VarName=>"x",Characteristic=>0})
makeRing(ZZ):= o -> (n) ->(
	Rfield:=QQ;
	a:=symbol a;
	L:=toList(flatten for i from 1 to n list for j from 1 to n list o.VarName_{i,j});
	if o.Characteristic !=0 then Rfield = GF(o.Characteristic,Variable=>a);
	R:=Rfield[L,MonomialOrder=>o.MonomOrder];
	return(R)	
	)










stiefelCoordinates=method(Options=>{MonomOrder=>GRevLex,VarName=>"x",Characteristic=>0})
---------------------------------------------------------------------------------
--  stiefelCoordinates
--     Input:
--          [name=conditions,
--	     dataType=List,
--	     mathObject=list of 1 or 2 schubert conditions]
--          [name=flagType,
--	     dataType=List,
--	     mathObject=indicates flag manifold]
--     Output:
--          [name=localMatrix,
--	     dataType=Matrix,
--	     mathObject=matrix indicating stiefel coordinates for the situation]
--	    The situation is either (A) one schubert condition for any flag manifold
--			          or(B) two schubert conditions for a Grassmannian
--     Options:
--	    (To be added later) VarName=>symbol x
--	    Characteristic=>0
--	    MonomOrder=>monomial order
--    Description:
--          Takes the specified data for a ring and returns a ring with variables
--		x_{1,1}..x_{n,n}, of characteristic Characteristic, and monomial
--		order: MonomOrder
---------------------------------------------------------------------------------
stiefelCoordinates(List,List):=o->(conditions,flagType)->(
--pull, launder, and validate the input
	n:=last(flagType);
        m:=flagType#(#flagType-2);
	w:=completePermutation(conditions#0,n);
	assert(isCondition(w,flagType));
--Create a list of the coordinates that are not a priori 1 or 0 
	E:=select((1,1)..(n,n),p->isSubset({p_0-1},for i from 0 to p_1-1 list n-w#i)==false and p_0-1<(n-w#(p_1-1)));
--Make the ring
	x:=symbol x; a:=symbol a;
	Rfield:=QQ;
	if o.Characteristic !=0 then Rfield = GF(o.Characteristic,Variable=>a);
	R:=Rfield[apply(E,k->x_k)];
--make a matrix of zeros.put variables in the places that aren't 1's or SouthEast zeros, then put 1's in the pivots
	genMat:=mutableMatrix(R,n,n);
	scan(E,k->genMat_(k_0-1,k_1-1)=x_k);
	scan(w,i->genMat_(n-i,position(w,k->k==i))=1);
------------------
--If there is one Schubert condition given, do this
------------------
	if #conditions==1 then(
--pull the descents (as we will be able to push zeros to the west up to these marks)
	   descents:=getDescents(w);
	   descents=join({0},descents);
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
------------------
--If there are two Schubert conditions given, do this
------------------
    	if #conditions>1 then(
	    assert(#conditions==2);
	    assert(#flagType==2);
	    v:=reverse for i from 0 to m-1 list((completePermutation(conditions#1,n))#i);
	    print(v);
    	    for j from 0 to m-1 do(
--		assert(v#i-1<n-w#i);
		for i from 0 to v#j-2 do genMat_(i,j)=0;
		print("Note that we assume "|toString(x_(v#j,j+1))|" is nonzero");
		),	         
	    ),
	localMatrix:=restrictRing(new Matrix from genMat_(for i from 0 to m-1 list i),MonomOrder=>o.MonomOrder);
	return(localMatrix);
	)




