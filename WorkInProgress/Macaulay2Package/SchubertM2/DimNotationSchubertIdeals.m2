-- THIS CODE WORKS, BUT USES THE DIMENSION CONVENTIONS WE DON'T WANT IN OUR FINAL PACKAGE
-- I'm keeping this to remember the way I used to do things for comparison purposes

------------------------------------
-- typeAStiefelCoords
------------------------------------
-- Computes Stiefel Coordinates for a Type A Flag Variety (including Grassmannians as a special case)
-- Inputs: k, the dimension of the largest proper subspace in our flag variety (if we want 2 planes in 4 planes in 6 space, k = 4)
--            (do I need to specify the other subspaces instead, or is this enough? If no change, how do I really know based off of
--             alpha which flag variety I'm working in? For example, if k = 4, n = 6, and alpha = {1,2,3,4}, how would I know whether
--             I am in 2 planes in 4 planes in 6 space vs just 4 planes in 6 space, since there are no descents? This shouldn't affect
--             any of the functionality of my code below, but I was just wondering.)
--         n, dimension of the ambient affine space (if we want 2 planes in 4 planes in 6 space, n = 6)
--         alpha, a k element subset of {1,...,n} (descents of alpha imply which flag variety we're working in: 
--                if we want 2 planes in 4 planes in 6 space, alpha_1 < alpha_2 and alpha_3 < alpha_4, but perhaps alpha_2 > alpha_3)
--         K, coefficient ring (for example QQ)
-- Outputs: M, the matrix of Stiefel coordinates
--          R, the ring of variables used in M (right now, actually more variables than that - can fix?)
           
typeAStiefelCoords = method()
typeAStiefelCoords(ZZ,ZZ,List,Ring) := (k,n,alpha,K) -> (
-- Define ring of variables
     S = K[y_(1,1)..y_(n,k)];
-- Define matrix of correct size (and over the correct ring) that we can manipulate
     M = mutableMatrix(S,n,k);
-- Set leading ones in kxk identity submatrix with rows indexed by alpha
     for i from 1 to k do M_(alpha_(i-1)-1,i-1) = 1;
-- Set variables above the leading 1's
     for j from 1 to k do
     for i from 1 to alpha_(j-1)-1 do M_(i-1,j-1) = y_(i,j);
-- Set to 0 all entries below and to the right of leading 1's
     for i from 1 to k do
     for j from i+1 to k do M_(alpha_(i-1)-1,j-1) = 0;
-- Make matrix non-mutable
     M = matrix M;
-- Create a new ring with variables only those that show up in the matrix M
     R = K[support M];
-- Make it so that M is a matrix over the new ring
     M = sub(M,R);
-- Return Stiefel coordinates and new ring
     {M, R})
     
----- NOTE: "exteriorPower(k,M)" will compute the Plucker vector for us -----
----- NOTE: "subsets({1..n},k)" will compute all k element subsets of {1,...,n} for us, 
-----             IN THE SAME ORDERING as the Plucker vector from "exteriorPower" above -----
     
     
     
notLessThan = method(TypicalValue=>Boolean)
notLessThan(List,List) := (beta,alpha) -> (
      NotLessThan = false;
      for i from 1 to length(beta) do
      if beta_(i-1) > alpha_(i-1) then NotLessThan = true;
      return(NotLessThan))
      
allNotLessThan = method()
allNotLessThan(List,ZZ) := (alpha, n) -> (
      L = {};
      for beta in subsets(splice {1..n},length(alpha)) do
      if notLessThan(beta,alpha) then L = append(L,beta);
      return(L))
      
----- NOTE: Need to adjust so that field isn't always QQ for cauchyBinet below
cauchyBinet = method()
cauchyBinet(ZZ,ZZ,Matrix,List) := (k,n,F,L) -> (
      Finv = inverse F;
      M = mutableMatrix(QQ,length(L),binomial(n,k));
      subs = subsets(splice {1..n},k);
      kOnes = splice{k:1};
      for i from 0 to length(L)-1 do
      for j from 0 to binomial(n,k)-1 do
      M_(i,j) = det(submatrix(Finv,L_(i)-kOnes,subs_(j)-kOnes));
      return(matrix M))
      
schubertIdeal = method()
----- NOTE: There should be m alphas and m-1 flags (first flag will be assumed to be the identity and not given as input)
----- NOTE: The flags should be general and the alpha's codimensions should add up to k(n-k) to give an actual Schubert problem
schubertIdeal(List,List,List,Ring) := (flagType,alphas,flags,K) -> (
      k = flagType_(0);
      n = flagType_(1);
      coords = typeAStiefelCoords(k,n,alphas_(0),K);
      R = coords_(1);
      I = ideal(0_R);
      PY = exteriorPower(k,coords_(0));
      for i from 1 to length(alphas)-1 do 
      I = I + ideal(cauchyBinet(k,n,flags_(i-1),allNotLessThan(alphas_(i),n))*PY);
      return(I))

numSols = method()
numSols(List,List,List,Ring) := (flagType,alphas,flags,K) -> (
      I = schubertIdeal(flagType,alphas,flags,K);
      return (dim I, degree I))

all2SchubertProblemSols = method()
all2SchubertProblemSols(ZZ,ZZ) := (k,n) -> (
      AllAlphas = subsets(splice({1..n}),k);
      l = length(AllAlphas);
      for i from 1 to l do
            for j from i to l do
                  if (numSols(k,n,{AllAlphas_(i-1),AllAlphas_(j-1)},{random(QQ^n,QQ^n)}))_(0) == 0 
                         then print(AllAlphas_(i-1),AllAlphas_(j-1),(numSols(k,n,{AllAlphas_(i-1),AllAlphas_(j-1)},{random(QQ^n,QQ^n)}))_(1));
      )
      
typeASchubertIdeal = method()
typeASchubertIdeal(List,List,List,Ring) := (flagType,conditions,flags,K) -> (
      n = last(flagType);
      s = length(flags);
      subspaces = delete(n,flagType);
      bigRing = (typeAStiefelCoords(last(subspaces),n,conditions#0,K))#1;
      eqns = ideal(0_bigRing);
      for a in subspaces do(
           conds = {take(conditions#0,a)};
           for i from 1 to s do(
                conds = append(conds,sort(take(conditions#i,a))));
           eqns = eqns + sub(schubertIdeal({a,n},conds,flags,K),bigRing));
      return(eqns))

numSolsA = method()
numSolsA(List,List,List,Ring) := (flagType,conditions,flags,K) -> (
      I = typeASchubertIdeal(flagType,conditions,flags,K);
      return (dim I, degree I))
      
typeCStiefelCoords = method()
typeCStiefelCoords(ZZ,ZZ,List,Ring) := (k,n,alpha,K) -> (
-- Define ring of variables
     S = K[y_(1,1)..y_(n,k)];
-- Define matrix of correct size (and over the correct ring) that we can manipulate
     M = mutableMatrix(S,n,k);
-- Set leading ones in kxk identity submatrix with rows indexed by alpha
     for i from 1 to k do M_(alpha_(i-1)-1,i-1) = 1;
-- Set variables above the leading 1's
     for j from 1 to k do
     for i from 1 to alpha_(j-1)-1 do M_(i-1,j-1) = y_(i,j);
-- Set to 0 all entries below and to the right of leading 1's
     for i from 1 to k do
     for j from i+1 to k do M_(alpha_(i-1)-1,j-1) = 0;
-- Make matrix non-mutable
     M = matrix M;
-- Create a new ring with variables only those that show up in the matrix M
     R = K[support M];
-- Make it so that M is a matrix over the new ring
     M = sub(M,R);
-- Create the symplectic form J
     J = mutableMatrix(R,n,n);
     half_n = sub(n/2,ZZ);
     for i from 1 to half_n do J_(n-i,i-1) = 1;
     for j from half_n+1 to n do J_(n-j,j-1) = -1;
     J = matrix J;
-- Create ideal of symplectic relations
     rels = ideal(0_R);
     for i from 1 to k do 
     for j from i to k do rels = rels + (transpose(submatrix(M,{i-1}))*J*submatrix(M,{j-1}))_(0,0);
-- Return Stiefel coordinates and new ring, along with the ideal of relations among the variables and the dimension of that ideal
     {M, R, rels, dim(rels)})
     
notGreaterThan = method(TypicalValue=>Boolean)
notGreaterThan(List,List) := (beta,alpha) -> (
      NotGreaterThan = false;
      for i from 1 to length(beta) do
      if beta_(i-1) < alpha_(i-1) then NotGreaterThan = true;
      return(NotGreaterThan))
      
allNotGreaterThan = method()
allNotGreaterThan(List,ZZ) := (alpha, n) -> (
      L = {};
      for beta in subsets(splice {1..n},length(alpha)) do
      if notGreaterThan(beta,alpha) then L = append(L,beta);
      return(L))

-- Osculating Flags
parametrizedSymplecticFlag = method()
parametrizedSymplecticFlag(QQ, ZZ) := (t, n) -> (
      F = mutableMatrix(QQ,n,n);
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
      n = numgens target M;
      M = mutableMatrix M;
-- Make anti-upper triangular
      for i from 1 to n do(
            M_(i-1,n-i) = 1;
            for j from i to (n-1) do(
                  M_(j,n-i) = 0));
-- f_i and f_(n-i) are "orthogonal" under skew-symmetric bilinear form
      for i from 0 to (sub(n/2,ZZ)-2) do M_(n-i-2,i) = (-1)*M_(i,n-i-2);
-- Create the symplectic form J
      J = mutableMatrix(QQ,n,n);
      half_n = sub(n/2,ZZ);
      for i from 1 to half_n do J_(n-i,i-1) = 1;
      for j from half_n+1 to n do J_(n-j,j-1) = -1;
-- Make 1st half of columns symplectic via J
      for j from 0 to (sub(n/2,ZZ)-2) do(
            r = sub(n/2,ZZ)-2-j;
            for i from 0 to (sub(n/2,ZZ)-r-2) do(
                  s = sub(n/2,ZZ)-1-i;
	          M_(s,r) = M_(s,r) + (transpose(submatrix(M,{r}))*J*submatrix(M,{s}))_(0,0)));
      M = matrix M;
      return M)

------ BELOW ONLY WORKS IF SYMPLECTIC FLAGS ARE USED! ------
typeCGrassmannianSchubertIdeal = method()
----- NOTE: There should be m alphas and m-1 flags (first flag will be assumed to be the identity and not given as input)
----- NOTE: The flags should be general and the alpha's codimensions should add up to k(n-k) to give an actual Schubert problem

typeCGrassmannianSchubertIdeal(List,List,List,Ring) := (flagType,alphas,flags,K) -> (
      k = flagType_(0);
      n = flagType_(1);
      coords = typeCStiefelCoords(k,n,alphas_(0),K);
      R = coords_(1);
      I = coords_(2);
      PY = exteriorPower(k,coords_(0));
      for i from 1 to length(alphas)-1 do 
      I = I + ideal(cauchyBinet(k,n,flags_(i-1),allNotLessThan(alphas_(i),n))*PY);
      return(I))

numSolsGrassmannianC = method()
numSolsGrassmannianC(List,List,List,Ring) := (flagType,alphas,flags,K) -> (
      I = typeCGrassmannianSchubertIdeal(flagType,alphas,flags,K);
      return (dim I, degree I))

typeCSchubertIdeal = method()
typeCSchubertIdeal(List,List,List,Ring) := (flagType,conditions,flags,K) -> (
      n = last(flagType);
      s = length(flags);
      subspaces = delete(n,flagType);
      bigRing = (typeCStiefelCoords(last(subspaces),n,conditions#0,K))#1;
      eqns = ideal(0_bigRing);
      for a in subspaces do(
           conds = {take(conditions#0,a)};
           for i from 1 to s do(
                conds = append(conds,sort(take(conditions#i,a))));
           eqns = eqns + sub(typeCGrassmannianSchubertIdeal({a,n},conds,flags,K),bigRing));
      return(eqns))
      
numSolsC = method()
numSolsC(List,List,List,Ring) := (flagType,conditions,flags,K) -> (
      I = typeCSchubertIdeal(flagType,conditions,flags,K);
      return (dim I, degree I))
      
secantFlag = method()
secantFlag(List,Ring) := (L,R) -> (
      n = length(L);
      secantflag = mutableMatrix(R,n,n);
      for i from 1 to n do
      for j from 1 to n do secantflag_(i-1,j-1) = L_(j-1)^i;
      secantflag = matrix secantflag;
      return(secantflag))

randomSecantFlag = method()
randomSecantFlag(ZZ,Ring) := (n,R) -> (
      L = {};
      for i from 1 to n do
      L = append(L,random(R));
      return(secantFlag(L,R)))

completePermutation = method(TypicalValue=>List)
completePermutation(List,ZZ):=(w,n) ->(
	for i from 1 to n do(
		if isSubset({i},w)==false then w=append(w,i));
        return(w))

typeALength = method()
typeALength(List,ZZ) := (w,n) -> (
      w = completePermutation(w,n);
      count = 0;
      for i from 1 to n do
            for j from i+1 to n do
                  if w_(i-1) > w_(j-1) then count = count+1;
      return(count))

typeCLength = method()
typeCLength(List) := (w) -> (
      n = length(w);
      count = 0;
      for i from 1 to n do
            for j from i+1 to n do
                  if w_(i-1) > w_(j-1) then count = count+1;
      for i from 1 to n do
            for j from i to n do
                  if w_(i-1) + w_(j-1) > 2*n+1 then count = count+1;
      return(count))

typeALeastLength = method()
typeALeastLength(List,ZZ) := (conditions,n) -> (
      least = conditions_(0);
      for alpha in conditions do
            if typeALength(alpha,n) < typeALength(least,n) then least = alpha;
      return(least))

typeCLeastLength = method()
typeCLeastLength(List) := (conditions) -> (
      least = conditions_(0);
      for alpha in conditions do
            if typeCLength(alpha) < typeCLength(least) then least = alpha;
      return(least))

bubbleSort = method()
bubbleSort(List) := (L) -> (
      n = length(L);
      sorted = reverse(sort(L));
      swaps = {};
      while (L != sorted) do(
            for i from 0 to (n-2) do(
                  if L_(i) < L_(i+1) then(
                        swaps = prepend(i,swaps);
                        L = switch(i,i+1,L);
                        break)));
      return(swaps))

deltaSwap = method()
deltaSwap(Thing,Ring,ZZ) := (f,R,k) -> (
      ringVars = gens R;
      return sub((f-sub(f,{ringVars_(k)=>ringVars_(k+1),ringVars_(k+1)=>ringVars_(k)}))/(ringVars_(k)-ringVars_(k+1)),R))
      
polyRep = method();
      polyRep(List,Ring) := (w,R) -> (
            ringVars = gens R;
            n = length(ringVars);
            pointclass = 1;
            for i from 1 to (n-1) do(
                  pointclass = pointclass*(ringVars_(i-1))^(n-i));
            polyrep = pointclass;
            for i in w do(
                  polyrep = deltaSwap(polyrep,R,i));
            return(polyrep))
	    
-- Test: polyRep(bubbleSort({1,4,3,2}),QQ[a,b,c,d]) 
-- Returns: a^2*b + a*b^2  + a^2*c + a*b*c + b^2*c

-- Test for printing out all permutations at once:
-- for perm in permutations({1,2,3,4}) do(
--       print(perm);
--       print(polyRep(bubbleSort(perm),QQ[a,b,c,d])))
-- Returns: All 24 Schubert polynomials for S_4

--------------------- Create the Cohomology Ring for Full Type A Flag Manifolds -----------------------------------
elementarySymmetricIdeal = method()
elementarySymmetricIdeal(ZZ) := (n) -> (
      R = QQ[y_(1)..y_(n)][t];
      f =1_R;
      for i from 1 to n do(
      f = f*(y_(i)+t));
      coeffs = (coefficients (f-t^n))_(1);
      S = QQ[y_(1)..y_(n)];
      I = sub(ideal(coeffs),S);
      return(S,I,S/I))
      
------------------- Computes intersection numbers of Type A Full Flag Varieties Using Cohomology ---------------------------
intA = method()
intA(List,Ring,Ideal) := (alphas,S,I) -> (
f = 1_S;
for alpha in alphas do(
f = f*polyRep(bubbleSort(alpha),S));
f = f % I;
return (((coefficients f)_(1))_(0))_(0))
-- NOTE: Currently Struggles if answer is 0, need an "if, then" statement to rectify this.
-- Tests: elementarySymmetricIdeal(4) (sets up S and I)
--       intA({{2,1,3,4},{3,4,2,1}},S,I) (gives 1)
--       intA({{2,1,3,4},{4,3,1,2}},S,I) (gives error, should be 0)
--       intA({{2,1,3,4},{1,3,2,4},{1,3,2,4},{1,3,2,4},{1,3,2,4},{1,2,4,3}},S,I) (gives 2)

---------------------------- Type B and C Versions of Everything ---------------------------------------
elementarySymmetricSquaresIdeal = method()
elementarySymmetricSquaresIdeal(ZZ) := (n) -> (
      R = QQ[y_(1)..y_(n)][t];
      f =1_R;
      for i from 1 to n do(
            f = f*(y_(i)^2+t));
      coeffs = (coefficients (f-t^n))_(1);
      S = QQ[y_(1)..y_(n)];
      I = sub(ideal(coeffs),S);
      return(S,I,S/I))
      
elementarySchurDeterminantC = method()
elementarySchurDeterminantC(List,ZZ) := (lambda,n) -> (
      Rt = QQ[y_(1)..y_(n)][t];
      f =1_(Rt);
      for i from 1 to n do(
            f = f*(y_(i)+t));
      elempolys = ((coefficients (f-t^n))_(1))_(0);
      S = QQ[y_(1)..y_(n)];
      fixedElemPolys = {};
      for i from 1 to n do fixedElemPolys = append(fixedElemPolys,sub(elempolys_(i-1),S));
      M = mutableMatrix(S,n,n);
      for i from 1 to n do(
            for j from 1 to n do(
                  if (lambda_(i-1)+j-i) == 0 then M_(i-1,j-1) = 1;
                  if ((lambda_(i-1)+j-i) > 0 and (lambda_(i-1)+j-i) <= n) then M_(i-1,j-1) = fixedElemPolys_(lambda_(i-1)+j-i-1)));
      return determinant(matrix M))

elementarySchurDeterminantB = method()
elementarySchurDeterminantB(List,ZZ) := (lambda,n) -> (
      Rt = QQ[y_(1)..y_(n)][t];
      f =1_(Rt);
      for i from 1 to n do(
            f = f*(y_(i)+t));
      elempolys = ((coefficients (f-t^n))_(1))_(0);
      S = QQ[y_(1)..y_(n)];
      fixedElemPolys = {};
      for i from 1 to n do fixedElemPolys = append(fixedElemPolys,(1/2)*(sub(elempolys_(i-1),S)));
      M = mutableMatrix(S,n,n);
      for i from 1 to n do(
            for j from 1 to n do(
                  if (lambda_(i-1)+j-i) == 0 then M_(i-1,j-1) = 1;
                  if ((lambda_(i-1)+j-i) > 0 and (lambda_(i-1)+j-i) <= n) then M_(i-1,j-1) = fixedElemPolys_(lambda_(i-1)+j-i-1)));
      return determinant(matrix M))

signedToNot = method()
signedToNot(List) := (perm) -> (
      n = length(perm);
      wnew = {};
      for i from 1 to n do(
            if perm_(i-1) > 0 then wnew = append(wnew,perm_(i-1));
	    if perm_(i-1) < 0 then wnew = append(wnew,2*n+1+perm_(i-1)));
      return wnew)
      
signedBubbleSort = method()
signedBubbleSort(List) := (L) -> (
      n = length(L);
      eventual = {};
      for i from 1 to n do(
            eventual = append(eventual,2*n+1-i));
      swaps = {};
      while (L != eventual) do(
            if L == reverse(sort(L)) then(
	          smallest = L_(-1);
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
      ringVars = gens R;
      return sub((f-sub(f,{ringVars_(-1)=>(-1)*ringVars_(-1)}))/(2*ringVars_(-1)),R))
      
deltaSwapB = method()
deltaSwapB(Thing,Ring) := (f,R) -> (
      ringVars = gens R;
      return sub((f-sub(f,{ringVars_(-1)=>(-1)*ringVars_(-1)}))/(ringVars_(-1)),R))

---- NOTE: all polyRepB/C/D methods require R to be in terms of variables y_1..y_n, not a,b,c, etc. FIX THIS! ---

polyRepC = method()
polyRepC(List,Ring) := (w,R) -> (
      ringVars = gens R;
      n = length(ringVars);
      pointclass = 1;
      for i from 1 to (n-1) do(
            pointclass = pointclass*(ringVars_(i-1))^(n-i));
      lambda = {};
      for i from 1 to n do(
	    lambda = prepend(i,lambda));
      delta = sub(elementarySchurDeterminantC(lambda,n),R);
      polyrep = pointclass*delta;
      for i in w do(
	    if (i != n-1) then(
                  polyrep = deltaSwap(polyrep,R,i));
            if (i == n-1) then(
		  polyrep = deltaSwapC(polyrep,R)));
      return(polyrep))
      
polyRepB = method()
polyRepB(List,Ring) := (w,R) -> (
      ringVars = gens R;
      n = length(ringVars);
      pointclass = 1;
      for i from 1 to (n-1) do(
            pointclass = pointclass*(ringVars_(i-1))^(n-i));
      lambda = {};
      for i from 1 to n do(
	    lambda = prepend(i,lambda));
      delta = sub(elementarySchurDeterminantB(lambda,n),R);
      polyrep = pointclass*delta;
      for i in w do(
	    if (i != n-1) then(
                  polyrep = deltaSwap(polyrep,R,i));
            if (i == n-1) then(
		  polyrep = deltaSwapB(polyrep,R)));
      return(polyrep))

intC = method()
intC(List,Ring,Ideal) := (alphas,S,I) -> (
      f = 1_S;
      for alpha in alphas do(
            f = f*polyRepC(signedBubbleSort(signedToNot(alpha)),S));
      f = f % I;
      return (((coefficients f)_(1))_(0))_(0))

intB = method()
intB(List,Ring,Ideal) := (alphas,S,I) -> (
      f = 1_S;
      for alpha in alphas do(
            f = f*polyRepB(signedBubbleSort(signedToNot(alpha)),S));
      f = f % I;
      return (((coefficients f)_(1))_(0))_(0))

typeBLength = method()
typeBLength(List) := (w) -> (
      n = length(w);
      count = 0;
      for i from 1 to n do
            for j from i+1 to n do
                  if w_(i-1) > w_(j-1) then count = count+1;
      for i from 1 to n do
            for j from i to n do
                  if w_(i-1) + w_(j-1) > 2*n+2 then count = count+1;
      return(count))

---------------------------- Type D Version of Everything ---------------------------------------

elementarySymmetricDIdeal = method()
elementarySymmetricDIdeal(ZZ) := (n) -> (
      Rt = QQ[y_(1)..y_(n)][t];
      f =1_(Rt);
      squareProd = 1_(Rt);
      prod = 1_(Rt);
      for i from 1 to n do(
            f = f*(y_(i)^2+t);
	    squareProd = squareProd*((y_(i))^2);
	    prod = prod*(y_(i)));
      coeffs = (coefficients (f-t^n-squareProd))_(1);
      S = QQ[y_(1)..y_(n)];
      I = sub(ideal(coeffs,prod),S);
      return(S,I,S/I))

signedBubbleSortD = method()
signedBubbleSortD(List) := (L) -> (
      n = length(L);
      eventual = {};
      for i from 1 to (n-1) do(
            eventual = append(eventual,2*n+1-i));
      if (n % 2 == 0) then eventual = append(eventual,n+1);
      if (n % 2 != 0) then eventual = append(eventual,n);
      swaps = {};
      while (L != eventual) do(
            if L == reverse(sort(L)) then(
	          smallest = L_(-1);
		  nextSmallest = L_(-2);
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
      ringVars = gens R;
      return sub((f-sub(f,{ringVars_(-2)=>(-1)*ringVars_(-1),ringVars_(-1)=>(-1)*ringVars_(-2)}))/(ringVars_(-2)+ringVars_(-1)),R))
      
----- NOTE: NEED TO MAKE A SCHUR DETERMINANT FOR TYPE D TO BE ABLE TO USE polyRepD PROPERLY! -----      
      
elementarySchurDeterminantD = method()
elementarySchurDeterminantD(List,ZZ) := (lambda,n) -> (
      Rt = QQ[y_(1)..y_(n)][t];
      f =1_(Rt);
      for i from 1 to n do(
            f = f*(y_(i)+t));
      elempolys = ((coefficients (f-t^n))_(1))_(0);
      S = QQ[y_(1)..y_(n)];
      fixedElemPolys = {};
      for i from 1 to n do fixedElemPolys = append(fixedElemPolys,(1/2)*(sub(elempolys_(i-1),S)));
      M = mutableMatrix(S,n-1,n-1);
      for i from 1 to (n-1) do(
            for j from 1 to (n-1) do(
                  if (lambda_(i-1)+j-i) == 0 then M_(i-1,j-1) = 1;
                  if ((lambda_(i-1)+j-i) > 0 and (lambda_(i-1)+j-i) <= n) then M_(i-1,j-1) = fixedElemPolys_(lambda_(i-1)+j-i-1)));
      return determinant(matrix M))      
      
polyRepD = method()
polyRepD(List,Ring) := (w,R) -> (
      ringVars = gens R;
      n = length(ringVars);
      pointclass = 1;
      for i from 1 to (n-1) do(
            pointclass = pointclass*(ringVars_(i-1))^(n-i));
      lambda = {};
      for i from 1 to (n-1) do(
	    lambda = prepend(i,lambda));
      delta = sub(elementarySchurDeterminantD(lambda,n),R);
      polyrep = pointclass*delta;
      for i in w do(
	    if (i != n-1) then(
                  polyrep = deltaSwap(polyrep,R,i));
            if (i == n-1) then(
		  polyrep = deltaSwapD(polyrep,R)));
      return(polyrep))
  
intD = method()
intD(List,Ring,Ideal) := (alphas,S,I) -> (
      f = 1_S;
      for alpha in alphas do(
            f = f*polyRepD(signedBubbleSortD(signedToNot(alpha)),S));
      f = f % I;
      return (((coefficients f)_(1))_(0))_(0))

typeDLength = method()
typeDLength(List) := (w) -> (
      n = length(w);
      count = 0;
      for i from 1 to n do
            for j from i+1 to n do
                  if w_(i-1) > w_(j-1) then count = count+1;
      for i from 1 to n do
            for j from i+1 to n do
                  if w_(i-1) + w_(j-1) > 2*n+1 then count = count+1;
      return(count))

---------------------------- PARTIAL FLAG SCHUBERT COMPUTATIONS ------------------------------------

-- flagType a list of the form {a_1,a_2,...,a_s,n}
partialIntA = method()
partialIntA(List,List,Ring,Ideal) := (flagType,alphas,S,I) -> (
      l = length(flagType);
      n = flagType_(-1);
      newAlphas = {};
      for alpha in alphas do(
            newAlpha = completePermutation(alpha,n);
            newAlphas = append(newAlphas,newAlpha));
      dualClass = {};
      for k from 1 to (l-1) do(
            for j from (flagType_(-(k+1)) + 1) to flagType_(-k) do(
	          dualClass = prepend(j,dualClass)));
      for i from 1 to flagType_(0) do(
            dualClass = prepend(i,dualClass));
      newAlphas = append(newAlphas,dualClass);
      return(intA(newAlphas,S,I)))

completeSignedPermutation = method()
completeSignedPermutation(List,ZZ) := (w,n) -> (
      for i from 1 to n do(
		if (isSubset({i},w)==false and isSubset({-i},w)==false) then w=append(w,i));
      return(w))

partialIntC = method()
partialIntC(List,List,Ring,Ideal) := (flagType,alphas,S,I) -> (
      l = length(flagType);
      n = flagType_(-1);
      newAlphas = {};
      for alpha in alphas do(
            newAlpha = completeSignedPermutation(alpha,n);
            newAlphas = append(newAlphas,newAlpha));
      dualClass = {};
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
      l = length(flagType);
      n = flagType_(-1);
      newAlphas = {};
      for alpha in alphas do(
            newAlpha = completeSignedPermutation(alpha,n);
            newAlphas = append(newAlphas,newAlpha));
      dualClass = {};
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
      l = length(flagType);
      n = flagType_(-1);
      newAlphas = {};
      for alpha in alphas do(
            newAlpha = completeSignedPermutation(alpha,n);
            newAlphas = append(newAlphas,newAlpha));
      dualClass = {};
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
