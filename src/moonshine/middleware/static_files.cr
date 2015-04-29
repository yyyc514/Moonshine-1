module Moonshine
	module Middleware
		class StaticFiles < Middleware::Base

			def initialize(@path)
				@app = self
			end

			def call(request)
				filepath = File.join(@path, request.path)
				if File.exists?(filepath)
					resp = Moonshine::Response.new(200, File.read(filepath))
					resp.headers["Content-Type"] = mime_type(filepath)
					resp
				else
					# call deeper into the stack
					@app.call(request)
				end
			end

			private def mime_type(path)
				case File.extname(path)
				when ".txt" then "text/plain"
				when ".htm", ".html" then "text/html"
				when ".cr" then "text/plain"
				when ".md" then "text/x-markdown"
				when ".css" then "text/css"
				when ".js" then "application/javascript"
				else "application/octet-stream"
				end
			end

		end
	end
end
