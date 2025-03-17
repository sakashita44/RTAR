# RTAR (Reproducible and Traceable Analysis for Research)

## 概要

このプロジェクトはデータ解析の効率化と再現性向上を目的としたテンプレートを提供する．
データ加工履歴の追跡，バージョン管理，環境の汚染防止などを効率的に行うためのツールや手法を統合する．
なお，このREADMEを含むほとんどのドキュメントやスクリプトは生成AIによって作成したものである．
MITライセンスの下で公開しており，本テンプレートの使用に伴う損害や問題については一切の責任を負わない．
また本テンプレートは発展途上であり，現時点では基本的なコンセプトを示すに留まる．

## 特徴

* **柔軟性と自動化**: Notebookによる柔軟な探索的解析とスクリプトによる自動化を組み合わせたデータ解析
* **効率化と再現性向上**: 研究データ解析の効率化と再現性向上
* **バージョン管理**: データと解析スクリプトのバージョン対応の容易化
* **階層構造データの管理**: 階層構造を持つデータの管理をサポート
* **処理経路の可視化**: 処理経路を可視化し，意思決定プロセスを追跡
* **認知負荷の低減**: 規格化されたディレクトリ構造とドキュメント記述ルールによる認知負荷の低減

## 使用ツール

以下のツールを使用しないユーザは考慮外だが，異なるツールを用いて同様の機能を実現することも可能と考えられる．

* **VS Code**: 豊富な拡張機能を活用して他ツールとの連携を図る．
* **Jupyter Notebook**: 探索的な解析を行う際に意思決定プロセスを同時に記録するためのツールとして使用する．
* **Python**: データ処理の汎用的な言語として柔軟なデータ処理を行う．
* **PowerShell/ShellScript**: 自動化スクリプト作成用にネイティブな環境で使用可能な言語として採用する．
* **Git, GitHub**: プロジェクトのバージョン管理と共有を行う．
* **DVC**: データのバージョン管理を行う．
* **Docker**: コンテナ化による環境分離と再現性向上を図る．
* **DuckDB**: リレーショナルデータベースを用いた階層構造データの管理を行う．
* **nbstripout**: Jupyter Notebookの管理を容易化する．

## ディレクトリ構造

```text
analysis-template/
├── data/
|   ├── dvc_repo/             # DVCリモートリポジトリ
│   ├── raw/                  # 生データ
│   ├── processed/            # 加工データ
│   └── analysis/             # 解析データ
├── params/                   # パラメータファイル
|   ├── preprocessing.yaml    # 前処理パラメータ
|   └── analysis.yaml         # 解析パラメータ
├── exploratory/              # 試行錯誤用Notebook
│   ├── preprocessing/        # データ前処理用Notebook
│   └── analysis/             # 解析(統計解析等)用Notebook
├── reports/                  # レポート用Notebookとスクリプト
│   ├── notebooks/            # レポート用Notebook
│   └── common/               # レポート用共通スクリプト
├── scripts/                  # スクリプト
│   ├── preprocessing/        # データ前処理スクリプト
│   ├── analysis/             # 解析スクリプト
│   ├── common/               # 共通処理ファイル
|   ├── interface/            # インターフェーススクリプト
|   └── misc/                 # その他のスクリプト
├── schema/                   # データの構造定義
|   ├── data_structure.yaml   # data/のデータ構造定義
|   └── entity_relation.yaml  # ER定義
├── env/                      # 仮想環境関連ファイル
│   ├── Dockerfile            # Docker設定ファイル
|   ├── requirements.txt      # Pythonパッケージ依存関係
│   └── analysis.code-profile # VS Codeの設定ファイル
├── docs/                     # ドキュメント
│   ├── Design.md             # デザインドキュメント
│   ├── Workflow.md           # ワークフロードキュメント
│   ├── Setup.md              # セットアップドキュメント
|   ├── DocumentationRules.md # ドキュメント記述ルール
|   └── LearningRoadmap.md    # 学習ロードマップ
├── info/                     # 確認の必要なファイル
|   ├── DATA_REQUIREMENTS.md  # データ要件定義文書
│   ├── PROCESS_OVERVIEW.md   # 処理経路の概要
│   ├── VERSION_MAPPING.md    # バージョン対応ドキュメント
│   └── dag_images/           # DAG画像
├── dvc.yaml                  # DVC設定ファイル
├── dvc_stages/               # DVCステージファイル
├── README.md                 # プロジェクトの概要
...                           # その他のディレクトリ
```

## セットアップ方法

詳細なセットアップ手順は [docs/Setup.md](docs/Setup.md) を参照．

## 使用方法

* ワークフローの詳細は [docs/Workflow.md](docs/Workflow.md) を参照．
* 設計思想については [docs/Design.md](docs/Design.md) を参照．
* 学習ロードマップについては [docs/LearningRoadmap.md](docs/LearningRoadmap.md) を参照．
* `info/`以下のドキュメント記述ルールについては [docs/DocumentationRules.md](docs/DocumentationRules.md) を参照．

## ライセンス

MITライセンスを適用する．詳細は [LICENSE](LICENSE) を参照．
