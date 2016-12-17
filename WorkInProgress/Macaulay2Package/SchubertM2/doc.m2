Node
  Key
    SchubertIdeals
  Headline
    Computating ideals of Schubert varieties on flag manifolds.
  Description
    Text      
      This package computes ideals defining Schubert varieties on flag manifolds. Such ideals are indexed by collections of
			Schubert conditions on flags. A Schubert condition consists of a permutation along with a flag. The permutation encodes
			intersection conditions with the given flag. A solution to a Schubert problem will describe a flag that satisfies each
      of these conditions.
	--subnodes


--------
Node
  Key
  	isCondition
		(isCondition,List,List)
  Headline
   decides whether or not a permutation corresponds to a Schubert condition for a given flag manifold
  Usage
	 isCondition(w,flagType)
  Inputs
   w:List
			encoding a full or partial permutation.
   flagType:List
   	$\{a_1<a_2<\cdots<a_{s-1}=m<a_{s}=n\}$ encoding a flag manifold.
  Outputs
   b:Boolean
     telling whether or not the permutation $w$ has descents at only the $a_i$.
  Description
    Text
			Check if a full and a partial permutation are Schubert conditions for a particular flag manifold.
    Example
			flagType={1,3,5,8}
			w={1,4,5,2,3,6}
			v={1,6,3,7,2,4,8,5}
			isCondition(w,flagType)
			isCondition(v,flagType)
Node
  Key
  	completePermutation
		(completePermutation,List,ZZ)
  Headline
   completes a partial permutation to a full permutation by appending the missing numbers in ascending order
  Usage
	 completePermutation(w,n)
  Inputs
   w:List
			encoding a partial permutation.
   n:ZZ
   	the symmetric group to complete the permutation to.
  Outputs
   v:List
     a full permutation on $S_n$ which is the unique completion of $w$ to an element of $S_n$ that preserves the descents. 
  Description
    Text
			Complete a permutation to two different symmetric groups.
    Example
			w={1,4,5,2}
			v=completePermutation(w,8)
			p=completePermutation(w,10)
Node
  Key
  	stiefelCoordinates
		VarName
		Characteristic
		(stiefelCoordinates,List,List)
		[stiefelCoordinates,VarName]
		[stiefelCoordinates,MonomialOrder]
		[stiefelCoordinates,Characteristic]
  Headline
   creates Stiefel coordinates with respect either two Grassmannian conditions, or one flag manifold condition
  SeeAlso
   getEquations
  Usage
	 stiefelCoordinates({{1,3,2,4},{1,3,2,4}},{2,4})
  Inputs
   conditions:List
			a list of Schubert conditions on flagType given by either full or partial permutations.
   flagType:List
   	$\{a_1<a_2<\cdots<a_{s-1}=m<a_{s}=n\}$ encoding a flag manifold.
   MonomialOrder => Symbol
			a monomial order for the ring in which the Stiefel coordinates will be created.  	
   VarName => Symbol
			a name for the variable in the ring in which the Stiefel coordinates will be created.
   Characteristic => ZZ
			the characteristic of the ring in which the Stiefel coordinates will be created.
  Outputs
   M:Matrix
     a matrix of Stiefel coordinates
  Description
    Text
			Create Stiefel coordinates for two Schubert conditions on $Gr(2,4)$ or one Schubert condition on the flag manifold ${2,4,6}$
    Example
			w={1,3,2,4}
			M=stiefelCoordinates({w,w},{2,4},MonomialOrder => Lex)
			v={1,4,2,6,3}
			N=stiefelCoordinates({v},{2,4,6}, Characteristic => 101)
Node
  Key
   randomFlag
	 FieldChoice
	 (randomFlag,ZZ)
	 [randomFlag,FieldChoice]
  Headline
  	produces a random full flag in k^n for some field k
  SeeAlso
	 getEquations
   osculatingFlag
  Usage
	 randomFlag(n)
  Inputs
   n:ZZ
			the dimension of the ambient space
   FieldChoice => RingFamily
   	the field k (default value QQ) that the flag is over.
  Outputs
   M:Matrix
    an n by n matrix with random entries in k. Its column space gives a flag in k^n.
  Description
    Text
		  Producing a random flag over QQ, CC, and GF(5) respectively
    Example
			Mq=randomFlag(4)
			Mc=randomFlag(2,FieldChoice=>CC)
			Mgf=randomFlag(7,FieldChoice=>GF(5))
Node
  Key
  	osculatingFlag
		(osculatingFlag,List,QQ)
		(osculatingFlag,List,ZZ)
  Headline
   produces an osculating flag to a curve at a point
  SeeAlso
	 getEquations
   randomFlag
  Usage
	 osculatingFlag(F,p)
  Inputs
   F:List
			a curve given as n univariate polynomials over QQ.
   p:QQ
			a point F(p) on the curve given by F to which the outputted flag will osculate.
  Outputs
   M:Matrix
    an n by n matrix with entries in QQ. Its column space gives a flag in QQ^n which osculates the curve given by F at the point F(p).
  Description
    Text
			Producing an osculating flag at a point of the moment curve in $\mathbb{A}^4$.
    Example
			R=QQ[t]
			F={t,t^2,t^3,t^4}
			F=osculatingFlag(F,3/5)
Node
  Key
  	getEquations
		(getEquations,Matrix,List,List)
  Headline
   gets equations for a Schubert variety
  SeeAlso
   osculatingFlag
	 randomFlag
	 stiefelCoordinates
  Usage
	 getEquations(H,conditions,flagType)
  Inputs
   H:Matrix
			Stiefel coordinate matrix.
   conditions:List
			Schubert conditions on flagType given by pairs:a partial permutation and a flag.
   flagType:List
   	$\{a_1<a_2<\cdots<a_{s-1}=m<a_{s}=n\}$ encoding a flag manifold.
  Outputs
   F:List
     generators for an ideal defining the Schubert variety.
  Description
    Text
			Create equations for an instance of the problem of four lines in $Gr(2,4)$
    Example
			w={1,3,2,4}
			H=stiefelCoordinates({w,w},{2,4},MonomialOrder => Lex)
			flag1=randomFlag(4)
			flag2=randomFlag(4)
			F=getEquations(H,{{w,flag1},{w,flag2}},{2,4})
			I=ideal(F)
			dim(I)
			degree(I)
