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
schubertIdeal(ZZ,ZZ,List,List) := (k,n,alphas,flags) -> (
      coords = typeAStiefelCoords(k,n,alphas_(0),QQ);
      R = coords_(1);
      I = ideal(0_R);
      PY = exteriorPower(k,coords_(0));
      for i from 1 to length(alphas)-1 do 
      I = I + ideal(cauchyBinet(k,n,flags_(i-1),allNotLessThan(alphas_(i),n))*PY);
      return(I))

numSols = method()
numSols(ZZ,ZZ,List,List) := (k,n,alphas,flags) -> (
      I = schubertIdeal(k,n,alphas,flags);
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
typeASchubertIdeal(List,List,List) := (flagType,conditions,flags) -> (
      n = last(flagType);
      s = length(flags);
      subspaces = delete(n,flagType);
      bigRing = (typeAStiefelCoords(last(subspaces),n,conditions#0,QQ))#1;
      eqns = ideal(0_bigRing);
      for a in subspaces do(
           conds = {take(conditions#0,a)};
           for i from 1 to s do(
                conds = append(conds,sort(take(conditions#i,a))));
           eqns = eqns + sub(schubertIdeal(a,n,conds,flags),bigRing));
      return(eqns))

numSolsA = method()
numSolsA(List,List,List) := (flagType,conditions,flags) -> (
      I = typeASchubertIdeal(flagType,conditions,flags);
      return (dim I, degree I))

permutationMatrix = method()
permutationMatrix(List) := (perm) -> ( --takes a complete permutation (1,2,3,4,5,6)->(pi(1),pi(2),...,pi(6))
     permMatrix = matrix(for i in perm list entries(id_(ZZ^(#perm))_(i-1)))
)


permRank = method()
permRank(List) := (perm) -> (
     mat= permutationMatrix(perm);
     rankMat = matrix(for i to (#perm-1) list (for j to (#perm-1) list sum(sum(entries(submatrix(mat, 0..i,0..j))))));
     return rankMat;
)

essentialSet = method()
essentialSet(List) := (perm) -> ( 
     mat = permutationMatrix(perm);
     rankMat= permRank(perm);
     setOfOnes = flatten(for i to #perm-1 list (for j to #perm-1 list (if mat_(i,j)==0 then continue; {i,j})));
     --To do: make a mutableMatrix from rankMat, replace anything weakly below or to the right of the indices
     --in setOfOnes with -1s. Then, essentialSet will be the result of a for loop listing only when both i+1 
     --and j+1 are negative. Will have to sanitize so that i+1, j+1< #perm
     mutRankMat = mutableMatrix(rankMat);
     
     for i in setOfOnes do (
          
          for j from i_(0) to #perm-1 do (
               --if j==#perm then break;
               mutRankMat_(j,i_(1)) = -1;
          );
          for k from i_(1) to #perm-1 do (
               mutRankMat_(i_(0),k) = -1;
          );
     );
     diagram = matrix mutRankMat;
     print diagram;
     essential = flatten(for i to #perm-1 list (for j to #perm-1 list(if diagram_(i,j)==-1 then continue; if i< #perm-1  then(if diagram_(i+1,j)>=0 then continue); if j< #perm-1 then (if diagram_(i,j+1)>=0 then continue); {i,j,diagram_(i,j)})));
     return essential;
)

