require_relative 'SparseMatrix'
require_relative 'NDimensionalMatrix'
require 'test/unit'
class MatrixFactory
  include Test::Unit::Assertions
  def initialize
  end
  def create_matrix(arg)
    assert_respond_to(arg, :to_a)
    assert_respond_to(arg, :flatten)
    arg=arg.to_a
    dim=[arg.length,arg[0].length]
    if(arg.flatten.length/2<arg.flatten.count(0))
      return SparseMatrix.new(*dim).init_array(arg)
    else
      return NDimensionalMatrix.new(arg)
    end
  end
end

# b = SparseMatrix.new([[1,0],[0,0],[1,0]])
# myhash=Hash.new
# myhash[[0,0]]=1
#
# c =SparseMatrix.new(2,2)
# c.insert_at([1,0],20)
# d=SparseMatrix.new(2,2,myhash)
# puts b
# puts d
# puts c
factory=MatrixFactory.new
a=factory.create_matrix([[1,0],[0,0],[1,0]])
b=factory.create_matrix([[1,0],[1,1],[1,0]])
puts a.class
puts b.class
