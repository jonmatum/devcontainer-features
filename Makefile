# Configuration
SANDBOX_DIR = .sandbox
SANDBOX_ANSWERS_FILE = $(SANDBOX_DIR)/answers.yml
COPIER_VENV = .venv-tools
COPIER_BIN = $(COPIER_VENV)/bin/copier
FEATURES ?= shell
IMAGE ?= ubuntu:latest
IMAGES = ubuntu:latest debian:latest amazonlinux:2023 mcr.microsoft.com/devcontainers/base:ubuntu
ANSWERS_FILE = .copier-answers.yml

.PHONY: help sandbox clean build up rebuild exec stop logs interactive ensure-copier format validate

# Help Documentation
help:
	@echo ""
	@echo "Available make commands"
	@echo "------------------------"
	@echo "Sandbox Management:"
	@printf "  %-28s %s\n" "make sandbox" "Create sandbox using Copier and answers file"
	@printf "  %-28s %s\n" "make interactive" "Prompt user to create .copier-answers.yml"
	@printf "  %-28s %s\n" "make clean" "Remove the generated sandbox directory"
	@echo ""
	@echo "Devcontainer Lifecycle:"
	@printf "  %-28s %s\n" "make devcontainer-up" "Create and run devcontainer"
	@printf "  %-28s %s\n" "make build" "Build devcontainer image only"
	@printf "  %-28s %s\n" "make up" "Alias to 'devcontainer-up'"
	@printf "  %-28s %s\n" "make exec CMD='zsh'" "Execute command in container"
	@echo ""
	@echo "Utility and Maintenance:"
	@printf "  %-28s %s\n" "make format" "Format devcontainer.json using jq"
	@printf "  %-28s %s\n" "make container-id" "Print running devcontainer ID"
	@echo ""
	@echo "Reference:"
	@echo "  - Features live under ./src/<feature>"
	@echo "  - Base images: $(IMAGES)"
	@echo ""
	@echo "Examples:"
	@echo "  make sandbox FEATURES=\"shell hello\" IMAGE=debian:latest"
	@echo "  make devcontainer-up"

# List available feature folders
list-features:
	@echo "Available features:"
	@cd src && find . -maxdepth 1 -mindepth 1 -type d | sed 's|^\./||' | sort | nl

# List supported base images
list-images:
	@echo "Available base images:"
	@echo "$(IMAGES)" | tr ' ' '\n' | sort | nl

# Ensure Copier is installed in a local virtualenv
ensure-copier:
	@echo "Checking for Copier..."
	@if [ ! -x "$(COPIER_BIN)" ]; then \
		echo "Copier not found. Creating virtualenv..."; \
		if ! command -v python3 >/dev/null 2>&1; then \
			echo "python3 is required but not found. Please install it."; \
			exit 1; \
		fi; \
		python3 -m venv $(COPIER_VENV); \
		. $(COPIER_VENV)/bin/activate && pip install --upgrade pip copier; \
		echo "Copier installed in $(COPIER_VENV)"; \
	else \
		echo "Copier already available."; \
	fi

# Generate the sandbox with Copier
sandbox: ensure-copier
	@if [ ! -f $(ANSWERS_FILE) ]; then \
		echo "No $(ANSWERS_FILE) found. Running interactive setup..."; \
		$(MAKE) interactive; \
	else \
		read -p "Use existing $(ANSWERS_FILE)? [Y/n]: " CONFIRM; \
		if [ "$$CONFIRM" = "n" ] || [ "$$CONFIRM" = "N" ]; then \
			$(MAKE) interactive; \
		fi; \
	fi
	@echo "Using $(ANSWERS_FILE) to generate sandbox..."
	rm -rf $(SANDBOX_DIR)
	mkdir -p $(SANDBOX_DIR)
	@echo "Copying feature definitions into sandbox..."
	mkdir -p $(SANDBOX_DIR)/.devcontainer/features
	cp -R src/* $(SANDBOX_DIR)/.devcontainer/features/
	cp $(ANSWERS_FILE) $(SANDBOX_ANSWERS_FILE)
	$(COPIER_BIN) copy -a $(notdir $(SANDBOX_ANSWERS_FILE)) .template $(SANDBOX_DIR)
	@$(MAKE) format
	@jq . $(SANDBOX_DIR)/.devcontainer/devcontainer.json


# Prompt user to select features and base image, then generate answers file
interactive: ensure-copier
	@$(MAKE) list-features
	@read -p "Select feature numbers (space-separated): " NUMS; \
	FEATURES_SELECTED=""; \
	for n in $$NUMS; do \
		F=$$(cd src && find . -maxdepth 1 -mindepth 1 -type d | sed 's|^\./||' | sort | sed -n "$${n}p"); \
		FEATURES_SELECTED="$$FEATURES_SELECTED $$F"; \
	done; \
	echo ""; \
	$(MAKE) list-images; \
	read -p "Select image number: " IMG_NUM; \
	IMAGE_SELECTED=$$(echo "$(IMAGES)" | tr ' ' '\n' | sort | sed -n "$${IMG_NUM}p"); \
	echo ""; \
	echo "You selected: $$FEATURES_SELECTED for image $$IMAGE_SELECTED"; \
	echo "features:" > $(ANSWERS_FILE); \
	for f in $$FEATURES_SELECTED; do echo "  - $$f"; done >> $(ANSWERS_FILE); \
	echo "image: $$IMAGE_SELECTED" >> $(ANSWERS_FILE); \
	echo "$(ANSWERS_FILE) generated."

# Clean the sandbox directory
clean:
	@echo "Cleaning sandbox..."
	rm -rf $(SANDBOX_DIR)
	@echo "Sandbox cleaned."

# Devcontainer lifecycle commands
	
devcontainer-up: sandbox
	@echo "Launching devcontainer..."
	cd $(SANDBOX_DIR) && devcontainer up --workspace-folder .

build:
	cd $(SANDBOX_DIR) && devcontainer build --workspace-folder .

up:
	cd $(SANDBOX_DIR) && devcontainer up --workspace-folder .

exec:
	cd $(SANDBOX_DIR) && devcontainer exec --workspace-folder . -- $(CMD)

# Format devcontainer.json using jq
format:
	@echo "Formatting devcontainer.json..."
	@jq . $(SANDBOX_DIR)/.devcontainer/devcontainer.json > $(SANDBOX_DIR)/.devcontainer/devcontainer.json.tmp && \
	mv $(SANDBOX_DIR)/.devcontainer/devcontainer.json.tmp $(SANDBOX_DIR)/.devcontainer/devcontainer.json && \
	echo "Formatted successfully."

container-id:
	@docker ps --filter "name=devcontainer" --format "{{.ID}}"