module Moonshine
	module Middleware
		class Session < Base

			SESSION_NAME = "moonshine.session"

			def call(request)
				load_session(request)
				resp = @app.call(request)
				save_session(request.session, resp)
				resp
			end

			def load_session(request)
				puts "COOKIES: #{request.cookies.inspect}"

				return unless request.cookies.has_key?(SESSION_NAME)
				puts "loading session from cookie"
				str = request.cookies[SESSION_NAME]
				deserialize(str, request.session)
			end

			def save_session(session, resp)
				puts "new session: #{session.inspect}"
				resp.cookies[SESSION_NAME] = serialize(session)
			end

			def deserialize(str, session)
				h = JSON.parse(str) as Hash(String, JSON::Type)
				h.each do |k, v|
					session[k]  = v
				end
			end

			def serialize(session)
				session.to_json
			end

		end
	end
end
