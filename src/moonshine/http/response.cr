class Moonshine::Response
	getter status_code
	property body
	getter headers
	getter cookies
	setter cookies

	def initialize(@status_code, @body, @version = "HTTP/1.1", @cookies = {} of String => String)
		@headers = HTTP::Headers.new
	end

	def set_header(key, value)
		@headers[key] = value
	end


	def to_base_response()
		unless @cookies.empty?
			cookie_string = serialize_cookies()
			@headers["Set-Cookie"] = cookie_string
		end
		return HTTP::Response.new(@status_code, @body,
			headers = @headers, version = @version)
	end

	def serialize_cookies()
		cookie_string = ""
		@cookies.each do |key, value|
			cookie_string += key + "=" + value + ", "
		end
		cookie_string = cookie_string[0..-2]
		cookie_string
	end
end
