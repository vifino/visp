# Basic visp makefile.

LUA ?= lua
BUSTED ?= busted
BUSTED_ARGS ?= --lua=$(LUA) --verbose

# Building
# TODO: build stage 1 once applicable

# Testing
test:
	# TODO: make lisp test suite, run that too
	$(BUSTED) $(BUSTED_ARGS) spec

coverage:
	$(BUSTED) --coverage $(BUSTED_ARGS) spec
	luacov
