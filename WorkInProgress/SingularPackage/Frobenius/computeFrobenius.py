#FrobeniusAlgorithm.py
#
# This python3 file tests for full symmetric Galois group of all Schubert problems encoded in input.json 
#
import json
import os

####################    Read in the number of Frobenius elements to compute
numberTCFile =  open('numberToCompute.txt', 'r')
numberToCompute = int(numberTCFile.readline().rstrip())

####################    Read in Schubert data from input.json
probFile =  open('enrichedProblems.json', 'r')
problems = json.load(probFile)
enrichedProblems = []



#################### Find the type, dimension n and the rest of the flagtype, and initiate the enriched problems
flagInfo = problems.pop(0)
LieType = flagInfo[0]
flagType = flagInfo[1]
n = flagType[-1]

####################    Loop to run computeFrobenius on each Schubert problem in enrichedProblems.json
for schubProb in problems:
    
    tElapsed = schubProb[2]
    freq = schubProb[1]
    nSuccess = 0
    for cycle in freq:
        nSuccess = nSuccess + freq[cycle]

    #############################    First make Singular input file
    inputFile = open("input.txt", "w")
    inputFile.write("/////////////   Singular input file\n")
    inputFile.write("int Char = 1009;\n")
    s = f'intvec flagType = '
    for aindex in flagType[0:-1]:
        s = f'{s!s} {aindex!s},'
    s = f'{s!s} {n!s};\nstring LieType = "{LieType!s}";\n'
    inputFile.write(s)

    nSols = schubProb[0][0]
    ####################  list of conditions
    schubertProblem = schubProb[0][1]
    
    inputFile.write(f'int numSolns = {nSols};\n')
    Lst = schubertProblem[-1]
    s = f'list SchubertProblem ='
    for cond in schubertProblem[0:-1]:
        s = f'{s!s} intvec('
        for idx in cond[0:-1]:
            s=f'{s!s}{idx!s},'
        s=f'{s!s}{cond[-1]!s}),'
    s=f'{s!s}intvec('
    for idx in Lst[0:-1]:
        s=f'{s!s}{idx!s},'
    s=f'{s!s}{Lst[-1]!s});\n'
    inputFile.write(s)
    s = f'int nSuccess = {nSuccess};\nint tElapsed = {tElapsed};\nint numberToCompute = {numberToCompute};\n'
    inputFile.write(s)

    inputFile.close()

    ####################   Having written the input file, run computeFrobenius.sing
    os.system("Singular -q --min-time=0.01 --ticks-per-sec=100  computeFrobenius.sing")

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
    tElapsed = tElapsed + int(timeLine.rstrip())
    enrichedProblems.append([[nSols, schubertProblem], freq, tElapsed])


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

