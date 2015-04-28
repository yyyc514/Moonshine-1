class Moonshine::Route
	# Moonshine route class
	# Is a simple 2-tuple of a regex and a
	# controller class name

	getter pattern
	getter block

	def initialize(@method, @pattern, @block)
		# strip trailing slash
		unless @pattern == "/"
			@pattern = @pattern.gsub(/\/$/, "")
		end
	end

	# Check if request matched the current route
	def match?(request : Moonshine::Request)
		# Non matching request method
		return false unless request.method == @method

		path = request.path
		# return path == "/" if @path == "/"
		return false if path.split("/").length !=
			@pattern.split("/").length
		regex = Regex.new(@pattern.to_s.gsub(/(:\w*)/, ".*"))
		if path.match(regex)
			return true
		else
			return false
		end

	end

	# Returns hash of request parameters from
	# request
	def get_params(request : Moonshine::Request)
		# get request path
		path = request.path
		params = {} of String => String
		path_items = path.split("/")
		pattern_items = @pattern.split("/")
		path_items.length.times do |i|
			if pattern_items[i].match(/(:\w*)/)
				params[pattern_items[i].gsub(/:/, "")] = path_items[i]
			end
		end
		return params
	end
end
