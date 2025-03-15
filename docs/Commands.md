# データ解析コマンドリファレンス

このドキュメントでは，解析テンプレートで使用する主要コマンドの使用方法を説明する．
Workflow.mdで説明している標準的な流れを補完するコマンド集である．

## 目次

* [データ解析コマンドリファレンス](#データ解析コマンドリファレンス)
    * [目次](#目次)
    * [環境設定コマンド](#環境設定コマンド)
        * [仮想環境の操作](#仮想環境の操作)
        * [Docker環境](#docker環境)
    * [Git操作コマンド](#git操作コマンド)
    * [DVC関連コマンド](#dvc関連コマンド)
        * [DAG可視化コマンド](#dag可視化コマンド)
        * [高度な使用法](#高度な使用法)
    * [データ処理コマンド](#データ処理コマンド)
        * [DuckDBコマンド](#duckdbコマンド)
    * [Jupyter関連コマンド](#jupyter関連コマンド)
        * [nbstripoutの設定と操作](#nbstripoutの設定と操作)
    * [プロジェクト文書化コマンド](#プロジェクト文書化コマンド)
    * [テストと品質管理](#テストと品質管理)
    * [トラブルシューティング](#トラブルシューティング)
        * [一般的な問題解決](#一般的な問題解決)

## 環境設定コマンド

### 仮想環境の操作

* 仮想環境の作成

```bash
# Python仮想環境を作成
python -m venv .venv
```

* 仮想環境の有効化（OS別）

```bash
# Windows (PowerShell)
.\.venv\Scripts\Activate.ps1

# Windows (コマンドプロンプト)
.\.venv\Scripts\activate.bat

# Linux/macOS
source .venv/bin/activate
```

**出力例:**

```powershell
# Windows (PowerShell)
(.venv) PS C:\Users\username\project>
```

```bash
# Linux/macOS
(.venv) username@hostname:~/project$
```

* 仮想環境の無効化

```bash
# 全OS共通
deactivate
```

* パッケージのインストール

```bash
# requirements.txtからインストール
pip install -r env/requirements.txt
```

**出力例:**

```console
Collecting matplotlib==3.8.2
  Using cached matplotlib-3.8.2-cp310-cp310-win_amd64.whl
Collecting seaborn==0.13.1
  Using cached seaborn-0.13.1-py3-none-any.whl
...
Successfully installed matplotlib-3.8.2 seaborn-0.13.1 ...
```

### Docker環境

* Dockerコンテナのビルド

```bash
# Dockerイメージを構築
docker build -t analysis-env .
```

* Dockerコンテナの実行

```bash
# ホストのカレントディレクトリをマウントしてコンテナを実行
docker run -v ${PWD}:/workspace -p 8888:8888 analysis-env
```

**出力例:**

```console
[I 2023-03-15 12:34:56.789 ServerApp] Jupyter Server 2.7.0 is running at:
[I 2023-03-15 12:34:56.789 ServerApp] http://a1b2c3d4e5f6:8888/lab?token=abcdef123456...
[I 2023-03-15 12:34:56.789 ServerApp] or http://127.0.0.1:8888/lab?token=abcdef123456...
```

* 特定のスクリプト実行

```bash
# Dockerコンテナでコマンド実行
docker run --rm -v ${PWD}:/workspace analysis-env python scripts/preprocessing/process.py

# 環境変数を含めたDockerコンテナ実行
docker run --rm -v ${PWD}:/workspace -e DATA_PATH=/workspace/data analysis-env python scripts/analysis/analyze.py
```

## Git操作コマンド

* 変更履歴の確認

```bash
# ファイルの変更履歴を表示
git log --follow -p -- params/analysis.yaml
```

**出力例:**

```console
commit a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2
Author: ユーザー名 <email@example.com>
Date:   Wed Mar 15 12:34:56 2023 +0900

    feat: 分析パラメータの調整

diff --git a/params/analysis.yaml b/params/analysis.yaml
index 1234567..89abcdef 100644
--- a/params/analysis.yaml
+++ b/params/analysis.yaml
@@ -10,7 +10,7 @@ parameters:
   alpha: 0.05
-  iterations: 1000
+  iterations: 5000
```

* ファイルの状態確認

```bash
# 変更されたファイルの詳細確認
git diff --word-diff
```

* タグの管理

```bash
# タグ一覧の表示
git tag -l

# タグの詳細情報表示
git show v1.0
```

**出力例:**

```console
tag v1.0
Tagger: ユーザー名 <email@example.com>
Date:   Wed Mar 15 12:34:56 2023 +0900

生データ追加

commit a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2
Author: ユーザー名 <email@example.com>
Date:   Wed Mar 15 12:34:56 2023 +0900

    feat: 生データ追加
```

## DVC関連コマンド

* データの追加と更新

```bash
# 複数ファイルを一度に追加
dvc add data/raw/*.csv

# 特定のデータセットにタグ付け
dvc add data/raw/dataset.csv --desc "2023年実験データ"
```

**出力例:**

```console
100% Adding...
data/raw/dataset1.csv
data/raw/dataset2.csv
data/raw/dataset3.csv
To track the changes with git, run:
    git add data/raw/dataset1.csv.dvc data/raw/dataset2.csv.dvc data/raw/dataset3.csv.dvc
```

* データのロールバック

```bash
# 特定バージョンのデータに戻す
git checkout v1.0 data/raw/example.csv.dvc
dvc checkout
```

* パイプラインの管理

```bash
# 特定ステージのみ実行
dvc repro --single-item preprocessing

# 並列実行でパフォーマンス向上
dvc repro --jobs 4

# パイプラインの依存関係を表示
dvc dag
```

**出力例:**

```console
+---------------+
| preprocessing |
+-------+-------+
        |
        v
    +-------+
    | model |
    +---+---+
        |
        v
+---------------+
|   evaluate    |
+---------------+
```

* メトリクスの管理

```bash
# メトリクス表示
dvc metrics show

# メトリクス比較
dvc metrics diff HEAD HEAD~1
```

**出力例:**

```console
Path         metric    HEAD    HEAD~1   Change
metrics.json accuracy  0.92    0.89     0.03
metrics.json f1_score  0.91    0.87     0.04
```

### DAG可視化コマンド

```bash
# DOT形式で保存してからPNGに変換
dvc dag --dot > info/dag_images/pipeline.dot
dot -Tpng info/dag_images/pipeline.dot -o info/dag_images/pipeline.png

# SVG形式で出力（より高品質な画像）
dvc dag --dot | dot -Tsvg -o info/dag_images/pipeline.svg

# 特定ステージのみの依存関係を表示
dvc dag preprocessing
```

### 高度な使用法

```bash
# DVCリモートの設定
dvc remote add -d myremote s3://bucket/path
dvc remote modify myremote access_key_id 'YOUR-ACCESS-KEY'
dvc remote modify myremote secret_access_key 'YOUR-SECRET-KEY'

# パラメータを使ったパイプライン定義
dvc exp run --set-param params/preprocessing.yaml:threshold=0.7

# 実験の比較
dvc exp show
dvc exp apply <exp_hash>

# パイプラインの依存関係の詳細表示
dvc pipeline show --ascii preprocessing
```

## データ処理コマンド

* データ統計量の確認

```bash
# CSVファイルのプレビュー (Linux/macOS)
head -n 5 data/raw/example.csv

# CSVファイルのプレビュー (Windows PowerShell)
Get-Content data/raw/example.csv -Head 5
```

**出力例:**

```console
id,timestamp,temperature,humidity,pressure
1,2023-03-15 09:00:00,22.5,45,1013.2
2,2023-03-15 09:15:00,22.7,44,1013.1
3,2023-03-15 09:30:00,23.1,43,1012.9
4,2023-03-15 09:45:00,23.4,42,1012.7
```

* データ変換スクリプト実行

```bash
# パラメータを指定してスクリプトを実行
python scripts/preprocessing/process_data.py --input data/raw/example.csv --output data/processed/processed.csv
```

* データサイズ確認 (Linux/macOS)

```bash
# データディレクトリのサイズ確認
du -sh data/*
```

**出力例:**

```console
5.2M    data/analysis
128K    data/external
2.1G    data/raw
890M    data/processed
```

### DuckDBコマンド

```bash
# DuckDBの対話的シェル起動
duckdb data/database.db

# Pythonでの実行例
python -c "
import duckdb
import pandas as pd

# DuckDB接続
con = duckdb.connect('data/database.db')

# SQLクエリ実行
df = con.execute('SELECT * FROM experiment_data').fetchdf()

# Pandasデータフレームをテーブルとして登録
con.register('temp_df', df)
result = con.execute('SELECT AVG(value) FROM temp_df GROUP BY category').fetchdf()
"
```

## Jupyter関連コマンド

* Jupyter Labの起動

```bash
# 標準的な起動
jupyter lab

# リモートアクセス用起動
jupyter lab --ip=0.0.0.0 --no-browser
```

**出力例:**

```console
[I 2023-03-15 12:34:56.789 ServerApp] Jupyter Server 2.7.0 is running at:
[I 2023-03-15 12:34:56.789 ServerApp] http://localhost:8888/lab?token=abcdef123456...
```

* ノートブック変換

```bash
# ノートブックをPDFに変換
jupyter nbconvert --to pdf reports/notebooks/final_report.ipynb

# ノートブックをHTMLに変換
jupyter nbconvert --to html exploratory/analysis/data_exploration.ipynb
```

* 出力クリア

```bash
# ノートブックの出力をクリア
jupyter nbconvert --clear-output --inplace exploratory/preprocessing/data_cleaning.ipynb
```

### nbstripoutの設定と操作

```bash
# nbstripoutの初期設定（Gitフックに登録）
nbstripout --install

# 特定のNotebookに対して手動実行
nbstripout exploratory/analysis/notebook.ipynb

# 設定の確認
nbstripout --status
```

## プロジェクト文書化コマンド

```bash
# DAG画像を生成して文書に埋め込む
dvc dag --dot | dot -Tpng -o info/dag_images/current_pipeline.png
echo "## 現在のパイプライン構造\n\n![パイプライン](../info/dag_images/current_pipeline.png)" >> info/PROCESS_OVERVIEW.md

# バージョン情報の記録
git describe --tags > .version
echo "- $(date +%Y-%m-%d) $(cat .version): $(git log -1 --pretty=%B)" >> info/VERSION_MAPPING.md
```

## テストと品質管理

* テスト実行

```bash
# 全テスト実行
pytest

# 特定のテストファイルのみ実行
pytest tests/test_preprocessing.py
```

**出力例:**

```console
===================== test session starts =====================
platform win32 -- Python 3.10.6, pytest-8.0.0, pluggy-1.4.0
rootdir: C:\Users\username\project
collected 5 items

tests/test_preprocessing.py .....                        [100%]

====================== 5 passed in 2.31s ======================
```

* コードフォーマット

```bash
# コード整形
black scripts tests

# コードリンター実行
flake8 scripts
```

**出力例:**

```console
reformatted scripts/preprocessing/process_data.py
reformatted scripts/analysis/analyze_data.py
All done! ✨ 🍰 ✨
2 files reformatted, 3 files left unchanged.
```

## トラブルシューティング

### 一般的な問題解決

* DVC/Gitキャッシュのクリーンアップ

```bash
# DVCキャッシュのチェックと修正
dvc gc -w
dvc status --cloud

# Gitオブジェクトのクリーンアップ
git gc --prune=now
```

* 依存関係の競合解決

```bash
# パッケージの依存関係確認
pip list --format=freeze > current_env.txt
pip check
```

* データロールバック

```bash
# 特定バージョンのデータに戻す
git checkout v1.0 data/raw/example.csv.dvc
dvc checkout
```

**出力例:**

```console
M       data/raw/example.csv
M       data/processed/processed_data.csv
```

* パーミッション問題（Linux/macOS）

```bash
# スクリプトに実行権限を付与
chmod +x scripts/misc/*.sh
```

このドキュメントはよく使用されるコマンドのリファレンスを提供するもので，必要に応じて実際のプロジェクト要件に合わせてカスタマイズすることを推奨する．
