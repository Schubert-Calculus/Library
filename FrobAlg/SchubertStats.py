# Created by Robert Williams Fall 2014
#
# Change below text
#
# Takes a file titled Unknown_Galois_Group.txt and computes instances of the problem to gather statistical 
#		data about the Galois Group of the given problem.
#		This code is designed to work in hand with FrobAlg.py
#		For maximal effiency, the largest two Schubert conditions should be listed last.
#		In it's current state, the script will assume that [x1,x2,...,xn] is a condition in G(n,xn)
#			This can be changed by hand by modifing the entries for m and p in the script so that 
#				you are in G(m,m+p)
#
#################################################################################################################################################################

import fileinput
import subprocess

# char is the characteristic of the ring. If you do not want to enter a characteristic when you first run program, comment out the line where the function is called in the main program block

def pickchar():
	exampleprimes= [1009, 1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097, 1103,
	                1109, 1117, 1123, 1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223, 1229, 1231,
	                1237, 1249, 1259, 1277, 1279, 1283, 1289, 1291, 1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 1367,
	                1373, 1381, 1399, 1409, 1423, 1427, 1429, 1433, 1439, 1447, 1451, 1453, 1459, 1471, 1481, 1483, 1487,
	                1489, 1493, 1499, 1511, 1523, 1531, 1543, 1549, 1553, 1559, 1567, 1571, 1579, 1583, 1597, 1601, 1607,
	                1609, 1613, 1619, 1621, 1627, 1637, 1657, 1663, 1667, 1669, 1693, 1697, 1699, 1709, 1721, 1723, 1733,
	                1741, 1747, 1753, 1759, 1777, 1783, 1787, 1789, 1801, 1811, 1823, 1831, 1847, 1861, 1867, 1871, 1873,
	                1877, 1879, 1889, 1901, 1907, 1913, 1931, 1933, 1949, 1951, 1973, 1979, 1987, 1993, 1997, 1999]
	while 1:
		try:
			char= int(input('What should be the characteristic of the ring? ')) # should input 0 or a prime number
			if char== 0 or char in exampleprimes:
				return char
			elif char< 0:
				print('That was not a valid entry. Please try again.')
				continue
			elif char< 1000 or char> 2000:
				conf= str(input('Caution: This program does not check to ensure a characteristic is prime unless it is between 1000 and 2000. Are you sure you want to use this number? Y/N: '))
				if conf in ['Y', 'Yes', 'y', 'yes']:
					return char
				else:
					continue
			else:
				print('The number you entered is not prime. Plese try again.')
				continue
		except ValueError:
			print('That was not a valid entry. Please try again.')

#################################################################################################################################################################

# For G(m,n), completecond(condition vector, n) takes the condition vector and outputs the corresponding vector with unique descent
#	e.g. completecond('(3,4,7)',7) outputs  1,4,5,2,3,6,7

def completecond(cond,space):
	pieces= list(cond)
	diagramsize, finishedcond= [], []
	for piece in pieces:
		try:
			finishedcond.append(int(piece))
		except ValueError:
			continue
	for i in range(len(finishedcond)):
		diagramsize.append(space-finishedcond[len(finishedcond)-1-i]-i)
	for i in range(len(finishedcond)):
		finishedcond[i]=diagramsize[i]+i+1
	for num in range(1,space+1):
		if num not in finishedcond:
			finishedcond.append(num)
	return str(finishedcond).split('[')[1].split(']')[0]

#################################################################################################################################################################

# the function below writes a template singular file to be filled in as new problems are run through the algorithm

def createtemplate():
	with open('cycle_sample.sing','w') as template:
		template.write('// Caution: Altering this file could cause SchubertStats.py to run into errors or  \
produce false results. Deleting this file is safe as SchubertStats.py will rewrite it if it can not be found. \n\n\
option(redSB); \n\
LIB "matrix.lib"; \n\
LIB "linalg.lib"; \n\
LIB "schubert.lib"; \n\n\n\
// We are in G(m,m+p). The vectors w and v encode the first two Schubert conditions \n\n\
int character = \n\
int m = \n\
int p = \n\
int numsolns = \n\
// trials is the number of cycles we will sample \n\
int trials = \n\
int badtrial = 0; //used to count number of trials discarded \n\
int variable= 0; //used to change what variable we reduce to if we encounter too many badtrials \n\
intvec cycles; \n\
int cycleplace; \n\
int randomnumsize = \n\
intvec w = \n\
intvec v = \n\n\
// conditions is a list of the vectors of all but the first two Schubert conditions \n\
list conditions = \n\
int i,ii,j; \n\
intvec mm = m; \n\
def R = flagRing(mm,m+p,v,w); \n\
setring R; \n\
ideal I; \n\
def S = myring(nvars(R), string(character)); \n\
setring(S); \n\
ideal J,B; \n\
list L, output; \n\
poly F; \n\n\
for (j=1; j<=trials; j++) { \n\
  setring R; \n\
  I= 0; \n\
  for (ii=1; ii<= size(conditions); ii++) { \n\
    I = I + randomCondition(conditions[ii], mm, randomnumsize, m+p, v, w); \n\
  } \n\
  setring S; \n\
  J= std(fetch(R,I)); \n\
  if (mult(J)==numsolns) { \n\
    B= kbase(J); \n\
    F= charpoly(coeffs(reduce(var(nvars(R)-variable)*B,J),B), varstr(nvars(R)-variable)); \n\
    L= factorize(F,2); \n\
    if (L[2]-1 <> 0 or deg(F) < numsolns) { \n\
      badtrial++; \n\
      j++; // this line counts discarded picks against total number of trials \n\
      if (badtrial > trials/4 & variable < nvars(R)-1) { \n\
        variable++; // tries next variable \n\
        list output; // clears output list \n\
        badtrial= 0; \n\
        j= 1; // restart counters \n\
      } \n\
      continue; \n\
    } \n\
    cycles=0; \n\
    for (i=1; i<=size(L[1]); i++) { \n\
      cycles[i]= deg(L[1][i]); \n\
    } \n\
    if (size(output) == 0) { \n\
      output= cycles,intvec(1); \n\
    } \n\
    else { \n\
      // we now check if we have already encountered this cycle \n\
      for (i=1; i<=(size(output) div 2); i++) {\n\
        cycleplace=0; \n\
        for (ii=1; ii<= size(cycles); ii++) {\n\
          if (cycles[ii] > output[2*i-1][ii]) {\n\
            cycleplace=1; \n\
          	break; \n\
          } \n\
          if (cycles[ii] < output[2*i-1][ii]) {\n\
            cycleplace=2; \n\
            break; \n\
          } \n\
        }\n\
        if (cycleplace == 0) {\n\
          output[2*i][1]= output[2*i][1]+1; \n\
          break; \n\
        } \n\
        if (cycleplace == 1) {\n\
          output= insert(output,intvec(1),2*(i-1)); \n\
          output= insert(output,cycles,2*(i-1)); \n\
          break; \n\
        } \n\
        if ( i == (size(output) div 2) ) { \n\
          output= insert(output,cycles,size(output)); \n\
          output= insert(output,intvec(1),size(output)); \n\
          break; \n\
        } \n\
      } \n\
    } \n\
  } \n\
  else { \n\
    badtrial++; \n\
  } \n\
} \n\
string pretty_output= "%s | %s"; \n\
for (i=1; i< (size(output) div 2); i++) { \n\
  pretty_output= pretty_output + "%n%s | %s"; \n\
} \n\
badtrial; \n\
pretty_output= sprintf(pretty_output,output); \n\
pretty_output; \n\
size( sprintf("%s", badtrial)+pretty_output); \n\
quit; \
')

#################################################################################################################################################################

# This function creates an example problem file if one is not found

def createprobtemplate():
	with open('Unknown_Galois_Group.txt','w') as template:
		template.write('# Schubert problems should be written in the following manner: \n\
#    [num_of_solns, [cond_1], [cond_2], ... , [cond_n]] \n\
# where the two largest conditions are written last.\n\
# \n\
# Only 1 problem per line \n\
# The script will ignore any line that does not start with a [ \n\
#   ! Lines that start with a space will be ignored \n\
#     Do not insert spaces before the [ on any problem you want worked. \n\
# \n\
# Example: below we write the following problem in G(4,9) \n\
# \n\
# []^4 . [][] . [][][] = 6 \n\
# []     [][]   [][][] \n\
#        [][] \n\
\n\
[6, [5,6,8,9], [5,6,8,9], [5,6,8,9], [5,6,8,9], [4,5,6,9], [3,4,8,9]] \
')

##################################################################################################################################################################

# This function formats our output to create a statistics table in LaTeX

def tabletoTeX(table,totalsample):
	lines= table.count('\n')
	TeX= '\\begin{tabular}{|c|c|c|} \n\
    \\hline \n\
    Cycles found in '+str(totalsample)+' samples \\\\\n\
    \\hline \n\
    Cycle Type & Frequency & Fraction \\\\\n\
    \\hline\n'
	for i in xrange(lines+1):
		myline=table.partition('\n')[0]
		l=len(myline.partition('|')[0])
		num=myline.partition('|')[2]
		TeX= TeX+'    ('+myline.partition('|')[0][0:l-1] + ') & '+ num + ' & ' + str(float(num)/totalsample) + '\\\\\n    \\hline\n'
		table=table.partition('\n')[2]
	TeX= TeX+'\\end{tabular}'
	return TeX
		

##################################################################################################################################################################

# Main program starts here

try:
	with open('cycle_sample.sing','r'):
		pass
except IOError:
	createtemplate()

try:
	with open('Unknown_Galois_Group.txt','r'):
		pass
except IOError:
	createprobtemplate()

# You can change char to whatever characteristic you want to work in.
# Commenting out 'char= 1009' and removing the comment from 'char= pickchar()' will allow you to choose the characteristic each time you initiate the script

#char= pickchar()
char= 1009

with open('Unknown_Galois_Group.txt','r') as problems:
	for line in problems:
		# Gather all of the required information from the problem given
		if not line.startswith('['):
			continue
		parts= line.split('[')
		numsolns= parts[1].split(',')[0]
		# we check for desired cycles trials*numsolns times
		trials= 300000
		# maximum size of random numbers when generating a random condition
		randomnumsize= 1000
		# length of a condition vector
		m= len(parts[2].split(','))-1
		# (last entry of a condition vector)-(length of condition vector)
		p= int(parts[2].split(',')[-2].split(']')[0])-m
		condone= completecond(parts[len(parts)-1],m+p)
		condtwo= completecond(parts[len(parts)-2],m+p)
		remaincond= 'list( intvec('
		for i in range(2,len(parts)-2):
			if i < len(parts)-3:
				remaincond= remaincond + completecond(parts[i],m+p) + '), intvec('
			else:
				remaincond= remaincond + completecond(parts[i],m+p) + ') )'
		# Fill in the variables in the singular script
		for myline in fileinput.input('cycle_sample.sing', inplace=1):
			if myline.startswith('int') or myline.startswith('list'):
				if myline.startswith('int character'):
					print('{0}{1}{2}{3}'.format(myline.partition('=')[0], '= ', str(char), ';'))
				elif myline.startswith('int m'):
					print('{0}{1}{2}{3}'.format(myline.partition('=')[0], '= ', str(m),';'))
				elif myline.startswith('int p'):
					print('{0}{1}{2}{3}'.format(myline.partition('=')[0], '= ', str(p),';'))
				elif myline.startswith('int numsolns'):
					print('{0}{1}{2}{3}'.format(myline.partition('=')[0], '= ', numsolns,';'))
				elif myline.startswith('int trials'):
					print('{0}{1}{2}{3}'.format(myline.partition('=')[0], '= ', str(trials),';'))
				elif myline.startswith('int randomnumsize'):
					print('{0}{1}{2}{3}'.format(myline.partition('=')[0], '= ', str(randomnumsize),';'))
				elif myline.startswith('intvec w'):
					print('{0}{1}{2}{3}'.format(myline.partition('=')[0], '= ', condone,';'))
				elif myline.startswith('intvec v'):
					print('{0}{1}{2}{3}'.format(myline.partition('=')[0], '= ', condtwo,';'))
				elif myline.startswith('list conditions'):
					print('{0}{1}{2}{3}'.format(myline.partition('=')[0], '= ', remaincond,';'))
				else:
					print('{0}'.format(myline.partition('\n')[0]))
			else:
				print('{0}'.format(myline.partition('\n')[0]))
		# Now that we have filled in the variables, we run Singular on schubert_template.sing
		result= str( subprocess.check_output(['Singular', 'cycle_sample.sing']) )
		i=0
		l=len(result)
		# This loop checks for the length of our table so we know how much of the output string we want
		# Each iteration of the loop checks to see if the number is another digit in length
		# e.g. a 135 char long string will make the loop below store length as 5, then 35, then 135, then it breaks out of the loop
		while 1:
			try:
				size_of_table=int(result[l-19-i:l-18])
				i=i+1
			except ValueError:
				break
		result= result[l-19-i-size_of_table:l-18-i].partition('\n')
		if trials > int(result[0]):
			TeX_result= tabletoTeX(result[2], trials-int(result[0]))
		else:
			TeX_result= ''
		with open('Schubert_Stats.txt','a') as output_file:
			output_file.write(line + ' \n\n' + result[2] + ' \n\n' + TeX_result + ' \n\n####################################\n\n')	
