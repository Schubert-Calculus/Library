newPackage(
  "SchubertIdeals",
  Version => "0.0.1", 
  Date => "November 23, 2022",
  Authors => {
    {Name => "C.J. Bott", 
     Email => "cbott2@tamu.edu"},
    {Name => "Frank Sottile",
     Email=>"sottile@tamu.edu",
     HomePage=>"https://www.math.tamu.edu/~sottile/"}
  },
--  HomePage => "<FIX>",
  Headline => "Package for computing ideals of Schubert subvarieties of flag manifolds",
  Keywords=>{"Schubert Calculus"},
  PackageImports=>{},
  PackageExports=>{},
  DebuggingMode => false
)

export{
  --methods
  "dimToCodim",
  "splitPermutation",
  "typeAStiefelCoords",
  "notGreaterThan",
  "allNotGreaterThan",
  "cauchyBinetCoefficients",
  "typeAGrassmannianSchubertIdeal",
  "typeASchubertIdeal",
  "numSolsA",
  "completePermutation",
  "typeALength",
  "bubbleSort",
  "deltaSwapA",
  "polyRepA",
  "elementarySymmetricIdeal",
  "intA",
  "partialIntA",
  "typeCStiefelCoords",
  "secantFlag",
  "randomSecantFlag",
  "parametrizedSymplecticFlag",
  "symplectify",
  "typeCGrassmannianSchubertIdeal",
  "typeCSchubertIdeal",
  "numSolsC",
  "typeBLength",
  "typeCLength",
  "typeDLength",
  "elementarySymmetricSquaresIdeal",
  "elementarySchurDeterminantC",
  "elementarySchurDeterminantB",
  "signedToNot",
  "signedBubbleSort",
  "deltaSwapC",
  "deltaSwapB",
  "polyRepC",
  "polyRepB",
  "intC",
  "intB",
  "elementarySymmetricDIdeal",
  "signedBubbleSortD",
  "deltaSwapD",
  "elementarySchurDeterminantD",
  "polyRepD",
  "intD",
  "completeSignedPermutation",
  "partialIntC",
  "partialIntB",
  "partialIntD"
}

------------------------------
-- DECLARE VARIABLES --
x := symbol x;
y := symbol y;
t := symbol t;
------------------------------

------------------------------
-- METHODS --
------------------------------

dimToCodim = method()
dimToCodim(List,List) := (flagshape,alpha) -> (
      s := length(flagshape) - 1;
      n := flagshape_(-1);
      breaks := prepend(0,flagshape);
      alphadual := {};
      for b from 1 to s do(
            k := breaks_(b) - breaks_(b-1);
            for i from 1 to k do(
                  alphadual = append(alphadual,n+1-alpha_(breaks_(b-1)+k-i))));
      return(alphadual))

splitPermutation = method()
splitPermutation(List,List) := (flagshape,alpha) -> (
      gaps := {flagshape_(0)};
      for i from 1 to (length(flagshape)-2) do(
            gaps = append(gaps,flagshape_(i)-flagshape_(i-1)));
      splitperm := {};
      copyalpha := alpha;
      for gap in gaps do(
            subalpha := {};
            for i from 0 to (gap-1) do(
                  subalpha = append(subalpha,copyalpha_(0));
                  copyalpha = delete(copyalpha_(0),copyalpha));
            splitperm = append(splitperm,subalpha));
      return(splitperm))

typeAStiefelCoords = method()
typeAStiefelCoords(List,List,Ring) := (flagshape,alpha,K) -> (
      n := flagshape_(-1);
      as := flagshape_(-2);
      S := K[x_(1,1)..x_(n,as)];
      alphalist := splitPermutation(flagshape,alpha);
      firstalpha := alphalist_(0);
      l := length(firstalpha);
-- Define matrix of correct size (and over the correct ring) that we can manipulate for the first subalpha
      M := mutableMatrix(S,n,l);
-- Set leading ones in lxl identity submatrix with rows indexed by alpha
      for i from 1 to l do M_(firstalpha_(i-1)-1,i-1) = 1;
-- Set variables below the leading 1's
      for j from 1 to l do
      for i from firstalpha_(j-1)+1 to n do M_(i-1,j-1) = x_(i,j);
-- Set to 0 all entries above and to the left of leading 1's
      for i from 1 to l do
      for j from 1 to i-1 do M_(firstalpha_(i-1)-1,j-1) = 0;
-- Make matrix non-mutable
      M = matrix M;
-- Remove firstalpha from alphalist
      alphalist = delete(firstalpha,alphalist);
-- Now repeat and concatenate the matrices
      indexshift := length(firstalpha);
      for subalpha in alphalist do(
            l = length(subalpha);
            N := mutableMatrix(S,n,l);
            for i from 1 to l do N_(subalpha_(i-1)-1,i-1) = 1;
            for j from 1 to l do
                  for i from subalpha_(j-1)+1 to n do N_(i-1,j-1) = x_(i,j+indexshift);
            for i from 1 to l do
                  for j from 1 to i-1 do N_(subalpha_(i-1)-1,j-1) = 0;
            N = matrix N;
            M = M | N;
            indexshift = indexshift + l);
      M = mutableMatrix M;
      for i from 1 to as do(
            for j from i to as-1 do(
                  M_(alpha_(i-1)-1,j) = 0));
      M = matrix M;
-- Create a new ring with variables only those that show up in the matrix M
      R := K[support M];
-- Make it so that M is a matrix over the new ring
      M = sub(M,R);
-- Return Stiefel coordinates and new ring
      return({M, R}))
     
notGreaterThan = method(TypicalValue=>Boolean)
notGreaterThan(List,List) := (beta,alpha) -> (
      NotGreaterThan := false;
      for i from 1 to length(beta) do
            if beta_(i-1) < alpha_(i-1) then NotGreaterThan = true;
      return(NotGreaterThan))
      
allNotGreaterThan = method()
allNotGreaterThan(List,ZZ) := (alpha, n) -> (
      L := {};
      for beta in subsets(splice {1..n},length(alpha)) do
            if notGreaterThan(beta,alpha) then L = append(L,beta);
      return(L))

cauchyBinetCoefficients = method()
cauchyBinetCoefficients(List,List,Matrix,Ring) := (grassmannianshape,betas,F,K) -> (
      k := grassmannianshape_(0);
      n := grassmannianshape_(1);
      Finv := inverse F;
      M := mutableMatrix(K,length(betas),binomial(n,k));
      subs := subsets(splice {1..n},k);
      kOnes := splice{k:1};
      for i from 0 to length(betas)-1 do(
            for j from 0 to binomial(n,k)-1 do(
                  M_(i,j) = det(submatrix(Finv,betas_(i)-kOnes,subs_(j)-kOnes))));
      return(matrix M))

typeASchubertIdeal2 = method()
----- NOTE: There should be m alphas and m-1 flags (first flag will be assumed to be the identity and not given as input)
----- NOTE: The flags should be general and the alpha's codimensions should add up to k(n-k) to give an actual Schubert problem
typeASchubertIdeal2(List,List,List,Ring) := (flagshape,alphas,flags,K) -> (
      n := last(flagshape);
      q := length(flags);
      subspaces := delete(n,flagshape);
      bigcoords = (typeAStiefelCoords(flagshape,alphas_(0),K))_(0);
      bigring := (typeAStiefelCoords(flagshape,alphas_(0),K))_(1);
      eqns := ideal(0_bigring);
      for a in subspaces do(
           coords := submatrix(bigcoords,{0..(a-1)});
	   PY = exteriorPower(a,coords);
           conds := {sort(take(alphas_(0),a))};
           for i from 1 to q do(
                conds = append(conds,sort(take(alphas_(i),a))));
           for i from 1 to length(conds)-1 do( 
                 eqns = eqns + sub(ideal(cauchyBinetCoefficients({a,n},allNotGreaterThan(conds_(i),n),flags_(i-1),K)*PY),bigring)));
      return(eqns))

numSolsA = method()
numSolsA(List,List,List,Ring) := (flagshape,alphas,flags,K) -> (
      I := typeASchubertIdeal(flagshape,alphas,flags,K);
      return (dim I, degree I))

completePermutation = method(TypicalValue=>List)
completePermutation(List,ZZ):=(w,n) ->(
	for i from 1 to n do(
		if isSubset({i},w)==false then w=append(w,i));
        return(w))

typeALength = method()
typeALength(List,ZZ) := (w,n) -> (
      wcomp := completePermutation(w,n);
      count := 0;
      for i from 1 to n do
            for j from i+1 to n do
                  if wcomp_(i-1) > wcomp_(j-1) then count = count+1;
      return(count))
      
bubbleSort = method()
bubbleSort(List) := (L) -> (
      n := length(L);
      sorted := reverse(sort(L));
      swaps := {};
      while (L != sorted) do(
            for i from 0 to (n-2) do(
                  if L_(i) < L_(i+1) then(
                        swaps = prepend(i,swaps);
                        L = switch(i,i+1,L);
                        break)));
      return(swaps))

deltaSwapA = method()
deltaSwapA(Thing,Ring,ZZ) := (f,R,k) -> (
      ringvars := gens R;
      return sub((f-sub(f,{ringvars_(k)=>ringvars_(k+1),ringvars_(k+1)=>ringvars_(k)}))/(ringvars_(k)-ringvars_(k+1)),R))
      
polyRepA = method();
polyRepA(List,Ring) := (w,R) -> (
      ringvars := gens R;
      n := length(ringvars);
      pointclass := 1;
      for i from 1 to (n-1) do(
            pointclass = pointclass*(ringvars_(i-1))^(n-i));
      polyrep := pointclass;
      for i in w do(
            polyrep = deltaSwapA(polyrep,R,i));
      return(polyrep))

elementarySymmetricIdeal = method()
elementarySymmetricIdeal(ZZ) := (n) -> (
      R := QQ[y_(1)..y_(n)][t];
      f :=1_R;
      for i from 1 to n do(
      f = f*(y_(i)+t));
      coeffs := (coefficients (f-t^n))_(1);
      S := QQ[y_(1)..y_(n)];
      I := sub(ideal(coeffs),S);
      return(S,I))
      
intA = method()
intA(List,Ring,Ideal) := (alphas,S,I) -> (
      f := 1_S;
      for alpha in alphas do(
            f = f*polyRepA(bubbleSort(alpha),S));
      f = f % I;
      return (((coefficients f)_(1))_(0))_(0))
      
-- flagType a list of the form {a_1,a_2,...,a_s,n}
partialIntA = method()
partialIntA(List,List,Ring,Ideal) := (flagType,alphas,S,I) -> (
      l := length(flagType);
      n := flagType_(-1);
      newAlphas := {};
      for alpha in alphas do(
            newAlpha := completePermutation(alpha,n);
            newAlphas = append(newAlphas,newAlpha));
      dualClass := {};
      for k from 1 to (l-1) do(
            for j from (flagType_(-(k+1)) + 1) to flagType_(-k) do(
	          dualClass = prepend(j,dualClass)));
      for i from 1 to flagType_(0) do(
            dualClass = prepend(i,dualClass));
      newAlphas = append(newAlphas,dualClass);
      return(intA(newAlphas,S,I)))
      
typeCStiefelCoords = method()
typeCStiefelCoords(List,List,Ring) := (flagshape,alpha,K) -> (
      n := flagshape_(-1);
      as := flagshape_(-2);
      S := K[x_(1,1)..x_(n,as)];
      alphalist := splitPermutation(flagshape,alpha);
      firstalpha := alphalist_(0);
      l := length(firstalpha);
-- Define matrix of correct size (and over the correct ring) that we can manipulate for the first subalpha
      M := mutableMatrix(S,n,l);
-- Set leading ones in lxl identity submatrix with rows indexed by alpha
      for i from 1 to l do M_(firstalpha_(i-1)-1,i-1) = 1;
-- Set variables below the leading 1's
      for j from 1 to l do
      for i from firstalpha_(j-1)+1 to n do M_(i-1,j-1) = x_(i,j);
-- Set to 0 all entries above and to the left of leading 1's
      for i from 1 to l do
      for j from 1 to i-1 do M_(firstalpha_(i-1)-1,j-1) = 0;
-- Make matrix non-mutable
      M = matrix M;
-- Remove firstalpha from alphalist
      alphalist = delete(firstalpha,alphalist);
-- Now repeat and concatenate the matrices
      indexshift := length(firstalpha);
      for subalpha in alphalist do(
            l = length(subalpha);
            N := mutableMatrix(S,n,l);
            for i from 1 to l do N_(subalpha_(i-1)-1,i-1) = 1;
            for j from 1 to l do
                  for i from subalpha_(j-1)+1 to n do N_(i-1,j-1) = x_(i,j+indexshift);
            for i from 1 to l do
                  for j from 1 to i-1 do N_(subalpha_(i-1)-1,j-1) = 0;
            N = matrix N;
            M = M | N;
            indexshift = indexshift + l);
      M = mutableMatrix M;
      for i from 1 to as do(
            for j from i to as-1 do(
                  M_(alpha_(i-1)-1,j) = 0));
      M = matrix M;
-- Create a new ring with variables only those that show up in the matrix M
      R := K[support M];
-- Make it so that M is a matrix over the new ring
      M = sub(M,R);
-- Create the symplectic form J
     J := mutableMatrix(R,n,n);
     halfn := sub(n/2,ZZ);
     for i from 1 to halfn do J_(n-i,i-1) = 1;
     for j from halfn+1 to n do J_(n-j,j-1) = -1;
     J = matrix J;
-- Create ideal of symplectic relations
     rels := ideal(0_R);
     for i from 1 to as do 
     for j from i to as do rels = rels + (transpose(submatrix(M,{i-1}))*J*submatrix(M,{j-1}))_(0,0);
-- Return Stiefel coordinates and new ring, along with the ideal of relations among the variables and the dimension of that ideal
     {M, R, rels, dim(rels)})
     
secantFlag = method()
secantFlag(List,Ring) := (L,R) -> (
      n := length(L);
      secantflag := mutableMatrix(R,n,n);
      for i from 1 to n do
            for j from 1 to n do secantflag_(i-1,j-1) = L_(j-1)^i;
      secantflag = matrix secantflag;
      return(secantflag))

randomSecantFlag = method()
randomSecantFlag(ZZ,Ring) := (n,R) -> (
      L := {};
      for i from 1 to n do
            L = append(L,random(R));
      return(secantFlag(L,R)))

-- Osculating Flags
parametrizedSymplecticFlag = method()
parametrizedSymplecticFlag(QQ, ZZ) := (t, n) -> (
      F := mutableMatrix(QQ,n,n);
      for i from 0 to n-1 do F_(i,0) = t^(i)/(i!);
            for j from 1 to n-1 do 
                  for k from j to n-1 do
                        F_(k,j) = F_(k-1,j-1);
      for l from sub(n/2,ZZ) to n-1 do if odd l then
            for m from 0 to n-1 do
                  F_(l,m) = -1*F_(l,m);
      F = matrix F;
      return F)
    
symplectify = method()
symplectify(Matrix) := (M) -> (
      n := numgens target M;
      Mnew := mutableMatrix M;
-- Make anti-upper triangular
      for i from 1 to n do(
            Mnew_(i-1,n-i) = 1;
            for j from i to (n-1) do(
                  Mnew_(j,n-i) = 0));
-- f_i and f_(n-i) are "orthogonal" under skew-symmetric bilinear form
      for i from 0 to (sub(n/2,ZZ)-2) do Mnew_(n-i-2,i) = (-1)*Mnew_(i,n-i-2);
-- Create the symplectic form J
      J := mutableMatrix(QQ,n,n);
      halfn := sub(n/2,ZZ);
      for i from 1 to halfn do J_(n-i,i-1) = 1;
      for j from halfn+1 to n do J_(n-j,j-1) = -1;
-- Make 1st half of columns symplectic via J
      for j from 0 to (sub(n/2,ZZ)-2) do(
            r := sub(n/2,ZZ)-2-j;
            for i from 0 to (sub(n/2,ZZ)-r-2) do(
                  s := sub(n/2,ZZ)-1-i;
	          Mnew_(s,r) = Mnew_(s,r) + (transpose(submatrix(Mnew,{r}))*J*submatrix(Mnew,{s}))_(0,0)));
      Mnew = matrix Mnew;
      return Mnew)

typeCGrassmannianSchubertIdeal = method()
typeCGrassmannianSchubertIdeal(List,List,List,Ring) := (grassmannianshape,alphas,flags,K) -> (
      k := grassmannianshape_(0);
      n := grassmannianshape_(1);
      coords := typeCStiefelCoords(grassmannianshape,alphas_(0),K);
      R := coords_(1);
      I := coords_(2);
      PY := exteriorPower(k,coords_(0));
      for i from 1 to length(alphas)-1 do 
            I = I + ideal(cauchyBinetCoefficients(grassmannianshape,allNotGreaterThan(alphas_(i),n),flags_(i-1),K)*PY);
      return(I))
      
typeCSchubertIdeal = method()
typeCSchubertIdeal(List,List,List,Ring) := (flagshape,conditions,flags,K) -> (
      n := last(flagshape);
      s := length(flags);
      subspaces := delete(n,flagshape);
      bigRing := (typeCStiefelCoords(flagshape,conditions#0,K))#1;
      eqns := ideal(0_bigRing);
      for a in subspaces do(
           conds := {take(conditions#0,a)};
           for i from 1 to s do(
                conds = append(conds,sort(take(conditions#i,a))));
           eqns = eqns + sub(typeCGrassmannianSchubertIdeal({a,n},conds,flags,K),bigRing));
      return(eqns))
      
numSolsC = method()
numSolsC(List,List,List,Ring) := (flagshape,conditions,flags,K) -> (
      I := typeCSchubertIdeal(flagshape,conditions,flags,K);
      return (dim I, degree I))

typeBLength = method()
typeBLength(List) := (w) -> (
      n := length(w);
      count := 0;
      for i from 1 to n do
            for j from i+1 to n do
                  if w_(i-1) > w_(j-1) then count = count+1;
      for i from 1 to n do
            for j from i to n do
                  if w_(i-1) + w_(j-1) > 2*n+2 then count = count+1;
      return(count))

typeCLength = method()
typeCLength(List) := (w) -> (
      n := length(w);
      count := 0;
      for i from 1 to n do
            for j from i+1 to n do
                  if w_(i-1) > w_(j-1) then count = count+1;
      for i from 1 to n do
            for j from i to n do
                  if w_(i-1) + w_(j-1) > 2*n+1 then count = count+1;
      return(count))

typeDLength = method()
typeDLength(List) := (w) -> (
      n := length(w);
      count := 0;
      for i from 1 to n do
            for j from i+1 to n do
                  if w_(i-1) > w_(j-1) then count = count+1;
      for i from 1 to n do
            for j from i+1 to n do
                  if w_(i-1) + w_(j-1) > 2*n+1 then count = count+1;
      return(count))

elementarySymmetricSquaresIdeal = method()
elementarySymmetricSquaresIdeal(ZZ) := (n) -> (
      R := QQ[y_(1)..y_(n)][t];
      f := 1_R;
      for i from 1 to n do(
            f = f*(y_(i)^2+t));
      coeffs := (coefficients (f-t^n))_(1);
      S := QQ[y_(1)..y_(n)];
      I := sub(ideal(coeffs),S);
      return(S,I,S/I))
      
elementarySchurDeterminantC = method()
elementarySchurDeterminantC(List,ZZ) := (lambda,n) -> (
      Rt := QQ[y_(1)..y_(n)][t];
      f := 1_(Rt);
      for i from 1 to n do(
            f = f*(y_(i)+t));
      elempolys := ((coefficients (f-t^n))_(1))_(0);
      S := QQ[y_(1)..y_(n)];
      fixedElemPolys := {};
      for i from 1 to n do fixedElemPolys = append(fixedElemPolys,sub(elempolys_(i-1),S));
      M := mutableMatrix(S,n,n);
      for i from 1 to n do(
            for j from 1 to n do(
                  if (lambda_(i-1)+j-i) == 0 then M_(i-1,j-1) = 1;
                  if ((lambda_(i-1)+j-i) > 0 and (lambda_(i-1)+j-i) <= n) then M_(i-1,j-1) = fixedElemPolys_(lambda_(i-1)+j-i-1)));
      return determinant(matrix M))

elementarySchurDeterminantB = method()
elementarySchurDeterminantB(List,ZZ) := (lambda,n) -> (
      Rt := QQ[y_(1)..y_(n)][t];
      f := 1_(Rt);
      for i from 1 to n do(
            f = f*(y_(i)+t));
      elempolys := ((coefficients (f-t^n))_(1))_(0);
      S := QQ[y_(1)..y_(n)];
      fixedElemPolys := {};
      for i from 1 to n do fixedElemPolys = append(fixedElemPolys,(1/2)*(sub(elempolys_(i-1),S)));
      M := mutableMatrix(S,n,n);
      for i from 1 to n do(
            for j from 1 to n do(
                  if (lambda_(i-1)+j-i) == 0 then M_(i-1,j-1) = 1;
                  if ((lambda_(i-1)+j-i) > 0 and (lambda_(i-1)+j-i) <= n) then M_(i-1,j-1) = fixedElemPolys_(lambda_(i-1)+j-i-1)));
      return determinant(matrix M))

signedToNot = method()
signedToNot(List) := (perm) -> (
      n := length(perm);
      wnew := {};
      for i from 1 to n do(
            if perm_(i-1) > 0 then wnew = append(wnew,perm_(i-1));
	    if perm_(i-1) < 0 then wnew = append(wnew,2*n+1+perm_(i-1)));
      return wnew)
      
signedBubbleSort = method()
signedBubbleSort(List) := (L) -> (
      n := length(L);
      eventual := {};
      for i from 1 to n do(
            eventual = append(eventual,2*n+1-i));
      swaps := {};
      while (L != eventual) do(
            if L == reverse(sort(L)) then(
	          smallest := L_(-1);
	          L = drop(L,-1);
		  L = append(L,2*n+1-smallest);
		  swaps = prepend(n-1,swaps));
            for i from 0 to (n-2) do(
                  if L_(i) < L_(i+1) then(
                        swaps = prepend(i,swaps);
                        L = switch(i,i+1,L);
                        break)));
      return(swaps))

deltaSwapC = method()
deltaSwapC(Thing,Ring) := (f,R) -> (
      ringVars := gens R;
      return sub((f-sub(f,{ringVars_(-1)=>(-1)*ringVars_(-1)}))/(2*ringVars_(-1)),R))
      
deltaSwapB = method()
deltaSwapB(Thing,Ring) := (f,R) -> (
      ringVars := gens R;
      return sub((f-sub(f,{ringVars_(-1)=>(-1)*ringVars_(-1)}))/(ringVars_(-1)),R))

polyRepC = method()
polyRepC(List,Ring) := (w,R) -> (
      ringVars := gens R;
      n := length(ringVars);
      pointclass := 1;
      for i from 1 to (n-1) do(
            pointclass = pointclass*(ringVars_(i-1))^(n-i));
      lambda := {};
      for i from 1 to n do(
	    lambda = prepend(i,lambda));
      delta := sub(elementarySchurDeterminantC(lambda,n),R);
      polyrep := pointclass*delta;
      for i in w do(
	    if (i != n-1) then(
                  polyrep = deltaSwapA(polyrep,R,i));
            if (i == n-1) then(
		  polyrep = deltaSwapC(polyrep,R)));
      return(polyrep))
      
polyRepB = method()
polyRepB(List,Ring) := (w,R) -> (
      ringVars := gens R;
      n := length(ringVars);
      pointclass := 1;
      for i from 1 to (n-1) do(
            pointclass = pointclass*(ringVars_(i-1))^(n-i));
      lambda := {};
      for i from 1 to n do(
	    lambda = prepend(i,lambda));
      delta := sub(elementarySchurDeterminantB(lambda,n),R);
      polyrep := pointclass*delta;
      for i in w do(
	    if (i != n-1) then(
                  polyrep = deltaSwapA(polyrep,R,i));
            if (i == n-1) then(
		  polyrep = deltaSwapB(polyrep,R)));
      return(polyrep))

intC = method()
intC(List,Ring,Ideal) := (alphas,S,I) -> (
      f := 1_S;
      for alpha in alphas do(
            f = f*polyRepC(signedBubbleSort(signedToNot(alpha)),S));
      f = f % I;
      return (((coefficients f)_(1))_(0))_(0))

intB = method()
intB(List,Ring,Ideal) := (alphas,S,I) -> (
      f := 1_S;
      for alpha in alphas do(
            f = f*polyRepB(signedBubbleSort(signedToNot(alpha)),S));
      f = f % I;
      return (((coefficients f)_(1))_(0))_(0))

elementarySymmetricDIdeal = method()
elementarySymmetricDIdeal(ZZ) := (n) -> (
      Rt := QQ[y_(1)..y_(n)][t];
      f := 1_(Rt);
      squareProd := 1_(Rt);
      prod := 1_(Rt);
      for i from 1 to n do(
            f = f*(y_(i)^2+t);
	    squareProd = squareProd*((y_(i))^2);
	    prod = prod*(y_(i)));
      coeffs := (coefficients (f-t^n-squareProd))_(1);
      S := QQ[y_(1)..y_(n)];
      I := sub(ideal(coeffs,prod),S);
      return(S,I,S/I))

signedBubbleSortD = method()
signedBubbleSortD(List) := (L) -> (
      n := length(L);
      eventual := {};
      for i from 1 to (n-1) do(
            eventual = append(eventual,2*n+1-i));
      if (n % 2 == 0) then eventual = append(eventual,n+1);
      if (n % 2 != 0) then eventual = append(eventual,n);
      swaps := {};
      while (L != eventual) do(
            if L == reverse(sort(L)) then(
	          smallest := L_(-1);
		  nextSmallest := L_(-2);
	          L = drop(L,-1);
		  L = drop(L,-1);
		  L = append(L,2*n+1-smallest);
		  L = append(L,2*n+1-nextSmallest);
		  swaps = prepend(n-1,swaps));
            for i from 0 to (n-2) do(
                  if L_(i) < L_(i+1) then(
                        swaps = prepend(i,swaps);
                        L = switch(i,i+1,L);
                        break)));
      return(swaps))

deltaSwapD = method()
deltaSwapD(Thing,Ring) := (f,R) -> (
      ringVars := gens R;
      return sub((f-sub(f,{ringVars_(-2)=>(-1)*ringVars_(-1),ringVars_(-1)=>(-1)*ringVars_(-2)}))/(ringVars_(-2)+ringVars_(-1)),R))    
      
elementarySchurDeterminantD = method()
elementarySchurDeterminantD(List,ZZ) := (lambda,n) -> (
      Rt := QQ[y_(1)..y_(n)][t];
      f := 1_(Rt);
      for i from 1 to n do(
            f = f*(y_(i)+t));
      elempolys := ((coefficients (f-t^n))_(1))_(0);
      S := QQ[y_(1)..y_(n)];
      fixedElemPolys := {};
      for i from 1 to n do fixedElemPolys = append(fixedElemPolys,(1/2)*(sub(elempolys_(i-1),S)));
      M := mutableMatrix(S,n-1,n-1);
      for i from 1 to (n-1) do(
            for j from 1 to (n-1) do(
                  if (lambda_(i-1)+j-i) == 0 then M_(i-1,j-1) = 1;
                  if ((lambda_(i-1)+j-i) > 0 and (lambda_(i-1)+j-i) <= n) then M_(i-1,j-1) = fixedElemPolys_(lambda_(i-1)+j-i-1)));
      return determinant(matrix M))      
      
polyRepD = method()
polyRepD(List,Ring) := (w,R) -> (
      ringVars := gens R;
      n := length(ringVars);
      pointclass := 1;
      for i from 1 to (n-1) do(
            pointclass = pointclass*(ringVars_(i-1))^(n-i));
      lambda := {};
      for i from 1 to (n-1) do(
	    lambda = prepend(i,lambda));
      delta := sub(elementarySchurDeterminantD(lambda,n),R);
      polyrep := pointclass*delta;
      for i in w do(
	    if (i != n-1) then(
                  polyrep = deltaSwapA(polyrep,R,i));
            if (i == n-1) then(
		  polyrep = deltaSwapD(polyrep,R)));
      return(polyrep))
  
intD = method()
intD(List,Ring,Ideal) := (alphas,S,I) -> (
      f := 1_S;
      for alpha in alphas do(
            f = f*polyRepD(signedBubbleSortD(signedToNot(alpha)),S));
      f = f % I;
      return (((coefficients f)_(1))_(0))_(0))

---------------------------- PARTIAL FLAG SCHUBERT COMPUTATIONS ------------------------------------

completeSignedPermutation = method()
completeSignedPermutation(List,ZZ) := (w,n) -> (
      wnew := w;
      for i from 1 to n do(
		if (isSubset({i},wnew)==false and isSubset({-i},wnew)==false) then wnew=append(wnew,i));
      return(wnew))

partialIntC = method()
partialIntC(List,List,Ring,Ideal) := (flagType,alphas,S,I) -> (
      l := length(flagType);
      n := flagType_(-1);
      newAlphas := {};
      for alpha in alphas do(
            newAlpha := completeSignedPermutation(alpha,n);
            newAlphas = append(newAlphas,newAlpha));
      dualClass := {};
      for k from 2 to (l-1) do(
            for j from (flagType_(-(k+1)) + 1) to flagType_(-k) do(
	          dualClass = prepend(j,dualClass)));
      for i from 1 to flagType_(0) do(
            dualClass = prepend(i,dualClass));
      for i from 1 to (n-flagType_(-2)) do(
            dualClass = append(dualClass,-i));
      newAlphas = append(newAlphas,dualClass);
      return(intC(newAlphas,S,I)))
      
partialIntB = method()
partialIntB(List,List,Ring,Ideal) := (flagType,alphas,S,I) -> (
      l := length(flagType);
      n := flagType_(-1);
      newAlphas := {};
      for alpha in alphas do(
            newAlpha := completeSignedPermutation(alpha,n);
            newAlphas = append(newAlphas,newAlpha));
      dualClass := {};
      for k from 2 to (l-1) do(
            for j from (flagType_(-(k+1)) + 1) to flagType_(-k) do(
	          dualClass = prepend(j,dualClass)));
      for i from 1 to flagType_(0) do(
            dualClass = prepend(i,dualClass));
      for i from 1 to (n-flagType_(-2)) do(
            dualClass = append(dualClass,-i));
      newAlphas = append(newAlphas,dualClass);
      return(intB(newAlphas,S,I)))
      
partialIntD = method()
partialIntD(List,List,Ring,Ideal) := (flagType,alphas,S,I) -> (
      l := length(flagType);
      n := flagType_(-1);
      newAlphas := {};
      for alpha in alphas do(
            newAlpha := completeSignedPermutation(alpha,n);
            newAlphas = append(newAlphas,newAlpha));
      dualClass := {};
      for k from 2 to (l-1) do(
            for j from (flagType_(-(k+1)) + 1) to flagType_(-k) do(
	          dualClass = prepend(j,dualClass)));
      for i from 1 to flagType_(0) do(
            dualClass = prepend(i,dualClass));
      for i from 1 to (n-flagType_(-2)-1) do(
            dualClass = append(dualClass,-i));
      if (n-flagType_(-2) % 2 == 0) then dualClass = append(dualClass,n-flagType_(-2));
      if (n-flagType_(-2) % 2 != 0) then dualClass = append(dualClass,flagType_(-2)-n);
      newAlphas = append(newAlphas,dualClass);
      return(intC(newAlphas,S,I)))
