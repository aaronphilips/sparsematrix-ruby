require 'matrix'
require 'pp'
require 'test/unit'

class NDimensionalMatrix
	attr_accessor :dimension, :values_hash
	include Test::Unit::Assertions



	def initialize(*args)
		begin
			*rest_of_args,input_hash=*args
			init_Hash(*rest_of_args,input_hash)
		rescue
			init_dim_val *args
		end
	end


	# initialize the SparseMatrix
	def init_dim_val(*args)
		*rest, value= args
		@arr=recursive_nest_array(*rest,value)

	end


	def init_Hash(*rest_of_args,input_hash)

		# should be in a pre and post
			# assert_respond_to(input_hash, :[])
			assert_respond_to(input_hash, :length)
			assert_respond_to(input_hash, :hash)
			rest_of_args.each do |arg|

				assert_respond_to(arg,:to_i)
			end
			# 2d for now
			init_dim_val(*rest_of_args,0)
			input_hash.each do |key, value|
				@arr[key[0]][key[1]]=value

			end
			@values_hash=input_hash
			@dimension=*rest_of_args
	end








	def recursive_nest_array(*args,value)
		arg1,*rest = args
		Array.new(arg1){rest.empty? ? value: recursive_nest_array(*rest,value)}
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

	def to_s
		@arr.inspect
	end
	def get_2d_matrix
		Matrix[*@arr]
	end
	def printMatrix
		puts get_2d_matrix.to_a.map(&:inspect)
	end
end

# NDimensionalMatrix.new 1

n = Hash.new
n[[2,1]]=4
n[[1,1]]=2
n[[0,0]]=1


b=NDimensionalMatrix.new(3,3,n)
c=NDimensionalMatrix.new(3,3,"hi")
puts b
puts c
# m= b.get_2d_matrix
# puts m.to_a.map(&:inspect)
b.printMatrix