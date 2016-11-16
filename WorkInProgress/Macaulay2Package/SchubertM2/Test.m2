
newPackage(
  "SchubertIdealsTest",
  Version => "1.0.0", 
  Date => "Novmeber 16, 2016",
  Authors => {
    {Name => "Taylor Brysiewicz"}
  },
  Headline => "Combuting Ideals for Schubert Varieties",
  DebuggingMode => false
)

export{
"getDescents",
"isCondition",
"completePermutation",
"lengthOfPermutation"
}


---------------------------------------------------------------------------------
----------------------------SCHUBERT IDEALS-(Test)-------------------------------
---------------------------------------------------------------------------------
--  This is for methods that are being tested and developed prior to 
--    committing to the main package file
--
---------------------------------------------------------------------------------



---------------------------------------------------------------------------------
-------------------------------CONVENTIONS---------------------------------------
---------------------------------------------------------------------------------
--  flagType is a list {a_1,...,a_s=m,n}={adot,n} with increasing
--    entries. This specifies the type of flag manifold.
--  Example:
--    flagType = (3,6) is the Grassmanian of 3-planes in 6-space
--      here n=6 and m=k=3
--    flagType = (2,3,7) is the manifold of partial flags consisting
--      of a 2-plane in a 3-plane in 7-space. Here n=7,m=3.
---------------------------------------------------------------------------------
--  Schubert conditions are given as partial permutations 
--    for example, w={1,4,6,8,2,9} in flagType={4,6,23}
--  w must have descents only at positions of adot, where
--    where flagType=(adot,n)
---------------------------------------------------------------------------------



---------------------------------------------------------------------------------
----------------------------------METHODS----------------------------------------
---------------------------------------------------------------------------------
--  completePermutation
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--          [name=flagType,dataType=List,mathObject=flagType]
--     Output:
--          [name=w,dataType=List,mathObject=fullPermutation]
--    Description:
--          Takes a partial permutation and completes it by appending the missing
--           numbers in order to the end.
---------------------------------------------------------------------------------
--  getDescents
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--     Output:
--          [name=descents,dataType=List,mathObject=list of descent locations]
--    Description:
--         returns a list of locations of descents for a given permutation
--         
---------------------------------------------------------------------------------
--  isCondition
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--          [name=flagType,dataType=List,mathObject=flagType]
--     Output:
--          boolean
--    Description:
--         decides whether or not a schubert condition is valid for
--         the flagType given
---------------------------------------------------------------------------------
--  lengthOfPermutation
--    Input:
--         [name=w,dataType=List,mathObject=full permutation]
--    Output:
--         [name=len,dataType=integer,mathObject=length of w]
--    Description:
--         returns the length of a permutation
---------------------------------------------------------------------------------
--  <INSERT METHOD NAME HERE>
--     Input:
--          [name=,dataType=,mathObject=]
--          [name=,dataType=,mathObject=]
--     Output:
--          [name=,dataType=,mathObject=]
--          [name=,dataType=,mathObject=]
--    Description:
--         
---------------------------------------------------------------------------------



---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
----------------------------------CODE----------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------





completePermutation = method()
---------------------------------------------------------------------------------
--  completePermutation
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--          [name=flagType,dataType=List,mathObject=flagType]
--     Output:
--          [name=w,dataType=List,mathObject=fullPermutation]
--    Description:
--          Takes a partial permutation and completes it by appending the missing
--           numbers in order to the end.
--    Notes:
--          You actually don't need the flagType. You seem to only need "n"
---------------------------------------------------------------------------------
completePermutation(List,List):=(w,flagType) ->(
    n:=last(flagType);
    for i from 1 to n do(
	if isSubset({i},w)==false then w=append(w,i);
	),
    return(w)
    )
---------------------------------------------------------------------------------
--Example:
	w={2,8,3,4,7,1,5,6}
	u={1,3,5,7,2,4,6,8}
	myFlagType={2,5,8}
	completePermutation(w,myFlagType)
	completePermutation(u,myFlagType)
---------------------------------------------------------------------------------









getDescents = method()
---------------------------------------------------------------------------------
--  getDescents
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--     Output:
--          [name=descents,dataType=List,mathObject=list of descent locations]
--    Description:
--         returns a list of locations of descents for a given permutation
--         
---------------------------------------------------------------------------------
getDescents(List):=(w) ->(
    w=completePermutation(w,{max(w)});
    descents:={};
    for i from 0 to #w-2 do(
	if((w#i)>(w#(i+1))) then descents=append(descents,i+1);
	),
    return(descents)
    )
---------------------------------------------------------------------------------
--Example:
	w={2,8,3,4,7,1,5,6}
	v={2,8}
	getDescents(w)
	getDescents(u)
---------------------------------------------------------------------------------






isCondition = method()
---------------------------------------------------------------------------------
--  isCondition
--     Input:
--          [name=w,dataType=List,mathObject=partialPermutation]
--          [name=flagType,dataType=List,mathObject=flagType]
--     Output:
--          boolean
--    Description:
--         decides whether or not a schubert condition is valid for
--         the flagType given
---------------------------------------------------------------------------------
isCondition(List,List):=(w,flagType) ->(
    descents:=getDescents(w);
    return(isSubset(descents,flagType))
    )
---------------------------------------------------------------------------------
--Example:
	myFlagType = {2,5,8}
	w = {2,8, 3,4,7, 1,5,6}
	v = {2,4, 5,7,8}
	u = {1,3,5,7, 2,4,6,8}
	x = {2,8}
	
	isCondition(w,myFlagType)
	isCondition(v,myFlagType)
	isCondition(u,myFlagType)
	isCondition(x,myFlagType)
---------------------------------------------------------------------------------






lengthOfPermutation = method()
---------------------------------------------------------------------------------
--    Input:
--         [name=w,dataType=List,mathObject=partial or full permutation]
--    Output:
--         [name=len,dataType=integer,mathObject=length of w]
--    Description:
--         returns the length of a permutation
--    Notes:
--         You actually don't need to know the flagType if it is a partial perm
--          in order to compute this. (think about it)
--          if it is a partial perm for a flagType, then "n" must appear in the
--          partial perm. So you know n is the max of w
---------------------------------------------------------------------------------
lengthOfPermutation(List):=(w) ->(
    len:=0;
    w=completePermutation(w,{max(w)});
    --print("We've completed the permutation to:");
    --print(w);
    for i from 0 to #w-1 do(
	for j from i+1 to #w-1 do(
	    if((w#i)>(w#j)) then len=len+1;--tally length for each descent
	    ),
	),
    return(len)
    )
---------------------------------------------------------------------------------
--Example:
	w = {2,8, 3,4,7, 1,5,6}
	v = {2,4, 5,7,8}
	u = {1,3,5,7, 2,4,6,8}
	x = {2,8}
	lengthOfPermutation(w)
	lengthOfPermutation(v)
	lengthOfPermutation(u)
	lengthOfPermutation(x)
---------------------------------------------------------------------------------










