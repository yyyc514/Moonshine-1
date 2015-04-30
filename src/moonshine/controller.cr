abstract class Moonshine::Controller

	getter :response
	getter :request

	def initialize(@request)
		@response = Moonshine::Response.new(200, "")
		# @template_rendered = ""
	end

	macro add_template(name)
		def render_{{name.id}}
			"{{name.id}}"
		end
	end

	macro render(name)
		@template_rendered = render_{{name.id}}
	end


	def status(code)
		@response.status_code = code
	end

	def return_response
		@response.body = @template_rendered
		@response
	end

	# Returns a response object with HTTP Okay
	# status code
	def ok(string)
		return Moonshine::Response.new(200, string)
	end
end
