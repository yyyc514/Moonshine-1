require "./src/moonshine"
include Moonshine
include Moonshine::Shortcuts

viewcount = 0

app = Moonshine::App.new
app.get "/", do |request|
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

app.get "/api", do |request|
	res = ok("{ name : 'moonshine'}")
	res.headers["Content-type"] = "text/json"
	res
end
app.run()