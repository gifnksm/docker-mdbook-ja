MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
.SECONDEXPANSION:

GITHUB_IMAGE_NAME ?= ghcr.io/gifnksm/mdbook-ja
GITLAB_IMAGE_NAME ?= registry.gitlab.com/gifnksm/docker-mdbook-ja

.PHONY: default
default: build

## Build a Docker image from Dockerfile
.PHONY: build
build: build-github build-gitlab

.PHONY: build-github
build-github:
	docker build -t $(GITHUB_IMAGE_NAME) .

.PHONY: build-gitlab
build-gitlab:
	docker build -t $(GITLAB_IMAGE_NAME) .

## Print this message
help:
	@printf "Available targets:\n\n"
	@awk '/^[a-zA-Z\-_0-9%:\\]+/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", helpCommand); \
			gsub(":+$$", "", helpCommand); \
			printf "  \x1b[32;01m%-16s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ \
		if ($$0 !~ /^.PHONY/) { \
			lastLine = $$0 \
		} \
	} \
	' $(MAKEFILE_LIST) | sort -u
	@printf "\n"
