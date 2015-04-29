module Moonshine
	module Middleware
		class Logger < Base
			def initialize(@app, opts)
			end
		end
	end
end
