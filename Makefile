APP_NAME = API Matrix
BUNDLE_ID = com.apimatrix.mac

build:
	swift build -c release

run:
	swift run

BINARY = $(shell find .build -path "*/release/API Matrix" -type f 2>/dev/null | head -1)

app-bundle:
	mkdir -p "Build/$(APP_NAME).app/Contents/MacOS"
	mkdir -p "Build/$(APP_NAME).app/Contents/Resources"
	cp -f "$(BINARY)" "Build/$(APP_NAME).app/Contents/MacOS/$(APP_NAME)"
	cp -f Sources/APIMatrix/Info.plist "Build/$(APP_NAME).app/Contents/Info.plist"
	cp -r Sources/APIMatrix/Resources/* "Build/$(APP_NAME).app/Contents/Resources/" 2>/dev/null || true

release: build app-bundle
	cd Build && zip -ry "$(APP_NAME).zip" "$(APP_NAME).app"

.PHONY: build run app-bundle release
