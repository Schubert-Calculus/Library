newPackage(
  "NewSchubertIdeals",
  Version => "0.0.1", 
  Date => "November 30, 2022",
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
  "dualCondition",
  "splitPermutation",
  "stiefelCoords",
  "notGreaterThan",
  "allNotGreaterThan",
  "cauchyBinetCoefficients",
  "schubertIdeal",
  "numSols",
  "completePermutation",
  "coxeterLength"
}

exportMutable{"Field","VariableName"}
------------------------------
-- DECLARE VARIABLES --
x := symbol x;
y := symbol y;
t := symbol t;
------------------------------

------------------------------
-- METHODS --
------------------------------

--------------------------------------------------

-- TYPE A CODE

--------------------------------------------------

-- Converts a partial permutation in dimension notation to the corresponding one in codimension notation. (Equivalently, gives the dual class).
dualCondition = method()
dualCondition(List,List) := (flagtype,condition) -> (
      s := length(flagtype) - 1;
      n := flagtype_(-1);
      breaks := prepend(0,flagtype);
      dualcondition := {};
      for b from 1 to s do(
            k := breaks_(b) - breaks_(b-1);
            for i from 1 to k do(
                  dualcondition = append(dualcondition,n+1-condition_(breaks_(b-1)+k-i))));
      return(dualcondition))

-- A helper function for typeAStiefelCoords
splitPermutation = method()
splitPermutation(List,List) := (flagtype,condition) -> (
      gaps := {flagtype_(0)};
      for i from 1 to (length(flagtype)-2) do(
            gaps = append(gaps,flagtype_(i)-flagtype_(i-1)));
      splitperm := {};
      copycondition := condition;
      for gap in gaps do(
            subcondition := {};
            for i from 0 to (gap-1) do(
                  subcondition = append(subcondition,copycondition_(0));
                  copycondition = delete(copycondition_(0),copycondition));
            splitperm = append(splitperm,subcondition));
      return(splitperm))

-- Gives the Stiefel Coordinates for a Type A Schubert Variety
stiefelCoords = method(Options => true)
stiefelCoords(List,List) := {Field => QQ,VariableName => x} >> o -> (flagtype,condition) -> (
-- Define ring of variables
     K := o.Field;
     x := o.VariableName;
     n := flagtype_(-1);
     as := flagtype_(-2);
     S := K[x_(1,1)..x_(n,as)];
-- Define matrix of correct size (and over the correct ring) that we can manipulate
     M := mutableMatrix(S,n,as);
     dualcondition := dualCondition(flagtype,condition);
-- Set leading ones in asxas identity submatrix with rows indexed by condition
     for i from 1 to as do M_(dualcondition_(i-1)-1,i-1) = 1;
-- Set variables above the leading 1's
     for j from 1 to as do
     for i from 1 to dualcondition_(j-1)-1 do M_(i-1,j-1) = x_(i,j);
-- Set to 0 all entries below and to the right of leading 1's
     for i from 1 to as do
     for j from i+1 to as do M_(dualcondition_(i-1)-1,j-1) = 0;
-- Make matrix non-mutable
     M = matrix M;
-- Create a new ring with variables only those that show up in the matrix M
     R := K[support M];
-- Make it so that M is a matrix over the new ring
     M = sub(M,R);
-- Return Stiefel coordinates and new ring
     return({M, R}))
     
----- NOTE: "exteriorPower(k,M)" will compute the Plucker vector for us -----
----- NOTE: "subsets({1..n},k)" will compute all k element subsets of {1,...,n} for us, 
-----             IN THE SAME ORDERING as the Plucker vector from "exteriorPower" above -----
     
-- Returns whether a partial permutation is not greater than or equal to another in the Bruhat order.
notGreaterThan = method(TypicalValue=>Boolean)
notGreaterThan(List,List) := (beta,condition) -> (
      notgreaterthan := false;
      for i from 1 to length(beta) do
            if beta_(i-1) < condition_(i-1) then notgreaterthan = true;
      return(notgreaterthan))
      
-- Gives all partial permutations not greater than or equal to a fixed one.
allNotGreaterThan = method()
allNotGreaterThan(List,ZZ) := (condition, n) -> (
      L := {};
      for beta in subsets(splice {1..n},length(condition)) do
            if notGreaterThan(beta,condition) then L = append(L,beta);
      return(L))

-- Computes the P(condition)(F^{-1}) matrix that is essential in finding a minimal number of generators for the ideal of a Schubert problem.
cauchyBinetCoefficients = method(Options => true)
cauchyBinetCoefficients(List,List,Matrix) := {Field => QQ} >> o -> (grassmannianshape,betas,F) -> (
      K := o.Field;
      k := grassmannianshape_(0);
      n := grassmannianshape_(1);
      Finv := inverse F;
      M := mutableMatrix(K,length(betas),binomial(n,k));
      subs := subsets(splice {1..n},k);
      kones := splice{k:1};
      for i from 0 to length(betas)-1 do(
            for j from 0 to binomial(n,k)-1 do(
                  M_(i,j) = det(submatrix(Finv,betas_(i)-kones,subs_(j)-kones))));
      M = matrix M;
      return(M))

-- Computes the ideal for a Type A Schubert problem.
schubertIdeal = method(Options => true)
----- NOTE: There should be m conditions and m-1 flags (first flag will be assumed to be the identity and not given as input)
----- NOTE: The flags should be general and the condition's codimensions should add up to k(n-k) to give an actual Schubert problem
schubertIdeal(List,List,List) := {Field => QQ} >> o -> (flagtype,conditions,flags) -> (
      K := o.Field;
      n := last(flagtype);
      q := length(flags);
      subspaces := delete(n,flagtype);
      bigcoords := (stiefelCoords(flagtype,conditions_(0),Field=>K))_(0);
      bigring := (stiefelCoords(flagtype,conditions_(0),Field=>K))_(1);
      eqns := ideal(0_bigring);
      for a in subspaces do(
           coords := submatrix(bigcoords,{0..(a-1)});
	   PY := exteriorPower(a,coords);
           conds := {sort(take(conditions_(0),a))};
           for i from 1 to q do(
                conds = append(conds,sort(take(conditions_(i),a))));
           for i from 1 to length(conds)-1 do( 
                 eqns = eqns + sub(ideal(cauchyBinetCoefficients({a,n},allNotGreaterThan(conds_(i),n),flags_(i-1),Field=>K)*PY),bigring)));
      return(eqns))

-- Computes the dimension and degree of the ideal of a Type A Schubert problem.
numSols = method(Options => true)
numSols(List,List,List) := {Field => QQ} >> o -> (flagtype,conditions,flags) -> (
      K := o.Field;
      I := schubertIdeal(flagtype,conditions,flags,Field=>K);
      return (dim I, degree I))

-- Completes a partial permutation into a full one.
completePermutation = method(TypicalValue=>List)
completePermutation(List,ZZ):=(w,n) ->(
      wcomplete := w;
      for i from 1 to n do(
            if isSubset({i},wcomplete)==false then wcomplete=append(wcomplete,i));
      return(wcomplete))

-- Gives the Coxeter length of a partial permutation.
coxeterLength = method()
coxeterLength(List,ZZ) := (w,n) -> (
      wcomp := completePermutation(w,n);
      count := 0;
      for i from 1 to n do
            for j from i+1 to n do
                  if wcomp_(i-1) > wcomp_(j-1) then count = count+1;
      return(count))
