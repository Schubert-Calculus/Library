import fileinput
import subprocess

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
poly F; \n\
int T=timer; \n\
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
        fprintf(":a output_Time","%s", timer-T);\n\
	fprintf(":a output_Steps", "%s",j);\n\
        quit; \n\
      } \n\
    } \n\
  } \n\
} \n\
fprintf(":a output_Time","Fail");\n\
fprintf(":a output_Steps", "Fail");\n\
quit; \
')

#################################################################################################################################################################

try:
	with open('schubert_template.sing','r'):
		pass
except IOError:
	createtemplate()


with open('problems.txt','r') as problems:
	for line in problems:
		# Gather all of the required information from the problem given
#		if not line.startswith('['):
#			continue
		char=1009
		parts= line.split('|')
		numsolns=int( parts[2])
		# we check for desired cycles trials*numsolns times
		trials= 10
		# maximum size of random numbers when generating a random condition
		randomnumsize= 1000
		# length of a condition vector
		m=int( parts[1].split(',')[0])
		# (last entry of a condition vector)-(length of condition vector)
		p=int( parts[1].split(',')[1])-m
		condone= parts[3].split(';')[0]
		condtwo= parts[3].split(';')[1]
		remaincond= 'list( intvec('
		for i in range(2,len(parts[3].split(';'))):
			if i < len(parts[3].split(';'))-1:
				remaincond= remaincond + parts[3].split(';')[i] + '), intvec('
			else:
				remaincond= remaincond + parts[3].split(';')[i] + ') )'
		
		f = open('output_Steps', 'a')
		f.write(parts[0] + ": \n",)
		f.close()
		f = open('output_Time', 'a')
		f.write(parts[0] + ": \n",)		
		f.close()

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
		count = 0
		while (count < 1000):
   			count = count + 1
			subprocess.check_output(['Singular', 'schubert_template.sing']) 
#		print("%s is done. \n", parts[0])

#print("Finished.")

