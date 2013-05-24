.PHONY: test install

help:
	@echo make test
	@echo make install

test:
	cd test; make

install:
	ruby install.rb
