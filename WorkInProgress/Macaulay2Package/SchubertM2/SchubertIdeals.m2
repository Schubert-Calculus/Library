------------------------------
-- NOTES:

-- OUR FIELD: K (can be any field).

-- COMPLETE FLAG IN K^n: Represented by an nxn invertible matrix F, whose column spans give the corresponding flag.

-- FLAG SHAPE: A list {a_1,...,a_s,n} (1 <= a_1 < ... < a_s < n) representing flags (and their corresponding flag varieties) that only consist of 
-- a_1-planes contained in ... contained in a_s planes in K^n. With this terminology, complete flags have shape {1,2,...,n-1,n}.

-- SCHUBERT CONDITION (minimal length coset representative of cosets of a Weyl group): Represented by a "partial permutation", a list of size a_s
-- of increasing elements of [n], except for possible descents in positions a_1,...,a_s (index starting at 1). These partial permutations represent a
-- unique permutation in S_n, which is obtained by appending the remaining elements of [n] in increasing order.

------------------------------
-- dimToCodim --

-- Function: 
-- Takes in a flag shape and Schubert condition for that shape, returning the "dual Schubert condition" of the same shape. Schubert conditions commonly 
-- have two conventions (dimension convention and codimension convention). A condition in dimension convention represents the same object as its dual
-- condition in codimension convention, and vice versa. Dimension convention makes the definition of Schubert varieities and their Stiefel coordinates
-- much more tractable, but codimension convention is what we actually want to use in this package, partially because it then matches the cohomology
-- calculations for intersection theory. Also, the length of a permutation giving codimension is an invariant when embedding smaller flag varieties 
-- and their Schubert subvarieties into larger flag varieties, while dimension is not. Hence, while we like our inputs for Schubert conditions to use 
-- codimension convention, we convert it to its dual to actually compute Stiefel coordinates.

-- Inputs: 
-- (1) flagShape, a list {a_1,...,a_s,n}
-- (2) alpha, a list {alpha_1,...,alpha_(a_s)} giving a Schubert condition of that shape.

-- Outputs:
-- (1) al


-- Code:

dimToCodim = method()
dimToCodim(List,List) := (flagType,alpha) -> (
      s = length(flagType) - 1;
      n = flagType_(-1);
      breaks = prepend(0,flagType);
      alphaDual = {};
      for b from 1 to s do(
            k = breaks_(b) - breaks_(b-1);
            for i from 1 to k do(
                  alphaDual = append(alphaDual,n+1-alpha_(breaks_(b-1)+k-i))));
      return(alphaDual))
      
 -- Tests: 
