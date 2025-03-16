#!/bin/bash
# filepath: scripts/misc/setup.sh
# RTARテンプレート自動セットアップスクリプト (Linux/Mac用)

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 前提条件の確認
echo -e "${CYAN}前提条件を確認...${NC}"

missing_tools=()

# Dockerの確認
echo -n "[Docker] の確認中... "
if command -v docker &> /dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}未インストール${NC}"
    missing_tools+=("Docker")
fi

# Gitの確認
echo -n "[Git] の確認中... "
if command -v git &> /dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}未インストール${NC}"
    missing_tools+=("Git")
fi

# VS Codeの確認
echo -n "[VS Code] の確認中... "
if command -v code &> /dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}未インストール${NC}"
    missing_tools+=("VS Code")
fi

# 不足ツールがある場合は終了
if [ ${#missing_tools[@]} -gt 0 ]; then
    echo -e "\n${RED}以下のツールがインストールされていない:${NC}"
    for tool in "${missing_tools[@]}"; do
        echo -e "${RED} - $tool${NC}"
    done
    echo -e "\n${RED}セットアップを続行するには, これらのツールをインストールする.${NC}"
    exit 1
fi

# 0. 設定ファイルの確認
echo -e "\n${CYAN}[1/5] 設定ファイルの確認${NC}"

# 必要なファイルの存在確認
config_files=("env/Dockerfile" "env/python.json" "env/requirements.txt" "env/dvc.json")
missing=false

for file in "${config_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}$file が見つかりません. リポジトリに問題があります.${NC}"
        missing=true
    fi
done

if [ "$missing" = true ]; then
    echo -e "${RED}必要な設定ファイルが不足しています. リポジトリを確認してください.${NC}"
    exit 1
fi

# 設定ファイル修正の案内
echo -e "\n${YELLOW}設定ファイルの確認と必要に応じた修正を行ってください:${NC}"
echo -e "${YELLOW} - env/python.json: Pythonバージョンとイメージの設定${NC}"
echo -e "${YELLOW} - env/requirements.txt: 必要なPythonパッケージを設定 (解析途中でも修正可能)${NC}"
echo -e "${YELLOW} - env/dvc.json: DVCリモートの設定${NC}"

read -p "設定ファイルを確認・修正しましたか? (y/n): " answer
if [[ $answer != "y" && $answer != "Y" ]]; then
    echo -e "${YELLOW}セットアップを中断します. 設定ファイルを確認・修正後, 再度実行してください.${NC}"
    exit 0
fi

# 1. ディレクトリ構造の生成
echo -e "\n${CYAN}[2/5] ディレクトリ構造を生成...${NC}"
bash ./scripts/misc/gen_structure.sh

# 2. Dockerコンテナのビルド
echo -e "\n${CYAN}[3/5] Dockerコンテナをビルド...${NC}"

# Dockerイメージのビルド
echo -e "${YELLOW}Dockerイメージをビルド中...${NC}"
docker build -t rtar-analysis -f env/Dockerfile env/

echo -e "${YELLOW}解析環境に変更が必要になった場合は, env/requirements.txt を編集し${NC}"
echo -e "${YELLOW}docker build -t rtar-analysis -f env/Dockerfile env/ を実行することで更新可能です.${NC}"

# 3. DVC初期化と設定
echo -e "\n${CYAN}[4/5] DVCを初期化...${NC}"

# リポジトリが既にGit初期化されているか確認
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}Gitリポジトリを初期化...${NC}"
    git init
fi

# DVC初期化（Docker内で実行）
echo -e "${YELLOW}DVCリポジトリを初期化...${NC}"
docker run --rm -v $(pwd):/workspace -w /workspace rtar-analysis bash -c "pip install dvc && dvc init && dvc config core.autostage true"

# DVC設定ファイルの読み込み
if [ -f "env/dvc.json" ]; then
    # jqがない場合に備えて単純な方法でJSON解析
    DVC_REMOTE_PATH=$(grep -o '"url": *"[^"]*"' env/dvc.json | cut -d'"' -f4)
    DVC_REMOTE_NAME=$(grep -o '"name": *"[^"]*"' env/dvc.json | cut -d'"' -f4)

    # ローカルリモートの設定
    docker run --rm -v $(pwd):/workspace -w /workspace rtar-analysis bash -c "pip install dvc && dvc remote add -d ${DVC_REMOTE_NAME} ${DVC_REMOTE_PATH}"
else
    echo -e "${YELLOW}DVC設定ファイルが見つかりません. デフォルト設定を使用します.${NC}"
    docker run --rm -v $(pwd):/workspace -w /workspace rtar-analysis bash -c "pip install dvc && dvc remote add -d local_remote ./data/dvc_repo"
fi

# 4. VS Code設定
echo -e "\n${CYAN}[5/5] VS Code設定を確認...${NC}"

# VS Codeプロファイルの確認
if [ -f "env/rtar.code-profile" ]; then
    echo -e "${YELLOW}VS Codeプロファイルをインポート...${NC}"
    code --profile-import env/rtar.code-profile
else
    echo -e "${YELLOW}VS Codeプロファイルファイルが見つかりません. デフォルト設定を使用します.${NC}"
fi

# .devcontainerの確認
if [ ! -d ".devcontainer" ]; then
    echo -e "${YELLOW}.devcontainerディレクトリが見つかりません. 作成します.${NC}"
    mkdir -p .devcontainer

    # 最小限のdevcontainer.jsonを作成
    cat > .devcontainer/devcontainer.json << EOF
{
    "name": "RTAR Analysis Environment",
    "dockerFile": "../env/Dockerfile",
    "context": "../env",
    "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-toolsai.jupyter",
        "iterative.dvc"
    ],
    "settings": {
        "python.linting.enabled": true,
        "python.formatting.provider": "black"
    },
    "workspaceMount": "source=\${localWorkspaceFolder},target=/workspace,type=bind",
    "workspaceFolder": "/workspace"
}
EOF
    echo -e "${YELLOW}.devcontainer.jsonを作成しました.${NC}"
fi

# Git属性ファイルの確認と設定
if [ ! -f ".gitattributes" ]; then
    echo -e "${YELLOW}.gitattributesファイルが見つかりません. 作成します.${NC}"
    cat > .gitattributes << EOF
# .gitattributes
# データファイルをDVCで管理
data/**/*.csv filter=dvc
data/**/*.json filter=dvc
data/**/*.c3d filter=dvc
# テキストファイルの改行コードを自動変換
*.md text
*.py text
*.sh text
*.yaml text
*.yml text
EOF
    echo -e "${YELLOW}.gitattributesファイルを作成しました.${NC}"
fi

# セットアップ完了メッセージ
echo -e "\n${GREEN}✅ セットアップが完了!${NC}"
echo -e "\n${CYAN}次のステップ:${NC}"
echo -e " 1. VS Codeで左下の「><」アイコンをクリック"
echo -e " 2. 「Reopen in Container」を選択"
echo -e " 3. Dockerコンテナ内のVS Code環境が起動するのを待つ"
echo -e "\n${CYAN}詳細なドキュメントは docs/ ディレクトリを参照.${NC}"
