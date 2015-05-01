require "./src/moonshine"
include Moonshine
include Moonshine::Shortcuts

viewcount = 0


class PostController < Moonshine::Controller

	def index
		render "index"
	end

	add_template :index

end

app = Moonshine::App.new
app.routes.get "/", do |request|
	viewcount += 1
	count = (request.session["count"]? || 0.to_i64) as Int64
	request.session["count"] = count += 1
	request.session["booger"]="you are a prick"
	html = "
		<html>
			<body>
				<h1>It worked!</h1>
				<hr>
				#{request.headers.inspect}
				<p>You have visited this page #{count} times.</p>
				<p>This page has been visited #{viewcount} times.</p>
			</body>
		</html>
	"
	ok(html)
end

macro get(url, to, x)
{% controller = to.split("#").first.capitalize %}
{% action = to.split("#").last %}
	get {{url}}, do |request|
		c = {{controller.id}}Controller.new(request)
		c.{{action.id}}()
		c.return_response
	end
end

macro getx(url, &block)
	{% klass = "Klass#{url.id.gsub(%r{[/:]},"")}".id %}
	get "{{url.id}}" do |request|
		class {{ klass.id }} < Moonshine::Controller
			def action
	 			{{block.body}}
	 		end
	 	end
	 	c = {{klass}}.new(request)
	 	c.action
	 	c.return_response
	end
end


app.routes.draw do
	# getx "/dogs/:more" do |request|
	# 	redirect_to "/cats"
	# end
	get "/blah", redirect_to("x", code: 302)
	# get "/posts", to: "post#index"
	get "/posts" do |request|
		c = PostController.new(request)
		c.index()
		c.return_response
	end

	get "/api", do |request|
		res = ok("{ name : 'moonshine'}")
		res.headers["Content-type"] = "text/json"
		res
	end

end

# app.add_static_dir(".")
app.run()
