# Basic visp makefile.

LUA ?= lua
BUSTED ?= busted
BUSTED_ARGS ?= --lua=$(LUA) --verbose

# Building
# TODO: build stage 1 once applicable

# Testing
ci: coverage check cloc
test:
	# TODO: make lisp test suite, run that too
	$(BUSTED) $(BUSTED_ARGS) spec

coverage:
	$(BUSTED) --coverage $(BUSTED_ARGS) spec
	luacov

check:
	luacheck --new-globals _BUSTED --std max+busted src spec || true

cloc:
	# SOURCE
	cloc --by-file src
	# TESTS
	cloc --by-file spec
	# STDLIB
	cloc --by-file stdlib
