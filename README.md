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

###Design Patterns
###Delegate Pattern

-Using composition to avoid code reuse. This requires essentially two thing: first, incorporating other objects and classes in a class. This is called composition. Second, responsiblility is passed from the original class, to methods of the classes and objects that are used in composition of the original class. This is called delgation.
Abstract Factory Pattern

    Basically a tool for making a group of related objects ( using factories) but without making concrete instances itself. The Group of related objects would be concrete factories that could instantiate concrete objects

###Ruby Delegate

    We can introduce a form of multiple inheritance with mixin modules. Mixin is a feature of ruby where you use the 'include' keyword to easily include definitions of all the methods of that module in that class. The classes can mixin a series of modules for composition by including them. The modules would handle the delegated responsibilities.

###Ruby Abstract Factory

    We would use the ineritance operator '<'. To mimmic the abstract aspect, we can have the parent abstract class raise exceptions in the methods that would be inherited in the concrete factory subclasses

###Applications to sparsematrix-ruby

    The Delegate pattern could be used tranfer responsiblilities. For example: tri-diagonal matrics with dimensions NxN where N larger than 5, could delate responsiblility to sparse matrix class that would be used in the tri-diagonal class with composition
    The Abstract Factory pattern can be used to create generic matrices. The concrete factories and classes that would be instantiated could be Dense matrices, sparse matrices, tri-diagonal matrices


###Assume that you have a customer for your sparse matrix package. The customer states that their primary requirements as: for a N x N matrix with m non-zero entries
	###Storage should be ~O(km), where k << N and m is any arbitrary type defined 	in your design.
	###Adding the m+1 value into the matrix should have an execution time of ~O(p) 	where the execution time of all method calls in standard Ruby container classes 	is considered to have a unit value and p << m ideally p = 1. In this scenario, 	what is a good data representation for a sparse matrix?
-A good data representation might be to use CSR or CSC, but keep a record of the dimension of the matrix, that way, it would not lose any information on the matrix



##What implementation approach are you using (reuse class, modify class, inherit from class, compose with class, build new standalone class); justify your selection.

The implementation approach that will be used is composition. The defined matrix class in ruby will be used in the implementation of the sparse matrix. Some operations will have a matrix object to speed up the computation. A new standalone sparce matrix class will be implemented that uses the matix class.

###Is iteration a good technique for sparse matrix manipulation? Is “custom” iteration required for this problem?

 Yes, iteration would be a good technique for sparse matrix manipulation.

###What exceptions can occur during the processing of sparse matrices? And how should the system handle them?
- a sparse matrix could potentially break the definition of a sparse matrix after operations such as addition or subtraction. The post conidtion of the operation will detect that the conditions for a sparse matrix has been broken. It will then return the result as a matrix class instead of a sparse matrix class. If the object that is being assigned the result is a sparse matrix it will then check its invariants to determine if they have been broken or not. If they are broken, the invariant method of the sparse matrix will then throw an error indicating that the invariants have been broken.

###What are the important quality characteristics of a sparse matrix package? Reusability? Efficiency? Efficiency of what?
- A sparse matrix package should be reusable as it should be able to be be used in a general matrix class that has a condition that is under a sparse matrix's domain. Or it should be able to be modified to work as a dense matrix or any other matrix types. 
- The package should be efficient in that it should not take more resources than a simple matrix generally would. Nor should it take more time to run any operation than the simple matrix would.
- The package should be usable. It shouldn't require a manual on how to use all the functions. It should be logical and consistent on how the functions are used. 
- The package should be reliable. It shouldn't return any incorrect return values.
- the package should also be Extendable. It shouldn't be difficult to implement new functions into it that are required yet missing. 

###How do we generalize 2-D matrices to n-D matrices, where n > 2 – um, sounds like an extensible design?

    We will use another system for compressing n- D dimestional matrices that is not as efficient as CSR. Essentially it will use tuples for every non-zero values, along with its position in in each dimension of the matrice. Example: for a 3x3x3 or 3-D matrices. ( Note it is depicated as 3 pages of 3x3 , 2-D matrices) [1 0 0] [0 8 3] [0 2 8] [0 2 0] [0 2 0] [1 0 0] [4 0 0] [0 0 6] [0 0 0]
    The tuples would be: (1,0,0,0) (2,1,1,0) (4,0,2,0) (8,1,0,1) (3,2,0,1) (2,1,1,1) (6,2,2,1) (2,1,0,2) (8,2,0,2) (1,0,1,2)

The heuristics are as follows:. While it make not efficient as CSR, as shown above, it is extensible to n dimensions






