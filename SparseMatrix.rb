require 'matrix'
require 'pp'
require 'test/unit'
require_relative 'SparseMatrixPrePost'
require_relative 'NDimensionalMatrix'
require_relative 'MatrixFactory'
class SparseMatrix
	attr_accessor :dimension, :values_hash
	include Test::Unit::Assertions

	def initialize(*args)
		init_dim *args
		@factory = MatrixFactory.new
	end

	def init_Hash(input_hash)

		assert_respond_to(input_hash, :length)
		assert_respond_to(input_hash, :hash)
		@values_hash=input_hash
		return self
	end


	def init_dim(*args)
		pre_init_dim(*args)
		@values_hash = Hash.new
		@dimension=*args
		invariants
	end

	def init_array(arg)
		pre_init_array(arg)
		arg = arg.to_a
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
		return @dimension.inject(:*)
	end

	def getDimension
		return self.dimension
	end

	def getValues
		return self.values_hash
	end

	def printMatrix
		NDimensionalMatrix.new(self).printMatrix
		# matrix = Matrix.zero(self.getDimension[0], self.getDimension[1])
		# puts matrix.to_a.map(&:inspect)
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
			result = self.sparse_matrix_multiplication(m.inv)
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
		if m.class != NDimensionalMatrix
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

	def inv
		preInverse(self)
		if self.class != NDimensionalMatrix
			matrix_1=NDimensionalMatrix.new(self).inv
			result = @factory.create_matrix(matrix_1.get_array)
			postInverse(self,result)
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



end
