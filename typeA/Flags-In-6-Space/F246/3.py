import subprocess

f = open('output3-F246.txt', 'x')
f.close()

with open('batch3.txt','r') as input_file:
	content = input_file.read()
lines = content.split('\n')
del lines[-1]

if lines != ['']:
	for line in lines:
		with open('frob3.m2', 'r') as file:
			data = file.readlines()	
		data[167] = 'problem = ' + str(line) + ';\n'
		with open('frob3.m2', 'w') as file:
			file.writelines(data)
		subprocess.run(["M2 frob3.m2"], shell=True, capture_output=True, text=True)	
