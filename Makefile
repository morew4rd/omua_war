default: build

build-app:
	rm -rf bin/app.zip
	cd game && zip -r -j ../bin/app.zip *

build-web:
	rm -rf out/omua_war.zip
	cd bin && zip -r  ../out/omua_war.zip index.html lyte.wasm lyte.js app.zip

build: build-app build-web

host:
	python3 -m http.server -d bin