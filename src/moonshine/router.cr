module Moonshine
	class Router < Middleware::Base

		def initialize()
			@routes = [] of Moonshine::Route
			@error_handlers = {} of Int32 => Request -> Response
			@error_handlers[404] = ->(request : Request) { Response.new(404, "Not found")}
			@app = self
		end

		def initialize(@app, opts)
			initialize()
		end

		# Add route for all methods to the app
		# Takes in regex pattern and block
		def route(regex, &block : Moonshine::Request -> Moonshine::Response)
			methods = ["GET", "POST", "PUT", "DELETE", "PATCH"]
			methods.each do |method|
				@routes.push Moonshine::Route.new(method, regex,
					block)
			end
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
			@error_handlers[404].call(request)
		end
	end

end
