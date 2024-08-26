.PHONY: help build test ruff image clean
.DEFAULT_GOAL := help

APP_NAME := map

# Init the venv
init: sync
	@git init
	@uvx pre-commit install

# Sync the project with the venv
sync:
	@uv sync

# Build wheel
build:
	@uvx hatch build

# Test
test:
	@uvx hatch test

# Ruff
ruff:
	@uvx ruff format .
	@uvx ruff check . --fix

# Build image
image:
	@docker image build -t $(APP_NAME) .

# Start a compose service
compose-up:
	@docker compose -f ./compose.yml -p $(APP_NAME) up -d

# Shutdown a compose service
compose-down:
	@docker compose -f ./compose.yml down

# Clean build artifacts
clean:
	@rm -rf build dist *.egg-info htmlcov .coverage coverage.xml coverage.lcov
	@docker compose -f ./compose.yml down -v
	@docker image rm -f $(APP_NAME)

# Show help
help:
	@echo ""
	@echo "Usage:"
	@echo "    make [target]"
	@echo ""
	@echo "Targets:"
	@awk '/^[a-zA-Z\-_0-9]+:/ \
	{ \
		helpMessage = match(lastLine, /^# (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")-1); \
			helpMessage = substr(lastLine, RSTART + 2, RLENGTH); \
			printf "\033[36m%-22s\033[0m %s\n", helpCommand,helpMessage; \
		} \
	} { lastLine = $$0 }' $(MAKEFILE_LIST)