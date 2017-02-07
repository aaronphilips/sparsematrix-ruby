require 'matrix'
require 'pp'
require 'test/unit'

class SparseMatrix
	attr_accessor :dimension, :valuesHash
	include Test::Unit::Assertions

	def initialize(args)
		@values_hash = Hash.new
		@dimension=args
		invariants
	end

	def insert_at(position,value)
		pre_insert_at(position,value)
		@values_hash[position] = value
		post_insert_at(position,value)
	end

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

	def size()
		@dimension.inject(:*)
	end

	def +(m)
		preAddition(m)
		postAddition(m)
	end

	def -(m)
		preSubstraction
		postSubstraction
	end

	def *(m)
		preMultiplication
		postMultiplication
	end

	def /(m)
		preDivision
		postDivision
	end

	def det()
		preDeterminant
		postDeterminant
	end

	def **(other)
		pre_power
		post_power
	end

	def power(other)
		pre_power(other)
		copy_hash = @values_hash.dup
		post_power(other,copy_hash)
	end

	def transpose()
		preTranspose
		postTranspose
	end

	def inverse()
		preInverse
		postInverse
	end

	def getDimension
		return self.dimension
	end

	def getValues
		return self.valuesHash
	end

	def scalar_addition(other)
		pre_scalar_addition(other)
		copy_hash = @values_hash.dup
		post_scalar_addition(other, copy_hash)
	end

	def scalar_subtraction(other)
		pre_scalar_subtraction(other)
		copy_hash = @values_hash.dup
		post_scalar_subtraction(other,copy_hash)
	end

	def scalar_multiplication(other)
		pre_scalar_multiplication(other)
		copy_hash = @values_hash.dup
		post_scalar_multiplication(other,copy_hash)
	end

	def scalar_division(other)
		pre_scalar_division(other)
		copy_hash = @values_hash.dup
		post_scalar_division(other,copy_hash)
	end

	def pre_insert_at(position,value)
		invariants
		assert_equal position.length, @dimension.length,"Invalid position."
		#puts "#{@dimension.length}"
		for i in 0..@dimension.length-1 do
			assert(@dimension[i]>position[i], "Invalid")
		end
		assert(value!=0)
	end

	def post_insert_at(position,value)
		invariants
		assert_equal value,@values_hash[position],"Invalid"

	end

	def preAddition(m)
		invariants
		assert(m.is_a?(SparseMatrix), 'not adding by a sparse matrix')
		assert_equal self.dimension.length, m.getDimension.length, "matrices need to be same dimension"
		assert_equal self.dimension, m.getDimension, "dimension sizes are different"

	end

	def postAddition(m)
		invariants
		assert_equal(self, result - m, 'matrices didnt add correct')
	end

	def preSubstraction()
		#same as preAddition
		invariants
	end

	def postSubstraction()
		#same as postSubtraction
		invariants
	end

	def pre_scalar_subtraction()
		invariants
		assert (other.is_a? Numeric), "Not a number"
	end

	def post_scalar_subtraction()
		invariants
		# think it should be try catch
		if other == 0
			invariants
		else
			# assume Dense matrix returned
			#check dense matrix is correct
			#see n_dimensional_array
		end
	end

	def pre_scalar_addition(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
	end

	def post_scalar_addition(other, copy_hash)
		# think it should be try catch
		if other == 0
			invariants
		else
			# assume Dense matrix returned
			#check dense matrix is correct
		end

	end

	def preMultiplication()
		invariants
	end

	def postMultiplication()
		invariants
	end

	def pre_scalar_multiplication(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
	end

	def post_scalar_multiplication(other, copy_hash)
		invariants
		@values_hash.each do |key,value|
			assert_equal (copy_hash[key]*other),value, "Did not multiply successfully"
		end
	end

	def preDivision()
		invariants
	end

	def postDivision()
		invariants
	end

	def pre_scalar_division(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
		assert (other!=0), "Division by a zero"
	end

	def post_scalar_division(other, copy_hash)
		invariants
		@values_hash.each do |key,value|
			assert_equal (copy_hash[key]/other),value, "Did not divide successfully"
		end

	end

	def preDeterminant()
		assert_block ('matrix is not square') do
			self.getDimension.all? {|dimensionSize| dimensionSize == self.getDimension[0]}
		end
		invariants
	end

	def postDeterminant(result)
		assert(result.is?Integer, 'result is not an Integer')
		assert_equal(result, (self.transpose).determinant, 'det didnt work')

		invariants
	end


	def preTranspose()
		#nothing?
		invariants
	end

	def postTranspose(result)
		assert_equal(self.getDimension, result.getDimension.reverse, 'dimensions are not correct')
		assert_equal(self, result.transpose, 'transpose not correct')
		invariants
	end

	def preInverse()
		assert(preDeterminant, 'matrix needs to be bale to get determinant')
		invariants
	end

	def postInverse(result)
		assert_equal(self.getDimension, result.getDimension, 'dimension are not the same')
		assert_equal(identityMatrix, self * result, 'inverse did not work')
		invariants
	end

	def pre_power(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
	end

	def post_power(other, copy_hash)
		if other != 0
			invariants
			@values_hash.each do |key,value|
				assert_equal (copy_hash[key]**other),value, "Did not exponentiate successfully"
			end
		else
			# check that its n_dimensional_array of ones
		end
	end
	# i feel like we need this
	# and it actually works
	def n_dimensional_array(dim_array,initial_value)
		# will use eval function with string like:
		# Array.new(dim_array[0]) {Array.new(dim_array[1])... {Array.new(dim_array[n], initial_value)}...}

	end

	private :preAddition, :postAddition
	private :pre_scalar_addition, :post_scalar_addition
	private :preSubstraction, :postSubstraction
	private :pre_scalar_subtraction, :post_scalar_subtraction
	private :preMultiplication, :postMultiplication
	private :pre_scalar_multiplication, :post_scalar_multiplication
	private :preDivision, :postDivision
	private :pre_scalar_division, :post_scalar_division
	private :preDeterminant, :postDeterminant
	private :preInverse, :postInverse
	private :preTranspose, :postTranspose
	private :pre_power, :post_power

end
b = SparseMatrix. new([2,2])
b.insert_at([1,1],1)
b.to_s

