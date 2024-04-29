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
enrichedProblems = [flagInfo]
LieType = flagInfo[0]
flagType = flagInfo[1]
n = flagType.pop()


####################    Loop to run isSymmetric on each Schubert problem in input.json
for schubProb in problems:
    #############################    First make Singular input file
    inputFile = open("input.txt", "w")
    inputFile.write("/////////////   Singular input file\n")
    inputFile.write("int Char = 1009;\n")
    s = f'intvec flagType = '
    for aindex in flagType:
        s = f'{s!s} {aindex!s},'
    s = f'{s!s} {n!s};\n'
    inputFile.write(s)
    s = f'string LieType = "{LieType!s}";\n'
    inputFile.write(s)
    nSols = schubProb[0]
    ####################  list of conditions
    schubertProblem = schubProb
    inputFile.write(f'int numSolns = {nSols};\n')
    Lst = schubProb[1].pop()
    s = f'list SchubertProblem ='
    for cond in schubProb[1]:
        s = f'{s!s} intvec('
        lidx = cond.pop()
        for idx in cond:
            s=f'{s!s}{idx!s},'
        s=f'{s!s}{lidx!s}),'
    s=f'{s!s}intvec('
    lidx = Lst.pop()
    for idx in Lst:
        s=f'{s!s}{idx!s},'
    s=f'{s!s}{lidx!s});'
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

#
#  Format this better, one problem per line, etc.
#
enrichedFile = open('enrichedProblems.json', 'w')
enrichedFile.write(f'[ {enrichedProblems.pop(0)}\n')
for enrichedProblem in enrichedProblems:
  enrichedFile.write(f',{enrichedProblem} \n')

enrichedFile.write(f']')
enrichedFile.close()

#  Need to clean everything up (delete extra files, add up elapsed times, and get this ready to be incorporated into the data base)
os.system("rm -f input.txt")
os.system("rm -f cycles.data")
os.system("rm -f isSymmetric.txt")
