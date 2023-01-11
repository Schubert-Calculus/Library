-- TO-DO LIST:
-- Actually detail out the "Inputs" and "Outputs" (can copy and paste a lot)
-- Add 1-liners for code in other file
-- Add tests for trivial intersection giving reverse identity flag itself back (G(1,4) and G(2,4) examples maybe)
-- Fix "intA" code to deal with empty intersections (0 solutions)
-- Possibly fix "intA" code to instead of extracting coefficient, divide by the basis element (takes care of negative coefficients of the basis element)
----
-- Type B and C code documentation
-- Redo code to follow Billey's thesis

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

-- TYPE A CODE

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

-- Tests: (DOESN'T WORK IF ONLY LOAD PACKAGE, HAVE TO HAVE PATH CORRECT FIRST)
-- (1) dimToCodim({2,4},{3,4}) should give {1,2} (the dense cell goes to the point)
-- (2) dimToCodim({2,4},{1,4}) should give {1,4} (self-dual example)
-- (3) dimToCodim({3,17,21},{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17}) should give {19, 20, 21, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18}
--     (just to have a more complicated example)

------------------------------

-- splitPermutation --

-- Function: A helper function that will split a partial permutation into a list of lists, separations determined by the flagshape.

-- Inputs:
-- (1) flagshape, a list {a_1,...,a_s,n}.
-- (2) alpha, a list {alpha_1,...,alpha_(a_s)} giving a Schubert condition of that shape.

-- Outputs:
-- (1) splitperm, a list of lists, whose concatenations give back alpha, broken up by the locations of possible descents from the prescribed flagshape.

-- Tests:
-- (1) splitPermutation({2,3,6,9},{7,8,4,1,2,3}) should return {{7,8},{4},{1,2,3}}.

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

-- Inputs: 
-- (1) beta, a partial permutation.
-- (2) alpha, a partial permutation of the same size as beta.

-- Outputs:
-- (1) notgreaterthan, a Boolean: "true" if beta is not greater than or equal to alpha (in the Bruhat order), and "false" otherwise.

-- Tests:
-- (1) notGreaterThan({1,2},{3,4}) returns "true"
-- (2) notGreaterThan({3,4},{1,2}) returns "false"
-- (3) notGreaterThan({1,4},{2,3}) returns "true" (incomparable example)
-- (4) notGreaterThan({1,2},{1,2}) returns "false"

------------------------------

-- allNotGreaterThan --

-- Function: For a fixed partial permutation, alpha, lists all other partial permutations of the same shape as alpha that are NOT greater than
-- alpha in the Bruhat partial order.

-- Inputs: 
-- (1) alpha, a partial permutation.
-- (2) n, a positive integer detailing that alpha comes as a subset of {1,...,n}.

-- Outputs:
-- (1) L, 

-- Tests:
-- (All examples in G(2,4))
-- (1) allNotGreaterThan({1,2},4) returns "{}"
-- (2) allNotGreaterThan({1,3},4) returns "{{1,2}}"
-- (3) allNotGreaterThan({1,4},4) returns "{{1,2},{1,3},{2,3}}"
-- (4) allNotGreaterThan({2,3},4) returns "{{1,2},{1,3},{1,4}}"
-- (5) allNotGreaterThan({2,4},4) returns "{{1,2},{1,3},{2,3},{1,4}}"
-- (6) allNotGreaterThan({3,4},4) returns "{{1,2},{1,3},{2,3},{1,4},{2,4}}"

------------------------------

-- cauchyBinetCoefficients --

-- Function: Creates the matrix of coefficients from the Cauchy-Binet formula P(alpha)(F^{-1}). See Theorem 1.3 and the preceeding discussion in 
-- "Numerical Schubert Calculus via the Littlewood-Richardson Homotopy Algorithm" (Leykin, del Campo, Sottile, Vakil, Verschelde).

-- Inputs:
-- (1) grassmannianshape, a list {k,n} giving the type of a Grassmannian.
-- (2) betas, an indexing set of partial permutations detailing which minors will be considered. For us, will be all betas not greater than or equal to
--            a specified alpha in the Bruhat order (see reference above).
-- (3) F, an invertible matrix representing a flag.
-- (4) K, a field.

-- Outputs:
-- (1) M, a matrix. For our uses, it will produce P(alpha)(F^{-1}) (see reference above).

-- Tests: 
-- (1) cauchyBinetCoefficients({2,4},allNotGreaterThan({2,4},4),id_(QQ^4),QQ) returns non-square identity-like matrix.

------------------------------

-- typeASchubertIdeal --

-- Function: Creates the ideal for an intersection of Schubert varieties in a given type A flag variety (could be Grassmannian, complete, or partial).
-- Note that in this situation, we can always assume that the first flag given is represented by the identity matrix, so we implement it as such. Thus,
-- the user inputs 1 fewer flag than conditions.

-- Inputs: 
-- (1) flagshape, a list {a_1,...,a_s,n}.
-- (2) alphas, a list of lists {alpha_1,...,alpha_(a_s)}, each giving a Schubert condition of that shape.
-- (3) flags, invertible nxn matrices representing general flags.
-- (4) K, a field.

-- Outputs: 
-- (1) eqns, an ideal with generators the defining equations (in local coordinates) of the corresponding Schubert intersection problem.

-- Tests:
-- All computations in G(2,4). Have to create some random flags first before use. After ideal I is returned, can use dim I, degree I to extract info.
-- (1)
-- F1 = random(QQ^4,QQ^4)
-- F2 = random(QQ^4,QQ^4)
-- F3 = random(QQ^4,QQ^4)
-- (1a) typeASchubertIdeal({2,4},{{3,4},{1,2}},{F1},QQ) returns 0 ideal in QQ
-- (1b) typeASchubertIdeal({2,4},{{1,2},{3,4}},{F1},QQ) returns an ideal with many generators in QQ[x_{3,1},x_{3,2},x_{4,1},x_{4,2}].
-- NOTE: The above 2 examples give the same (trivial) intersection with dim I = 0, degree I = 1. However, the coordinates are with respect to the first 
--       Schubert condition, so putting the larger length partial permutation first gives fewer variables and is preferable.
-- (1c) typeASchubertIdeal({2,4},{{1,3},{1,3},{1,3},{1,3}},{F1,F2,F3},QQ) returns an ideal I with dim I = 0, degree I = 2.
-- (1d) typeASchubertIdeal({2,4},{{1,3},{1,3}},{F1},QQ) returns an ideal I with dim I = 2, degree I = 2 (so doesn't have to be 0-dimensional).
-- (1e) typeASchubertIdeal({2,4},{{1,4},{2,3}},{F1},QQ) returns an ideal I with dim I = -1, degree I = 0 (even though codimensions add to 
-- (2)                                                        the dimension of G(2,4), they are not dual, and so give an empty intersection).
-- F1 = random(QQ^5,QQ^5)
-- F2 = random(QQ^5,QQ^5)
-- F3 = random(QQ^5,QQ^5)
-- F4 = random(QQ^5,QQ^5)
-- F5 = random(QQ^5,QQ^5)
-- F6 = random(QQ^5,QQ^5)
-- (2a) typeASchubertIdeal({1,2,5},{{2,1},{2,1},{1,3},{1,3},{1,3},{1,3},{1,3}},{F1,F2,F3,F4,F5,F6},QQ) returns an ideal eqns with dim(eqns) = 0, degree(eqns) = 5.
-- (2b) typeASchubertIdeal({1,2,5},{{2,1},{2,1},{2,1},{1,3},{1,3},{1,3},{1,3}},{F1,F2,F3,F4,F5,F6},QQ) returns an ideal eqns with dim(eqns) = 0, degree(eqns) = 3.
-- (3)
-- F1 = random(QQ^6,QQ^6)
-- F2 = random(QQ^6,QQ^6)
-- F3 = random(QQ^6,QQ^6)
-- (3a) typeASchubertIdeal({2,4,6},{{1,4,2,5},{1,4,2,5},{1,4,2,5},{1,4,2,5}},{F1,F2,F3},QQ) returns an ideal eqns with dim(eqns) = 0, degree(eqns) = 6.

------------------------------

-- numSolsA --

-- Function: Calls typeASchubertIdeal, but instead of outputting the ideal of an intersection of Schubert varieties in a type A flag manifold, gives 
-- directly the dimension and degree of the ideal.

-- Inputs: 
-- (1) flagshape, a list {a_1,...,a_s,n}.
-- (2) alphas, a list of lists {alpha_1,...,alpha_(a_s)}, each giving a Schubert condition of that shape.
-- (3) flags, invertible nxn matrices representing general flags.
-- (4) K, a field. 

-- Outputs: 
-- (1) dim I, the dimension of the corresponding Schubert intersection problem.
-- (2) degree I, the degree of the corresponding Schubert intersection problem. If dim I = 0, this degree is the number of solutions to the system.

-- Tests:
-- (1)
-- F1 = random(QQ^5,QQ^5)
-- F2 = random(QQ^5,QQ^5)
-- F3 = random(QQ^5,QQ^5)
-- F4 = random(QQ^5,QQ^5)
-- F5 = random(QQ^5,QQ^5)
-- F6 = random(QQ^5,QQ^5)
-- (1a) numSolsA({1,2,5},{{2,1},{2,1},{1,3},{1,3},{1,3},{1,3},{1,3}},{F1,F2,F3,F4,F5,F6},QQ) returns (0,5).
-- (1b) numSolsA({1,2,5},{{2,1},{2,1},{2,1},{1,3},{1,3},{1,3},{1,3}},{F1,F2,F3,F4,F5,F6},QQ) returns (0,3).

------------------------------

-- completePermutation --

-- Function: Takes a partial permutation, and completes it by adjoining the missing elements of {1,...,n} to the end in increasing order.

-- Inputs: 
-- (1) w, a partial permutation.
-- (2) n, a positive integer detailing that w comes as a subset of {1,...,n}.

-- Outputs: 
-- (1) wcomplete, a permutation of {1,...,n} that is w completed.

-- Tests: 
-- (1) completePermutation({7,8,4,1,2,3},9) returns {7,8,4,1,2,3,5,6,9}.

------------------------------

-- typeALength --

-- Function: Computes the Coxeter length of a partial permutation by first completing it to a full permutation, and then counting the number of inversions.
-- This length computes the codimension of the corresponding type A Schubert variety.

-- Inputs: 
-- (1) w, a partial permutation.
-- (2) n, a positive integer detailing that w comes as a subset of {1,...,n}.

-- Outputs: 
-- (1) count, the Coxeter length of w.

-- Tests: 
-- (1) typeALength({7,8,4,1,2,3},9) returns 15, which is the precise number of inversions of the completed permutation.

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

-- Inputs: 
-- (1) L, a (full) permutation.

-- Outputs: 
-- (1) swaps, A list corresponding to the indicies of a reduced word for L as a product of transpositions.

-- Tests:
-- (1) bubbleSort({1,2,3,4}) returns {0,1,2,0,1,0}. 
-- (2) bubbleSort({4,3,2,1}) returns {}.

------------------------------

-- deltaSwapA --

-- Function: Applies the divided difference operator delta_i corresponding to the simple transposition s_i (which swaps i and i+1), again following
-- computer science notation where i starts counting from 0 to n-2. This takes a polynomial to a polynomial of degree one less.

-- Inputs: 
-- (1) f, a multivariate polynomial.
-- (2) R, a polynomial ring containing f (could contain more variables).
-- (3) k, a nonnegative integer (corresponding to which divided difference operator to apply).

-- Outputs: 
-- (1) fnew, the polynomial produced by applying the kth divided difference operator to f (should be 1 degree less).

-- Tests:
-- (1)
-- Divided difference operators delta_0, delta_1, and delta_2 applied to the "staircase monomial" a^3*b^2*c in QQ[a,b,c,d].
-- R = QQ[a,b,c,d]
-- f = a^3*b^2*c
-- (1a) deltaSwapA(f,R,0) returns a^2*b^2*c
-- (1b) deltaSwapA(f,R,1) returns a^3*b*c
-- (1c) deltaSwapA(f,R,2) returns a^3*b^2

------------------------------

-- polyRepA --

-- Function: Given a reduced word from bubbleSort on a permutation, will apply the corresponding divided difference operators via deltaSwapA to
-- the staircase monomial x_1^(n-1)*x_2^(n-2)*...*x_(n-1) to obtain the Schubert polynomial representing the class of the Schubert variety indexed
-- by that permutation in the full flag manifold.

-- Inputs: 
-- (1) w, a list of indicies corresponding to a reduced word for a (full) permutation.
-- (2) R, a polynomial ring from which the staircase monomial will be computed.

-- Outputs: 
-- (1) polyrep, the Schubert polynomial representative for the Schubert class indexed by the (full) permutation w was the reduced word for.

-- Tests: 
-- (1) polyRepA(bubbleSort({1,4,3,2}),QQ[a,b,c,d])  returns a^2*b + a*b^2  + a^2*c + a*b*c + b^2*c
-- (2) Test for printing out all permutations at once:
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

-- Inputs: 
-- (1) n, a positive integer.

-- Outputs:
-- (1) S, the polynomial ring in n variables.
-- (2) I, the ideal of S generated by all elementary symmetric polynomials in n variables.

-- Tests: 
-- (1) elementarySymmetricIdeal(3) gives QQ[x_1,x_2,x_3], and the ideal generated by the 3 elementary symmetric polynomials.

------------------------------

-- intA --

-- Function: Solves Schubert problems in Type A complete flag manifolds. Given a list of Schubert conditions, as well as S and I from 
-- elementarySymmetricIdeal, this function computes the corresponding Schubert polynomials for those conditions, multiplies them together mod I,
-- and reads off the coefficient of the single standard monomial of top degree (has to be a 0-dimensional intersection)
-- NOTE: Currently Struggles if answer is 0, need an "if, then" statement to rectify this.

-- Inputs: 
-- (1) alphas, a list of lists {alpha_1,...,alpha_(a_s)}, each giving a Schubert condition of that shape.
-- (2) S, the polynomial ring in n variables.
-- (3) I, the ideal of S generated by all elementary symmetric polynomials in n variables.

-- Outputs: 
-- (1) numsols, the number of solutions to the Schubert problem.

-- Tests: 
-- (1)
-- (S,I) = elementarySymmetricIdeal(4) (sets up S and I) 
-- (1a) intA({{2,1,3,4},{3,4,2,1}},S,I) returns 1.
-- (1b) intA({{2,1,3,4},{4,3,1,2}},S,I) returns error, should be 0 (see NOTE above).
-- (1c) intA({{2,1,3,4},{1,3,2,4},{1,3,2,4},{1,3,2,4},{1,3,2,4},{1,2,4,3}},S,I) returns 2.

------------------------------

-- partialIntA --

-- Function: Solves Schubert problems in general Type A flag varieties. It solves the problem of the pulled back conditions in the ambient complete flag
-- manifold, and then intersects the result with the Schubert variety representing the ambient partial flag variety in the complete flag manifold.

-- Inputs: 
-- (1) flagshape, a list {a_1,...,a_s,n}.
-- (2) alphas, a list of lists {alpha_1,...,alpha_(a_s)}, each giving a Schubert condition of that shape.
-- (3) S, the polynomial ring in n variables.
-- (4) I, the ideal of S generated by all elementary symmetric polynomials in n variables.

-- Outputs: 
-- (1) numsols, the number of solutions to the Schubert problem.

-- Tests: 
-- (1) 
-- (S,I) = elementarySymmetricIdeal(5)
-- (1a) partialIntA({1,2,5},{{2,1},{2,1},{1,3},{1,3},{1,3},{1,3},{1,3}},S,I) returns 5.
-- (1b) partialIntA({1,2,5},{{2,1},{2,1},{2,1},{1,3},{1,3},{1,3},{1,3}},S,I) returns 3. 
-- (2)
-- (S,I) = elementarySymmetricIdeal(6)
-- (2a) partialIntA({2,4,6},{{1,4,2,5},{1,4,2,5},{1,4,2,5},{1,4,2,5}},S,I) returns -6 (I checked, and the staircase monomial % I has negative representative...)





