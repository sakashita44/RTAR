#!/bin/bash

# 解析テンプレートの初期セットアップを行うスクリプト

# エラーが発生した場合に停止
set -e

# 現在のディレクトリを取得
PROJECT_ROOT=$(pwd)

# 色の定義
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 前提条件の確認
echo -e "${CYAN}前提条件の確認を行います...${NC}"

# Docker の確認
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Docker が見つかりました${NC}"
else
    echo -e "${RED}✗ Docker が見つかりません. インストールしてから再実行してください${NC}"
    exit 1
fi

# Git の確認
if command -v git &> /dev/null; then
    echo -e "${GREEN}✓ Git が見つかりました${NC}"
else
    echo -e "${RED}✗ Git が見つかりません. インストールしてから再実行してください${NC}"
    exit 1
fi

# VS Code の確認
if command -v code &> /dev/null; then
    echo -e "${GREEN}✓ VS Code が見つかりました${NC}"
else
    echo -e "${RED}✗ VS Code が見つかりません. インストールしてから再実行してください${NC}"
    exit 1
fi

# Docker イメージのビルド
echo -e "${CYAN}Docker イメージをビルドしています...${NC}"

DOCKERFILE_PATH="${PROJECT_ROOT}/env/Dockerfile"
if [ ! -f "$DOCKERFILE_PATH" ]; then
    echo -e "${RED}✗ Dockerfile が見つかりません: $DOCKERFILE_PATH${NC}"
    exit 1
fi

docker build -t analysis-template -f "$DOCKERFILE_PATH" .
echo -e "${GREEN}✓ Docker イメージのビルドが完了しました${NC}"

# 仮想環境の作成
echo -e "${CYAN}Python 仮想環境を作成しています...${NC}"

# .venv ディレクトリが既に存在する場合は削除
VENV_PATH="${PROJECT_ROOT}/.venv"
if [ -d "$VENV_PATH" ]; then
    echo -e "${YELLOW}既存の .venv ディレクトリを削除しています...${NC}"
    rm -rf "$VENV_PATH"
fi

# Docker コンテナを使用して仮想環境を作成
docker run --rm -v "${PROJECT_ROOT}:/workspace" -w /workspace analysis-template python -m venv .venv
echo -e "${GREEN}✓ 仮想環境の作成が完了しました${NC}"

# 必要なライブラリのインストール
echo -e "${CYAN}必要なライブラリをインストールしています...${NC}"

REQUIREMENTS_PATH="${PROJECT_ROOT}/env/requirements.txt"
if [ ! -f "$REQUIREMENTS_PATH" ]; then
    echo -e "${RED}✗ requirements.txt が見つかりません: $REQUIREMENTS_PATH${NC}"
    exit 1
fi

# ローカルの仮想環境(venv)を使用してライブラリをインストール
"$VENV_PATH/bin/pip" install -r "$REQUIREMENTS_PATH"
if [ $? -ne 0 ]; then
    echo -e "${RED}✗ ライブラリのインストールに失敗しました${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ライブラリのインストールが完了しました${NC}"

# VS Code プロファイルの設定
echo -e "${CYAN}VS Code プロファイルを設定しています...${NC}"

PROFILE_PATH="${PROJECT_ROOT}/env/analysis.code-profile"
if [ ! -f "$PROFILE_PATH" ]; then
    echo -e "${RED}✗ VS Code プロファイルが見つかりません: $PROFILE_PATH${NC}"
    exit 1
fi

# VS Codeプロファイルをインポート
echo -e "${CYAN}VS Code プロファイルをインポートしています...${NC}"
# プロファイルをインポート (VS Codeのバージョンによって異なる可能性あり)
if code --profile "analysis" import "$PROFILE_PATH" 2>/dev/null; then
    echo -e "${GREEN}✓ VS Code プロファイルのインポートが完了しました${NC}"
else
    echo -e "${YELLOW}! VS Code プロファイルのインポートに問題が発生しました. 拡張機能のみインストールします${NC}"

    # 必須の拡張機能をインストール
    code --install-extension ms-python.python
    code --install-extension ms-toolsai.jupyter
    code --install-extension ms-azuretools.vscode-docker
    code --install-extension iterative.dvc

    echo -e "${GREEN}✓ VS Code 拡張機能のインストールが完了しました${NC}"
fi

echo -e "\n${CYAN}セットアップが完了しました！${NC}"
echo -e "${YELLOW}仮想環境を有効化するには以下のコマンドを実行してください:${NC}"
echo -e "source .venv/bin/activate"

echo -e "\n${YELLOW}使用方法の詳細については docs/Usage.md を参照してください${NC}"
