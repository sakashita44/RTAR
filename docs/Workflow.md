# データ解析ワークフロー

このドキュメントでは解析テンプレートを使った研究データ解析の標準ワークフローを解説する.
ここに記載されている以外の有用なコマンド例は[docs/Commands.md](Commands.md)に記載されている.

* [データ解析ワークフロー](#データ解析ワークフロー)
    * [用語](#用語)
    * [全体像](#全体像)
    * [ステップ1: 要求データ定義](#ステップ1-要求データ定義)
        * [要求データ定義の目的](#要求データ定義の目的)
        * [要求データ定義時タスク](#要求データ定義時タスク)
        * [要求データ定義の成果物](#要求データ定義の成果物)
    * [ステップ2: データ加工 (Preprocessing)](#ステップ2-データ加工-preprocessing)
        * [データ加工の目的](#データ加工の目的)
        * [データ加工時タスク](#データ加工時タスク)
        * [データ加工の成果物](#データ加工の成果物)
        * [データ加工手順](#データ加工手順)
    * [ステップ3: 解析実行 (Analysis)](#ステップ3-解析実行-analysis)
        * [解析の目的](#解析の目的)
        * [解析のタスク](#解析のタスク)
        * [解析の成果物](#解析の成果物)
        * [解析の手順](#解析の手順)
    * [ステップ4: 結果出力 (Reporting)](#ステップ4-結果出力-reporting)
        * [出力の目的](#出力の目的)
        * [出力のタスク](#出力のタスク)
        * [成果物](#成果物)
        * [出力の手順](#出力の手順)
    * [再現性確保と追跡](#再現性確保と追跡)
        * [バージョン管理の実践](#バージョン管理の実践)
        * [処理経路の追跡](#処理経路の追跡)
    * [ワークフロー自動化](#ワークフロー自動化)

## 用語

* 生データ: 計測機器等から直接得られるデータ. 解析に使用するには適切な形式に加工する必要があることが多い.

## 全体像

データ解析は以下の4つの主要ステップからなる.

1. 要求データ定義
1. データ加工
1. 解析実行
1. 結果出力

これらを再現性高く効率的に行うためのワークフローを提供する.

## ステップ1: 要求データ定義

### 要求データ定義の目的

最終的な解析に必要なデータ形式を明確に定義し, 目標を設定する.

### 要求データ定義時タスク

* 以下の内容を`info/DATA_REQUIREMENTS.md`に記載 (`docs/DocumentationRules.md`に従う)
    * 生データの特性把握
    * 最終成果物（論文・発表）に必要なデータ項目の洗い出し
    * 生データから要求データへの変換に必要な中間データの特定

### 要求データ定義の成果物

* `info/DATA_REQUIREMENTS.md` - データ要件定義文書

## ステップ2: データ加工 (Preprocessing)

### データ加工の目的

生データを解析可能な形式に変換するプロセスを透明化・自動化する.

### データ加工時タスク

1. **探索的データ加工**
    * Jupyter Notebook (`exploratory/preprocessing/`) で加工手順を探索
    * データの特性把握と前処理方針の決定
    * 小規模データでの手法検証

1. **加工スクリプト化**
    * 検証済み手順を `scripts/preprocessing/` にPythonスクリプトとして実装
    * パラメータを `params/preprocessing.yaml` に分離

1. **パイプライン定義**
    * `dvc run` コマンドでデータ加工パイプラインを定義
        * 生成されるステージファイルは `dvc_stages/` にデータ処理の階層構造を保持して保存
    * `dvc.yaml` でデータ加工パイプラインを定義
    * `dvc repro` コマンドで再現可能な処理を確立

### データ加工の成果物

* 探索ノートブック (`exploratory/preprocessing/*.ipynb`)
* 加工スクリプト (`scripts/preprocessing/*.py`)
* 加工パラメータ (`params/preprocessing.yaml`)
* 加工データ (`data/processed/`)
* DVCパイプライン定義 (`dvc.yaml`, `dvc_stages/`)
* 処理経路ドキュメント (`info/PROCESS_OVERVIEW.md`)
* データ処理DAG図 (`info/dag_images/`)

### データ加工手順

```bash
# 0. データの追跡
dvc add data/raw/example.csv
dvc commit
git add data/raw/example.csv.dvc
git commit -m "feat: 生データ追加"
git tag -a "v1.0" -m "生データ追加"
git push origin v1.0

# 1. 探索的データ加工（Jupyter Notebook起動）
jupyter notebook exploratory/preprocessing/notebook_name.ipynb

# 2. 加工スクリプトの実行
python scripts/preprocessing/process_data.py

# 3. DVCでパイプライン定義

dvc run -n dvc_stages/preprocessing \
        -d scripts/preprocessing/process_data.py \
        -d params/preprocessing.yaml \
        -d data/raw/example.csv \
        -o data/processed/processed_data.csv \
        python scripts/preprocessing/process_data.py

# 4. DVCでパイプライン実行と追跡
dvc repro preprocessing
dvc dag --dot | dot -Tpng -o info/dag_images/preprocessing.png

# データのロールバック
git checkout v1.0 data/raw/example.csv.dvc
dvc checkout data/processed/processed_data.csv
```

## ステップ3: 解析実行 (Analysis)

### 解析の目的

加工データから知見を抽出し, 統計的分析を行う.

### 解析のタスク

1. **探索的解析**
    * Jupyter Notebook (`exploratory/analysis/`) で分析手法を検討
    * 仮説検証と統計モデルの選択
    * 結果の初期評価

1. **解析スクリプト化**
    * 確立した解析手法を `scripts/analysis/` にスクリプト化
    * 再現可能な分析プロセスの確立

1. **解析パイプライン実行**
    * DVCを用いた解析パイプラインの実行
    * 解析結果の自動生成と追跡

### 解析の成果物

* 探索ノートブック (`exploratory/analysis/*.ipynb`)
* 解析スクリプト (`scripts/analysis/*.py`)
* 解析パラメータ (`params/analysis.yaml`)
* 解析結果 (`data/analysis/`)
* 処理経路ドキュメント (`info/PROCESS_OVERVIEW.md`)
* データ処理DAG図 (`info/dag_images/`)

### 解析の手順

```bash
# 1. 探索的解析（Jupyter Notebook起動）
jupyter notebook exploratory/analysis/notebook_name.ipynb

# 2. 解析スクリプトの実行
python scripts/analysis/analyze_data.py

# 3. DVCで解析パイプライン実行
dvc repro analysis
dvc metrics show
```

## ステップ4: 結果出力 (Reporting)

### 出力の目的

解析結果を可視化し, 論文や発表用の図表を生成する.

### 出力のタスク

1. **可視化設計**
    * 結果を効果的に伝えるためのグラフ・表の設計
    * 論文/発表に適した形式の検討

1. **レポート生成**
    * Jupyter Notebook (`reports/notebooks/`) で出力用ノートブック作成
    * 図表の生成と整形

1. **エクスポート**
    * 可視化結果のPDF/PNG/SVG形式でのエクスポート
    * 論文/発表資料への組み込み

### 成果物

* レポートノートブック (`reports/notebooks/*.ipynb`)
* 図表ファイル (`reports/figures/`)
* レポート生成スクリプト (`reports/common/*.py`)

### 出力の手順

```bash
# 1. レポート用Notebookの起動
jupyter notebook reports/notebooks/

# 2. レポート生成スクリプトの実行
python reports/common/generate_figures.py

# 3. レポートのエクスポート
jupyter nbconvert --to pdf reports/notebooks/final_report.ipynb
```

## 再現性確保と追跡

### バージョン管理の実践

* **コード管理** - Git によるスクリプトとパラメータのバージョン管理
* **データ管理** - DVC によるデータのバージョン管理
* **環境管理** - Dockerコンテナによる実行環境の一貫性確保

### 処理経路の追跡

* `info/PROCESS_OVERVIEW.md` でデータフローを文書化
* `info/dag_images/` にデータ処理DAG図を保存
* `info/VERSION_MAPPING.md` でデータとコードのバージョン対応を記録

## ワークフロー自動化

```bash
# 全処理パイプラインの実行
dvc repro all

# データとコードの同期
dvc push
git add .
git commit -m "feat: 解析パイプライン更新"
git push
```

このワークフローは研究の性質やデータによって調整できる. 各ステップは独立しており, 必要に応じて反復・修正可能な設計となっている.
