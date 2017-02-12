require 'matrix'
require 'pp'
require 'test/unit'
require_relative 'NDimensionalMatrix'

class SparseMatrix
	attr_accessor :dimension, :values_hash
	include Test::Unit::Assertions

	# initialize the SparseMatrix
	def initialize(*args)
		begin
			*rest_of_args,input_hash=*args
			init_Hash(*rest_of_args,input_hash)
		rescue
			init_dim *args
		end
	end

	def init_Hash(*rest_of_args,input_hash)

		# should be in a pre and post
			# assert_respond_to(input_hash, :[])
			assert_respond_to(input_hash, :length)
			assert_respond_to(input_hash, :hash)
			rest_of_args.each do |arg|

				assert_respond_to(arg,:to_i)
			end

			@values_hash=input_hash
			@dimension=*rest_of_args
	end


	def init_dim(*args)

		@values_hash = Hash.new
		@dimension=*args
		invariants
	end

	# Insert values into matrix
	def insert_at(position,value)
		pre_insert_at(position,value)
		@values_hash[position] = value
		post_insert_at(position,value)
	end

	#
	def to_s
		@values_hash.each do |key, array|
			puts "#{key}---#{array}"
		end
	end

	def invariants()
		assert(@values_hash.length <= size/2,"this is not sparse")
		assert(size >= 1,"not a valid matrix dimension")
		assert (self.is_a? SparseMatrix), "It is not a sparse matrix whoops"
	end
    #returns the size
	def size()
		return @dimension.inject(:*)
	end


	def checkSum
		preCheckSum(self)
		sum = 0
		self.getValues.each do |key,value|
			sum = yield sum, value
		end
		postCheckSum(sum)
		return sum
	end

	def preCheckSum(matrix)
		assert(matrix.respond_to? (:getValues))
		invariants
	end

	def postCheckSum(sum)
		assert sum.respond_to? (:round)
		invariants
	end

	# FOR LATERRRR ################
	# def +(m)
	# 	pre_sparse_matrix_addition(m)
	# 	post_sparse_matrix_addition(m)
	# end


	def +(m)
		if m.respond_to?(:sparse_matrix_add_sub)
			result = self.sparse_matrix_add_sub(m){|v1,v2| v1+v2}
		else
			result = self.scalar_add_sub(m){|v1| v1 + m}
		end
	end

	def -(m)
		if m.respond_to?(:sparse_matrix_add_sub)
			result = self.sparse_matrix_add_sub(m){|v1,v2| v1-v2}
		else
			result = self.scalar_add_sub(-m){|v1| v1 - m}
		end
	end

	def sparse_matrix_add_sub(m)
		result=m.get_array
		@values_hash.each do |key, value|
			result[key[0]][key[1]] = yield(values_hash[key],result[key[0]][key[1]])
		end

		begin
			result=array_to_sparse(result)
		rescue
			return result
		end

		return result
	end

	#need to move this into calvin's class
	def array_to_sparse(dense_m)
		sparse_m=SparseMatrix.new
		for i in 0..dense_m.getDimension[0]-1 do
			for j in 0..dense_m.getDimension[0]-1 do

				if dense_m[i][j]!=0
					sparse_m.insert_at([i,j],dense_m[i][j])
				end

			end
		end
		return sparse_m
	end
	def get_array
		result=Array.new(dimension[0]){Array.new(dimension[1],0)}
		@values_hash.each do |key,value|
			result[key[0]][key[1]]=value
		end
		return result
	end
	def scalar_add_sub(m)


		result=Array.new(@dimension[0]){Array.new(@dimension[1],m)}
		@values_hash.each do |key,value|
			result[key[0]][key[1]] = yield(values_hash[key])
		end
		return result
	end

	def *(m)

		if m.respond_to?(:sparse_matrix_multiplication)
			result = self.sparse_matrix_multiplication(m)
		else
			result = self.scalar_mult_div{|v1| v1 * m}
		end
	end

	def /(m)
		if m.respond_to?(:sparse_matrix_multiplication)
			result = self.sparse_matrix_multiplication(inverse(m))
		else
			result = self.scalar_mult_div{|v1| v1 / m}
		end
	end

	def scalar_mult_div
		result = @values_hash.dup
		result.each do |key1, value1|
			puts
			result[key1] = yield(result[key1])
		end
		return SparseMatrix.new(*@dimension,result)
	end



	## NOT DONE
	def sparse_matrix_multiplication(m)

		for i in 0..dimension[0]-1 do
			sum = 0
			for j in 0..dimension[0]-1 do
				v1=0;
				v2=0;
				begin
					v1= @values_hash[[i,j]]
				rescue
					v2=m.getValues([])
				rescue
					next
				end
			end
		end
		return something
	end

	# def det()
	# 	preDeterminant
	# 	postDeterminant
	# end

	# def **(other)
	# 	pre_power
	# 	post_power
	# end

	# raises every element in the matrix to numbers power
	def power(other)
		pre_power(other)
		# stuff
		retval=SparseMatrix.new(@dimension)
		post_power(other,retval)
	end


	def transpose()
		# preTranspose
		# postTranspose
	end

	def inverse(m)
		preInverse
		postInverse
	end

	def getDimension
		return self.dimension
	end

	def getValues
		return self.values_hash
	end

	def scalar_addition(other)
		pre_scalar_addition(other)
		retval = SparseMatrix.new(@dimension)
		post_scalar_addition(other,retval){|other, original| original.checkSum{|sum, value| sum+value} + (original.size * other)}
	end

	def scalar_subtraction(other)
		pre_scalar_subtraction(other)
		retval = SparseMatrix.new(@dimension)
		post_scalar_subtraction(other,retval){|other, original| original.checkSum{|sum, value| sum+value} - (original.size * other)}
	end

	def scalar_multiplication(other)
		pre_scalar_multiplication(other)
		retval = SparseMatrix.new(@dimension)
		post_scalar_multiplication(other,retval){|other, original| original.checkSum{|sum, value| sum+value} * other}
	end

	def scalar_division(other)
		pre_scalar_division(other)
		retval = SparseMatrix.new(@dimension)
		post_scalar_division(other,retval){|other, original| original.checkSum{|sum, value| sum+value} / other}
	end

	# to insert a value in a sparse matrix we have to ensure the position is valid for that matrix's dimension
	# we also cannot insert zeros as they are implied to be there.
	def pre_insert_at(position,value)
		invariants
		assert_equal position.length, @dimension.length,"Invalid position."
		for i in 0..@dimension.length-1 do
			assert(@dimension[i]>position[i], "Invalid position in matrix")
		end
		assert (value!=0), "Inserting a zero"
	end

	# ensures that the value is inserted to the matrix
	def post_insert_at(position,value)
		invariants
		assert_equal value,@values_hash[position],"Value is not inserted. FAILED."
	end

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
	# i feel like we need this
	# and it actually works
	def n_dimensional_array(dim_array,initial_value)
		# will use eval function with string like:
		# Array.new(dim_array[0]) {Array.new(dim_array[1])... {Array.new(dim_array[n], initial_value)}...}

	end

	private :pre_sparse_matrix_addition, :post_sparse_matrix_addition
	private :pre_scalar_addition, :post_scalar_addition
	private :pre_sparse_matrix_subtraction, :post_sparse_matrix_subtraction
	private :pre_scalar_subtraction, :post_scalar_subtraction
	private :pre_sparse_matrix_multiplication, :post_sparse_matrix_multiplication
	private :pre_scalar_multiplication, :post_scalar_multiplication
	private :pre_sparse_matrix_division, :post_sparse_matrix_division
	private :pre_scalar_division, :post_scalar_division
	private :preDeterminant, :postDeterminant
	private :preInverse, :postInverse
	private :preTranspose, :postTranspose
	# private :pre_power, :post_power

end

# b = SparseMatrix. new(2,2)
# b.insert_at([1,1],5)
# b.to_s
# puts b.checkSum{|sum, x| sum+x}
#
# c = DenseMatrix. new(3,3)
# c.insert_at([1,1],2)
# c.insert_at([0,0],0)
# c.insert_at([0,1],0)
# c.insert_at([1,0],1)
#
# a = DenseMatrix. new(2,3)
# a.insert_at([1,1],10)
# a.insert_at([0,0],0)
# a.insert_at([0,1],0)
# a.insert_at([1,0],5)
#
# d= SparseMatrix. new(3,2)
# d.insert_at([2,1],5)


b = SparseMatrix. new(3,3)
b.insert_at([1,1],1)
b.insert_at([0,0],2)
b.insert_at([0,1],2)
d = SparseMatrix. new(3,3)
# d.insert_at([1,1],2)
# d.insert_at([0,0],2)
# d.insert_at([0,1],2)
b.to_s
c = b + d
c.to_s
p c
#I knew this wouldn't work but reem yelled at me NVM FIXED
e=b*2
p b.get_array
p e.get_array
# b.to_s
# h=Hash.new
# h[[1,1]]=1
# h[[0,1]]=2
# a= SparseMatrix.new(3,3,h)
# puts a.getDimension
