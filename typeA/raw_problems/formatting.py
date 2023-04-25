import json
import re

def unpack(input_string):
	modified_string = input_string.split("|")
	if len(modified_string) != 3:
		return(False)
	L1 = []
	L1.append([int(i) for i in modified_string[0]])
	L2 = []
	y = json.loads(modified_string[2])
	for thing in y:
		L2.extend([thing[0] for i in range(thing[1])])
	L1.append(L2)
	L = [L1,int(modified_string[1])]
	return(str(L))

with open('F235.txt','r') as input_file:
	content = input_file.read()

lines = content.split('\n')

modified_lines = []

for line in lines:
	modified_line = unpack(line)
	if modified_line:
		modified_lines.append(modified_line)

modified_content = '\n'.join(modified_lines)
modified_content = re.sub(r'\[','{',modified_content)
modified_content = re.sub(r'\]','}',modified_content)

with open('F235modified.txt','w') as output_file:
	output_file.write(modified_content)
