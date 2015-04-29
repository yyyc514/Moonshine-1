require "http"
require "regex"
require "./middleware/**"

module Moonshine
	class Router < Middleware::Base
		def initialize(@routes: Array(Moonshine::Route))
			@app = self
			# @routes = [] of Moonshine::Route
		end

		def initialize(@app, opts)
			@routes = [] of Moonshine::Route
		end

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
			Response.new(200, "ok")
		end
	end
end

class SimpleHandler
	def initialize(@app)
	end

	def call(base_request)
		request = Moonshine::Request.new(base_request)
		@app.call(request).to_base_response
	end
end

class Moonshine::App
	# Base class for Moonshine app
	getter server
	getter routes
	getter logger
	getter static_dirs


	def initialize(
		@static_dirs = [] of String,
		@routes = [] of Moonshine::Route,
		@error_handlers = {} of Int32 => Request -> Response,
		@request_middleware = [] of Request -> MiddlewareResponse)

		# @middleware = [] of Tuple
		@middleware = [] of Tuple(Middleware::Base.class, Hash(Symbol,String))

		# add_middleware Middleware::Logger
		add_middleware Middleware::Head
		add_middleware Middleware::Longer, {phrase: "superman"}
		app = Router.new(@routes)
		@middleware.reverse.each do |mw|
			ware = mw[0] #as Middleware::Base.class
			opts = mw[1]
			app = ware.new(app, opts)
			@app = app
		end



		# use Rack::Runtime
		# use Rack::MethodOverride
		# use ActionDispatch::RequestId
		# use Rails::Rack::Logger
		# use ActionDispatch::ShowExceptions
		# use ActionDispatch::DebugExceptions
		# use Airbrake::Rails::Middleware
		# use ActionDispatch::RemoteIp
		# use ActionDispatch::Callbacks
		# use ActiveRecord::ConnectionAdapters::ConnectionManagement
		# use ActiveRecord::QueryCache
		# use ActionDispatch::Cookies
		# use ActionDispatch::Session::CookieStore
		# use ActionDispatch::Flash
		# use SkipParamsParser
		# use ActionDispatch::Head
		# use Rack::ConditionalGet
		# use Rack::ETag
		# use ActionDispatch::BestStandardsSupport
		# use Rack::SSL
		# use Oink::Middleware
		# run Raptor::Application.routes


		@logger = Moonshine::Logger.new
		# add default 404 handler
		error_handler 404, do |req|
			Response.new(404, "Page not found")
		end
	end

	def add_middleware(middleware, opts = {} of Symbol => String)
		@middleware << {middleware as Middleware::Base.class, opts}
	end

	def run(port = 8000)
		# Run the webapp on the specified port
		puts "Moonshine serving at port #{port}..."
		# server = HTTP::Server.new(port, BaseHTTPHandler.new(@routes, @static_dirs, @error_handlers, @request_middleware))
		server = HTTP::Server.new(port,
			SimpleHandler.new(@app as Middleware::Base))
		server.listen()
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

	##
	# Add request handler. If handler returns a
	# response, no further handlers are called.
	# If nil is returned, the next handler is run
	def request_middleware(&block : Request -> MiddlewareResponse)
		@request_middleware << block
	end

	# Add handler for given error code
	# multiple calls for the same error code result
	# in overriding the previous handler
	def error_handler(error_code, &block : Request -> Response)
		@error_handlers[error_code] = block
	end

	def add_static_dir(path)
		@static_dirs << path
	end

	# methods for adding routes for individual
	# HTTP verbs
	{% for method in %w(get post put delete patch) %}
		def {{method.id}}(path, &block : Moonshine::Request -> Moonshine::Response)
			@routes << Moonshine::Route.new("{{method.id}}".upcase, path.to_s, block)
		end
	{% end %}
end


class Moonshine::BaseHTTPHandler < HTTP::Handler
	# Main HTTP handler class for Moonshine. It's call method
	# is called by the HTTP server when a request is received

	def initialize(@routes = [] of Route,
		@static_dirs = [] of String,
		@error_handlers = {} of Int32 => Moonshine::Request -> Moonshine::Response,
		@request_middleware = [] of Request -> MiddlewareResponse)
		# add default 404 handler if it isn't there
		unless @error_handlers.has_key? 404
			@error_handlers[404] = ->(request : Request) { Response.new(404, "Not found")}
		end
	end

	def call(base_request : HTTP::Request)
		request = Moonshine::Request.new(base_request)
		# call request middleware
		@request_middleware.each do |middleware|
			optionalresponse = middleware.call(request)
			unless optionalresponse.pass_through
				return optionalresponse.response.to_base_response
			end
		end

		# search @routes for matching route
		@routes.each do |route|
			if route.match? (request)
				# controller found
				request.set_params(route.get_params(request))
				response = route.block.call(request)

				# check if there's an error handler defined
				if response.status_code >= 400 && @error_handlers.has_key? response.status_code
					return @error_handlers[response.status_code].call(request).to_base_response
				end
				return response.to_base_response()
			end
		end

		# Search static dirs
		@static_dirs.each do |dir|
			filepath = File.join(dir, request.path)
			if File.exists?(filepath)
				return HTTP::Response.new(200, File.read(filepath),
					HTTP::Headers{"Content-Type": mime_type(filepath)})
			end
		end

		# Route match not found return 404 error response
		return @error_handlers[404].call(request).to_base_response
	end

	private def mime_type(path)
	    case File.extname(path)
	    when ".txt" then "text/plain"
	    when ".htm", ".html" then "text/html"
	    when ".css" then "text/css"
	    when ".js" then "application/javascript"
	    else "application/octet-stream"
	    end
	  end

	private def error_handler(error_code, &block : Request -> Response)
		@error_handlers[error_code] = block
	end
end
