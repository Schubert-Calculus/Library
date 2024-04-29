#FrobeniusAlgorithm.py
#
# This python3 file tests for full symmetric Galois group of all Schubert problems encoded in input.json 
#
import json
import os

timeFile = open('times.data', 'w')
timeFile.write('#  record of times\n')
timeFile.close()

####################    Read in Schubert data from input.json
probFile =  open('input.json', 'r')
problems = json.load(probFile)

####################   File to record computation statistics for the model
modelFile = open('model.maple', 'w')
modelFile.write('#  record of flagVariety, [numSolns, nvars, time in 100th seconds] \n')
modelFile.write(f'flagVariety := {problems[0]} :\nModel :=[ \n')
modelFile.close()

 
#################### Set up dimension n and the rest of the flagtype,
####################   and initiate list of possibly enriched Schubert problems
flagInfo = problems.pop(0)
enrichedProblems = []
LieType = flagInfo[0]
flagType = flagInfo[1]
n = flagType[-1]


####################    Loop to run isSymmetric on each Schubert problem in input.json
for schubProb in problems:
    #############################    First make Singular input file
    inputFile = open("input.txt", "w")
    inputFile.write("/////////////   Singular input file\n")
    inputFile.write("int Char = 1009;\n")
    s = f'intvec flagType = '
    for aindex in flagType[0:-1]:
        s = f'{s!s} {aindex!s},'
    s = f'{s!s} {n!s};\n'
    inputFile.write(s)
    s = f'string LieType = "{LieType!s}";\n'
    inputFile.write(s)
    nSols = schubProb[0]
    ####################  list of conditions
    schubertProblem = schubProb
    inputFile.write(f'int numSolns = {nSols};\n')
    Lst = schubProb[1][-1]
    s = f'list SchubertProblem ='
    for cond in schubProb[1][0:-1]:
        s = f'{s!s} intvec('
        for idx in cond[0:-1]:
            s=f'{s!s}{idx!s},'
        s=f'{s!s}{cond[-1]!s}),'
    s=f'{s!s}intvec('
    for idx in Lst[0:-1]:
        s=f'{s!s}{idx!s},'
    s=f'{s!s}{Lst[-1]!s});'
    inputFile.write(s)
    inputFile.close()

    ####################   Having written the input file, run isSymmetric.sing
    ##########os.system("cat input.txt")
    os.system("Singular -q --min-time=0.01 --ticks-per-sec=100  isSymmetric.sing")

    isSymmetricFile = open('isSymmetric.txt', 'r')
    isSymmetricLine = isSymmetricFile.readline()
    isSymmetric = int(isSymmetricLine.rstrip())

    if isSymmetric == 0:
        freq = dict()
        cyclesList = open('cycles.data','r')
        for line in cyclesList:
            cycle = line.rstrip()
            if not (cycle in freq):
                freq[cycle] = 1
            else:
                freq[cycle] = freq[cycle] + 1

        timeFile = open('time.txt', 'r')
        os.system("rm -f time.txt")
        timeLine = timeFile.readline()
        elTime = int(timeLine.rstrip())
        enrichedProblems.append([schubertProblem, freq, elTime])

####################   File to record computation statistics for the model
modelFile = open('model.maple', 'a')
modelFile.write('  NULL]:\n')
modelFile.close()

#     Write enriched problems to enrichedProblems.json.  In the future, will want to so this incrementally
enrichedFile = open('enrichedProblems.json', 'w')
flagInfoJson = json.dumps(flagInfo)
enrichedFile.write(f'[ {flagInfoJson}\n')
for enrichedProblem in enrichedProblems:
    epJson = json.dumps(enrichedProblem)
    enrichedFile.write(f',{epJson} \n')

enrichedFile.write(f']')
enrichedFile.close()

#  Need to clean everything up (delete extra files, add up elapsed times, and get this ready to be incorporated into the data base)
os.system("rm -f input.txt")
os.system("rm -f cycles.data")
os.system("rm -f isSymmetric.txt")
