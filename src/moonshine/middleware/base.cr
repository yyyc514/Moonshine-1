module Moonshine
	module Middleware
		abstract class Base
			def initialize(@app, @opts = {} of String => Class)
			end

			def call(request)
				@app.call(request)
			end
		end
	end
end
