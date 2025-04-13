#Study.py
#
# This python3 file studies thre enriched problems 
#
import json
import os

fVar = "55"
####################    Read in data file
enrichedProblemsFile = f'C{fVar}_enriched.json'
probFile =  open(enrichedProblemsFile, 'r')
enrichedProblems = json.load(probFile)

#################### Set up dimension n and the rest of the flagtype,
####################   and initiate list of possibly enriched Schubert problems
flagInfo = enrichedProblems.pop(0)
LieType = flagInfo[0]
flagType = flagInfo[1]
n = flagType[-1]

totalTime = 0
numberOfProblems = 0

for problemData in enrichedProblems:
    numberOfProblems = numberOfProblems + 1
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
        print('----------------------')





GHzYears = 3.7*timeHundrethsOfSecond/100/3600/24/365

print(f'There were {numberOfProblems} enriched problems on C{fVar}. Computing them took {GHzYears} GHz-Years')



    

        
#
#    Many problems for C66, incuding some with 8 solutions, did not have all cycles found in the first pass.
#
#    print(f'{SchubertProblem[0]}  {len(frequency.keys())}')

    
