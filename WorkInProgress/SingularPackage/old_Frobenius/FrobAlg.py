# Created by Robert Williams Summer 2014
#     schubert_template.sing is based off of a specialized version of the document created by Frank Sottile for the problem in G(3,6) with 42 solutions
#     ---------------- Updated 2/5/2016
#
# Takes a text file formatted as output by prettyFormat.py, named schubertprob.txt, and applies the Frobenius algorithm to the given Schubert problems.
#		Results are recorded by preceeding the problem with a F or an U to denote whether or not we found the full symmetric group.
#		For maximal effiency, the largest two Schubert conditions should be listed first.
#		In it's current state, the script will assume that [x1,x2,...,xn] is a condition in G(n,xn)
#			This can be changed by hand by modifing the entries for m and p in the script so that you are in G(m,m+p)
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

# This function checks to make sure we are not dealing with a reducable problem. If the problem reduces, it is sorted into a separate file, Not_Reduced.txt, with a note about how the problem reduces to one in a smaller space

def reduced(prob, m, p):
	reduced= True
	parts= prob.split('[')
	maxval=m+p
	a=[]
	for i in range(p):
		a.append(0)
	for i in range(2, len(parts)-1):
		if not reduced:
			break
		cond1=[]
		for k in range(m):
			cond1.append(maxval-m+k+1-int(parts[len(parts)-i].split(']')[0].split(',')[k]))
		for j in range(i-1):
			if not reduced:
				break
			cond2=[]
			for k in range(m):
				cond2.append(maxval-m+k+1-int(parts[len(parts)-j-1].split(']')[0].split(',')[k]))
			for k in range(m):
				if cond1[k]+cond2[m-1-k] < p:
					continue
				else:
					where= 'Full row when using conditions [' + str(parts[len(parts)-i].split(']')[0]) +'] and ['  + str(parts[len(parts)-j-1].split(']')[0]) + ']'
					reduced= False
				if not reduced:
					break
			if not reduced:
				break
			for k in range(p):
				a[k]=0
			for k in range(m):
				for l in range(cond1[k]):
					a[l]=a[l]+1
				for l in range(cond2[k]):
					a[p-l-1]=a[p-l-1]+1
			for k in range(p):
				if a[k] < m:
					continue
				else:
					where= 'Full column when using conditions [' + str(parts[len(parts)-i].split(']')[0]) +'] and ['  + str(parts[len(parts)-j-1].split(']')[0]) + ']'
					reduced= False
				if not reduced:
					break
	if not reduced:
		with open('Not_Reduced.txt','a') as answer_file:
			answer_file.write(line+ '\n' + where + '\n\n')
	return reduced


#################################################################################################################################################################

# For G(m,n), completecond(condition vector, n) takes the condition vector and outputs the corresponding vector with unique descent
#	e.g. completecond('(3,4,7)',7) outputs  1,4,5,2,3,6,7

def completecond(cond,space):
	pieces= cond.split(']')[0].split(',')
	diagramsize, finishedcond= [], []
	for piece in pieces:
		finishedcond.append(int(piece))
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
	with open('schubert_template.sing','w') as template:
		template.write('// Caution: Altering this file could cause FrobAlg.py to run into errors or  \
produce false results. Deleting this file is safe as FrobAlg.py will rewrite it if it can not be found. \n\n\
option(redSB); \n\
LIB "matrix.lib"; \n\
LIB "linalg.lib"; \n\
LIB "schubert.lib"; \n\n\n\
// We are in G(m,m+p). The vectors w and v encode the first two Schubert conditions \n\n\
int character = \n\
int m = \n\
int p = \n\
int numsolns = \n\
// trials*numsolns is the number of times we will pick random cycles to check for desired cycle types \n\
int trials = \n\
int badtrial = 0; //used to count number of trials discarded \n\
int variable= 0; //used to change what variable we reduce to if we encounter too many badtrials \n\
int randomnumsize = \n\
intvec w = \n\
intvec v = \n\n\
// conditions is a list of the vectors of all but the first two Schubert conditions \n\
list conditions = \n\
int i,ii,j; \n\
intvec mm = m; \n\
int OddCycle = 0; \n\
int Nminusonecycle = 0; \n\
int BigPrimecycle = 0; \n\
def R = flagRing(mm,m+p,v,w); \n\
setring R; \n\n\
int half = numsolns div 2; \n\
// When building the Primes vector, we take advantage of the occasional strange relation between numsolns div 2 and numsolns-3 for numsolns<=7 to give us a vector that will be useful when we get the loop where we check for BigPrimecycle\'s \n\
intvec Primes = primes(half,numsolns-3); \n\n\
// this conditonal code block eliminates the potential small prime that we may have picked up above \n\
if (Primes[1] < half) { \n\
  Primes[1] = 0; \n\
  Primes = compress(Primes); \n\
} \n\n\
ideal I; \n\
def S = myring(nvars(R), string(character)); \n\
setring(S); \n\n\
ideal J,B; \n\
list L; \n\
poly F; \n\n\
for (j=1; j<=trials*numsolns; j++) { \n\
  setring R; \n\n\
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
      j++; \n\
      if (badtrial > trials*numsolns/2 & variable < nvars(R)-1) { \n\
        variable++; // tries next variable \n\
        list output; // clears output list \n\
        badtrial= 0; \n\
        j= 1; // restart counters \n\
      } \n\
      continue; \n\
    } \n\
    if (numsolns== 3) { \n\
      if (deg(L[1][1])== 2) { \n\
        1; \n\
        quit; \n\
      } \n\
    } \n\
    else {\n\
      if ( numsolns%2 <> size(L[1])%2 ) {  \n\
        OddCycle=1; \n\
      } \n\
      if (deg(L[1][1])== numsolns-1) { \n\
        Nminusonecycle=1; \n\
      } \n\
      if (numsolns == 7) { \n\
        if (deg(L[1][1]) == 4) { \n\
          BigPrimecycle=1; \n\
        } \n\
      } \n\
      // When we have 5 solutions, Primes=2. When we have 7 solutions, Primes=3 \n\
      if (numsolns == 5 or numsolns == 7) { \n\
        int Count_Prime_Appearance = 0; \n\
        for (ii=1; ii<=size(L[1]); ii++) { \n\
          if (deg(L[1][ii]) == Primes[1]) {\n\
            Count_Prime_Appearance++; \n\
          } \n\
        } \n\
        if (Count_Prime_Appearance == 1) { \n\
          BigPrimecycle=1; \n\
        } \n\
      } \n\
      else{ \n\
        for (ii=1; ii<=nrows(Primes); ii++) { \n\
          if (ii == 1 and 2*Primes[1] <= numsolns) { \n\
            if (deg(L[1][1])== Primes[1]) { \n\
              if (deg(L[1][2]) < Primes[1]) { \n\
                BigPrimecycle=1; \n\
              } \n\
            } \n\
          } \n\
          else { \n\
            if (deg(L[1][1])==Primes[ii]) { \n\
              BigPrimecycle=1; \n\
            } \n\
          } \n\
        } \n\
      } \n\
      if (OddCycle*BigPrimecycle*Nminusonecycle==1) { \n\
        1; \n\
        quit; \n\
      } \n\
    } \n\
  } \n\
} \n\
0; \n\
quit; \
')

#################################################################################################################################################################

# This function creates an example problem file if one is not found

def createprobtemplate():
	with open('grassprobs.txt','w') as template:
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

#################################################################################################################################################################

# Main program starts here

try:
	with open('schubert_template.sing','r'):
		pass
except IOError:
	createtemplate()

try:
	with open('grassprobs.txt','r'):
		pass
except IOError:
	createprobtemplate()

# You can change char to whatever characteristic you want to work in.
# Commenting out 'char= 1009' and removing the comment from 'char= pickchar()' will allow you to choose the characteristic each time you initiate the script

#char= pickchar()
char= 1009

with open('grassprobs.txt','r') as problems:
	for line in problems:
		# Gather all of the required information from the problem given
		if not line.startswith('['):
			continue
		parts= line.split('[')
		numsolns= parts[1].split(',')[0]
		# we check for desired cycles trials*numsolns times
		trials= 10
		# maximum size of random numbers when generating a random condition
		randomnumsize= 1000
		# length of a condition vector
		m= len(parts[2].split(','))-1
		# (last entry of a condition vector)-(length of condition vector)
		p= int(parts[2].split(',')[-2].split(']')[0])-m
		if not reduced(line, m, p):
			continue
		condone= completecond(parts[2],m+p)
		condtwo= completecond(parts[3],m+p)
		remaincond= 'list( intvec('
		for i in range(4,len(parts)):
			if i < len(parts)-1:
				remaincond= remaincond + completecond(parts[i],m+p) + '), intvec('
			else:
				remaincond= remaincond + completecond(parts[i],m+p) + ') )'
		# Fill in the variables in the singular script
		for myline in fileinput.input('schubert_template.sing', inplace=1):
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
		result= int( str( subprocess.check_output(['Singular', 'schubert_template.sing']) )[-19] )
		# Singular will output documentation information along with the return from our singular file. The character we read above is the output of our program
		# Next, we will add the problem we just ran to one of two files depending on whether or not we found the full Symmetric group.
		if result:
			with open('Full_Symmetric_Group.txt','a') as answer_file:
				answer_file.write(line + ' \n')
		else:
			with open('Unknown_Galois_Group.txt','a') as answer_file:
				answer_file.write(line + ' \n')
