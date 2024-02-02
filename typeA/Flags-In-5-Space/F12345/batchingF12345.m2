restart
path = {"../../../WorkInProgress/Macaulay2Package/SchubertM2/"} | path 
recursionLimit=10000
loadPackage("SchubertIdeals", Reload => true)

frobtime = method()
frobtime(List) := (prob) -> (
    v := typeALength(dimToCodim(prob#0#0,prob#0#1#0),prob#0#0#-1);
    s := prob#1;
    A := exp(0.234*v-1.8)-0.574;
    B := exp(0.751*v-9.05)+0.02;
    C := 4.11*exp(-0.246*v)+0.211;
    T := (A+B*s)^C;
    return(T*12*prob#1))

regressionTime = method()
regressionTime(List) := (prob) -> (
    v := typeALength(dimToCodim(prob#0#0,prob#0#1#0),prob#0#0#-1);
    s := prob#1;
    return(-8.64298235 + 0.0395682*v + 1.98113039*s))
    
inputfile = get "F12345.txt";
filelist = lines(inputfile);
problems = {};
for file in filelist do(
	problems = append(problems, value(file)))
j = 1;
i = 0;
batchlimit = 60;
while i < length(problems) do(
	f = concatenate("batch",toString(j),".txt") << "";
	currentsum = 0;
	while (currentsum < batchlimit and i < length(problems)) do(
		currentsum = currentsum + regressionTime(problems#i);
		f << problems#i << endl;
		i = i+1);
	j = j+1)
quit();
