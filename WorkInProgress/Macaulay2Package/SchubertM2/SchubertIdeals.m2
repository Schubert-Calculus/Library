--------------------------------------------------
-- NOTES:

-- OUR FIELD: K (can be any field).

-- COMPLETE FLAG IN K^n: Represented by an nxn invertible matrix F, whose column spans give the corresponding flag.

-- FLAG SHAPE: A list {a_1,...,a_s,n} (1 <= a_1 < ... < a_s < n) representing the flag variety that only consists of flags given by a_1-dimensional
-- subspaces contained in ... contained in a_s-dimensional subspaces in K^n. With this terminology, complete flags have shape {1,2,...,n-1,n}.

-- SCHUBERT CONDITION (minimal length coset representative of element of a Weyl group): Represented by a "partial permutation", a list of size a_s
-- of increasing elements of [n], except for possible descents in positions a_1,...,a_s (index starting at 1). These partial permutations represent a
-- unique permutation in S_n, which is obtained by appending the remaining elements of [n] in increasing order.

--------------------------------------------------
-- dimToCodim --

-- Function: 
-- Takes in a flag shape and Schubert condition for that shape, returning the "dual Schubert condition" of the same shape. Schubert conditions commonly 
-- have two conventions (dimension convention and codimension convention). A condition in dimension convention represents the same object as its dual
-- condition in codimension convention, and vice versa. Dimension convention makes the definition of Schubert varieities and their Stiefel coordinates
-- much more tractable, but codimension convention is what we actually want to use in this package, primarily because it then matches the cohomology
-- calculations for intersection theory. Also, the length of a permutation giving codimension is an invariant when embedding smaller flag varieties 
-- and their Schubert subvarieties into larger flag varieties, while dimension is not. 

-- Inputs: 
-- (1) flagshape, a list {a_1,...,a_s,n}.
-- (2) alpha, a list {alpha_1,...,alpha_(a_s)} giving a Schubert condition of that shape.

-- Outputs:
-- (1) alphadual, another list {alpha_1^(hat),...,alpha_(a_s)^(hat)} of the same size as alpha, representing the dual Schubert condition to alpha
--                in the flag variety of shape {a_1,...,a_s,n}.


-- Code:

dimToCodim = method()
dimToCodim(List,List) := (flagshape,alpha) -> (
      s = length(flagshape) - 1;
      n = flagshape_(-1);
      breaks = prepend(0,flagshape);
      alphadual = {};
      for b from 1 to s do(
            k = breaks_(b) - breaks_(b-1);
            for i from 1 to k do(
                  alphadual = append(alphadual,n+1-alpha_(breaks_(b-1)+k-i))));
      return(alphadual))
      
-- Tests: 
-- (1) dimToCodim({2,4},{3,4}) should give {1,2} (the dense cell goes to the point)
-- (2) dimToCodim({2,4},{1,4}) should give {1,4} (self-dual example)
-- (3) dimToCodim({3,17,21},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17}) should give {19, 20, 21, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
--     (just to have a more complicated example)

------------------------------
-- typeAStiefelCoords --

-- Function: 
-- Takes in a flag shape and Schubert condition for that shape, along with a coefficient field K, and returns the Stiefel coordinates for the 
-- correspoding type A Schubert variety. These Stiefel coordinates are specific local coordinates for the (smooth) points of the Schubert variety
-- with respect to how that variety intersects the standard opposite flag (reverse identity on anti-diagonal, all other entries zero). In particular,
-- these coordinates are given in terms of a matrix with identity matrix in rows indexed by the Schubert condition, and with zeros above and to the 
-- left of the leading ones. Here we use codimension convention, and index rows from top to bottom.

-- Inputs:
-- (1) flagshape, a list {a_1,...,a_s,n}.
-- (2) alpha, a list {alpha_1,...,alpha_(a_s)} giving a Schubert condition of that shape.
-- (3) K, a coefficient field for our polynomial ring.

-- Outputs:
-- (1) M, a matrix giving Stiefel coordinates for the Schubert variety given by flagshape and alpha.
-- (2) R, a polynomial ring whose generators are the intdeterminates in M, with number of generators the dimension of the Schubert variety.

-- Helper Function:
-- (splits alpha up into a list of lists determined by flagshape)

splitPermutation = method()
splitPermutation(List,List) := (flagshape,alpha) -> (
      gaps = {flagshape_(0)};
      for i from 1 to (length(flagshape)-2) do(
            gaps = append(gaps,flagshape_(i)-flagshape_(i-1)));
      splitperm = {};
      copyalpha = alpha;
      for gap in gaps do(
            subalpha = {};
            for i from 0 to (gap-1) do(
                  subalpha = append(subalpha,copyalpha_(0));
                  copyalpha = delete(copyalpha_(0),copyalpha));
            splitperm = append(splitperm,subalpha));
      return(splitperm))

-- Code:

typeAStiefelCoords = method()
typeAStiefelCoords(List,List,Ring) := (flagshape,alpha,K) -> (
      n = flagshape_(-1);
      a_s = flagshape_(-2);
      S = K[x_(1,1)..x_(n,a_s)];
      alphalist = splitPermutation(flagshape,alpha);
      firstalpha = alphalist_(0);
      l = length(firstalpha);
-- Define matrix of correct size (and over the correct ring) that we can manipulate for the first subalpha
      M = mutableMatrix(S,n,l);
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
      indexshift = length(firstalpha);
      for subalpha in alphalist do(
            l = length(subalpha);
            N = mutableMatrix(S,n,l);
            for i from 1 to l do N_(subalpha_(i-1)-1,i-1) = 1;
            for j from 1 to l do
            for i from subalpha_(j-1)+1 to n do N_(i-1,j-1) = x_(i,j+indexshift);
            for i from 1 to l do
            for j from 1 to i-1 do N_(subalpha_(i-1)-1,j-1) = 0;
            N = matrix N;
            M = M | N;
            indexshift = indexshift + l);
      M = mutableMatrix M;
      for i from 1 to a_s do(
            for j from i to a_s-1 do(
                  M_(alpha_(i-1)-1,j) = 0));
      M = matrix M;
-- Create a new ring with variables only those that show up in the matrix M
      R = K[support M];
-- Make it so that M is a matrix over the new ring
      M = sub(M,R);
-- Return Stiefel coordinates and new ring
      return({M, R}))
     
----- NOTE: "exteriorPower(k,M)" will compute the Plucker vector for us -----
----- NOTE: "subsets({1..n},k)" will compute all k element subsets of {1,...,n} for us, 
-----             IN THE SAME ORDERING as the Plucker vector from "exteriorPower" above -----
      
-- Tests:
-- (All big cells in 4-space)
-- (1) typeAStiefelCoords({1,4},{1},QQ)
-- (2) typeAStiefelCoords({2,4},{1,2},QQ)
-- (3) typeAStiefelCoords({1,2,4},{1,2},QQ)
-- (4) typeAStiefelCoords({3,4},{1,2,3},QQ)
-- (5) typeAStiefelCoords({1,3,4},{1,2,3},QQ)
-- (6) typeAStiefelCoords({2,3,4},{1,2,3},QQ)
-- (7) typeAStiefelCoords({1,2,3,4},{1,2,3},QQ)
-- (8) typeAStiefelCoords({4,4},{1,2,3,4},QQ)

------------------------------
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

cauchyBinetCoefficients = method()
cauchyBinetCoefficients(List,List,Matrix,Ring) := (grassmannianshape,betas,F,K) -> (
      k = grassmannianshape_(0);
      n = grassmannianshape_(1);
      Finv = inverse F;
      M = mutableMatrix(K,length(betas),binomial(n,k));
      subs = subsets(splice {1..n},k);
      kOnes = splice{k:1};
      for i from 0 to length(betas)-1 do(
            for j from 0 to binomial(n,k)-1 do(
                  M_(i,j) = det(submatrix(Finv,betas_(i)-kOnes,subs_(j)-kOnes))));
      return(matrix M))
      
typeAGrassmannianSchubertIdeal = method()
----- NOTE: There should be m alphas and m-1 flags (first flag will be assumed to be the identity and not given as input)
----- NOTE: The flags should be general and the alpha's codimensions should add up to k(n-k) to give an actual Schubert problem
typeAGrassmannianSchubertIdeal(List,List,List,Ring) := (grassmannianshape,alphas,flags,K) -> (
      k = grassmannianshape_(0);
      n = grassmannianshape_(1);
      coords = typeAStiefelCoords(grassmannianshape,alphas_(0),K);
      R = coords_(1);
      I = ideal(0_R);
      PY = exteriorPower(k,coords_(0));
      for i from 1 to length(alphas)-1 do 
      I = I + ideal(cauchyBinetCoefficients(grassmannianshape,allNotGreaterThan(alphas_(i),n),flags_(i-1),K)*PY);
      return(I))

typeASchubertIdeal = method()
typeASchubertIdeal(List,List,List,Ring) := (flagshape,alphas,flags,K) -> (
      n = last(flagshape);
      s = length(flags);
      subspaces = delete(n,flagshape);
      bigRing = (typeAStiefelCoords(flagshape,alphas_(0),K))#1;
      eqns = ideal(0_bigRing);
      for a in subspaces do(
           conds = {take(alphas_(0),a)};
           for i from 1 to s do(
                conds = append(conds,sort(take(alphas_(i),a))));
           eqns = eqns + sub(typeAGrassmannianSchubertIdeal({a,n},conds,flags,K),bigRing));
      return(eqns))

numSolsA = method()
numSolsA(List,List,List,Ring) := (flagshape,alphas,flags,K) -> (
      I = typeASchubertIdeal(flagshape,alphas,flags,K);
      return (dim I, degree I))

typeCStiefelCoords = method()
typeCStiefelCoords(List,List,Ring) := (flagshape,alpha,K) -> (
n = flagshape_(-1);
      a_s = flagshape_(-2);
      S = K[x_(1,1)..x_(n,a_s)];
      alphalist = splitPermutation(flagshape,alpha);
      firstalpha = alphalist_(0);
      l = length(firstalpha);
-- Define matrix of correct size (and over the correct ring) that we can manipulate for the first subalpha
      M = mutableMatrix(S,n,l);
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
      indexshift = length(firstalpha);
      for subalpha in alphalist do(
            l = length(subalpha);
            N = mutableMatrix(S,n,l);
            for i from 1 to l do N_(subalpha_(i-1)-1,i-1) = 1;
            for j from 1 to l do
            for i from subalpha_(j-1)+1 to n do N_(i-1,j-1) = x_(i,j+indexshift);
            for i from 1 to l do
            for j from 1 to i-1 do N_(subalpha_(i-1)-1,j-1) = 0;
            N = matrix N;
            M = M | N;
            indexshift = indexshift + l);
      M = mutableMatrix M;
      for i from 1 to a_s do(
            for j from i to a_s-1 do(
                  M_(alpha_(i-1)-1,j) = 0));
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

typeCGrassmannianSchubertIdeal(List,List,List,Ring) := (grassmannianshape,alphas,flags,K) -> (
      k = grassmannianshape_(0);
      n = grassmannianshape_(1);
      coords = typeCStiefelCoords(grassmannianshape,alphas_(0),K);
      R = coords_(1);
      I = coords_(2);
      PY = exteriorPower(k,coords_(0));
      for i from 1 to length(alphas)-1 do 
      I = I + ideal(cauchyBinetCoefficients(grassmannianshape,allNotGreaterThan(alphas_(i),flags_(i-1),n))*PY);
      return(I))
      
typeCSchubertIdeal = method()
typeCSchubertIdeal(List,List,List,Ring) := (flagshape,conditions,flags,K) -> (
      n = last(flagshape);
      s = length(flags);
      subspaces = delete(n,flagshape);
      bigRing = (typeCStiefelCoords(flagshape,conditions#0,K))#1;
      eqns = ideal(0_bigRing);
      for a in subspaces do(
           conds = {take(conditions#0,a)};
           for i from 1 to s do(
                conds = append(conds,sort(take(conditions#i,a))));
           eqns = eqns + sub(typeCGrassmannianSchubertIdeal({a,n},conds,flags,K),bigRing));
      return(eqns))
      
numSolsC = method()
numSolsC(List,List,List,Ring) := (flagshape,conditions,flags,K) -> (
      I = typeCSchubertIdeal(flagshape,conditions,flags,K);
      return (dim I, degree I))
