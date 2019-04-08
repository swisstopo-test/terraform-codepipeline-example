


build: hello

hello: main.go
	go build -o hello main.go

.PHONY: test
test:
	@echo "Doing some tests"


install: hello
	@echo "Installing..."

.PHONY: clean
clean:
	rm -rf hello

