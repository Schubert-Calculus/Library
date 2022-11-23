newPackage(
  "TestLibrary",
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
  "splitPermutation"
}


----------------------------
--METHODS --
----------------------------


dimToCodim = method()
dimToCodim(List,List) := (flagshape,alpha) -> (
      s := length(flagshape) - 1;
      n := flagshape_(-1);
      breaks := prepend(0,flagshape);
      alphadual = {};
      for b from 1 to s do(
            k := breaks_(b) - breaks_(b-1);
            for i from 1 to k do(
                  alphadual := append(alphadual,n+1-alpha_(breaks_(b-1)+k-i))));
      return(alphadual))

splitPermutation = method()
splitPermutation(List,List) := (flagshape,alpha) -> (
      gaps := {flagshape_(0)};
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

