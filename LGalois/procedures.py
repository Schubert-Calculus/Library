# procedures.py

# 
#   decompositionPoints( wo, uo )  Computes the decomposition points of two Lagrangian Schubert conditions
#   decomposeOneStep ( wo, uo )    Computes one step of the decomposition of two Lagrangian Schubert conditions
#   numberOfVariables ( wo, uo )   Computes the number of variables in the propitious Richardson coordinates
#
#


##############################    Returns the number of cycles computed in a frequency table
#
#fullProblemData is a triple 0 := Schubert problem
#                            1 := frequency table
#                            2 := timing in hundreths of a second
#
def nCycles( fullProblemData ):
    fTable = fullProblemData[1]
    nCyc = 0
    for cyc in fTable:
        nCyc = nCyc + fTable[cyc]
    return( nCyc )
##################################################

##############################    Computes the decomposition points of two Lagrangian Schubert conditions
def decompositionPoints( wo, uo ):
    decPts = []
    n = len(wo)
    for i in range(n-1):
        if (wo[i+1]+uo[n-1-i] > 2*n+1):
            decPts.append(i)
    return(decPts)
###################################################
#
##############################   Computes one step of the decomposition of two Lagrangian Schubert conditions
def decomposeOneStep( wo, uo ):
    dP = decompositionPoints( wo, uo )
    if (len(dP) > 0):
        ni = len(wo)
        ai = dP[0]+1
        bi = ni - dP[-1]-1
        m = dP[-1]-ai+1
        cw = wo[0:ai]
        for i in range(bi):
            cw.append( wo[ai+m+i]-2*m )
        cu = uo[0:bi]
        for i in range(ai):
            cu.append( uo[bi+m+i]-2*m )
        wp = []
        up = []
        for i in range(m):
            wp.append(wo[ai+i]-ai-bi)
            up.append(uo[bi+i]-ai-bi)

        return([cw,cu,wp,up])
    else:
        print("This should only be called on a decomposable pair")
##################################################
#
##############################   Computes the number of variables in the propitious Richardson coordinates
def numberOfVariables ( wo, uo ):
    wtmp = wo
    utmp = uo
    components = []
    while (len(decompositionPoints( wtmp, utmp ))>1):
        L = decomposeOneStep(wtmp, utmp)
        components.append( [ L[0] , L[1] ] )
        wtmp = L[2]
        utmp = L[3]

    components.append( [ wtmp , utmp ] )
    nVars = 0
    for pr in components:
        wtmp = pr[0]
        utmp = pr[1]
        dP = decompositionPoints( wtmp, utmp )
        ni = len( wtmp )
        if (wtmp[ni-1]==ni or utmp[ni-1]==ni):      #  One condition is empty
            nVars = nVars + ni*(ni+1)//2
            for i in range(ni):
                if wtmp[i]> ni:
                    nVars = nVars - wtmp[i] + ni
                if utmp[i]> ni:
                    nVars = nVars - utmp[i] + ni
                
        elif ( len(dP)==0 ):                        #   No break point and Richardson
            nVars = nVars + 2*ni*ni+ni
            for i in range(ni):
                nVars = nVars - wtmp[i] - utmp[i]
         
        elif (len(dP)==1 and wtmp[dP[0]]!=dP[0]+1 and utmp[ni-dP[-1]-2]!=ni-dP[-1]-1):  #  Break Point, but Richardson
            nVars = nVars + 2*ni*ni+ni
            for i in range(ni):
                nVars = nVars - wtmp[i] - utmp[i]
          
        elif (len(dP)==1 and (wtmp[dP[0]]==dP[0]+1 or utmp[ni-dP[-1]-2]==ni-dP[-1]-1)):  # optimal coordinates
            nVars = nVars + ni*(ni+1)//2
            for i in range(ni):
                if wtmp[i]> ni:
                    nVars = nVars - wtmp[i] + ni
                if utmp[i]> ni:
                    nVars = nVars - utmp[i] + ni

    return(nVars);                    
####################################################################################################
#
#  computes the minimal number of variables needed for Richardson formulation of a Lagrangian Schubert problem
#
#   Earlier version had: minVars = min( numberOfVariables(SchubProb[i], iden), minVars)
#    which compared to Schubert cell.  Experiments suggested that this is not efficient.  More research is needed.
#
def minimalNumberOfVariables ( SchubProb ):
    iden = list(range(1, len(SchubProb[1])+1))
    minVars = len(SchubProb[1])*(len(SchubProb[1])+1)
    for i in range(len(SchubProb)-1):
        #minVars = min( numberOfVariables(SchubProb[i], iden), minVars)
        for j in range(i+1,len(SchubProb)):
            minVars = min( numberOfVariables(SchubProb[i], SchubProb[j]), minVars)
    return(minVars)
####################################################################################################
#
#  Exports the first (in lex) pair [i, j] with i<j which indexes a pair of Schubert conditions
#    having a minimal number of variables in the formulation
#
#  Earlier version allowed a Schubert cell " #if minVars == numberOfV....."
#      Experiments suggested that this is not efficient.  More research is needed.
#
def bestIndices ( SchubProb ):
    minVars = minimalNumberOfVariables ( SchubProb )
    id = list(range(1, len(SchubProb[1])+1))
    for i in range(len(SchubProb)-1):
        #if minVars == numberOfVariables(SchubProb[i], id):
        #    return([i])
        for j in range(i+1,len(SchubProb)):
            if minVars == numberOfVariables(SchubProb[i], SchubProb[j]):
                return([i,j])
##################################################

##############################  write the .json file
def writeJSONFile( fName, flagInfo, enrichedProblems):
    import json
    jsonFile =  open(f'{fName}.json', 'w')
    flagInfoJson = json.dumps(flagInfo)
    jsonFile.write(f'[ {flagInfoJson}\n')
    for i in range(len(enrichedProblems)):
        problem = enrichedProblems[i]
        probJson = json.dumps(problem)
        jsonFile.write(f',{probJson} \n')
    jsonFile.write(f']\n')
    jsonFile.close()
   
##############################  This updates the .json file and time
#
#  This is called by  initialRun.py
#
def updateJSONFile( fName, SchubProblem, eTime, threshold ):
    import json
    jsonFile =  open(f'{fName}.json', 'r')
    allData = json.load(jsonFile)
    jsonFile.close()
    elTime = allData.pop()+ eTime
    allData.append(SchubProblem)
    ##############################   If this Schubert problem takes more than the threshold
    if elTime  > threshold:
        numJSONFile = open("numJSON.txt", "r")
        numJSONLine = numJSONFile.readline()
        numJSON = int(numJSONLine.rstrip())
        jsonFile =  open(f'{fName}.json.{numJSON}', 'w')
        flagData = allData.pop(0)
        jsonFile.write(f'[ [ "{flagData[0]}", {flagData[1]} ]')
        for schubProb in allData:
            jsonFile.write(f'\n,{schubProb!s}')
        jsonFile.write(f"\n,{elTime}\n]\n")
        jsonFile.close()
        writeJSONFile(fName, [flagData,0])
        numJSON = numJSON + 1
        numJSONFile = open("numJSON.txt", "w")
        numJSONFile.write(f"{numJSON}")
        numJSONFile.close()

    else:
        allData.append(elTime)
        writeJSONFile(fName, allData)

    
##############################   Makes the Singular input file
#
#   This can be improved---look at computeFrobenius.py.
#
#
def makeSingularInput(flagType, LieType, schubertProblem):
    ####################
    nSols = schubertProblem[0]
    schubertConditions = schubertProblem[1]
    ##########       Move the conditions so te the first two are the best two
    bestI = bestIndices(schubertConditions)
    if len(bestI)==2:
        tmpC = [ schubertConditions[bestI[0]], schubertConditions[bestI[1]] ]
        schubertConditions[bestI[0]] = schubertConditions[0]
        schubertConditions[bestI[1]] = schubertConditions[1]
        schubertConditions[0] = tmpC[0]
        schubertConditions[1] = tmpC[1]
    else:
        mty = list(range(1, flagType[-1]+1))
        schubertConditions.insert(1, mty)
    
    n = flagType[-1]
    inputFile = open("input.txt", "w")
    inputFile.write("/////////////   Singular input file\n")
    inputFile.write("int Char = 33554467;\n")
    s = f'intvec flagType = '
    for aindex in flagType[:-1]:
        s = f'{s!s} {aindex},'
    s = f'{s!s} {n!s};\n'
    inputFile.write(s)
    s = f'string LieType = "{LieType!s}";\n'
    inputFile.write(s)
    ####################  list of conditions
    inputFile.write(f'int numSolns = {nSols};\n')
    s = f'list SchubertProblem ='
    lSC = len(schubertConditions)
    for i in range(lSC):
        cond = schubertConditions[i]
        s = f'{s!s} intvec('
        lidx = cond[-1]
        for idx in cond:
            if idx != lidx:
                s=f'{s!s}{idx!s},'
            elif i < lSC-1:
                s=f'{s!s}{idx!s}),'
            else:
                s=f'{s!s}{lidx!s});\n'
 
    inputFile.write(s)
    inputFile.close()

##################################################
