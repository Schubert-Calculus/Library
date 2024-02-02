import numpy as np

def multivariateRegression(X,Y,Z):
	A = np.array([[np.shape(X)[1],np.sum(X),np.sum(Y)],[np.sum(X),np.sum(X*X),np.sum(X*Y)],[np.sum(Y),np.sum(X*Y),np.sum(Y*Y)]])
	b = np.array([[np.sum(Z)],[np.sum(X*Z)],[np.sum(Y*Z)]])
	return(np.linalg.inv(A).dot(b))

X = np.array([[18,24,12,30,30,22]])
Y = np.array([[52,40,40,48,32,16]])
Z = np.array([[144,142,124,64,96,92]])

multivariateRegression(X,Y,Z)

