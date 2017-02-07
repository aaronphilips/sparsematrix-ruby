require 'SparseMatrix'
class TriDiagonalSparse<SparseMatrix

	def initialize(args)
		super(args)
		invariants
	end

	def invariants()
		assert_equal @dimension.length, 2, "Not a 2D TriDiagonalSparse Matrix"
		assert(@dimension[0]>=6, "Not a valid TriDiagonalSparse Matrix. Too small")
		assert(@dimension[1]>=6, "Not a valid TriDiagonalSparse Matrix. Too small")
		super.invariants()

	end

	# better determinant functions
	def determinant
	end


end
b=TriDiagonalSparse.new([3,2])