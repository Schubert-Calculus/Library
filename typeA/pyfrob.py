import subprocess

f = open('frobenius_output-F1346.txt', 'x')
f.close()

with open('Flags-In-6-Space/F1346/F1346.txt','r') as input_file:
	content = input_file.read()
lines = content.split('\n')
del lines[-1]

if lines != ['']:
	for line in lines:
		with open('trial_frobenius.m2', 'r') as file:
			data = file.readlines()	
		data[167] = 'problem = ' + str(line) + ';\n'
		with open('trial_frobenius.m2', 'w') as file:
			file.writelines(data)
		subprocess.run(["M2 trial_frobenius.m2"], shell=True, capture_output=True, text=True)	
