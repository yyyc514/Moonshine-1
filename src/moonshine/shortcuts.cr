module Moonshine::Shortcuts

	# Returns a Moonshine::Response object
	# from string
	def ok(body)
		Moonshine::Response.new(200, body)
	end

	# Returns a Redirect response to the specified
	# location
	def redirect(location)
		res = Moonshine::Response.new(302, "")
		res.headers["Location"] = location
		res
	end
end
