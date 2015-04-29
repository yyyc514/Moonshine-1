module Moonshine
	module Middleware
		abstract class Base
			def initialize()
				@app = self
			end

			# def initialize(@app, @opts = {} of String => Class)
			# end

			def wrap(app)
				@app = app
				self
			end

			def call(request)
				@app.call(request)
			end
		end
	end
end
