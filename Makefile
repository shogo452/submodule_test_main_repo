# プロジェクト用Makefile

.PHONY: help setup-cursor update-cursor-rules remove-cursor-rules clean

# 共通ルールのリポジトリURL
CURSOR_RULES_REPO = https://github.com/your-org/cursor-common-rules.git
CURSOR_RULES_DIR = .cursor-rules

help:
	@echo "Cursorルール管理 - 利用可能なコマンド:"
	@echo "  make setup-cursor        - Cursorルールの初期セットアップ"
	@echo "  make update-cursor-rules - Cursorルールを最新版に更新"
	@echo "  make remove-cursor-rules - Cursorルールを削除"
	@echo "  make clean              - 一時ファイルを削除"

# Cursorルールの初期セットアップ
setup-cursor:
	@echo "Cursorルールをセットアップ中..."
	@if [ ! -d "$(CURSOR_RULES_DIR)" ]; then \
		echo "共通ルールをsubmoduleとして追加中..."; \
		git submodule add $(CURSOR_RULES_REPO) $(CURSOR_RULES_DIR); \
		git submodule update --init --recursive; \
	else \
		echo "既にsubmoduleが存在します"; \
	fi
	@$(MAKE) link-cursor-rules
	@echo "✅ Cursorルールのセットアップ完了"

# ルールファイルのシンボリックリンクまたはコピー
link-cursor-rules:
	@echo "ルールファイルをリンク中..."
	@mkdir -p .cursor
	@if [ -d "$(CURSOR_RULES_DIR)/.cursor/rules" ]; then \
		if [ -L ".cursor/rules" ]; then \
			rm .cursor/rules; \
		elif [ -d ".cursor/rules" ]; then \
			rm -rf .cursor/rules; \
		fi; \
		ln -sf ../$(CURSOR_RULES_DIR)/.cursor/rules .cursor/rules; \
		echo "✅ ルールファイルをリンクしました"; \
	else \
		echo "❌ エラー: 共通ルールディレクトリが見つかりません"; \
		exit 1; \
	fi

# Cursorルールの更新
update-cursor-rules:
	@echo "Cursorルールを更新中..."
	@if [ -d "$(CURSOR_RULES_DIR)" ]; then \
		cd $(CURSOR_RULES_DIR) && git pull origin main; \
		echo "✅ Cursorルールを更新しました"; \
	else \
		echo "❌ エラー: Cursorルールがセットアップされていません"; \
		echo "先に 'make setup-cursor' を実行してください"; \
		exit 1; \
	fi

# Cursorルールの削除
remove-cursor-rules:
	@echo "Cursorルールを削除中..."
	@if [ -d "$(CURSOR_RULES_DIR)" ]; then \
		git submodule deinit -f $(CURSOR_RULES_DIR); \
		git rm -f $(CURSOR_RULES_DIR); \
		rm -rf .git/modules/$(CURSOR_RULES_DIR); \
	fi
	@if [ -L ".cursor/rules" ]; then \
		rm .cursor/rules; \
	fi
	@echo "✅ Cursorルールを削除しました"

# プロジェクト固有のルール追加
add-project-rules:
	@echo "プロジェクト固有のルールを追加中..."
	@mkdir -p .cursor/rules-local
	@if [ ! -f ".cursor/rules-local/project.md" ]; then \
		echo "# プロジェクト固有ルール\n\n## このプロジェクト特有の設定\n- ここにプロジェクト固有のルールを記述" > .cursor/rules-local/project.md; \
		echo "✅ プロジェクト固有ルールファイルを作成しました"; \
	else \
		echo "📝 プロジェクト固有ルールファイルは既に存在します"; \
	fi

# 開発環境のセットアップ
setup-dev: setup-cursor add-project-rules
	@echo "✅ 開発環境のセットアップが完了しました"

# 一時ファイルの削除
clean:
	@echo "一時ファイルを削除中..."
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "✅ クリーンアップ完了"

# submoduleの状態確認
status:
	@echo "Submoduleの状態:"
	@git submodule status
	@echo "\nCursorルールの状態:"
	@if [ -L ".cursor/rules" ]; then \
		echo "✅ ルールファイルはリンクされています"; \
		ls -la .cursor/rules; \
	else \
		echo "❌ ルールファイルがリンクされていません"; \
	fi
