require 'matrix'
require 'pp'
require 'test/unit'

class SparseMatrix
	attr_accessor :dimension, :values_hash
	include Test::Unit::Assertions

	# initialize the SparseMatrix
	def initialize(*args)
		@values_hash = Hash.new
		@dimension=args
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
		preTranspose
		postTranspose
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
		post_scalar_addition(other, retval)
	end

	def scalar_subtraction(other)
		pre_scalar_subtraction(other)
		retval = SparseMatrix.new(@dimension)
		post_scalar_subtraction(other,retval)
	end

	def scalar_multiplication(other)
		pre_scalar_multiplication(other)
		retval = SparseMatrix.new(@dimension)
		post_scalar_multiplication(other,retval)
	end

	def scalar_division(other)
		pre_scalar_division(other)
		retval = SparseMatrix.new(@dimension)
		post_scalar_division(other,retval)
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
		invariants
		assert(other.is_a?(SparseMatrix), 'not adding by a sparse matrix')
		# assert_equal self.dimension.length, other.getDimension.length, "matrices need to be same dimension"
		assert_equal self.dimension, other.getDimension, "dimension sizes are different"
	end

	# ensures that that the sparse matrix is added correctly
	def post_sparse_matrix_addition(other,result)
		invariants
		result.getValues.each do |key1,value1|
			assert_equal (@values_hash[key1]+other[key1]),value1,"Did not add SparseMatrix correctly"
		end
	end

	# ensures that the value taken in is a sparse matrix and the dimensions of the two matrices are the same
    def pre_sparse_matrix_subtraction(m)
        invariants
        assert(m.is_a?(SparseMatrix), 'not subtracting by a sparse matrix')
        # assert_equal self.dimension.length, m.getDimension.length, "matrices need to be same dimension"
        assert_equal self.dimension, m.getDimension, "dimension sizes are different"
    end

    # ensures that the sparse matrix is subtracted correctly
    def post_sparse_matrix_subtraction(other,result)
        invariants
        result.getValues.each do |key1,value1|
			assert_equal (@values_hash[key1]-other[key1]),value1,"Did not subtract SparseMatrix correctly"
		end
    	
    end

    # ensures that the value inputted is a a Numeric
	def pre_scalar_subtraction(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
	end

	# ensures that the scalar subtraction is correct. Also makes sure that if the value to be substracted
	# is zero, then the result matrix is the same as the original matrix
	def post_scalar_subtraction(other,result)
		invariants
		# think it should be try catch
		if other == 0
			assert_equal self, result, "Not the same matrix"
		else
			@values_hash.each do |key,value|
				retval=eval("result"+key.to_s.gsub(",","]["))
				assert_equal (value-other),retval, "Did not substract successfully"
			end
			# assume Dense matrix returned
			#check dense matrix is correct
			#see n_dimensional_array
		end
	end

	# ensures that the value inputted is a Numeric value
	def pre_scalar_addition(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
	end

	# ensures that the scalar addition is correct. If the value is zero then the matrix should be the same
	def post_scalar_addition(other,result)
		# think it should be try catch
		invariants
		if other == 0
			assert_equal self, result, "Not the same matrix"
		else
			@values_hash.each do |key,value|
				retval=eval("result"+key.to_s.gsub(",","]["))
				assert_equal (value+other),retval, "Did not add successfully"
			end
			# assume Dense matrix returned
			#check dense matrix is correct
		end

	end

	# ensures that the value inputted is a sparse matrix and the dimensions is 2 (for now)
	def pre_sparse_matrix_multiplication(other)
		invariants
		assert (other.is_a? SparseMatrix), "Not a SparseMatrix"
		assert_equal @dimension.length,2,"n dimensional multiplication not implemented yet"
	end

	# ensures that the multiplication of a sparse matrix is multiplied correctly
	def post_sparse_matrix_multiplication(other,result)
		invariants
		result.getValues.each do |key1,value1|
			sum=0
			@values_hash.each do |key2,value2|
				other.getValues do |key3,value3|
					if key2[0]==key1[0] and key1[1]==key3[1]
						sum+=(value2+value3)
					end
				end
				assert_equal sum,value1,"did not add correctly"
			end	
		end
	end

	# ensures that the value inputted is a numeric
	def pre_scalar_multiplication(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
	end

	# ensures that the multiplication of a scalar is correct and is always a sparse matrix
	def post_scalar_multiplication(other, retval)
		invariants
		@values_hash.each do |key,value|
			assert_equal (value*other),retval[key], "Did not multiply successfully"
		end
	end

	# ensures that the value inputted is a sparse matrix
	def pre_sparse_matrix_division(other)
		invariants
		assert (other.is_a? SparseMatrix), "Not a SparseMatrix"
		assert_equal @dimension.length,2,"n dimensional multiplication not implemented yet"
	end

	# ensures that the division of the matrix is implemented correctly by taking the inverse of the matrix
	def post_sparse_matrix_division(result)
		invariants
		post_sparse_matrix_multiplication(inverse(result))
	end

	# ensures that the number inputted is a numeric
	def pre_scalar_division(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
		assert (other!=0), "Division by a zero"
	end

	# ensures that the division of the scalar is done successfully
	def post_scalar_division(other, retval)
		invariants
		@values_hash.each do |key,value|
			assert_equal (value*other),retval[key], "Did not divide successfully"
		end

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
		assert(result.is?Integer, 'result is not an Integer')
		assert_equal(result, (self.transpose).determinant, 'det didnt work')

		invariants
	end

	# ensures that it is a sparse matrix
	def preTranspose()
		#nothing?
		invariants
	end

	# ensures that the result of the transpose is correct by retransposing it 
	def postTranspose(result)
		assert_equal(self.getDimension, result.getDimension.reverse, 'dimensions are not correct')
		assert_equal(self, result.transpose, 'transpose not correct')
		invariants
	end

	# ensures that the matrix is a sparse matrix
	def preInverse()
		assert(preDeterminant, 'matrix needs to be bale to get determinant')
		invariants
	end

	# ensures that the inverse is done correctly
	def postInverse(result)
		assert_equal(self.getDimension, result.getDimension, 'dimension are not the same')
		assert_equal(identityMatrix, self * result, 'inverse did not work')
		invariants
	end

	# ensures that it is a sparse matrix
	def pre_power(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
	end

	# ensures that the result of the power operator is correct
	def post_power(other, result)
		if other != 0
			invariants
			@values_hash.each do |key,value|
				assert_equal (value**other),result[key], "Did not exponentiate successfully"
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
	private :pre_power, :post_power

end
b = SparseMatrix. new(3,3)
b.insert_at([1,1],1)
b.insert_at([0,0],2)
b.insert_at([0,1],2)
d = SparseMatrix. new(3,3)
d.insert_at([1,1],2)
d.insert_at([0,0],2)
d.insert_at([0,1],2)
d.to_s
c = b + d
p c
