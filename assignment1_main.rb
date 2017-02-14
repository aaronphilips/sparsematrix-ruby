require_relative 'MatrixFactory'
require_relative 'SparseMatrix'

puts 'hi, welcome to ECE 421 sparse matrix package'

factory=MatrixFactory.new
a=factory.create_matrix([[0,0,2],[0,1,0],[2,0,1]])
b=factory.create_matrix([[1,0,1], [2,1,0], [0,0,1]])

a.printMatrix
c = a/b
c.printMatrix
# puts "my result from + is #{c.getValues}"
# # b=factory.create_matrix([[1,0],[1,1],[1,0]])


# factory=MatrixFactory.new
# a=factory.create_matrix([[1,0,0],[0,1,0], [0,1,0]])
# b=factory.create_matrix([[1,0,2], [0,0,2], [2,0,0]])
# c = a + b
# c.printMatrix
# d= SparseMatrix. new(3,2)
# d.insert_at([2,1],5)
#p d
