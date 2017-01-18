# sparsematrix-ruby
## An object-oriented library for sparse 2-dimensional matrices

### What is a sparse matrix?
-A sparse matrix is a matrix whose elements are mainly zero. Namely there a <br>
a majority of elements with a value of zero <br>

### What are sparse matrices used for ?
-Sparse matrices have applications in science and mathematics, mainly for <br>
partial differentials

###Derived features from:
-Wikipedia, Matlab documents, Ruby Matrix class documents <br>

###Most likely users of this library
-Programmers, mathematicians, engineers, scientists <br>

###What is a tri-diagonal matrix?
-A matrix where on a diagonal band of three lines, non-zero numbers are only on the lines. <br>
-Properties of a tri-diagonal matrix with the assumption that it is a square: <br>
	-Number of non-zero = n + 2(n - 1) = 3n - 2
	-Number of zeros = n^2 - non-zero = n^2 - n - 2(n -1) = n^2 -3n + 2

###What is the relationship between a tri-diagonal matrix and a generic sparse matrix
-Assuming the matrices are nxn and using the above equations and defintion of a sparse matrix
	- # of zero > # of non-zero
	- n^2 -3n + 2 > 3n -2
	- n^2 -6n + 4 > 0
	- the roots of the left are (3 +/- sqrt(5))
	- therefore a tri-diagonal matrix becomes a generic sparse matrix when the size is greater than 6

###Are tri-diagonal matrices important? And should they impact our design and if so how?
-Yes they are important. They are used to solve linear system of equations. They can be used to solve partial differential equations as well. <br>
-It impacts the design because if the size is greater than 6, we then know it is a subset of a sparse matrix
-If two tri-diagonal matrices of the same size and are a sprse matrix and are added or subtracted together, 
the result is always a sparse matrix. Avoiding any kind post condition checks.

###What is a good data representation for a sparse matrix?
-Methods that could be used to represent the data is compressed sparse row (CSR) and compressed sparse columns (CSC) <br>