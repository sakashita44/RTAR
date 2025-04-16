# Data Dependencies Rule

`data_dependencies.yml` の記述ルール

* [Data Dependencies Rule](#data-dependencies-rule)
  * [概要](#概要)
  * [全体構造](#全体構造)
  * [`metadata` セクション](#metadata-セクション)
  * [`target` セクション](#target-セクション)
  * [`data` セクション](#data-セクション)
  * [`parameter` セクション](#parameter-セクション)

## 概要

`data_dependencies.yml` は, 解析におけるデータとパラメータの依存関係を定義するための YAML ファイルである.
このファイルは, 解析の抽象的な構造を管理することに焦点を当てており, データファイルの具体的なパスやパラメータの実際の値は含まない.
このファイルを中心として解析手順等を管理することになる.
このファイルの生成支援や可視化, 周辺ファイル(data_structure.yml, entity_relation.yml等)の生成, 検証は[`rtar-ddeps`](https://github.com/sakashita44/rtar-ddeps)により行うことができる.

## 全体構造

YAML ファイルは以下のトップレベルキーを持つ必要がある.

* `metadata`: 解析に関するメタデータ (必須)
* `target`: 解析の最終的な出力対象となるデータ (必須)
* `data`: 解析で使用するデータの定義 (必須)
* `parameter`: 解析で使用するパラメータの定義 (任意)

```yaml
metadata:
  # ... metadata contents ...
target:
  # ... target contents ...
data:
  # ... data definitions ...
parameter:
  # ... parameter definitions ...
```

## `metadata` セクション

解析の目的や補足情報を記述するセクション (必須).

* `title` (必須): 解析目的を簡潔に示すタイトル (文字列).
* `purposes` (必須): 解析やデータ算出の目的, 意義を記述するリスト (文字列のリスト).
* `terms` (任意): 解析に関連する用語を定義するリスト.
    * `name` (必須): 用語名 (文字列).
    * `descriptions` (必須): 用語の説明を記述するリスト (文字列のリスト).
* `note` (任意): 用語定義やその他の補足情報を記述するリスト (文字列のリスト).

```yaml
metadata:
  title: タイトル
  purposes:
    - 解析目的1
    - 解析目的2
  terms:
    - name: "用語1"
      descriptions:
        - "用語1の説明"
    - name: "用語2"
      descriptions:
        - "用語2の説明"
  note:
    - 注意事項1
    - 注意事項2
```

## `target` セクション

解析の最終的な出力対象となるデータを指定するセクション (必須).

* このセクションには, `data` セクションで定義されたデータ名をリスト形式で記述する (文字列のリスト).
* リストされたデータが, この依存関係定義における最終的な生成目標となる.

```yaml
target:
  - single_data_X # data セクションで定義されたデータ名
  - ts_data_Y     # data セクションで定義されたデータ名
```

## `data` セクション

解析で使用する全てのデータを定義するセクション (必須).
このセクションに記載のないデータは解析で使用できない.

* キー: 任意のデータ名 (文字列, 必須). この名前はファイル内で一意である必要がある.
* 値: 各データの詳細を定義する辞書.
    * `descriptions` (必須): データの概要や目的を記述するリスト (文字列のリスト).
    * `format` (必須): データの形式を示す文字列 (`table`, `single`, `time_series` など. 拡張子ではない).
    * `unit` (必須): データの単位を示す文字列. 単位がない場合やテーブル形式の場合は `-` を記述する.
    * `columns` (任意): データが `table` 形式の場合に列情報を定義するリスト. format が `table` の場合は必須.
        * `name` (必須): 列名 (文字列).
        * `description` (必須): 列の説明 (文字列). 単位を含む場合は単位も記載する.
    * `required_data` (任意): このデータの生成に必要な他のデータを指定するリスト. `data` セクションに存在するデータ名を記述する (文字列のリスト).
    * `required_parameter` (任意): このデータの生成に必要なパラメータを指定するリスト. `parameter` セクションに存在するパラメータ名を記述する (文字列のリスト).
    * `process` (任意): このデータを生成するための処理手順を記述するリスト. 自然言語で記述し, 特定のスクリプト名などは可能な限り避ける (文字列のリスト).

```yaml
data:
  rawA: # データ名 (キー)
    descriptions:
      - 説明1
      - 説明2
    format: table # データ形式
    unit: "-" # 単位 (テーブルなので `-`)
    columns: # table 形式の場合必須
      - name: time # 列名
        description: 時間 (s) # 列の説明 (単位含む)
      - name: value
        description: 計測値 (mV)
  dataA:
    descriptions:
      - 説明1
    format: time_series
    unit: mV
    required_data: # 依存データ
      - rawA
    required_parameter: # 依存パラメータ
      - parameter1
    process: # 処理手順
      - rawA から不要な列を削除
      - parameter1 を用いてフィルタリング
```

## `parameter` セクション

解析で使用するパラメータを定義するセクション (任意).
このセクションに記載のないパラメータは解析で使用できない.

* キー: 任意のパラメータ名 (文字列, 必須). この名前はファイル内で一意である必要がある.
* 値: 各パラメータの詳細を定義する辞書.
    * `descriptions` (必須): パラメータの概要や目的を記述するリスト (文字列のリスト).
    * `unit` (必須): パラメータの単位を示す文字列. 単位がない場合は `-` を記述する.

```yaml
parameter:
  parameter1: # パラメータ名 (キー)
    descriptions:
      - フィルタリングの閾値
    unit: mV # 単位
  parameter2:
    descriptions:
      - 解析対象のID
    unit: "-" # 単位なし
```
