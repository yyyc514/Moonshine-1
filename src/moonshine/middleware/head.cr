module Moonshine
	module Middleware
		class Head < Base
			def initialize(@app, opts)
			end

			def call(request)
				@app.call(request).tap do |r|
					r.body = "" if request.method == "HEAD"
				end
			end
		end

		class Longer < Base
			def initialize(@app, @opts)
			end

			def call(request)
				@app.call(request).tap do |r|
					r.body += @opts[:phrase]
				end
			end
		end

	end
end
