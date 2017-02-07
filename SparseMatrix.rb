require 'matrix'
require 'pp'
require 'test/unit'

class SparseMatrix
	attr_accessor :dimension, :valuesHash
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
		assert(@values.length <= @dimension[0]*@dimension[1]/2,"this is not sparse")
		assert(@dimension[0]*@dimension[1] >= 1,"not a valid matrix dimension")
		assert_equal @total_of_value_per_row[-1],@values.length,0
		for i in @column_for_corresponding_values
			assert_true i < @dimension[0]
		end

	end


	def +(m)
		preAddition(m)
		result = []
		postAddition(m,result)
	end

	def -(m)
		preSubstraction
		postSubstraction
	end

	# def +(other)
	# 	preScalarAddition
	# 	postScalarAddition
	# end

	def -(other)
		preScalarSubstraction
		postScalarSubstration
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
		preScalarMultiplication
		postScalarMultiplication
	end

	def /(other)
		preScalarDivision
		postScalarDivision
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

	def getDimension
		return self.dimension
	end

	def getValues
		return self.valuesHash
	end

	def preInsertAt(position,value)
		assert_equal position.length, @dimension.length,"Invalid position."
		for i in 0..@dimension.length-1 do
			assert(@dimension[i]>position[i], "Valid")
		end
		assert(value!=0)
	end

	def postInsertAt(position,value)

	end


	def preAddition(m)
		#invariants
		assert(m.is_a?(SparseMatrix), 'not adding by a sparse matrix')
		assert_equal self.dimension.length, m.getDimension.length, "matrices need to be same dimension"
		assert_equal self.dimension, m.getDimension, "dimension sizes are different"

	end

	def postAddition(m, result)
		assert_equal(self, result - m, 'matrices didnt add correct')

		invariants	

	end

	def preSubstraction()
		#same as preAddition

		invariants
	end

	def postSubstraction()
		#same as postSubtraction
		invariants
	end

	def preScalarSubstraction()
		invariants
	end

	def postScalarSubstration()
		invariants
	end

	# def preScalarAddition()
	# 	#invariants
	# end

	# def postScalarAddition()
	# 	#invariants
	# end

	def preMultiplication()
		invariants
	end

	def postMultiplication()
		invariants
	end

	def preScalarMultiplication()
		invariants
	end

	def postScalarMultiplication()
		invariants
	end

	def preDivision()
		invariants
	end

	def postDivision()
		invariants
	end

	def preScalarDivision()
		invariants
	end

	def postScalarDivision()
		invariants
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

	def prePower()
		#nothing?
		invariants
	end

	def postPower(power, result)
		assert_equal(self.getDimension, result.getDimension, 'dimension are not the same')
		assert_equal(self, result**(-power), 'power did not work')

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
b = SparseMatrix.new([2,2])
b.insert_at([1,1],1)
b.insert_at([0,0],2)
b.insert_at([0,1],2)
b.insert_at([1,0],3)
a = SparseMatrix.new([2,2])
a.insert_at([0,0], 2)
puts 'matrix b'
b.to_s
puts b.getValues
puts 'matrix a'
a.to_s
puts a.getValues
c = a+b
puts 'THE END'