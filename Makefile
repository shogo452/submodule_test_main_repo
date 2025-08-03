.PHONY: help setup-cursor-rules update-cursor-rules clean-cursor-rules

SUBMODULE_DIR = cursor-rules-common
CURSOR_RULES_DIR = .cursor/rules
SUBMODULE_RULES_DIR = $(SUBMODULE_DIR)/.cursor/rules

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
	@$(MAKE) copy-cursor-rules
	@echo "Cursor rules setup completed"

update-cursor-rules: ## Update cursor rules from latest submodule
	@echo "Updating cursor rules..."
	@git submodule update --remote $(SUBMODULE_DIR)
	@$(MAKE) copy-cursor-rules
	@echo "Cursor rules updated"

copy-cursor-rules: ## Copy rules from submodule to .cursor/rules
	@echo "Copying cursor rules..."
	@mkdir -p $(CURSOR_RULES_DIR)
	@if [ -d "$(SUBMODULE_RULES_DIR)" ]; then \
		cp -r $(SUBMODULE_RULES_DIR)/* $(CURSOR_RULES_DIR)/; \
		echo "Rules copied successfully"; \
	else \
		echo "Error: Submodule rules directory not found"; \
		exit 1; \
	fi

clean-cursor-rules: ## Remove copied cursor rules (keeps submodule)
	@echo "Cleaning cursor rules..."
	@rm -rf $(CURSOR_RULES_DIR)
	@echo "Cursor rules cleaned"

update-submodule-version: ## Update submodule to specific version
	@echo "Available versions:"
	@cd $(SUBMODULE_DIR) && git tag --sort=-version:refname | head -10
	@echo -n "Enter version to use (e.g., v1.0.1): " && read version && \
	cd $(SUBMODULE_DIR) && \
	git checkout $$version && \
	cd .. && \
	git add $(SUBMODULE_DIR) && \
	git commit -m "Update cursor-rules to $$version" && \
	$(MAKE) copy-cursor-rules

status: ## Show current submodule status
	@echo "Submodule status:"
	@git submodule status
	@echo "\nCurrent rules files:"
	@find $(CURSOR_RULES_DIR) -name "*.md" -type f 2>/dev/null | sort || echo "No rules files found"
