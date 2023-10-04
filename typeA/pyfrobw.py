import subprocess

f = open('frobenius_output-F246.txt', 'x')
f.close()

with open('F246.txt','r') as input_file:
	content = input_file.read()
lines = content.split('\n')

for line in lines:
	with open('wfrobenius.m2', 'r') as file:
		data = file.readlines()	
	data[167] = 'problem = ' + str(line) + ';\n'
	with open('wfrobenius.m2', 'w') as file:
		file.writelines(data)
	subprocess.run(["M2 wfrobenius.m2"], shell=True, capture_output=True, text=True)
