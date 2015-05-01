module Moonshine
	class Router

		def initialize()
			@routes = [] of Moonshine::Route
			# @error_handlers = {} of Int32 => Request -> Response
			# @error_handlers[404] = ->(request : Request) { Response.new(404, "Not found")}
		end

		def draw(&block)
			with self yield
		end

		def route(regex, &block : Moonshine::Request -> Moonshine::Response)
			any(regex, &block)
		end

		# Add route for all methods to the app
		# Takes in regex pattern and block
		def any(regex, &block : Moonshine::Request -> Moonshine::Response)
			methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
			methods.each do |method|
				@routes.push Moonshine::Route.new(method, regex,
					block)
			end
		end

		def get(path : String,  routine : Moonshine::Request -> Moonshine::Response)
			get path, &routine
		end

		# methods for adding routes for individual
		# HTTP verbs
		{% for method in %w(get post put delete patch) %}
			def {{method.id}}(path, &block : Moonshine::Request -> Moonshine::Response)
				@routes << Moonshine::Route.new("{{method.id}}".upcase, path.to_s, block)
			end
		{% end %}

		def call(request)
			# search @routes for matching route
			@routes.each do |route|
				if route.match? (request)
					# controller found
					request.set_params(route.get_params(request))
					response = route.block.call(request)

					# check if there's an error handler defined
					# if response.status_code >= 400 && @error_handlers.has_key? response.status_code
					# 	return @error_handlers[response.status_code].call(request).to_base_response
					# end
					return response
				end
			end
			# 404, file is not found
			Response.new(404, "Not Found")
			# @error_handlers[404].call(request)
		end

		# helpers

		def redirect_to(url, code = 301)
			-> (request : Moonshine::Request ) {
				res = Moonshine::Response.new(code, "Moved")
				res.headers["Location"] = url
				res
			}
		end

	end

end
