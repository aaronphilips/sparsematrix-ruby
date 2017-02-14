require 'matrix'
require 'pp'
require 'test/unit'
require_relative 'SparseMatrixPrePost'
require_relative 'NDimensionalMatrix'
require_relative 'MatrixFactory'
class SparseMatrix
	attr_accessor :dimension, :values_hash
	include Test::Unit::Assertions

	# initialize the SparseMatrix
	def initialize(*args)
		# begin
		# 	*rest_of_args,input_hash=*args
		# 	init_Hash(*rest_of_args,input_hash)
		# rescue
		# 	begin
				init_dim *args
		# 	rescue
		# 		init_array args[0]
		# 	end
		# end
		@factory = MatrixFactory.new
	end

	def init_Hash(input_hash)

		# should be in a pre and post
		# assert(!rest_of_args.empty?, "empty")
			assert_respond_to(input_hash, :length)
			assert_respond_to(input_hash, :hash)
			# rest_of_args.each do |arg|
			#
			# 	assert_respond_to(arg,:to_i)
			# end

			@values_hash=input_hash
			return self
			# @dimension=*rest_of_args
	end


	def init_dim(*args)
		assert(args.length>1,"not right length")
		@values_hash = Hash.new
		@dimension=*args
		invariants
	end

	def init_array(arg)
		#NEED assert_respond_to
		# puts "got to array"
		@values_hash = Hash.new
		@dimension[0].times do |i|
			@dimension[1].times do |j|
				if(arg[i][j]!=0)
					@values_hash[[i,j]]=arg[i][j]
				end
			end
		end
		return self
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

	def getDimension
		return self.dimension
	end

	def getValues
		return self.values_hash
	end

	def printMatrix
		matrix = Matrix.zero(self.getDimension[0], self.getDimension[1])
		puts matrix.to_a.map(&:inspect)
	end


	def checkSum
		preCheckSum(self)
		sum = 0
		self.get_sparse_matrix_hash.each do |key,value|
			sum = yield sum, value
		end
		postCheckSum(sum)
		return sum
	end

	def preCheckSum(matrix)
		assert(matrix.respond_to? (:get_sparse_matrix_hash))
		invariants
	end

	def postCheckSum(sum)
		assert sum.respond_to? (:round)
		invariants
	end



	def +(m)
		if m.respond_to?(:checkSum)
			pre_sparse_matrix_addition(m)
			result = self.sparse_matrix_add_sub(m){|v1,v2| v1+v2}
			post_sparse_matrix_addition(m,result)
		else
			pre_scalar_addition(m)
			result = self.scalar_add_sub(m){|v1| v1 + m}
			post_scalar_addition(m,result){|other, original| original.checkSum{|sum, value| sum+value} + (original.size * other)}
		end
		result
	end

	def -(m)
		if m.respond_to?(:checkSum)
			pre_sparse_matrix_subtraction(m)
			result = self.sparse_matrix_add_sub(m){|v1,v2| v1-v2}
			post_sparse_matrix_subtraction(m, result)
		else
			pre_scalar_subtraction(m)
			result = self.scalar_add_sub(-m){|v1| v1 - m}
			post_scalar_subtraction(m, result){|other, original| original.checkSum{|sum, value| sum+value} - (original.size * other)}
		end
		result
	end

	def sparse_matrix_add_sub(m)
		result=m.get_array.map{|values| values.clone}

		result.length.times do |i|
			result[i].length.times do |j|
				if (self.getValues.key?([i,j]))
					result[i][j] = yield(self.getValues[[i,j]],result[i][j])
				else
					result[i][j] = yield(0,result[i][j])
				end
			end
		end
		result = @factory.create_matrix(result) 
		return result
	end

	def get_array
		result=Array.new(dimension[0]){Array.new(dimension[1],0)}
		self.getValues.each do |key,value|
			result[key[0]][key[1]]=value
		end
		return result
	end

	
	def scalar_add_sub(m)


		result=Array.new(@dimension[0]){Array.new(@dimension[1],m)}
		@values_hash.each do |key,value|
			result[key[0]][key[1]] = yield(values_hash[key])
		end
		result = @factory.create_matrix(result) 
		return result
	end

	def *(m)

		if m.respond_to?(:checkSum)
			pre_sparse_matrix_multiplication(m)
			result = self.sparse_matrix_multiplication(m)
			post_sparse_matrix_multiplication(m,result)
		else
			pre_scalar_multiplication(m)
			result = self.scalar_mult_div{|v1| v1 * m}
			post_scalar_multiplication(m,result){|other, original| original.checkSum{|sum, value| sum+value} * other}
		end
		result
	end

	def /(m)
		if m.respond_to?(:checkSum)
			pre_sparse_matrix_division(m)
			result = self.sparse_matrix_multiplication(inverse(m))
			post_sparse_matrix_division(m,result)
		else
			pre_scalar_division(m)
			result = self.scalar_mult_div{|v1| v1 / m}
			post_scalar_division(m,result){|other, original| original.checkSum{|sum, value| sum+value} / other}
		end
		result
	end

	def scalar_mult_div
		result = @values_hash.dup
		result.each do |key1, value1|
			result[key1] = yield(result[key1])
		end
		return SparseMatrix.new(*@dimension).init_Hash(result)
	end


	def sparse_matrix_multiplication(m)
		matrix_1=NDimensionalMatrix.new(self)
		if !m.class == NDimensionalMatrix
			matrix_2=NDimensionalMatrix.new(m)
			return @factory.create_matrix((matrix_1*matrix_2).get_array)
		end
		return @factory.create_matrix((matrix_1*m).get_array)
	end

	def det()
		preDeterminant
		matrix_1 = NDimensionalMatrix.new(self)
		result = matrix_1.det
		postDeterminant(result)
		return result
	end

	def **(other)
		pre_power(other)
		matrix_1=NDimensionalMatrix.new(self)
		matrix_1=matrix_1**other
		puts matrix_1.class
		post_power(matrix_1)
		return matrix_1
	end

	def transpose()
		preTranspose

		*args = self.getDimension.reverse
		result = SparseMatrix.new(*args)
		self.getValues.each do |key,value|
			result.insert_at(key.reverse,value)
		end

		postTranspose(result)

		return result
	end

	def inverse(m)
		preInverse(m)
		if m.class != NDimensionalMatrix
			matrix_1=NDimensionalMatrix.new(m)
			result = @factory.create_matrix(matrix_1.inv.get_array)
			postInverse(m,result)
			return result
		end
		result = @factory.create_matrix(m.inv.get_array)
		postInverse(m,result)
		return result
	end

	def get_sparse_matrix_hash
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

	
	# i feel like we need this
	# and it actually works
	def n_dimensional_array(dim_array,initial_value)
		# will use eval function with string like:
		# Array.new(dim_array[0]) {Array.new(dim_array[1])... {Array.new(dim_array[n], initial_value)}...}

	end

	# private :pre_sparse_matrix_addition, :post_sparse_matrix_addition
	# private :pre_scalar_addition, :post_scalar_addition
	# private :pre_sparse_matrix_subtraction, :post_sparse_matrix_subtraction
	# private :pre_scalar_subtraction, :post_scalar_subtraction
	# private :pre_sparse_matrix_multiplication, :post_sparse_matrix_multiplication
	# private :pre_scalar_multiplication, :post_scalar_multiplication
	# private :pre_sparse_matrix_division, :post_sparse_matrix_division
	# private :pre_scalar_division, :post_scalar_division
	# private :preDeterminant, :postDeterminant
	# private :preInverse, :postInverse
	 # public :preTranspose, :postTranspose
	# private :pre_power, :post_power

end

# b = SparseMatrix. new(2,2)
# b.insert_at([1,0],5)
# # b.to_s
# # puts b.checkSum{|sum, x| sum+x}
# #[0 0]
# #[5 0]

# c = DenseMatrix. new(3,3)
# c.insert_at([1,1],2)
# c.insert_at([0,0],0)
# c.insert_at([0,1],0)
# c.insert_at([1,0],1)
# #[0 0 0]
# #[1 2 0]
# #[0 0 0]

# a = DenseMatrix. new(2,3)
# a.insert_at([1,1],10)
# a.insert_at([0,0],0)
# a.insert_at([0,1],0)
# a.insert_at([1,0],5)

# d= SparseMatrix. new(3,2)
# d.insert_at([2,1],5)

# result = b+b

# result = b.transpose
# puts b.getValues
# puts result.getValues

# b = SparseMatrix. new(3,3)
# b.insert_at([1,1],1)
# b.insert_at([0,0],2)
# b.insert_at([0,1],2)
# d = SparseMatrix. new(3,3)
# # d.insert_at([1,1],2)
# # d.insert_at([0,0],2)
# # d.insert_at([0,1],2)
# b.to_s
# c = b + d
# c.to_s
# p c
# #I knew this wouldn't work but reem yelled at me NVM FIXED
# e=b*2
# p b.get_array
# p e.get_array
# # b.to_s
# # h=Hash.new
# # h[[1,1]]=1
# # h[[0,1]]=2
# # a= SparseMatrix.new(3,3,h)
# # puts a.getDimension

