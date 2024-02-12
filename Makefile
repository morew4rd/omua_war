default: build

build-app:
	rm -rf bin/app.zip
	zip -r -j bin/app.zip game/*

build-web:
	rm -rf out/omua_war.zip
	zip -r -j  out/omua_war.zip bin/index.html bin/lyte.wasm bin/lyte.js bin/app.zip

build: build-app build-web

host:
	python3 -m http.server -d bin