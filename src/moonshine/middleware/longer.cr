module Moonshine
	module Middleware

		class Longer < Base
			def initialize(phrase = "testing")
				@phrase = phrase
				@app = self
			end

			def call(request)
				@app.call(request).tap do |r|
					r.body += @phrase
				end
			end
		end

	end
end
