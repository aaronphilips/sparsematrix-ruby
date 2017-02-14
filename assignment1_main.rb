require_relative 'MatrixFactory'

puts 'hi, welcome to ECE 421 sparse matrix package'

factory=MatrixFactory.new
a=factory.create_matrix([[1,0,0],[0,1,0]])
b=factory.create_matrix([[1,0,2], [0,1,0]])
#make matrix
#[1 0]
#[0 0]
puts a
puts b
c = a+b
puts "my result from + is #{c}"
# b=factory.create_matrix([[1,0],[1,1],[1,0]])