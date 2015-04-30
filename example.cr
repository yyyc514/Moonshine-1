require "./src/moonshine"
include Moonshine
include Moonshine::Shortcuts

viewcount = 0


class PostController < Moonshine::Controller

	def index
		render "index"
	end

	def show
		render "show"
	end

	add_template :index
	add_template :show

end


app = Moonshine::App.new
app.routes.get "/", do |request|
	viewcount += 1
	html = "
		<html>
			<body>
				<h1>It worked!</h1>
				<hr>
				This page has been visited #{viewcount} times.
			</body>
		</html>
	"
	ok(html)
end

app.routes.draw do
	get "/posts" do |request|
		c = PostController.new(request)
		c.index()
		c.return_response
	end
end

app.routes.get "/api", do |request|
	res = ok("{ name : 'moonshine'}")
	res.headers["Content-type"] = "text/json"
	res
end
# app.add_static_dir(".")
app.run()
