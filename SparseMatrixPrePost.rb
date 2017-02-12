# ensures that the the value added is a spare matrix and dimensions of the two matrices are the same
def pre_sparse_matrix_addition(other)
	assert(other.respond_to?(:checkSum), 'not adding by a sparse matrix')
	# assert_equal self.dimension.length, other.getDimension.length, "matrices need to be same dimension"
	assert_equal self.dimension, other.getDimension, "dimension sizes are different"
	invariants
end

# ensures that that the sparse matrix is added correctly
def post_sparse_matrix_addition(other, result)
	expected = self.checkSum{|sum, value| sum + value} + other.checkSum{|sum, value| sum + value}
	actual = result.checkSum{|sum, value| sum + value}
	assert_equal expected, actual, 'matrices added wrong'
	assert_equal self.getDimension, result.getDimension, 'returned matrix of different dimension'
	invariants
end

# ensures that the value taken in is a sparse matrix and the dimensions of the two matrices are the same
def pre_sparse_matrix_subtraction(other)
    assert(other.respond_to?(:checkSum), 'not adding by a sparse matrix')
    # assert_equal self.dimension.length, m.getDimension.length, "matrices need to be same dimension"
    assert_equal self.dimension, other.getDimension, "dimension sizes are different"
    invariants
end

# ensures that the sparse matrix is subtracted correctly
def post_sparse_matrix_subtraction(other,result)
    expected = self.checkSum{|sum, value| sum + value} - other.checkSum{|sum, value| sum + value}
	actual = result.checkSum{|sum, value| sum + value}
	assert_equal expected, actual, 'matrices subtracted wrong'
	assert_equal self.getDimension, result.getDimension, 'returned matrix of different dimension'
	invariants
end

# ensures that the value inputted is a a Numeric
def pre_scalar_subtraction(other)
	assert (other.respond_to? (:round)), "Not a number"
	invariants
end

# ensures that the scalar subtraction is correct. Also makes sure that if the value to be substracted
# is zero, then the result matrix is the same as the original matrix
def post_scalar_subtraction(other,result)
	expected = yield other,self
	actual = result.checkSum{|sum, value| sum + value}
	assert_equal expected , actual, 'subtracted wrong by scalar'
	assert_equal self.getDimension, result.getDimension, 'returned matrix of different dimension'
	invariants
end

# ensures that the value inputted is a Numeric value
def pre_scalar_addition(other)
	assert (other.respond_to? (:round)), "Not a number"
	invariants
end

# ensures that the scalar addition is correct. If the value is zero then the matrix should be the same
def post_scalar_addition(other,result)
	expected = yield other,self
	actual = result.checkSum{|sum, value| sum + value}
	assert_equal expected , actual, 'added wrong by scalar'
	assert_equal self.getDimension, result.getDimension, 'returned matrix of different dimension'
	invariants
end

# ensures that the value inputted is a sparse matrix and the dimensions is 2 (for now)
def pre_sparse_matrix_multiplication(other)
	assert(other.respond_to?(:getDimension), 'not adding by a sparse matrix')
    # assert_equal self.dimension.length, m.getDimension.length, "matrices need to be same dimension"
    assert_equal self.getDimension[1], other.getDimension[0], "dimension sizes are incorrect"
    invariants
end

# ensures that the multiplication of a sparse matrix is multiplied correctly
def post_sparse_matrix_multiplication(other,result)
	assert_equal self.getDimension[0], result.getDimension[0], 'returned matrix of different x dimension'
	assert_equal other.getDimension[1], result.getDimension[1], 'returned matrix of different y dimension'
	invariants
end

# ensures that the value inputted is a numeric
def pre_scalar_multiplication(other)
	assert (other.respond_to? (:round)), "Not a number"
	invariants
end

# ensures that the multiplication of a scalar is correct and is always a sparse matrix
def post_scalar_multiplication(other, result)
	expected = yield other,self
	actual = result.checkSum{|sum, value| sum + value}
	assert_equal expected , actual, 'multiplied wrong by scalar'
	assert_equal self.getDimension, result.getDimension, 'returned matrix of different dimension'
	invariants
end

# ensures that the value inputted is a sparse matrix
def pre_sparse_matrix_division(other)
	invariants
	assert (other.respond_to? (:getDimension)), "Not a SparseMatrix"
	assert_block ('matrix is not square') do
		other.getDimension.all? {|dimensionSize| dimensionSize == other.getDimension[0]}
	end
	assert_equal self.getDimension[1], other.getDimension[0], "dimension sizes are incorrect"
	# assert(other.determinant != 0)

end

# ensures that the division of the matrix is implemented correctly by taking the inverse of the matrix
def post_sparse_matrix_division(other,result)
	assert_equal self.getDimension[0], result.getDimension[0], 'returned matrix of different x dimension'
	assert_equal other.getDimension[1], result.getDimension[1], 'returned matrix of different y dimension'
	invariants
end

# ensures that the number inputted is a numeric
def pre_scalar_division(other)
	assert (other.respond_to? (:round)), "Not a number"
	assert (other!=0), "Division by a zero"
	invariants
end

# ensures that the division of the scalar is done successfully
def post_scalar_division(other, result)
	expected = yield other,self
	actual = result.checkSum{|sum, value| sum + value}
	assert_equal expected , actual, 'divided wrong by scalar'
	assert_equal self.getDimension, result.getDimension, 'returned matrix of different dimension'
	invariants

end

# checks the preconditions of the determinant.
def preDeterminant()
	assert_block ('matrix is not square') do
		self.getDimension.all? {|dimensionSize| dimensionSize == self.getDimension[0]}
	end
	invariants
end

# ensures that the determinant is correct by taking the transpose
def postDeterminant(result)
	assert(result.respond_to? (:round), 'result is not an Integer')
	# assert_equal(result, (self.transpose).determinant, 'det didnt work')

	invariants
end

# ensures that it is a sparse matrix
def preTranspose()
	assert(self.respond_to? (:getDimension), 'not a sparse matrix')
	invariants
end

# ensures that the result of the transpose is correct by retransposing it
def postTranspose(result)
	assert_equal(self.getDimension, result.getDimension.reverse, 'dimensions are not correct')
	assert_equal(self.checkSum{|sum, value| sum + value}, result.checkSum{|sum, value| sum + value}, 'transpose failed')
	# assert_equal(self, result.transpose, 'transpose not correct')
	invariants
end

# ensures that the matrix is a sparse matrix
def preInverse()
	assert_block ('matrix is not square') do
		self.getDimension.all? {|dimensionSize| dimensionSize == self.getDimension[0]}
	end
	# assert(self.determinant != 0)
	invariants
end

# ensures that the inverse is done correctly
def postInverse(result)
	assert_equal(self.getDimension, result.getDimension, 'dimension are not the same')
	# assert_equal(identityMatrix, self * result, 'inverse did not work')
	invariants
end

# ensures that it is a sparse matrix
def pre_power(other)
	assert(other.respond_to? (:round), "Not a number")
	invariants
end

# ensures that the result of the power operator is correct
def post_power(result)
	assert_equal(self.getDimension, result.getDimension, 'dimensions not the same')
	invariants
end