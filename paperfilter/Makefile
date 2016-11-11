ELECTRON_VERSION = $(shell jq .devDependencies.electron $(shell git rev-parse --show-cdup)/package.json -r)

ifeq ($(OS),Windows_NT)

CONFIG = build/binding.sln
all: $(CONFIG)
	node-gyp build --target=$(ELECTRON_VERSION) --arch=x64 --dist-url=https://atom.io/download/electron

$(CONFIG):
	node-gyp configure --target=$(ELECTRON_VERSION) --arch=x64 --dist-url=https://atom.io/download/electron

else

CONFIG = build/Makefile
all: $(CONFIG)
	JOBS=4 HOME=~/.electron-gyp node-gyp build --target=$(ELECTRON_VERSION) --arch=x64 --dist-url=https://atom.io/download/electron

$(CONFIG):
	HOME=~/.electron-gyp node-gyp configure --target=$(ELECTRON_VERSION) --arch=x64 --dist-url=https://atom.io/download/electron

endif

clean:
	@node-gyp clean

fmt:
	@clang-format -i **/*.cpp **/*.hpp *.cpp *.hpp

.PHONY: all clean fmt
