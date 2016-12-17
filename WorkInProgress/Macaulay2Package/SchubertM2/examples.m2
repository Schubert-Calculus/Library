restart
uninstallPackage "SchubertIdeals"
installPackage "SchubertIdeals"
needsPackage "SchubertIdeals";
viewHelp
--click SchubertIdeals and feel free to explore
help getEquations
help SchubertIdeals
help completePermutation
help getEquations
help isCondition
help osculatingFlag
help randomFlag

R=RR[t]
F={t,t^2,t^3,t^4}
osculatingFlag(F,2)
R=CC[t]



--Catchable errors
completePermutation({1,4,2,3},3)
completePermutation({1,4,4,3},5)
completePermutation({1,4,2,3.0},5)
completePermutation({0,4,2,3},6)

isCondition({1,2,3},4)

stiefelCoordinates({{1,3,2,4}},{2,4.3})
stiefelCoordinates({{1,3,2,4}},{2,4,2})
stiefelCoordinates({{1,3,2,4}},{4,2})
stiefelCoordinates({{1,3,2,4}},{4})
stiefelCoordinates({1,3,2,4},{2,4,6})
stiefelCoordinates({},{2,4,6})
stiefelCoordinates({{1,3,2,4},{}},{2,5})

w={1,3,2,4}
H=stiefelCoordinates({w,w},{2,4})
getEquations(H,{w,w},{2,4})
getEquations(H,{{w},{w}},{2,4}) --(this is not an error, but a display of how the program will give random flags if flags aren't given)
getEquations(H,{{w,randomFlag(3)},{w}},{2,4})
getEquations(H,{{w,randomFlag(4)},{w}},{2,4}) --you can give specified flags for certain conditions and not for others
getEquations(H,{{{1,4,3,2},randomFlag(4)},{w}},{2,4})
getEquations(H,{{w,randomFlag(4)},{w}},{2,4,6})
getEquations(randomFlag(5),{{w},{w}},{2,4})


end
restart
loadPackage("SchubertIdeals",DebuggingMode=>true)



