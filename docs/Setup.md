# セットアップ

このドキュメントでは, 解析テンプレートをセットアップする手順を説明する.

## 目次

* [セットアップ](#セットアップ)
    * [目次](#目次)
    * [前提条件](#前提条件)
    * [セットアップ方法の選択](#セットアップ方法の選択)
    * [自動セットアップの手順](#自動セットアップの手順)
    * [手動セットアップの手順](#手動セットアップの手順)
        * [1. リポジトリのクローン](#1-リポジトリのクローン)
        * [2. 設定ファイルの確認と修正](#2-設定ファイルの確認と修正)
        * [3. ディレクトリ構造の生成](#3-ディレクトリ構造の生成)
        * [4. Dockerコンテナの作成](#4-dockerコンテナの作成)
        * [5. DVCの初期化](#5-dvcの初期化)
        * [6. VS Codeプロフィールの設定](#6-vs-codeプロフィールの設定)
        * [7. Dev Container設定](#7-dev-container設定)
    * [解析環境の使用](#解析環境の使用)
    * [トラブルシューティング](#トラブルシューティング)

## 前提条件

* Docker
    * 推奨バージョン: 最新の安定版
    * 役割: Python実行環境と仮想環境の作成に使用

* Git
    * 推奨バージョン: 2.0以降
    * 役割: リポジトリのクローンとバージョン管理に使用

* Visual Studio Code
    * 推奨バージョン: 最新の安定版
    * 役割: 開発環境として使用, Dev Containerの利用

## セットアップ方法の選択

このテンプレートは以下の2つの方法でセットアップできる:

* **自動セットアップ**: リポジトリで想定されたツールを全て使用する場合に選択
* **手動セットアップ**: エディタやバージョン管理ソフトを自分で選択する場合に選択

## 自動セットアップの手順

自動セットアップを行う場合は, 以下のステップで実行する:

1. リポジトリをクローン
1. 設定ファイルを確認・修正
1. セットアップスクリプトを実行
1. VS Codeでワークスペースを開き, Dev Containerで解析を開始

```bash
# リポジトリのクローン
git clone https://github.com/yourusername/analysis-template.git
cd analysis-template

# 設定ファイルの確認と修正
# - env/python.json: Pythonバージョンとイメージの設定
# - env/requirements.txt: 必要なPythonパッケージを設定 (解析途中でも修正可能)
# - env/dvc.json: DVCリモートの設定

# セットアップスクリプトの実行 (Windowsの場合)
.\scripts\misc\setup.ps1

# セットアップスクリプトの実行 (Linux/Macの場合)
bash ./scripts/misc/setup.sh
```

セットアップスクリプトは以下の処理を自動的に実行する:

* ディレクトリ構造の作成
* DVC初期化と設定
* Dockerコンテナのビルド
* VS Code設定の適用
* `.devcontainer`の設定

## 手動セットアップの手順

手動でセットアップする場合は, 以下の手順で実行する:

### 1. リポジトリのクローン

まず最初に, リポジトリをローカル環境にクローンする.

```bash
git clone https://github.com/yourusername/analysis-template.git
cd analysis-template
```

クローン後，.gitディレクトリを削除することをお勧めする．これにより，リポジトリの履歴が削除され，新しいリポジトリとして使用できる．

```bash
rm -rf .git
```

### 2. 設定ファイルの確認と修正

次に, 設定ファイルを確認し必要に応じて修正する.

```bash
# 設定ファイルの確認と修正
# - env/python.json: Pythonバージョンとイメージの設定
# - env/requirements.txt: 必要なPythonパッケージを設定 (解析途中でも修正可能)
# - env/dvc.json: DVCリモートの設定
```

### 3. ディレクトリ構造の生成

次に, 解析に必要なディレクトリ構造を生成する. これには自動生成スクリプトを使用する.

```bash
# Linux/Macの場合
bash scripts/misc/gen_structure.sh

# Windowsの場合
.\scripts\misc\gen_structure.ps1
```

このスクリプトは以下のようなディレクトリ構造を作成する:

* `data/`: データファイル用
    * `raw/`: 元データ
    * `processed/`: 前処理済みデータ
    * `analysis/`: 解析結果データ
* `scripts/`: 解析スクリプト用
    * `preprocessing/`: 前処理スクリプト
    * `analysis/`: 解析スクリプト
    * `common/`: 共通ライブラリ
    * `interface/`: データ操作インターフェース
    * `misc/`: その他のユーティリティ
* `exploratory/`: 探索的分析用ノートブック
* `reports/`: レポート用
* `params/`: パラメータファイル用
* `info/`: プロジェクト情報用

### 4. Dockerコンテナの作成

ディレクトリ構造が生成できたら, Dockerfileをビルドしてコンテナを作成する.

```bash
# コンテナのビルド
docker build -t analysis-env -f env/Dockerfile .
```

このコンテナで使用するPythonイメージは `env/python.json` で指定されており, コンテナ内で使用するPythonライブラリは `env/requirements.txt` で指定されている.

### 5. DVCの初期化

次に, DVCを初期化する.

```bash
# DVCの初期化
dvc init
dvc remote add -d myremote /path/to/remote/storage
```

### 6. VS Codeプロフィールの設定

Dockerコンテナが作成できたら, VS Codeのプロフィールを設定する.
なお自身の好みのプロフィールを使用する場合は, `env/rtar.code-profile`を直接編集するか，
.devcontainer/devcontainer.json内の`customizations` > `profile`を変更することで設定を変更できる.

```bash
# VS Codeプロフィールの設定
code --profile-import env/rtar.code-profile
```

これにより, 解析に適した拡張機能や設定が自動的にVS Codeに適用される.

### 7. Dev Container設定

VS Codeで開発コンテナを使用するには, `.devcontainer`ディレクトリが必要である. このディレクトリはリポジトリに含まれているため, 特別な設定は不要である.

Dev Container設定は以下の機能を提供する:

* Dockerコンテナ内でのVS Code開発環境
* ワークスペース全体のマウント
* 必要な拡張機能のプリインストール
* Python解析環境のセットアップ

## 解析環境の使用

環境設定が完了したら, VS CodeのDev Container機能を使用して解析を進める.

1. VS Codeで左下の「><」アイコンをクリック
1. 「Reopen in Container」を選択
1. Dockerコンテナ内のVS Code環境が起動するのを待つ

以上でセットアップは完了し, コンテナ化された一貫性のある環境で解析作業を開始できる.

## トラブルシューティング

* Dockerデーモンが起動していない場合は, Dockerを起動してから試す
* ビルドに失敗する場合は, インターネット接続を確認する
* VS Codeで開発コンテナ機能が見つからない場合は, Dev Containers拡張機能をインストールする
