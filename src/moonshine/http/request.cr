require "http"
require "time"

class Moonshine::Request
	getter params
	getter path
	property method
	getter version
	getter body
	getter headers

	def initialize(request : HTTP::Request)
		@path = request.path
		@method = request.method
		@version = request.version
		@body    = request.body
		@headers = request.headers
		@params = {} of String => String
	end

	def set_params(par)
		@params = par
	end
end
