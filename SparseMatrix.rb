require 'matrix'
require 'pp'
require 'test/unit'

class SparseMatrix
	attr_reader :dimension
	include Test::Unit::Assertions
	# @column_for_corresponding_values
	# @total_of_value_per_row
	# @values
	# @dimension

	def initialize(args)
		# @column_for_corresponding_values = Array.new
		# @total_of_value_per_row = Array.new
		# @values = Array.new
		# @dimension = Array.new
		#
		# @total_of_value_per_row.push 0
		# counter = 0
		#
		# for i in 0..matrix.column_count-1
		# 	for j in 0..matrix.row_count-1
		# 		if matrix[i,j] != 0
		# 			@values.push matrix[i,j]
		# 			counter = counter+1
		# 			@column_for_corresponding_values.push j
		# 		end
		# 	end
		# 	@total_of_value_per_row.push counter
		# end
		# @dimension.push matrix.row_count
		# @dimension.push matrix.column_count
		@valuesHash = Hash.new

		@dimension=args
		# for i in args do @dimension.push(i) end
		# puts @dimension
		# for
		invariants
	end

	def insert_at(position,value)
		preInsertAt(position,value)
		
		@valuesHash[position] = value
		
		postInsertAt(position,value)

	end

	def to_s
		@valuesHash.each do |key, array|
			puts "#{key}---#{array}"
		end
	end

	def invariants()

		assert(@valuesHash.length <= size/2,"this is not sparse")
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

	def +(other)
		preScalarAddition(other)
		copyHash = @valuesHash.dup
		postScalarAddition(other, copyHash)
	end

	def -(other)
		preScalarSubstraction(other)
		copyHash = @valuesHash.dup
		postScalarSubstration(other,copyHash)
	end

	def *(m)
		preMultiplication
		postMultiplication
	end

	def /(m)
		preDivision
		postDivision
	end

	def *(other)
		preScalarMultiplication(other)
		copyHash = @valuesHash.dup
		postScalarMultiplication(other,copyHash)
	end

	def /(other)
		preScalarDivision(other)
		copyHash = @valuesHash.dup
		postScalarDivision(other,copyHash)
	end

	def det()
		preDeterminant
		postDeterminant
	end

	def **(other)
		prePower
		postPower
	end

	def transpose()
		preTranspose
		postTranspose
	end

	def inverse()
		preInverse
		postInverse
	end



	def preInsertAt(position,value)
		invariants
		assert_equal position.length, @dimension.length,"Invalid position."
		#puts "#{@dimension.length}"
		for i in 0..@dimension.length-1 do
			assert(@dimension[i]>position[i], "Invalid")
		end
		assert(value!=0)
	end

	def postInsertAt(position,value)
		invariants
		assert_equal value,@valuesHash[position],"Invalid"

	end


	def preAddition(m)
		invariants
		assert_true m.is_a?(SparseMatrix)

	end

	def postAddition(m)
		invariants
	end

	def preSubstraction()
		invariants
	end

	def postSubstraction()
		invariants
	end

	def preScalarSubstraction()
		invariants
	end

	def postScalarSubstration()
		invariants
	end

	def preScalarAddition(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
	end

	def postScalarAddition(other, copyHash)
		if other == 0
			invariants
		end
		
	end

	def preMultiplication()
		invariants
	end

	def postMultiplication()
		invariants
	end

	def preScalarMultiplication(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
	end

	def postScalarMultiplication(other, copyHash)
		invariants
		@valuesHash.each do |key,value|
			assert_equal (other*value), copyHash[key], "Did not multiply successfully"
		end
	end

	def preDivision()
		invariants
	end

	def postDivision()
		invariants
	end

	def preScalarDivision(other)
		invariants
		assert (other.is_a? Numeric), "Not a number"
		assert (other!=0), "Division by a zero"
	end

	def postScalarDivision(other, copyHash)
		invariants
		@valuesHash.each do |key,value|
			assert_equal (other/value), copyHash[key], "Did not multiply successfully"
		end

	end

	def preDeterminant()
		invariants
	end

	def postDeterminant()
		invariants
	end

	def preTranspose()
		invariants
	end

	def postTranspose()
		invariants
	end

	def preInverse()
		invariants
	end

	def postInverse()
		invariants
	end

	def prePower()
		invariants
	end

	def postPower()
		invariants
	end

	private :preAddition, :postAddition
	private :preScalarAddition, :postScalarAddition
	private :preSubstraction, :postSubstraction
	private :preScalarSubstraction, :postScalarSubstration
	private :preMultiplication, :postMultiplication
	private :preScalarMultiplication, :postScalarMultiplication
	private :preDivision, :postDivision
	private :preScalarDivision, :postScalarDivision
	private :preDeterminant, :postDeterminant
	private :preInverse, :postInverse
	private :preTranspose, :postTranspose
	private :prePower, :postPower

end
b = SparseMatrix. new([2,2])
b.insert_at([1,1],1)

b/(2)

b.to_s
