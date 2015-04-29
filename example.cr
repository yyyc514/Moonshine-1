require "./src/moonshine"
include Moonshine
include Moonshine::Shortcuts

viewcount = 0

app = Moonshine::App.new
app.router.get "/", do |request|
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

app.router.get "/api", do |request|
	res = ok("{ name : 'moonshine'}")
	res.headers["Content-type"] = "text/json"
	res
end
# app.add_static_dir(".")
app.run()
