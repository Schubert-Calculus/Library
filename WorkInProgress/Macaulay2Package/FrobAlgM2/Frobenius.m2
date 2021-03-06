----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------FROBENIUS ALGORITHM-----------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
-----Author: Taylor Brysiewicz----------------------------------------------------------------------------
----Purpose: This software will compute cycle types of the monodromy group associated to a family---------
----------------of polynomial systems. It will also determine whether or not the monodromy group----------
----------------is the full symmetric group---------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
-----Functions:-------------------------------------------------------------------------------------------
-------smartFactor----------------------------------------------------------------------------------------
--------Input: currently, "factor" in M2 gives an object of the class Product. It is a few lines of ------
------------------code to pull information from a Product object so this function does exactly that-------
---------------a ring element F---------------------------------------------------------------------------
-------Output: a list of pairs. Each pair is comprised of the factor and the power of the factor----------
----------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------
---frobeniusForEliminant:---------------------------------------------------------------------------------
--------Input: an eliminant in one variable and n coefficients, the number of solutions to the eliminant--
-----------------and the number of frobenius lifts you want it to attempt---------------------------------
--------Output: a list of all of the frobenius lift cycle types-------------------------------------------
--frobeniusForIdeal:--------------------------------------------------------------------------------------
--------Input: same as above. replace eliminant in one variable <----> system of polynomials--------------
--------Output: same as above-----------------------------------------------------------------------------



myPrimes:={1009, 1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097, 1103,
    1109, 1117, 1123, 1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223, 1229, 1231,
	                1237, 1249, 1259, 1277, 1279, 1283, 1289, 1291, 1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 1367,
	                1373, 1381, 1399, 1409, 1423, 1427, 1429, 1433, 1439, 1447, 1451, 1453, 1459, 1471, 1481, 1483, 1487,
	                1489, 1493, 1499, 1511, 1523, 1531, 1543, 1549, 1553, 1559, 1567, 1571, 1579, 1583, 1597, 1601, 1607,
	                1609, 1613, 1619, 1621, 1627, 1637, 1657, 1663, 1667, 1669, 1693, 1697, 1699, 1709, 1721, 1723, 1733,
	                1741, 1747, 1753, 1759, 1777, 1783, 1787, 1789, 1801, 1811, 1823, 1831, 1847, 1861, 1867, 1871, 1873,
	                1877, 1879, 1889, 1901, 1907, 1913, 1931, 1933, 1949, 1951, 1973, 1979, 1987, 1993, 1997, 1999}


smartFactor = method()
smartFactor(RingElement) := (F) ->(
    P:=factor(F);
    L1:=new List from(P);
    L2:=for p in L1 list(new List from p);
    return(L2)
    )
---frobeniusForEliminant needs an update. been focusing on other frobenius
frobeniusForEliminant = method()
frobeniusForEliminant(RingElement,ZZ,ZZ,ZZ) := (E,n,numSols,runs) ->(
  theRing:=ring(E);
  replaceables:=for i from 0 to n-1 list(theRing_i);
  variables:=for i from n to numgens(theRing)-1 list(theRing_i);
  varRing:=ZZ[variables];
  cycleList:={};--n cyc, n-1 cyc, p<n-2, (p>n/2 as a factor)
  for i from 0 to runs do(
      replacements:=for j from 0 to n-1 list(theRing_j=>random(ZZ));--throw in some negatives and stuff
      replacements=flatten append(replacements,for j from n to numgens(theRing)-1 list(theRing_j=>varRing_(j-n)));
      Phi:=map(varRing,theRing,replacements);
      Enew:=Phi(E);
      p:=5;
      primeRing:=GF(p)[gens(varRing)];
      Psi:=map(primeRing,varRing,for j from 0 to numgens(varRing)-1 list(varRing_j=>primeRing_j));
      factorList:=smartFactor(Psi(Enew));
      if (product(for fac in factorList list(fac#1))) == 1 then (cycleList=append(cycleList,flatten for fac in factorList list(degree(fac#0))));
      ),
  cycleList=for c in cycleList list(if c#(#c-1) != 0 then c else delete(0,c));
  finalCycleList:={};
  for c in cycleList do(if sum(c)==numSols then finalCycleList=append(finalCycleList,c));
  use theRing;--so M2 keeps using the ring that was being used prior to this function being called
  return(finalCycleList)
  )
--------------------------------------------------------------------------------------------------------------------------
--Input: an ideal. the number of coefficients to be replaced each frobenius run, number of solutions, number of runs
--Output: a tally of cycle types found
--------------------------------------------------------------------------------------------------------------------------


frobeniusForIdeal = method()
--this first guy is if you've computed a general eliminant
frobeniusForIdeal(Ideal,ZZ,ZZ,ZZ) := (I,n,numSols,runs) ->(
  theRing:=ring(I);--this is the ring the ideal given lives in
  replaceables:=for i from 0 to n-1 list(theRing_i);--these are the coefficients that will be replaced by random numbers
  variables:=for i from n to numgens(theRing)-1 list(theRing_i);--these are the honest variables in theRing
  varRing:=ZZ[variables];--make a ring with just the honest variables
  cycleList:={};--this accumulates the cycle types found
  fullCycle:=0;
  nmoCycle:=0;
  primeCycle:=0;
  for i from 0 to runs do(--run a bunch of frobenius lifts
      replacements:=for j from 0 to n-1 list(theRing_j=>random(ZZ));--throw in some negatives and stuff
      replacements=flatten append(replacements,for j from n to numgens(theRing)-1 list(theRing_j=>varRing_(j-n)));
      Phi:=map(varRing,theRing,replacements);
      Inew:=Phi(I);
      p:=myPrimes#(random(0,#myPrimes-1));--313
      primeRing:=GF(p)[gens(varRing)];
      elimVar:=random(0,numgens(primeRing)-1);
      Psi:=map(primeRing,varRing,for j from 0 to numgens(varRing)-1 list(varRing_j=>primeRing_j));
      killList:={};
     -- print("Eliminating variable");
     -- print(primeRing_(elimVar));
      for k from 0 to numgens(primeRing)-1 do(
	if k != elimVar then killList = append(killList,primeRing_k);
	),
      Enew:=eliminate(Psi(Inew),killList);--creates eliminant of ideal in F_p
     -- print(Enew);
      if numgens(Enew) != 0 then(
        Enew=((entries gens(Enew))#0)#0;
        factorList:=smartFactor(Enew);
        if (product(for fac in factorList list(fac#1))) == 1 then (--make sure its square free
	    degreeCycleList:=flatten for fac in factorList list(degree(fac#0));--take a list of the degrees
	    if(#degreeCycleList !=0 and sum(degreeCycleList)==numSols) then(--make sure its not the empty list and that the sum equals degree
		  if(degreeCycleList#(#degreeCycleList-1) != 0) then(
	            cycleList=append(cycleList,degreeCycleList);
	          )
	          else cycleList=append(cycleList,delete(0,degreeCycleList));
        
	    ),
        ),
      ),
  print(tally cycleList);
  ),
  use theRing;--so M2 keeps using the ring that was being used prior to this function being called
  return(cycleList)   
    )



    
    
R=ZZ[b_2,b_3,b_4,b_5,a_2,a_3]
c43=b_4+3*a_2*b_3+2*a_3*b_2+a_2^2*b_2;
c53=b_5+4*a_2*b_4+3*a_3*b_3+3*a_2^2*b_3+2*a_2*a_3*b_2;
I3=ideal(c43,c53)
tally(frobeniusForIdeal(I3,4,3,100))

--635+1751+1127
--ZZ[x]
--x^4+3*x+3
--T=ZZ[b_2,b_3,b_4,b_5,b_6,b_7,b_8,a_2,a_3,a_4]

--c54=b_5+4*a_2*b_4+3*a_3*b_3+3*a_2^2*b_3+2*a_4*b_2+2*a_2*a_3*b_2
--c64=b_6+5*a_2*b_5+4*a_3*b_4+6*a_2^2*b_4+3*a_4*b_3+6*a_2*a_3*b_3+a_2^3*b_3+2*a_2*a_4*b_2+a_3^2*b_2
--c74=b_7+6*a_2*b_6+5*a_3*b_5+10*a_2^2*b_5+4*a_4*b_4+12*a_2*a_3*b_4+4*a_2^3*b_4+6*a_2*a_4*b_3+3*a_3^2*b_3+3*a_2^2*a_3*b_3+2*a_3*a_4*b_2
--I4=ideal(c54,c64,c74)

--Results=frobeniusForIdeal(I4,7,8,5000)
--tally(Results)
--tally(frobeniusForIdeal(I4,7,8,1000))



--schubert problem from robert (full symmetric)
--SSS=ZZ[y_1..y_(100),x_1..x_4]
--f=-x_(2)*x_(4)*y_(3)*y_(7)*y_(16)+x_(2)*x_(4)*y_(2)*y_(8)*y_(16)+x_(1)*x_(4)*y_(3)*y_(12)*y_(16)-x_(1)*x_(4)*y_(2)*y_(13)*y_(16)+x_(2)*x_(4)*y_(3)*y_(6)*y_(17)-x_(2)*x_(4)*y_(1)*y_(8)*y_(17)-x_(1)*x_(4)*y_(3)*y_(11)*y_(17)+x_(1)*x_(4)*y_(1)*y_(13)*y_(17)-x_(2)*x_(4)*y_(2)*y_(6)*y_(18)+x_(2)*x_(4)*y_(1)*y_(7)*y_(18)+x_(1)*x_(4)*y_(2)*y_(11)*y_(18)-x_(1)*x_(4)*y_(1)*y_(12)*y_(18)+x_(2)*x_(3)*y_(3)*y_(7)*y_(21)-x_(2)*x_(3)*y_(2)*y_(8)*y_(21)-x_(1)*x_(3)*y_(3)*y_(12)*y_(21)+x_(1)*x_(3)*y_(2)*y_(13)*y_(21)-x_(2)*x_(3)*y_(3)*y_(6)*y_(22)+x_(2)*x_(3)*y_(1)*y_(8)*y_(22)+x_(1)*x_(3)*y_(3)*y_(11)*y_(22)-x_(1)*x_(3)*y_(1)*y_(13)*y_(22)+x_(2)*x_(3)*y_(2)*y_(6)*y_(23)-x_(2)*x_(3)*y_(1)*y_(7)*y_(23)-x_(1)*x_(3)*y_(2)*y_(11)*y_(23)+x_(1)*x_(3)*y_(1)*y_(12)*y_(23)-x_(4)*y_(8)*y_(12)*y_(16)+x_(4)*y_(7)*y_(13)*y_(16)+x_(4)*y_(8)*y_(11)*y_(17)-x_(4)*y_(6)*y_(13)*y_(17)-x_(4)*y_(7)*y_(11)*y_(18)+x_(4)*y_(6)*y_(12)*y_(18)+x_(3)*y_(8)*y_(12)*y_(21)-x_(3)*y_(7)*y_(13)*y_(21)+x_(1)*y_(3)*y_(17)*y_(21)-x_(1)*y_(2)*y_(18)*y_(21)-x_(3)*y_(8)*y_(11)*y_(22)+x_(3)*y_(6)*y_(13)*y_(22)-x_(1)*y_(3)*y_(16)*y_(22)+x_(1)*y_(1)*y_(18)*y_(22)+x_(3)*y_(7)*y_(11)*y_(23)-x_(3)*y_(6)*y_(12)*y_(23)+x_(1)*y_(2)*y_(16)*y_(23)-x_(1)*y_(1)*y_(17)*y_(23)-y_(8)*y_(17)*y_(21)+y_(7)*y_(18)*y_(21)+y_(8)*y_(16)*y_(22)-y_(6)*y_(18)*y_(22)-y_(7)*y_(16)*y_(23)+y_(6)*y_(17)*y_(23)
--g=-x_(2)*x_(4)*y_(28)*y_(32)*y_(41)+x_(2)*x_(4)*y_(27)*y_(33)*y_(41)+x_(1)*x_(4)*y_(28)*y_(37)*y_(41)-x_(1)*x_(4)*y_(27)*y_(38)*y_(41)+x_(2)*x_(4)*y_(28)*y_(31)*y_(42)-x_(2)*x_(4)*y_(26)*y_(33)*y_(42)-x_(1)*x_(4)*y_(28)*y_(36)*y_(42)+x_(1)*x_(4)*y_(26)*y_(38)*y_(42)-x_(2)*x_(4)*y_(27)*y_(31)*y_(43)+x_(2)*x_(4)*y_(26)*y_(32)*y_(43)+x_(1)*x_(4)*y_(27)*y_(36)*y_(43)-x_(1)*x_(4)*y_(26)*y_(37)*y_(43)+x_(2)*x_(3)*y_(28)*y_(32)*y_(46)-x_(2)*x_(3)*y_(27)*y_(33)*y_(46)-x_(1)*x_(3)*y_(28)*y_(37)*y_(46)+x_(1)*x_(3)*y_(27)*y_(38)*y_(46)-x_(2)*x_(3)*y_(28)*y_(31)*y_(47)+x_(2)*x_(3)*y_(26)*y_(33)*y_(47)+x_(1)*x_(3)*y_(28)*y_(36)*y_(47)-x_(1)*x_(3)*y_(26)*y_(38)*y_(47)+x_(2)*x_(3)*y_(27)*y_(31)*y_(48)-x_(2)*x_(3)*y_(26)*y_(32)*y_(48)-x_(1)*x_(3)*y_(27)*y_(36)*y_(48)+x_(1)*x_(3)*y_(26)*y_(37)*y_(48)-x_(4)*y_(33)*y_(37)*y_(41)+x_(4)*y_(32)*y_(38)*y_(41)+x_(4)*y_(33)*y_(36)*y_(42)-x_(4)*y_(31)*y_(38)*y_(42)-x_(4)*y_(32)*y_(36)*y_(43)+x_(4)*y_(31)*y_(37)*y_(43)+x_(3)*y_(33)*y_(37)*y_(46)-x_(3)*y_(32)*y_(38)*y_(46)+x_(1)*y_(28)*y_(42)*y_(46)-x_(1)*y_(27)*y_(43)*y_(46)-x_(3)*y_(33)*y_(36)*y_(47)+x_(3)*y_(31)*y_(38)*y_(47)-x_(1)*y_(28)*y_(41)*y_(47)+x_(1)*y_(26)*y_(43)*y_(47)+x_(3)*y_(32)*y_(36)*y_(48)-x_(3)*y_(31)*y_(37)*y_(48)+x_(1)*y_(27)*y_(41)*y_(48)-x_(1)*y_(26)*y_(42)*y_(48)-y_(33)*y_(42)*y_(46)+y_(32)*y_(43)*y_(46)+y_(33)*y_(41)*y_(47)-y_(31)*y_(43)*y_(47)-y_(32)*y_(41)*y_(48)+y_(31)*y_(42)*y_(48)
--h=-x_(2)*x_(4)*y_(53)*y_(57)*y_(66)+x_(2)*x_(4)*y_(52)*y_(58)*y_(66)+x_(1)*x_(4)*y_(53)*y_(62)*y_(66)-x_(1)*x_(4)*y_(52)*y_(63)*y_(66)+x_(2)*x_(4)*y_(53)*y_(56)*y_(67)-x_(2)*x_(4)*y_(51)*y_(58)*y_(67)-x_(1)*x_(4)*y_(53)*y_(61)*y_(67)+x_(1)*x_(4)*y_(51)*y_(63)*y_(67)-x_(2)*x_(4)*y_(52)*y_(56)*y_(68)+x_(2)*x_(4)*y_(51)*y_(57)*y_(68)+x_(1)*x_(4)*y_(52)*y_(61)*y_(68)-x_(1)*x_(4)*y_(51)*y_(62)*y_(68)+x_(2)*x_(3)*y_(53)*y_(57)*y_(71)-x_(2)*x_(3)*y_(52)*y_(58)*y_(71)-x_(1)*x_(3)*y_(53)*y_(62)*y_(71)+x_(1)*x_(3)*y_(52)*y_(63)*y_(71)-x_(2)*x_(3)*y_(53)*y_(56)*y_(72)+x_(2)*x_(3)*y_(51)*y_(58)*y_(72)+x_(1)*x_(3)*y_(53)*y_(61)*y_(72)-x_(1)*x_(3)*y_(51)*y_(63)*y_(72)+x_(2)*x_(3)*y_(52)*y_(56)*y_(73)-x_(2)*x_(3)*y_(51)*y_(57)*y_(73)-x_(1)*x_(3)*y_(52)*y_(61)*y_(73)+x_(1)*x_(3)*y_(51)*y_(62)*y_(73)-x_(4)*y_(58)*y_(62)*y_(66)+x_(4)*y_(57)*y_(63)*y_(66)+x_(4)*y_(58)*y_(61)*y_(67)-x_(4)*y_(56)*y_(63)*y_(67)-x_(4)*y_(57)*y_(61)*y_(68)+x_(4)*y_(56)*y_(62)*y_(68)+x_(3)*y_(58)*y_(62)*y_(71)-x_(3)*y_(57)*y_(63)*y_(71)+x_(1)*y_(53)*y_(67)*y_(71)-x_(1)*y_(52)*y_(68)*y_(71)-x_(3)*y_(58)*y_(61)*y_(72)+x_(3)*y_(56)*y_(63)*y_(72)-x_(1)*y_(53)*y_(66)*y_(72)+x_(1)*y_(51)*y_(68)*y_(72)+x_(3)*y_(57)*y_(61)*y_(73)-x_(3)*y_(56)*y_(62)*y_(73)+x_(1)*y_(52)*y_(66)*y_(73)-x_(1)*y_(51)*y_(67)*y_(73)-y_(58)*y_(67)*y_(71)+y_(57)*y_(68)*y_(71)+y_(58)*y_(66)*y_(72)-y_(56)*y_(68)*y_(72)-y_(57)*y_(66)*y_(73)+y_(56)*y_(67)*y_(73)
--P=-x_(2)*x_(4)*y_(78)*y_(82)*y_(91)+x_(2)*x_(4)*y_(77)*y_(83)*y_(91)+x_(1)*x_(4)*y_(78)*y_(87)*y_(91)-x_(1)*x_(4)*y_(77)*y_(88)*y_(91)+x_(2)*x_(4)*y_(78)*y_(81)*y_(92)-x_(2)*x_(4)*y_(76)*y_(83)*y_(92)-x_(1)*x_(4)*y_(78)*y_(86)*y_(92)+x_(1)*x_(4)*y_(76)*y_(88)*y_(92)-x_(2)*x_(4)*y_(77)*y_(81)*y_(93)+x_(2)*x_(4)*y_(76)*y_(82)*y_(93)+x_(1)*x_(4)*y_(77)*y_(86)*y_(93)-x_(1)*x_(4)*y_(76)*y_(87)*y_(93)+x_(2)*x_(3)*y_(78)*y_(82)*y_(96)-x_(2)*x_(3)*y_(77)*y_(83)*y_(96)-x_(1)*x_(3)*y_(78)*y_(87)*y_(96)+x_(1)*x_(3)*y_(77)*y_(88)*y_(96)-x_(2)*x_(3)*y_(78)*y_(81)*y_(97)+x_(2)*x_(3)*y_(76)*y_(83)*y_(97)+x_(1)*x_(3)*y_(78)*y_(86)*y_(97)-x_(1)*x_(3)*y_(76)*y_(88)*y_(97)+x_(2)*x_(3)*y_(77)*y_(81)*y_(98)-x_(2)*x_(3)*y_(76)*y_(82)*y_(98)-x_(1)*x_(3)*y_(77)*y_(86)*y_(98)+x_(1)*x_(3)*y_(76)*y_(87)*y_(98)-x_(4)*y_(83)*y_(87)*y_(91)+x_(4)*y_(82)*y_(88)*y_(91)+x_(4)*y_(83)*y_(86)*y_(92)-x_(4)*y_(81)*y_(88)*y_(92)-x_(4)*y_(82)*y_(86)*y_(93)+x_(4)*y_(81)*y_(87)*y_(93)+x_(3)*y_(83)*y_(87)*y_(96)-x_(3)*y_(82)*y_(88)*y_(96)+x_(1)*y_(78)*y_(92)*y_(96)-x_(1)*y_(77)*y_(93)*y_(96)-x_(3)*y_(83)*y_(86)*y_(97)+x_(3)*y_(81)*y_(88)*y_(97)-x_(1)*y_(78)*y_(91)*y_(97)+x_(1)*y_(76)*y_(93)*y_(97)+x_(3)*y_(82)*y_(86)*y_(98)-x_(3)*y_(81)*y_(87)*y_(98)+x_(1)*y_(77)*y_(91)*y_(98)-x_(1)*y_(76)*y_(92)*y_(98)-y_(83)*y_(92)*y_(96)+y_(82)*y_(93)*y_(96)+y_(83)*y_(91)*y_(97)-y_(81)*y_(93)*y_(97)-y_(82)*y_(91)*y_(98)+y_(81)*y_(92)*y_(98)
--Ibig=ideal(f,g,h,P)
--results=frobeniusForIdeal(Ibig,100,5,1000)
--#results 
--(tally results)
--for i in {9,96,173,125,250,149,180} list(promote(i*(1/(982))*(5!),RR))
--{1,12,21,15,30,18,22}
--sum{1,10,20,15,30,20,24}
--tally o68



---robert non-symmetric example

