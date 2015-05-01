require "http"
require "time"
require "json"

class Moonshine::Request
	getter params
	getter path
	property method
	getter version
	getter body
	getter headers
	getter session

	def initialize(request : HTTP::Request)
		@path = request.path
		@method = request.method
		@version = request.version
		@body    = request.body
		@headers = request.headers
		@session = {} of String => JSON::Type
		@params = {} of String => String
	end

	def cookies
		hash = {} of String => String
	  # hash   = @env["rack.request.cookie_hash"] ||= {}
	  # string = @env["HTTP_COOKIE"]
	  string = headers["Cookie"]?
	  return hash if string.nil?

	  puts "string: #{string}"

	  # return hash if string == @env["rack.request.cookie_string"]
	  # hash.clear

	  # According to RFC 2109:
	  #   If multiple cookies satisfy the criteria above, they are ordered in
	  #   the Cookie header such that those with more specific Path attributes
	  #   precede those with less specific.  Ordering with respect to other
	  #   attributes (e.g., Domain) is unspecified.
	  cookies = Moonshine::Utils.parse_query(string, ";,") { |s| Moonshine::Utils.unescape(s) rescue s }
	  # cookies.each { |k,v| hash[k] = Array === v ? (v as Array).first : v }
	  puts "COOKIES"
	  cookies.each do |k,v|
	  	hash[k] = v
	  	# puts k
	  	# puts v
	  end
	  # @env["rack.request.cookie_string"] = string
	  hash
	end

	def set_params(par)
		@params = par
	end
end
