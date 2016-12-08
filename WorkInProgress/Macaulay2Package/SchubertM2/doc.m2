Node
  Key
    SchubertIdeals
  Headline
    Computating ideals of Schubert varieties on flag varieties.
  Description
    Text
      
      This package computes ideals defining Schubert varieties on flag varieties. Such ideals are indexed by collections of
			Schubert conditions on flags. A Schubert condition consists of a permutation along with a flag. The permutation encodes
			intersection conditions with the given flag. A solution to a Schubert problem will describe a flag that satisfies each
      of these conditions.
	--Subnodes


--------

Node
  Key
   restrictRing
  Headline
  	considers a ring element in the ring of its support
  Usage
		restrictRing(f)
  Inputs
  	f:RingElement
			usually a polynomial which one wants to consider in a restricted ring
  Outputs
   g:RingElement
    the same polynomial as f, now living in a ring whose generators are the support of f.
  Consequences
    Item
			If one enters a polynomial in the support of f after calling restrictRing(f), then this polynomial will also be considered as an element of the smaller ring.
  Description
    Text
			Restricting a polynomial to the ring of its support
    Example
			QQ[x,y]
			f=(x+y)^2-x^2-2*x*y
		  g=restrictRing(f)
