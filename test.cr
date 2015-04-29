# class B
# 	def initialize()
# 	end
# 	def fun
# 		puts "having fun"
# 	end
# end

# b = B
# b.new.fun()

# a = [] of Tuple

# a << {B, nil}

# b_again = a.first[0] as B.class
# b_again.new

abstract class Middleware
end

class B < Middleware
	def initialize
		puts "B"
	end
end

blah = [] of Class
blah << B

(blah.first as Middleware.class).new
