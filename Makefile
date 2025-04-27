SANDBOX_DIR = .sandbox
FEATURES ?= shell
IMAGE ?= ubuntu:latest
IMAGES = ubuntu:latest debian:latest amazonlinux:2023 mcr.microsoft.com/devcontainers/base:ubuntu

.PHONY: help sandbox clean build up rebuild exec stop logs interactive

help:
	@echo ""
	@echo "\033[1;36mAvailable make commands:\033[0m"
	@echo "--------------------------------------"
	@echo "\033[1;36mSandbox Management:\033[0m"
	@printf "  %-28s - %s\n" "make sandbox" "Create sandbox for features"
	@printf "  %-28s - %s\n" "make clean" "Remove sandbox"
	@echo ""
	@echo "\033[1;36mDevcontainer Lifecycle:\033[0m"
	@printf "  %-28s - %s\n" "make devcontainer-up" "Build/start devcontainer"
	@printf "  %-28s - %s\n" "make build" "Build the container only (no attach)"
	@printf "  %-28s - %s\n" "make up" "Start/attach to running container"
	@printf "  %-28s - %s\n" "make rebuild" "Clean + re-sandbox + up"
	@printf "  %-28s - %s\n" "make stop" "Stop the devcontainer"
	@printf "  %-28s - %s\n" "make logs" "Show container logs"
	@echo ""
	@echo "\033[1;36mDevcontainer Utilities:\033[0m"
	@printf "  %-28s - %s\n" "make exec CMD=\"zsh\"" "Execute a command in the devcontainer"
	@printf "  %-28s - %s\n" "make interactive" "Interactive feature/image selection"
	@echo ""
	@echo "\033[1;36mUsage Examples:\033[0m"
	@echo "--------------------------------------"
	@echo "  make sandbox FEATURES=\"shell hello\" IMAGE=<image>"
	@echo "  make devcontainer-up FEATURES=\"shell hello\" IMAGE=<image>"
	@echo ""

list-features:
	@echo "Available features:"
	@cd src && find . -maxdepth 1 -mindepth 1 -type d | sed 's|^\./||' | sort | nl

list-images:
	@echo "Available base images:"
	@echo "$(IMAGES)" | tr ' ' '\n' | sort | nl

sandbox:
	@echo "Creating sandbox environment for features: $(FEATURES) with base image: $(IMAGE)"
	rm -rf $(SANDBOX_DIR)
	mkdir -p $(SANDBOX_DIR)/.devcontainer/features
	@for feature in $(FEATURES); do \
		cp -r src/$$feature $(SANDBOX_DIR)/.devcontainer/features/$$feature; \
	done
	@echo '{' > $(SANDBOX_DIR)/.devcontainer/devcontainer.json
	@echo '  "name": "Feature Test Sandbox",' >> $(SANDBOX_DIR)/.devcontainer/devcontainer.json
	@echo '  "image": "$(IMAGE)",' >> $(SANDBOX_DIR)/.devcontainer/devcontainer.json
	@echo '  "features": {' >> $(SANDBOX_DIR)/.devcontainer/devcontainer.json
	@features_array=$(FEATURES); \
	for feature in $$features_array; do \
		echo "    \"./features/$$feature\": {}," >> $(SANDBOX_DIR)/.devcontainer/devcontainer.json; \
	done
	sed -i '' '$$s/,$$//' $(SANDBOX_DIR)/.devcontainer/devcontainer.json
	@echo '  }' >> $(SANDBOX_DIR)/.devcontainer/devcontainer.json
	@echo '}' >> $(SANDBOX_DIR)/.devcontainer/devcontainer.json
	@echo "Sandbox created at $(SANDBOX_DIR)/"

clean:
	@echo "Cleaning sandbox..."
	rm -rf $(SANDBOX_DIR)
	@echo "Sandbox cleaned."

devcontainer-up: sandbox
	@echo "Launching devcontainer for features $(FEATURES) using image $(IMAGE)..."
	cd $(SANDBOX_DIR) && devcontainer up --workspace-folder .

build:
	cd $(SANDBOX_DIR) && devcontainer build --workspace-folder .

up:
	cd $(SANDBOX_DIR) && devcontainer up --workspace-folder .

rebuild: clean devcontainer-up

exec:
	cd $(SANDBOX_DIR) && devcontainer exec --workspace-folder . -- $(CMD)

stop:
	cd $(SANDBOX_DIR) && devcontainer stop --workspace-folder .

logs:
	cd $(SANDBOX_DIR) && devcontainer logs --workspace-folder .

interactive:
	@$(MAKE) list-features
	@read -p "Select feature numbers (space-separated): " FEATURES_NUMBERS; \
	FEATURES_SELECTED=""; \
	for num in $$FEATURES_NUMBERS; do \
		FEATURE=$$(cd src && find . -maxdepth 1 -mindepth 1 -type d | sed 's|^\./||' | sort | sed -n "$${num}p"); \
		FEATURES_SELECTED="$$FEATURES_SELECTED $$FEATURE"; \
	done; \
	echo ""; \
	$(MAKE) list-images; \
	read -p "Select image number: " IMAGE_NUMBER; \
	IMAGE_SELECTED=$$(echo "$(IMAGES)" | tr ' ' '\n' | sort | sed -n "$${IMAGE_NUMBER}p"); \
	echo ""; \
	echo "Using features: $$FEATURES_SELECTED"; \
	echo "Using image: $$IMAGE_SELECTED"; \
	$(MAKE) devcontainer-up FEATURES="$$FEATURES_SELECTED" IMAGE="$$IMAGE_SELECTED"
