require 'matrix'
require 'pp'
require 'test/unit'

class DenseMatrix
	attr_accessor :dimension, :values_hash
	include Test::Unit::Assertions

	# initialize the SparseMatrix
	def initialize(*args)
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

	def to_s
		@values_hash.each do |key, array|
			puts "#{key}---#{array}"
		end
	end

	def invariants()
		assert(size >= 1,"not a valid matrix dimension")
		assert (self.is_a? DenseMatrix), "It is not a Dense matrix whoops"
	end

	# we also cannot insert zeros as they are implied to be there.
	def pre_insert_at(position,value)
		invariants
		assert_equal position.length, @dimension.length,"Invalid position."
		for i in 0..@dimension.length-1 do
			assert(@dimension[i]>position[i], "Invalid position in matrix")
		end
	end

	# ensures that the value is inserted to the matrix
	def post_insert_at(position,value)
		invariants
		assert_equal value,@values_hash[position],"Value is not inserted. FAILED."
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
end
