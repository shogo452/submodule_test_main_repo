.PHONY: help setup-cursor-rules update-cursor-rules clean-cursor-rules

SUBMODULE_DIR = cursor-rules-common
CURSOR_RULES_DIR = .cursor
SUBMODULE_RULES_DIR = $(SUBMODULE_DIR)/.cursor

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

setup-cursor-rules: ## Initial setup of cursor rules from submodule
	@echo "Setting up cursor rules..."
	@if [ ! -d "$(SUBMODULE_DIR)" ]; then \
		echo "Adding cursor-rules-common as submodule..."; \
		git submodule add <CURSOR_RULES_REPO_URL> $(SUBMODULE_DIR); \
	fi
	@git submodule update --init --recursive
	@$(MAKE) create-cursor-symlink
	@echo "Cursor rules setup completed"

update-cursor-rules: ## Update cursor rules from latest submodule
	@echo "Updating cursor rules..."
	@git submodule update --remote $(SUBMODULE_DIR)
	@$(MAKE) create-cursor-symlink
	@echo "Cursor rules updated"

create-cursor-symlink: ## Create symbolic link from .cursor to submodule .cursor directory
	@echo "Creating cursor rules symbolic link..."
	@if [ -L "$(CURSOR_RULES_DIR)" ]; then \
		echo "Removing existing symbolic link..."; \
		rm $(CURSOR_RULES_DIR); \
	fi
	@if [ -d "$(CURSOR_RULES_DIR)" ]; then \
		echo "Removing existing .cursor directory..."; \
		rm -rf $(CURSOR_RULES_DIR); \
	fi
	@if [ -d "$(SUBMODULE_RULES_DIR)" ]; then \
		ln -sf $(SUBMODULE_RULES_DIR) $(CURSOR_RULES_DIR); \
		echo "Symbolic link created successfully"; \
	else \
		echo "Error: Submodule rules directory not found"; \
		exit 1; \
	fi

clean-cursor-rules: ## Remove cursor rules symbolic link (keeps submodule)
	@echo "Cleaning cursor rules..."
	@if [ -L "$(CURSOR_RULES_DIR)" ]; then \
		rm $(CURSOR_RULES_DIR); \
		echo "Symbolic link removed"; \
	elif [ -d "$(CURSOR_RULES_DIR)" ]; then \
		rm -rf $(CURSOR_RULES_DIR); \
		echo "Cursor rules directory removed"; \
	else \
		echo "No cursor rules to clean"; \
	fi

update-submodule-version: ## Update submodule to specific version
	@echo "Available versions:"
	@cd $(SUBMODULE_DIR) && git tag --sort=-version:refname | head -10
	@echo -n "Enter version to use (e.g., v1.0.1): " && read version && \
	cd $(SUBMODULE_DIR) && \
	git checkout $$version && \
	cd .. && \
	git add $(SUBMODULE_DIR) && \
	git commit -m "Update cursor-rules to $$version" && \
	$(MAKE) create-cursor-symlink

status: ## Show current submodule status
	@echo "Submodule status:"
	@git submodule status
	@echo "\nCurrent .cursor link status:"
	@if [ -L "$(CURSOR_RULES_DIR)" ]; then \
		echo "Symbolic link exists:"; \
		ls -la $(CURSOR_RULES_DIR); \
		echo "Linked to:"; \
		readlink $(CURSOR_RULES_DIR); \
	elif [ -d "$(CURSOR_RULES_DIR)" ]; then \
		echo "Directory exists (not a symbolic link):"; \
		ls -la $(CURSOR_RULES_DIR); \
	else \
		echo "No .cursor directory or symbolic link found"; \
	fi
