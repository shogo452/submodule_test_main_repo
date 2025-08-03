RULES_SUBMODULE_DIR = cursor-rules-common
CURSOR_RULES_DIR = .cursor/rules

.PHONY: help setup-cursor-rules update-cursor-rules clean-cursor-rules

help: ## このヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

add-cursor-rules: ## Cursor rulesのsubmoduleを追加
	@echo "Cursor rules submoduleを追加します..."
	git submodule add https://github.com/shogo452/cursor-rules-common.git $(RULES_SUBMODULE_DIR)
	git submodule update --init --recursive

setup-cursor-rules: ## Cursor rulesをセットアップ
	@echo "Cursor rulesをセットアップします..."
	@if [ ! -d "$(RULES_SUBMODULE_DIR)" ]; then \
		echo "エラー: submoduleが見つかりません。先に 'make add-cursor-rules' を実行してください"; \
		exit 1; \
	fi
	@mkdir -p .cursor
	@if [ -d "$(CURSOR_RULES_DIR)" ]; then \
		echo "既存の .cursor/rules を削除します..."; \
		rm -rf $(CURSOR_RULES_DIR); \
	fi
	@echo "ルールファイルをコピーします..."
	@cp -r $(RULES_SUBMODULE_DIR)/.cursor/rules $(CURSOR_RULES_DIR)
	@echo "Cursor rulesのセットアップが完了しました"

update-cursor-rules: ## Cursor rulesを最新版に更新
	@echo "Cursor rulesを更新します..."
	@if [ ! -d "$(RULES_SUBMODULE_DIR)" ]; then \
		echo "エラー: submoduleが見つかりません"; \
		exit 1; \
	fi
	cd $(RULES_SUBMODULE_DIR) && git pull origin main
	@rm -rf $(CURSOR_RULES_DIR)
	@cp -r $(RULES_SUBMODULE_DIR)/.cursor/rules $(CURSOR_RULES_DIR)
	@echo "Cursor rulesを更新しました"

update-submodules: ## 全てのsubmoduleを更新
	git submodule update --remote --recursive

clean-cursor-rules: ## Cursor rulesを削除
	@echo "Cursor rulesを削除します..."
	@rm -rf $(CURSOR_RULES_DIR)
	@echo "Cursor rulesを削除しました"

status-cursor-rules: ## Cursor rulesの状態を確認
	@echo "=== Submodule状態 ==="
	@git submodule status
	@echo ""
	@echo "=== Cursor Rules ファイル ==="
	@if [ -d "$(CURSOR_RULES_DIR)" ]; then \
		ls -la $(CURSOR_RULES_DIR)/; \
	else \
		echo "Cursor rulesディレクトリが存在しません"; \
	fi

commit-submodule-update: ## submoduleの更新をコミット
	git add $(RULES_SUBMODULE_DIR)
	git add $(CURSOR_RULES_DIR)
	git commit -m "Update cursor rules submodule"
