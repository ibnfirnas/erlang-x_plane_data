.PHONY: \
	travis_ci \
	fresh-build \
	compile \
	clean \
	deps \
	deps-get \
	deps-update \
	dialyze \
	test

all: \
	clean \
	deps \
	compile \
	test \
	dialyze

travis_ci: \
	deps \
	compile \
	test

fresh-build: \
	clean \
	compile

compile:
	@rebar compile

clean:
	@rebar clean

deps: \
	deps-get \
	deps-update

deps-get:
	@rebar get-deps

deps-update:
	@rebar update-deps

dialyze:
	@dialyzer ebin

test:
	@rebar ct skip_deps=true --verbose=0
