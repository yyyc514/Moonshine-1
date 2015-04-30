require "json"

# abstract class Middleware
# end

# class B < Middleware
# 	def initialize
# 		puts "B"
# 	end
# end

# blah = [] of Class
# blah << B

# (blah.first as Middleware.class).new


alias Blah = Hash(Symbol,(Nil | Bool | String | Int32 | Float64))
a = Blah.new

a[:test] = 1
a[:now] = "super"
a[:then] = 6.5
# a[:params] = { :test => "2" }

s = StringIO.new
a.to_json(s)
puts "OUT"
puts as_string = s.read

# a.each do |k, v|
# 	puts "#{k}, #{v} #{v.class}"
# end

puts
puts "IN/OUT"
# b = Blah.new(JSON::PullParser.new(as_string))
# b.from_json(s.read)
# puts b.inspect

class HashWithIndifferentAccess
	def initialize(@hash)

	end

	def [](k)
		@hash[k.to_s]
	end

	def []=(k, v)
		@hash[k.to_s] = v
	end
end

a = Blah.new
x = JSON.parse(as_string) as Hash
# x.each do |k,v|
# 	a[k] = v as (Nil | Bool | String | Int32 | Float64)
# end
h = HashWithIndifferentAccess.new(x)

puts "now is #{h[:now]}"
h[:now] = "never"
puts "now is #{h[:now]}"
# puts "test".to_sym

# p = JSON::PullParser.new(as_string)
# hash = Blah.new
# p.read_object do |key|
# 	if p.kind == :null
# 	  puts p.read_next
# 	else
# 	# puts p.kind
# 	# p.read_int
# 	  # hash[key] = JSON::Any.new(p)
# 	end
# end
