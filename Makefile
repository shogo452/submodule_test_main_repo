# プロジェクト用Makefile

.PHONY: help setup-cursor update-cursor-rules remove-cursor-rules status clean

# 共通ルールのリポジトリURL
CURSOR_RULES_REPO = https://github.com/shogo452/cursor-rules-common.git
CURSOR_RULES_DIR = .cursor

help:
	@echo "Cursorルール管理 - 利用可能なコマンド:"
	@echo "  make setup-cursor        - Cursorルールの初期セットアップ"
	@echo "  make update-cursor-rules - Cursorルールを最新版に更新"
	@echo "  make list-cursor-rules   - 利用可能なルールファイル一覧"
	@echo "  make remove-cursor-rules - Cursorルールを削除"
	@echo "  make status             - submoduleの状態確認"
	@echo "  make clean              - 一時ファイルを削除"

# Cursorルールの初期セットアップ
setup-cursor:
	@echo "Cursorルールをセットアップ中..."
	@mkdir -p .cursor
	@if [ ! -d "$(CURSOR_RULES_DIR)" ]; then \
		echo "共通ルールをsubmoduleとして追加中..."; \
		git submodule add $(CURSOR_RULES_REPO) $(CURSOR_RULES_DIR); \
		git submodule update --init --recursive; \
		echo "✅ Cursorルールのセットアップ完了"; \
	else \
		echo "📝 既にsubmoduleが存在します"; \
		$(MAKE) update-cursor-rules; \
	fi

# Cursorルールの更新
update-cursor-rules:
	@echo "Cursorルールを更新中..."
	@if [ -d "$(CURSOR_RULES_DIR)" ]; then \
		cd $(CURSOR_RULES_DIR) && git pull origin main; \
		echo "✅ Cursorルールを更新しました"; \
		$(MAKE) list-cursor-rules; \
	else \
		echo "❌ エラー: Cursorルールがセットアップされていません"; \
		echo "先に 'make setup-cursor' を実行してください"; \
		exit 1; \
	fi

# 利用可能なルールファイル一覧
list-cursor-rules:
	@echo "利用可能なCursorルール:"
	@if [ -d "$(CURSOR_RULES_DIR)" ]; then \
		for file in $(CURSOR_RULES_DIR)/*.md; do \
			if [ -f "$$file" ]; then \
				filename=$$(basename "$$file" .md); \
				first_line=$$(head -n 1 "$$file" 2>/dev/null | sed 's/^# *//'); \
				echo "  📝 $$filename: $$first_line"; \
			fi; \
		done; \
	else \
		echo "❌ Cursorルールがセットアップされていません"; \
	fi

# 特定のルールファイルの内容確認
show-rule:
	@read -p "表示するルールファイル名を入力してください: " rulename; \
	if [ -f "$(CURSOR_RULES_DIR)/$$rulename.md" ]; then \
		echo "=== $$rulename ルール ==="; \
		cat "$(CURSOR_RULES_DIR)/$$rulename.md"; \
	else \
		echo "❌ エラー: $$rulename.md が見つかりません"; \
		echo "利用可能なルール:"; \
		$(MAKE) list-cursor-rules; \
	fi

# Cursorルールの削除
remove-cursor-rules:
	@echo "Cursorルールを削除中..."
	@if [ -d "$(CURSOR_RULES_DIR)" ]; then \
		git submodule deinit -f $(CURSOR_RULES_DIR); \
		git rm -f $(CURSOR_RULES_DIR); \
		rm -rf .git/modules/$(CURSOR_RULES_DIR); \
		echo "✅ Cursorルールを削除しました"; \
	else \
		echo "📝 Cursorルールは既に削除されています"; \
	fi

# プロジェクト固有のルール管理
setup-local-rules:
	@echo "プロジェクト固有のルールをセットアップ中..."
	@mkdir -p .cursor/local
	@if [ ! -f ".cursor/local/project.md" ]; then \
		project_name=$$(basename "$$(pwd)"); \
		echo "# $$project_name プロジェクト固有ルール\n\n## このプロジェクト特有の設定\n- ここにプロジェクト固有のルールを記述してください\n\n## 技術スタック\n- \n\n## 注意事項\n- " > .cursor/local/project.md; \
		echo "✅ プロジェクト固有ルールファイルを作成しました"; \
	else \
		echo "📝 プロジェクト固有ルールファイルは既に存在します"; \
	fi

# 開発環境の完全セットアップ
setup-dev: setup-cursor setup-local-rules
	@echo "✅ 開発環境のセットアップが完了しました"
	@echo ""
	@echo "📋 セットアップ完了後の状態:"
	@$(MAKE) status

# submoduleの状態確認
status:
	@echo "📊 Submoduleの状態:"
	@if [ -d ".git" ]; then \
		git submodule status 2>/dev/null || echo "  submoduleはありません"; \
	else \
		echo "  Gitリポジトリではありません"; \
	fi
	@echo ""
	@echo "📁 Cursorルールの状態:"
	@if [ -d "$(CURSOR_RULES_DIR)" ]; then \
		echo "  ✅ 共通ルールが利用可能です"; \
		rule_count=$$(find $(CURSOR_RULES_DIR) -name "*.md" | wc -l | tr -d ' '); \
		echo "  📝 $$rule_count 個のルールファイルが利用可能"; \
	else \
		echo "  ❌ 共通ルールがセットアップされていません"; \
	fi
	@if [ -d ".cursor/local" ]; then \
		local_count=$$(find .cursor/local -name "*.md" 2>/dev/null | wc -l | tr -d ' '); \
		echo "  📋 $$local_count 個のローカルルールファイル"; \
	fi

# 一時ファイルの削除
clean:
	@echo "一時ファイルを削除中..."
	@find . -name "*.tmp" -delete 2>/dev/null || true
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@echo "✅ クリーンアップ完了"

# 全体的なルール確認（共通＋ローカル）
check-all-rules:
	@echo "🔍 全ルールファイルの確認:"
	@echo ""
	@echo "📚 共通ルール:"
	@$(MAKE) list-cursor-rules
	@echo ""
	@echo "📋 ローカルルール:"
	@if [ -d ".cursor/local" ]; then \
		for file in .cursor/local/*.md; do \
			if [ -f "$$file" ]; then \
				filename=$$(basename "$$file" .md); \
				first_line=$$(head -n 1 "$$file" 2>/dev/null | sed 's/^# *//'); \
				echo "  📝 $$filename: $$first_line"; \
			fi; \
		done; \
	else \
		echo "  ローカルルールファイルはありません"; \
	fi
