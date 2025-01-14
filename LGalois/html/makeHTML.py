#makeHTML.py
#
# This is a first attempt at a python file that makes a web page of frequency tables
#
import json
import os

jsonFileName = 'C55_enriched.json'
#################### Read in Frobenius data from .json file
jsonFile = open(jsonFileName, 'r')
frobeniusData = json.load(jsonFile)

sName = 'LG5'
sName = 'tmp'
sTitle = 'Enriched Problems in LG(5)'
sRule = '<!-------------------------------------------------->'
lRule = '<!---------------------------------------------------------------------------------------------------->'
#################### Start .html file  ####################
myFile = f'{sName!s}.html'
htmlFile = open( myFile, 'w')
htmlFile.write('<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n')
htmlFile.write(f'<html>\n<head>\n  <title>{sTitle!s}</title>\n</head>\n')
htmlFile.write(f'<body bgcolor=\"#ffffff\">\n{lRule!s}\n')
####################  Title  ####################
htmlFile.write('<table>\n  <tr valign=top>\n    <td width=15> </td>\n    <td>\n')
htmlFile.write(f'      <h1>{sTitle!s}</h1>\n      <font size=+2>\n      <a href=\"https://franksottile.github.io\">Frank Sottile</a>\n')
htmlFile.write(f'      </font>\n    </td>\n  </tr>\n</table>\n{lRule!s}\n<hr>\n{lRule!s}\n')
####################################################################################################


#  Sizes of Galois groups For LG5 (the third is not yet proven as of 3 July 2024)
cardinality = [4,4,4,4,4,4,4, 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,  192,192,192,192,  384,384,384,384, 1152,1152,1152, 1920]
#                                                                                                                    fiction

#################### Initiate the flag manifold
flagInfo = frobeniusData.pop(0)
k = flagInfo[1][1]

####################  Tables for Schubert problems
for ind in range(0,len(frobeniusData)):
    myProblem = frobeniusData[ind]

    print(ind, myProblem)
    
    schubertProblem = myProblem[0]
    frequencyTable = myProblem[1]
    myKeys = sorted(list(frequencyTable.keys()))
    numberComputed = 0
    for cycleType in myKeys:
        numberComputed =  numberComputed + frequencyTable[cycleType]
    time = myProblem[2]
 
    numberOfSolutions = schubertProblem[0]
    conditions = schubertProblem[1]

    ####################  set up the list of partitions, and the list of strings of tableaux
    partitions = []
    tableaux = []
    for myCondition in conditions:
        partition = []
        tableau = ''
        for i in range(0,k-1):
            if myCondition[k-1-i]-k > 0:
                partition.append(myCondition[k-1-i]-k)     
                tableau = f'{tableau!s}{myCondition[k-1-i]-k!s}'
            
        partitions.append(partition)
        tableaux.append(tableau)
            
    ####################  make title   (Needs the list of strings of tableaux)
    title = '<font color=#0000ff size=+2>'
    for tind in range(0,len(tableaux)):
        tableau = tableaux[tind]
        partition = partitions[tind]
        if tind > 0:
            title = f'{title!s}&middot;'
        if len(partition)==1:
            title = f'{title!s}<img src=\"Tableaux/{tableau!s}.Small.gif\">'
        elif len(partition)==2:
            title = f'{title!s}<sub><img src=\"Tableaux/{tableau!s}.Small.gif\"></sub>'
        else:
            title = f'{title!s}<sub><sub><img src=\"Tableaux/{tableau!s}.Small.gif\"></sub></sub>'
            
    title = f'{title!s} = {numberOfSolutions} in LG({k!s}) </font>'

    ####################  Start to create the table for the given Schubert problem
    htmlFile.write(f'<table border=1>\n  <tr valign=top>\n    <td colspan=4 align=center>\n    {title!s} </td>\n   </tr>\n')
    htmlFile.write(f'  <tr valign=top> <th>Cycle type</th> <th>Frequency</th> <th>Fraction</th> <th>Empirical</th>  </tr>  {sRule!s}\n')

    for cycleType in reversed(myKeys):
        htmlFile.write(f'  <tr>\n    <td>&nbsp;{cycleType!s} </td>\n    <td align=right> {frequencyTable[cycleType]!s}&nbsp;</td>\n')
        htmlFile.write(f'    <td align=right> {frequencyTable[cycleType]/numberComputed:.4f}&nbsp;</td>\n')
        htmlFile.write(f'    <td align=right> {cardinality[ind]*frequencyTable[cycleType]/numberComputed:.4f}&nbsp;</td>\n  </tr>\n  {sRule!s}\n')

    htmlFile.write(f'  <tr>\n    <td colspan=4><font size=+1> This computed {numberComputed!s} Frobenius elements </font></td>\n  </tr>\n')
    if time < 360000:
        htmlFile.write(f'  <tr>\n    <td colspan=4><font size=+1> This took {time/100:.2f} seconds </font></td>\n  </tr>\n')
    elif time < 24*3600*100:
        htmlFile.write(f'  <tr>\n    <td colspan=4><font size=+1> This took {time/360000:.2f} Hours </font></td>\n  </tr>\n')
    else:
        htmlFile.write(f'  <tr>\n    <td colspan=4><font size=+1> This took {time/360000/24:.2f} Days </font></td>\n  </tr>\n')
        
    htmlFile.write(f'</table>\n{lRule!s}<br>\n')
    
#htmlFile.write(f)
#htmlFile.write(f)
#htmlFile.write(f)
#htmlFile.write(f)
#htmlFile.write(f)
#htmlFile.write(f)






####################################################################################################
htmlFile.write(f'{lRule!s}\n<hr>\n{lRule!s}\n<font color=\"#aa00aa\">\n')
date = os.popen("date").read()
htmlFile.write(f'<i> Created {date!s} by Frank Sottile</i>\n')
htmlFile.write('</font>\n<body>\n</html>\n')
