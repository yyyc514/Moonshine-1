# Moonshine 

[![Build Status](https://travis-ci.org/dhruvrajvanshi/Moonshine.svg?branch=master)](https://travis-ci.org/dhruvrajvanshi/Moonshine)

Moonshine is a minimal web framework for the Crystal language.
Code speaks louder than words, so here's an example.

	include Moonshine
	include Moonshine::Shortcuts

	app = Moonshine::App.new
	
	app.routes.draw do
	
		# respond to any HTTP verb
		any "/", do |request|
			ok("Hello Moonshine!")
		end

		# or particular HTTP verbs
		get "/get", do |request|
			ok("This is a get response")
		end

		# you can set response headers
		get "api", do |request|
			res = ok("{ name : 'moonshine'}")
			res.headers["Content-type"] = "text/json"
			res
		end
	end
	
	app.add_static_paths "./public"
	app.run()


## Routes

Routes are created by calling `App#routes.draw` and passing it a block of routes.

	app.routes.draw do 
		get("/status") do |request| 
			ok("we're all good here")
		end
	end
	


## Middleware

Middleware are small pieces of functionality that sit between your application and a request.  Any piece of middleware can modify the request, alter the response, or even halt requests completely.  The default functionality of Moonshine is provided by a middleware stack that sits on top of the application router.

### Default Middleware

- Middleware::Logger
- Middleware::ErrorHandling
- Middleware::Head
- Middleware::StaticFiles
- Router


## Custom Middleware

	class RequireSmartClient < Moonshine::Middleware::Base
		def initialize(@client)
			# required boilerplate
			@app = self 
		end
	
		def authorized?(request)
			request.headers["client"] == @client
		end
	
		def call(request)
			if authorized?(request)
				# user pass the request along to our app
				@app.call(request)
			else
				# acccess is denied
				Moonshine::Response.new(403, "Not allowed")
			end
		end
	end
	
	# add request middleware
	app.add_middleware RequireUser.new

To add a middleware, call `app.add_middleware` passing it a configured instance of your middlware.  If your middlware defines `initialize` you must set `@app` to `self`.  When the middleware stack is built `@app` will be set to the next layer of middlware in the stack (or the app itself).  

Each piece of middleware must respond to `call` taking a `Moonshine::Request` for input and returning a `Moonshine::Response` as it's output.  To call into the next layer of middleware just use `@app.call`.

Middleware gives you a lot of flexibility:

- call `@app.call(request)` but then modify the response before returning it (gzip, etc)
- modify the request headers before calling `@app.call` (rewriting a request)
- directly return the result of `@app.call` with no changes (you might do this if your middleware is only doing logging, etc.)
- return your own response skipping all deeper middleware


## Error Handlers

Error handlers are handled by the `ErrorHandling` middleware which sits near the top of the middleware stack.  If an error has been generated further down the stack your error handler can generated a nicer error message, or even change the response entirely.

	# add error handlers
	app.error_handler "404", do |req|
		Moonshine::Response.new(404, "Not found")
	end


## Static Files

Static directories will be searched in the order they are listed.  Static Files are handled by the `StaticFiles` middleware.

To serve a static directory pass an array of paths to Moonshine::App's constructor. 

	app = Moonshine::App.new(static_dirs = ["./res"])

You may also add static directories after init.

	app.add_static_dir "./res"


