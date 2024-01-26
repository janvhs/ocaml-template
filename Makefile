# References:
# - Reference files
#   - https://github.com/ocaml/ocaml.org/blob/main/Makefile
#   - https://github.com/aantron/dream/blob/master/Makefile

DUNE = opam exec -- dune
EXE = src/main.exe

.DEFAULT_GOAL := help

.PHONY: help
help: ## Print this help message
	@echo "List of available make commands";
	@echo "";
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}';
	@echo "";


.PHONY: switch_create
switch_create: ## Create an opam switch
	opam switch create . -y --deps-only --locked

.PHONY: opam_update
opam_update:
	opam update # refresh the package list of the opam repository at https://ocaml.org/packages/

.PHONY: deps
deps: ## Install development dependencies
	opam install -y . --deps-only --with-test --with-doc --with-dev-setup --locked # install development tools, test packages and odoc

.PHONY: init
init: opam_update switch_create deps ## Create an opam switch and install development dependencies

.PHONY: lock
lock: ## Lock the projects direct dependencies
	opam switch remove -y .
	@make switch_create
	opam lock --direct-only .

.PHONY: fmt
fmt: ## Format the source with ocamlformat
	@$(DUNE) build @fmt --auto-promote

.PHONY: release
release: build_release ## Alias for build_release

.PHONY: build_release
build_release: ## Build the project in release mode
	@$(DUNE) build --release $(EXE)

.PHONY: build_verbose
build_verbose:
	@$(DUNE) build --verbose --release $(EXE)

.PHONY: build
build: ## Build the project in development mode
	@$(DUNE) build

.PHONY: run
run: ## Compile and run the program in development mode
	@$(DUNE) exec $(EXE)

.PHONY: watch
watch: ## Watch the filesystem and rebuild in development mode
	@$(DUNE) build --watch

.PHONY: clean
clean: ## Clean build artifacts, generated files and opam switch
	@$(DUNE) clean
	@opam switch remove . -y

