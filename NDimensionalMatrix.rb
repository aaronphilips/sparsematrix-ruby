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
			begin
				init_dim_val *args
			rescue
				begin
					init_sparse_matrix *args
				rescue
					init_matrix *args
				end
			end
		end
	end

	#STUCK IN 2D. assert game is weak here too
	def init_matrix *args
		assert_equal 1,args.length,"Not the right size"
		m=args[0]
		assert_respond_to(m,:to_a)
		@arr=m.to_a
		@dimension=[m.to_a.length,m.to_a[0].length]
	end

	def init_sparse_matrix(*args)
		assert_equal 1,args.length,"Not the right size"
		sm=args[0]
		assert_respond_to(sm,:get_sparse_matrix_hash)
		puts "convert from sparse"
		init_Hash(*sm.getDimension,sm.get_sparse_matrix_hash)
	end


	# initialize the SparseMatrix
	def init_dim_val(*args)
		*rest, value= args
		@arr=recursive_nest_array(*rest,value)
		@dimension=*rest
	end

	def get_array
		return @arr
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
		assert (self.respond_to? (:checkSum)), "It is not a Dense matrix whoops"
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
		preCheckSum(@arr)
		result = @arr.flatten.inject(:+)
		postCheckSum(result)
		return result
	end

	def preCheckSum(matrix)
		assert(matrix.respond_to? (:flatten), 'not checking sum of array')
		invariants
	end

	def postCheckSum(sum)
		assert sum.respond_to? (:round), 'not returning a value as check sum'
		invariants
	end

	def to_s
		# @arr.inspect
		get_2d_matrix.to_a.map(&:inspect).inspect
	end
	def get_2d_matrix
		Matrix[*@arr]
	end
	def printMatrix
		puts get_2d_matrix.to_a.map(&:inspect)
	end
	def * (m)
		assert(self.respond_to?(:get_2d_matrix), 'self not NDimensionalMatrix')
		assert(m.respond_to?(:get_2d_matrix), 'other not NDimensionalMatrix')
		NDimensionalMatrix.new(self.get_2d_matrix*m.get_2d_matrix)
	end


	def **(m)
		NDimensionalMatrix.new(self.get_2d_matrix**m)
	end


	def +(m)
		begin

			self.get_2d_matrix+m.get_2d_matrix

		rescue

			self.get_2d_matrix+m
		end
	end

	def det
		result = self.get_2d_matrix.determinant
		return result
	end

	def inv 
		NDimensionalMatrix.new(self.get_2d_matrix.inverse)
	end
end
# def * (m)
# 	self.get_2d_matrix*m.get_2d_matrix
# end

# NDimensionalMatrix.new 1
