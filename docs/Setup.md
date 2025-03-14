# セットアップ手順

このドキュメントでは, 解析テンプレートをセットアップする手順を説明する.

## 前提条件

* Docker

    * 推奨バージョン: 最新の安定版
    * 役割: Python実行環境と仮想環境の作成に使用

* Git

    * 推奨バージョン: 2.0以降
    * 役割: リポジトリのクローンとバージョン管理に使用

* Visual Studio Code

    * 推奨バージョン: 最新の安定版
    * 役割: 開発環境として使用

## セットアップ方法の選択

セットアップには以下の2つの方法がある:

1. **自動セットアップ**: インストールスクリプトを使用して一括でセットアップを行う
    * 前提条件をすべて満たしてかつこだわりがない場合
1. **手動セットアップ**: 各ステップを手動で実行する
    * VS Codeを使用しない場合や手動で設定を行いたい場合
    * ローカルにインストールしたPythonやライブラリを使用する場合
    * インストールスクリプトが動作しない場合

## 自動セットアップの手順

### Windows環境

1. リポジトリをクローン

```powershell
git clone <リポジトリURL>
cd <クローンしたディレクトリ>
```

1. インストールスクリプトを実行

```powershell
.\scripts\misc\install.ps1
```

### Linux/Mac環境

1. リポジトリをクローン

    ```bash
    git clone <リポジトリURL>
    cd <クローンしたディレクトリ>
    ```

1. インストールスクリプトを実行

    ```bash
    bash ./scripts/misc/install.sh
    ```

## 手動セットアップの手順

### 1. リポジトリのクローン

```bash
git clone <リポジトリURL>
cd <クローンしたディレクトリ>
```

### 2. Dockerコンテナのビルド

```bash
docker build -t analysis-template -f env/Dockerfile .
```

### 3. 仮想環境の作成

Docker内のPythonを使用してローカル環境に仮想環境を作成する:

```bash
# Windows PowerShell
docker run --rm -v ${PWD}:/workspace -w /workspace analysis-template python -m venv .venv

# Linux/Mac
docker run --rm -v $(pwd):/workspace -w /workspace analysis-template python -m venv .venv
```

### 4. 仮想環境の有効化

```bash
# Windows PowerShell
.\.venv\Scripts\Activate.ps1

# Linux/Mac
source .venv/bin/activate
```

### 5. 必要なライブラリのインストール

```bash
pip install -r env/requirements.txt
```

### 6. VS Codeの設定

1. VS Codeで作業ディレクトリを開く

    ```bash
    code .
    ```

1. プロファイルを設定

    VS Codeのコマンドパレット (`Ctrl+Shift+P` または `Cmd+Shift+P`) を開き, `Profiles: Import Profile...` を選択して `env/analysis.code-profile` をインポートする.

1. 必要な拡張機能のインストール

    * Python
    * Jupyter
    * Docker
    * DVC

## トラブルシューティング

### Docker関連の問題

* **エラー**: Docker デーモンが起動していない
    * **解決策**: Docker Desktopを起動し, デーモンが実行されていることを確認

### 仮想環境の問題

* **エラー**: 仮想環境の作成に失敗
    * **解決策**: `.venv` ディレクトリを削除して再試行

* **エラー**: ライブラリのインストールに失敗
    * **解決策**: インターネット接続を確認し, `pip` を最新バージョンに更新してから再試行

### VS Code関連の問題

* **エラー**: プロファイルのインポートに失敗
    * **解決策**: 個別に必要な拡張機能をインストール

## 環境構成の詳細

* Docker環境
    * 基本イメージ: Python公式イメージ
    * 役割: Python実行環境とライブラリの提供

* 仮想環境 (`.venv`)
    * 場所: プロジェクトルート直下
    * 役割: プロジェクト固有のPythonライブラリの管理

* VS Code設定
    * `env/analysis.code-profile`: 拡張機能と設定のプロファイル
    * `.vscode/settings.json`: ワークスペース固有の設定

## 関連ドキュメント

* `docs/Usage.md`: 環境の使用方法
* `docs/Design.md`: 設計思想と構成
