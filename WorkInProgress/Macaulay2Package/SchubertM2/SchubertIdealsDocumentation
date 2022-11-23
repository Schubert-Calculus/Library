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

TYPE A CODE

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

-- Tests: 
-- (1) dimToCodim({2,4},{3,4}) should give {1,2} (the dense cell goes to the point)
-- (2) dimToCodim({2,4},{1,4}) should give {1,4} (self-dual example)
-- (3) dimToCodim({3,17,21},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17}) should give {19, 20, 21, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
--     (just to have a more complicated example)

------------------------------

-- splitPermutation --

-- Function: A helper function that will split a partial permutation into a list of lists, separations determined by the flagshape.

-- Tests:
-- splitPermutation({2,3,6,9},{7,8,4,1,2,3}) should return {{7,8},{4},{1,2,3}}.

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

----- NOTE: "exteriorPower(k,M)" will compute the Plucker vector for us -----
----- NOTE: "subsets({1..n},k)" will compute all k element subsets of {1,...,n} for us, 
-----             IN THE SAME ORDERING as the Plucker vector from "exteriorPower" above -----
      
-- Tests:
-- (All big cells in 4-space)
-- (1) typeAStiefelCoords({1,4},{1},QQ) should be 3 dimensional.
-- (2) typeAStiefelCoords({2,4},{1,2},QQ) should be 4 dimensional.
-- (3) typeAStiefelCoords({1,2,4},{1,2},QQ) should be 5 dimensional.
-- (4) typeAStiefelCoords({3,4},{1,2,3},QQ) should be 3 dimensional.
-- (5) typeAStiefelCoords({1,3,4},{1,2,3},QQ) should be 5 dimensional.
-- (6) typeAStiefelCoords({2,3,4},{1,2,3},QQ) should be 5 dimensional.
-- (7) typeAStiefelCoords({1,2,3,4},{1,2,3},QQ) should be 6 dimensional.
-- (8) typeAStiefelCoords({4,4},{1,2,3,4},QQ) should be 0 dimensional.

------------------------------

-- notGreaterThan --

-- Function: Determines whether a partial permutation, beta, is NOT greater than or equal to another partial permutation, alpha, in the Bruhat
-- partial order. If beta is NOT greater than or equal to alpha, the function returns "true". Otherwise, the function returns "false".

-- Tests:
-- notGreaterThan({1,2},{3,4}) returns "true"
-- notGreaterThan({3,4},{1,2}) returns "false"
-- notGreaterThan({1,4},{2,3}) returns "true" (incomparable example)
-- notGreaterThan({1,2},{1,2}) returns "false"

------------------------------

-- allNotGreaterThan --

-- Function: For a fixed partial permutation, alpha, lists all other partial permutations of the same shape as alpha that are NOT greater than
-- alpha in the Bruhat partial order.

-- Tests:
-- (All examples in G(2,4))
-- allNotGreaterThan({1,2},4) returns "{}"
-- allNotGreaterThan({1,3},4) returns "{{1,2}}"
-- allNotGreaterThan({1,4},4) returns "{{1,2},{1,3},{2,3}}"
-- allNotGreaterThan({2,3},4) returns "{{1,2},{1,3},{1,4}}"
-- allNotGreaterThan({2,4},4) returns "{{1,2},{1,3},{2,3},{1,4}}"
-- allNotGreaterThan({3,4},4) returns "{{1,2},{1,3},{2,3},{1,4},{2,4}}"

------------------------------

-- cauchyBinetCoefficients --

-- Function: Creates the matrix of coefficients from the Cauchy-Binet formula P(alpha)(F^{-1}). See Theorem 1.3 and the preceeding discussion in 
-- "Numerical Schubert Calculus via the Littlewood-Richardson Homotopy Algorithm" (Leykin, del Campo, Sottile, Vakil, Verschelde).

-- Test: cauchyBinetCoefficients({2,4},allNotGreaterThan({2,4},4),id_(QQ^4),QQ) returns non-square identity-like matrix.

------------------------------

-- typeAGrassmannianSchubertIdeal --

-- Function: Creates the ideal for an intersection of Schubert varieties in a Grassmannian with respect to local coordinates. Note that we always assume
-- that the first flag given is represented by the identity matrix, so user inputs 1 fewer flag than conditions. We will be using this function recursively
-- for the general type A flag manifold intersections, so while for Grassmannians we can further assume the second flag is the reverse identity, we can't 
-- assume that for the general type A situation, and so do not implement that shortcut here.

-- Tests:
-- All computations in G(2,4). Have to create some random flags first before use. After ideal I is returned, can use dim I, degree I to extract info.
-- F1 = random(QQ^4,QQ^4)
-- F2 = random(QQ^4,QQ^4)
-- F3 = random(QQ^4,QQ^4)
-- typeAGrassmannianSchubertIdeal({2,4},{{3,4},{1,2}},{F1},QQ) returns 0 ideal in QQ
-- typeAGrassmannianSchubertIdeal({2,4},{{1,2},{3,4}},{F1},QQ) returns an ideal with many generators in QQ[x_{3,1},x_{3,2},x_{4,1},x_{4,2}].
-- NOTE: The above 2 examples give the same (trivial) intersection with dim I = 0, degree I = 1. However, the coordinates are with respect to the first 
--       Schubert condition, so putting the larger length partial permutation first gives fewer variables and is preferable.
-- typeAGrassmannianSchubertIdeal({2,4},{{1,3},{1,3},{1,3},{1,3}},{F1,F2,F3},QQ) returns an ideal I with dim I = 0, degree I = 2.
-- typeAGrassmannianSchubertIdeal({2,4},{{1,3},{1,3}},{F1},QQ) returns an ideal I with dim I = 2, degree I = 2 (so doesn't have to be 0-dimensional).
-- typeAGrassmannianSchubertIdeal({2,4},{{1,4},{2,3}},{F1},QQ) returns an ideal I with dim I = -1, degree I = 0 (even though codimensions add to 
--                                                             the dimension of G(2,4), they are not dual, and so give an empty intersection).

------------------------------

-- typeASchubertIdeal --

-- Function: Creates the ideal for an intersection of Schubert varieties in a given type A flag variety (could be Grassmannian, complete, or partial).
-- Note that in this situation, we can always assume that the first flag given is represented by the identity matrix, so we implement it as such. Thus,
-- the user inputs 1 fewer flag than conditions.

-- Tests:
-- F1 = random(QQ^6,QQ^6)
-- F2 = random(QQ^6,QQ^6)
-- F3 = random(QQ^6,QQ^6)
-- F4 = random(QQ^6,QQ^6)
-- F5 = random(QQ^6,QQ^6)
-- F6 = random(QQ^6,QQ^6)
-- typeASchubertIdeal({1,2,5},{{2,1},{2,1},{1,3},{1,3},{1,3},{1,3},{1,3}},{F1,F2,F3,F4,F5,F6},QQ) returns an ideal eqns with dim(eqns) = 0, degree(eqns) = 5.
-- typeASchubertIdeal({1,2,5},{{2,1},{2,1},{2,1},{1,3},{1,3},{1,3},{1,3}},{F1,F2,F3,F4,F5,F6},QQ) returns an ideal eqns with dim(eqns) = 0, degree(eqns) = 3.

------------------------------

-- numSolsA --

-- Function: Calls typeASchubertIdeal, but instead of outputting the ideal of an intersection of Schubert varieties in a type A flag manifold, gives 
-- directly the dimension and degree of the ideal.

-- Tests:
-- Tests:
-- F1 = random(QQ^6,QQ^6)
-- F2 = random(QQ^6,QQ^6)
-- F3 = random(QQ^6,QQ^6)
-- F4 = random(QQ^6,QQ^6)
-- F5 = random(QQ^6,QQ^6)
-- F6 = random(QQ^6,QQ^6)
-- typeASchubertIdeal({1,2,5},{{2,1},{2,1},{1,3},{1,3},{1,3},{1,3},{1,3}},{F1,F2,F3,F4,F5,F6},QQ) returns (0,5).
-- typeASchubertIdeal({1,2,5},{{2,1},{2,1},{2,1},{1,3},{1,3},{1,3},{1,3}},{F1,F2,F3,F4,F5,F6},QQ) returns (0,3).

------------------------------

-- completePermutation --

-- Function: Takes a partial permutation, and completes it by adjoining the missing elements of [n] to the end in increasing order.

-- Tests: 
-- completePermutation({7,8,4,1,2,3},9) returns {7,8,4,1,2,3,5,6,9}.

------------------------------

-- typeALength --

-- Function: Computes the Coxeter length of a partial permutation by first completing it to a full permutation, and then counting the number of inversions.
-- This length computes the codimension of the corresponding type A Schubert variety.

-- Tests: typeALength({7,8,4,1,2,3},9) returns 15, which is the precise number of inversions of the completed permutation.

------------------------------

-- bubbleSort --

-- Function: For each i from 0 to n-2, we have the simple transposition s_i acting on a list of size n that swaps the entries in position i and position 
-- i+1 (using computer science convention that we start counting at 0). Given a permutation, this function uses simple transpositions to swap elements 
-- until the list is converted into {n,n-1,n-2,...,3,2,1} (the longest length element of S_n). Furthermore, the algorithm employed is guaranteed to use 
-- the minimal number of such transpositions, so keeping track of which transpositions are used by their index i, the output is a reduced word 
-- {i_m,i_{m-1},...,i_2,i_1}, where s_{i_1} is the first transposition used, and s_{i_m} is the last. The algorithm works by finding the first pair of
-- entries (searching from left to right) that are in increasing order, and then swaps them, and records the index of the transposition by adjoining it
-- to the beginning of our reduced word, repeating until the longest length element is obtained. The longest word may appear to be backwards, but the way
-- it will be employed will use these indicies in the reverse order from how we employed them, so this is done on purpose.

-- Tests:
-- bubbleSort({1,2,3,4}) returns {0,1,2,0,1,0}. 
-- bubbleSort({4,3,2,1}) returns {}.

------------------------------

-- deltaSwapA --

-- Function: Applies the divided difference operator delta_i corresponding to the simple transposition s_i (which swaps i and i+1), again following
-- computer science notation where i starts counting from 0 to n-2. This takes a polynomial to a polynomial of degree one less.

-- Tests:
-- Divided difference operators delta_0, delta_1, and delta_2 applied to the "staircase monomial" a^3*b^2*c in QQ[a,b,c,d].
-- R = QQ[a,b,c,d]
-- f = a^3*b^2*c
-- deltaSwapA(f,R,0) returns a^2*b^2*c
-- deltaSwapA(f,R,1) returns a^3*b*c
-- deltaSwapA(f,R,2) returns a^3*b2

------------------------------

-- polyRepA --

-- Function: Given a reduced word from bubbleSort on a permutation, will apply the corresponding divided difference operators via deltaSwapA to
-- the staircase monomial x_1^(n-1)*x_2^(n-2)*...*x_(n-1) to obtain the Schubert polynomial representing the class of the Schubert variety indexed
-- by that permutation in the full flag manifold.

-- Tests: polyRepA(bubbleSort({1,4,3,2}),QQ[a,b,c,d])  returns a^2*b + a*b^2  + a^2*c + a*b*c + b^2*c

-- Test for printing out all permutations at once:
-- for perm in permutations({1,2,3,4}) do(
--       print(perm);
--       print(polyRepA(bubbleSort(perm),QQ[a,b,c,d])))
-- Returns: All 24 Schubert polynomials for S_4

------------------------------

-- elementarySymmetricIdeal --

-- Function: Given a positive integer n, returns a polynomial ring in n variables, the ideal of that ring generated by the elementary symmetric
-- polynomials in n variables, and the corresponding quotient ring. Will be used as input in Schubert problems. The function creates these objects 
-- before an intersection theory problem is given so that if many intersection problems are to be called at once, this step won't be done for each 
-- instance, but just once ahead of time.

-- Tests: elementarySymmetricIdeal(3) gives QQ[x_1,x_2,x_3], and an ideal generated by the 3 elementary symmetric polynomials, and their quotient.

------------------------------

-- intA --

-- Function: Solves Schubert problems in Type A complete flag manifolds. Given a list of Schubert conditions, as well as S and I from 
-- elementarySymmetricIdeal, this function computes the corresponding Schubert polynomials for those conditions, multiplies them together mod I,
-- and reads off the coefficient of the single standard monomial of top degree (has to be a 0-dimensional intersection)
-- NOTE: Currently Struggles if answer is 0, need an "if, then" statement to rectify this.

-- Tests: elementarySymmetricIdeal(4) (sets up S and I)
--       intA({{2,1,3,4},{3,4,2,1}},S,I) returns 1.
--       intA({{2,1,3,4},{4,3,1,2}},S,I) returns error, should be 0 (see NOTE above).
--       intA({{2,1,3,4},{1,3,2,4},{1,3,2,4},{1,3,2,4},{1,3,2,4},{1,2,4,3}},S,I) returns 2.

------------------------------

-- partialIntA --

-- Function: Solves Schubert problems in general Type A flag varieties. It solves the problem of the pulled back conditions in the ambient complete flag
-- manifold, and then intersects the result with the Schubert variety representing the ambient partial flag variety in the complete flag manifold.

-- Tests:
-- partialIntA({1,2,5},{{2,1},{2,1},{1,3},{1,3},{1,3},{1,3},{1,3}},S,I) returns 5.
-- partialIntA({1,2,5},{{2,1},{2,1},{2,1},{1,3},{1,3},{1,3},{1,3}},S,I) returns 3. 
