#Study.py
#
# This python3 file studies thre enriched problems 
#
import json
import os

####################    Read in data file
enrichedProblemsFile = 'test.json'
enrichedProblemsFile = 'C44_enriched.json'
enrichedProblemsFile = 'C55_enriched.json'
#enrichedProblemsFile = 'C66_enriched.json'
probFile =  open(enrichedProblemsFile, 'r')
enrichedProblems = json.load(probFile)

#################### Set up dimension n and the rest of the flagtype,
####################   and initiate list of possibly enriched Schubert problems
flagInfo = enrichedProblems.pop(0)
LieType = flagInfo[0]
flagType = flagInfo[1]
n = flagType[-1]

totalTime = 0

for problemData in enrichedProblems:
    SchubertProblem = problemData[0]
    frequency = problemData[1]
    timeHundrethsOfSecond = problemData[2]
#    print(f'{SchubertProblem[0]}  {sorted(frequency.keys())}')
    if SchubertProblem[0] > 2:
        totalTime = totalTime + timeHundrethsOfSecond
        print(f'{len(frequency.keys())} {timeHundrethsOfSecond} {SchubertProblem[0]} {SchubertProblem[1]}  {len(frequency.keys())}')
#        print(f' time for one Frobenius elements = {timeHundrethsOfSecond/100/SchubertProblem[0]/100} secs.  number of cycles found = {len(frequency.keys())}')
#        print(f' time for this = {timeHundrethsOfSecond/3600/100} hours.  number of cycles found = {len(frequency.keys())}')
#        print(frequency)
        print("----------------------\n")


    

        
#
#    Many problems for C66, incuding some with 8 solutions, did not have all cycles found in the first pass.
#
#    print(f'{SchubertProblem[0]}  {len(frequency.keys())}')

    
