module Moonshine
	module Utils

		DEFAULT_SEP = /[&;] */
		COMMON_SEP = { ";" => /[;] */, ";," => /[;,] */, "&" => /[&] */ }

		# TODO: performance
		def self.escape(s)
			# URI.encode_www_form_component(s)
			s.gsub(/[^*\-.0-9A-Z_a-z]/) do |c|
				next "+" if c == " "
				"%%%02x" % c.char_at(0).ord
			end
		end

		# TODO: performance
		def self.unescape(s)
			# URI.decode_www_form_component(s)
			s.gsub(/\+|%[0-9A-F]{2}/) do |c|
				next " " if c == "+"
				c[1..-1].to_i(16).chr
			end
		end

		# Stolen from Mongrel, with some small modifications:
		# Parses a query string by breaking it up at the '&'
		# and ';' characters.  You can also use this to parse
		# cookies by changing the characters used in the second
		# parameter (which defaults to '&;').
		def self.parse_query(qs, d, &unescaper : String -> String)
			# unescaper ||= method(:unescape)

			# params = KeySpaceConstrainedParams.new
			params = {} of String => (String|Array(String))

			(qs || "").split(d ? (COMMON_SEP[d] || /[#{d}] */) : DEFAULT_SEP).each do |p|
				next if p.empty?
				k, v = p.split("=",2).map!(&unescaper)

				if cur = params[k]?
					# if cur.class == Array
					#   params[k] << v
					# else
					#   params[k] = [cur, v]
					# end
				else
					params[k] = v
				end
			end

			return params
			# return params.to_params_hash
		end



	end
end
