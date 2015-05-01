abstract class Moonshine::Controller

	getter :response
	getter :request

	def initialize(@request)
		@response = Moonshine::Response.new(200, "")
		# @template_rendered = ""
	end

	macro add_template(name)
		def render_{{name.id}}
			"<h1>{{name.id}}</h1>"
		end
	end

	macro render(name)
		@template_rendered = render_{{name.id}}
	end


	def status(code)
		@response.status_code = code
	end

	def return_response
		if @response.body == ""
			@response.body = @template_rendered
		end
		@response
	end

	def redirect_to(url, code = 301)
		status code
		@response.headers["Location"] = url
		@response.body = "Moved to #{url}"
	end

	# Returns a response object with HTTP Okay
	# status code
	def ok(string)
		return Moonshine::Response.new(200, string)
	end
end
