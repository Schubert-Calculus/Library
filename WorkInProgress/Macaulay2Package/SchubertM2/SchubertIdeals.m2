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

-- Code:

typeAStiefelCoords = method()
typeAStiefelCoords(List,List,Ring) := (flagshape,alpha,K) -> (
-- Define ring of variables
     k = flagshape_(-2);
     n = flagshape_(-1);
     S = K[x_(1,1)..x_(n,k)];
-- Define matrix of correct size (and over the correct ring) that we can manipulate
     M = mutableMatrix(S,n,k);
-- Set leading ones in kxk identity submatrix with rows indexed by alpha
     for i from 1 to k do M_(alpha_(i-1)-1,i-1) = 1;
-- Set variables below the leading 1's
     for j from 1 to k do
     for i from alpha_(j-1)+1 to n do M_(i-1,j-1) = x_(i,j);
-- Set to 0 all entries above and to the left of leading 1's
     for i from 1 to k do
     for j from 1 to i-1 do M_(alpha_(i-1)-1,j-1) = 0;
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
