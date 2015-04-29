module Moonshine
	module Middleware
		class Head < Base

			def call(request)
				is_head_request = request.method == "HEAD"
				request.method = "GET"
				@app.call(request).tap do |r|
					# TODO: fix HTTP::Response rewriting content length
					r.body = "" if is_head_request
				end
			end
		end

	end
end
