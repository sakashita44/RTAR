# データ解析テンプレート

## 概要

このプロジェクトはデータ解析の効率化と再現性向上を目的としたテンプレートを提供する．
データ加工履歴の追跡，バージョン管理，環境の汚染防止などを効率的に行うためのツールや手法を統合する．
なお，このREADMEを含むほとんどのドキュメントやスクリプトは生成AIによって作成したものである．
MITライセンスの下で公開しており，本テンプレートの使用に伴う損害や問題については一切の責任を負わない．

## 特徴

* **効率化と再現性向上**: 研究データ解析の効率化と再現性向上
* **バージョン管理**: データと解析スクリプトのバージョン対応の容易化
* **階層構造データの管理**: 階層構造を持つデータの管理をサポート
* **処理経路の可視化**: 処理経路を可視化し，意思決定プロセスを追跡

## 使用ツール

以下のツールを使用しないユーザは考慮外

* **VS Code**: 豊富な拡張機能を活用して他ツールとの連携を図る．
* **Jupyter Notebook**: 探索的な解析を行う際に意思決定プロセスを同時に記録するためのツールとして使用する．
* **Python**: データ処理の汎用的な言語として柔軟なデータ処理を行う．
* **PowerShell/ShellScript**: 自動化スクリプト作成用にネイティブな環境で使用可能な言語として採用する．
* **Git, GitHub**: プロジェクトのバージョン管理と共有を行う．
* **DVC**: データのバージョン管理を行う．
* **venv, Docker**: 仮想環境，コンテナ化による環境分離と再現性向上を図る．
* **DuckDB**: リレーショナルデータベースを用いた階層構造データの管理を行う．
* **nbstripout**: Jupyter Notebookの管理を容易化する．

## ディレクトリ構造

```text
analysis-template/
├── data/
|   ├── dvc_repo/           # DVCリモートリポジトリ
│   ├── raw/                # 生データ
│   ├── processed/          # 加工データ
│   └── analysis/           # 解析データ
├── params/                 # パラメータファイル
|   ├── preprocessing.yaml  # 前処理パラメータ
|   └── analysis.yaml       # 解析パラメータ
├── exploratory/            # 試行錯誤用Notebook
│   ├── preprocessing/      # データ前処理用Notebook
│   └── analysis/           # 解析(統計解析等)用Notebook
├── reports/                # レポート用Notebookとスクリプト
│   ├── notebooks/          # レポート用Notebook
│   └── common/             # レポート用共通スクリプト
├── scripts/                # スクリプト
│   ├── preprocessing/      # データ前処理スクリプト
│   ├── analysis/           # 解析スクリプト
│   ├── common/             # 共通処理ファイル
|   └── misc/               # その他のスクリプト
├── env/                    # 仮想環境関連ファイル
│   ├── Dockerfile
|   ├── requirements.txt
│   └── analysis.code-profile
├── docs/                   # ドキュメント
│   ├── INSTALL.md          # インストール手順
│   └── USAGE.md            # 使用方法
├── info/                   # 確認の必要なファイル
│   ├── PROCESS_OVERVIEW.md # 処理経路の概要
│   ├── VERSION_MAPPING.md  # バージョン対応ドキュメント
│   └── dag_images/         # DAG画像
├── dvc.yaml                # DVC設定ファイル
├── dvc_stages/             # DVCステージファイル
├── README.md               # プロジェクトの概要
...                         # その他のディレクトリ
```

## インストール方法

詳細なインストール手順は [docs/Setup.md](docs/Setup.md) を参照．

## 使用方法

ワークフローの詳細は [docs/Workflow.md](docs/Workflow.md) を参照．
設計思想については [docs/Design.md](docs/Design.md) を参照．
各種コマンドについては [docs/Commands.md](docs/Commands.md) を参照．
学習ロードマップについては [docs/LearningRoadmap.md](docs/LearningRoadmap.md) を参照．

## ライセンス

このプロジェクトは MIT ライセンスの下で公開されている．詳細は [LICENSE](LICENSE) ファイルを参照．
