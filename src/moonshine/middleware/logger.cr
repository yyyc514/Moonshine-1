module Moonshine
	module Middleware
		class Logger < Base

			def call(request)
				resp = @app.call(request)
				puts "#{resp.status_code} #{request.path} (#{resp.body.size})"
				resp
			end

		end
	end
end
