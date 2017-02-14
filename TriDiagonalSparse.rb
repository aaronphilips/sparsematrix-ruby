require_relative 'SparseMatrix'
class TriDiagonalSparse<SparseMatrix

	def initialize(*args)
		super(*args)
		invariants
	end

	def invariants()
		assert_equal @dimension.length, 2, "Not a 2D TriDiagonalSparse Matrix"
		assert(@dimension[0]>=6, "Not a valid TriDiagonalSparse Matrix. Too small")
		assert(@dimension[1]>=6, "Not a valid TriDiagonalSparse Matrix. Too small")

		super

	end

	def check_tri_diagonal
		retval=true
		self.get_sparse_matrix_hash.each do |key,value|
			if(key[0]>key[1]+1||key[0]<key[1]-1)
				return false
			end
		end
		return retval
	end
end
b=TriDiagonalSparse.new(6,6)
b.insert_at([0,0],23)
b.insert_at([1,0],23)
b.insert_at([0,1],23)
b.insert_at([2,1],23)
b.insert_at([1,2],23)
b.insert_at([3,1],23123)
puts b.check_tri_diagonal
