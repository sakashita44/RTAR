# Data Structure Rule

`data_structure.yml` の記述ルール

* [Data Structure Rule](#data-structure-rule)
    * [概要](#概要)
    * [全体構造](#全体構造)
    * [`placeholder` セクション](#placeholder-セクション)
    * [`data` セクション](#data-セクション)
        * [`layout` の種類](#layout-の種類)
        * [`columns` の定義 (`layout: long` または `layout: wide` の場合)](#columns-の定義-layout-long-または-layout-wide-の場合)
        * [`keys` の定義 (`layout: dictionary` の場合)](#keys-の定義-layout-dictionary-の場合)
        * [`type` の定義](#type-の定義)
    * [`parameter` セクション](#parameter-セクション)

## 概要

`data_structure.yml` は, 解析で使用するデータとパラメータの物理的な構造と配置を定義するための YAML ファイルである.
このファイルは, 各データがどのファイルパスに存在し, どのようなレイアウト (表形式, 辞書形式など) やデータ型を持つかを具体的に記述する.
`data_dependencies.yml` がデータ間の抽象的な依存関係を定義するのに対し, `data_structure.yml` はそれらのデータの具体的な物理的表現を定義する.
このファイルは, [`rtar-ddeps`](https://github.com/sakashita44/rtar-ddeps) などのツールによって, `data_dependencies.yml` からの生成支援や検証が行われることを想定している.

## 全体構造

YAML ファイルは以下のトップレベルキーを持つことができる.

* `placeholder` (任意): ファイルパス内で使用するプレースホルダーを定義する.
* `data` (必須): 解析で使用するデータの物理構造を定義する.
* `parameter` (必須): 解析で使用するパラメータの物理的な場所と型を定義する.

```yaml
placeholder:
  # ... placeholder definitions ...
data:
  # ... data structure definitions ...
parameter:
  # ... parameter structure definitions ...
```

## `placeholder` セクション

ファイルパス文字列内で繰り返し使用される部分文字列を置き換えるためのプレースホルダーを定義するセクション (任意).

* キー: プレースホルダー文字列 (例: `{A}`). 波括弧 `{}` で囲むことが推奨される.
* 値: プレースホルダーの展開先となるデータ名 (例: `user_ids`). これは, `data` や `parameter` セクションで定義されたデータ名と一致する必要がある.

```yaml
placeholder:
  "{A}": user_ids
```

この定義により, `data` や `parameter` セクションの `path` で `{A}` を使用すると, `user_ids` の各値に置き換えられ, パターンベースのファイル名を生成することができる.

## `data` セクション

`data_dependencies.yml` で定義された各データの物理的な構造と場所を定義するセクション (必須).

* キー: `data_dependencies.yml` の `data` セクションで定義されたデータ名と一致する必要がある (文字列, 必須).
* 値: 各データの物理的な詳細を定義する辞書.
    * `path` (必須): データファイルの相対パス (文字列). `placeholder` セクションで定義されたプレースホルダーを使用できる.
    * `layout` (必須): データの物理的なレイアウトを示す文字列. 省略可能だが, 明示的に指定することが推奨される. 以下のいずれかの値を推奨する.
        * `long`: 縦持ち形式のテーブルデータ (例: 1行1観測).
        * `wide`: 横持ち形式のテーブルデータ (例: 1行1サンプルで複数の変数が列).
        * `dictionary`: キーと値のペアで構成されるデータ (例: YAML, JSON ファイル).
        * `list`: 値のシーケンス (例: JSON 配列, 1列のみの CSV).
        * `other`: その他の形式 (例: バイナリファイル, 文書ファイル).
    * `columns` (任意): `layout` が `long` または `wide` の場合は必須. テーブル形式データの列情報を定義するリスト. 以下の要素を持つ辞書のリスト.
        * `name` (必須): 列名 (文字列).
        * `type` (必須): 列のデータ型 (文字列). [想定される型](#type-の定義) を参照.
    * `keys` (任意): `layout` が `dictionary` の場合は必須. 辞書形式データのキー情報を定義するリスト. 以下の要素を持つ辞書のリスト.
        * `name` (必須): キー名 (文字列).
        * `type` (必須): キーに対応する値のデータ型 (文字列). [想定される型](#type-の定義) を参照.
    * `type` (任意): `layout` が `list`, `other` の場合は必須. データの型を指定する文字列. [想定される型](#type-の定義) を参照.

```yaml
data:
  raw_sensor_data: # データ名 (data_dependencies.yml と一致)
    path: "data/raw/sensor_data/{A}.csv" # ファイルパス (プレースホルダー使用)
    layout: long # 物理レイアウト
    columns: # layout が long/wide なので columns を定義
      - name: timestamp
        type: DATETIME
      - name: value_raw
        type: DOUBLE
      - name: status_flag
        type: INTEGER
  statistics_summary:
    path: "results/summary/statistics_summary.yml"
    layout: dictionary # 物理レイアウト (明示的に指定)
    keys: # layout が dictionary なので keys を定義
      - name: mean
        type: DOUBLE
      - name: stddev
        type: DOUBLE
  calculated_threshold:
    path: "results/values/calculated_threshold.txt"
    layout: other # 物理レイアウト (明示的に指定)
    type: DOUBLE # layout が other なので type を定義
  raw_image:
    path: "data/raw/image_{A}.png"
    layout: other # 物理レイアウト (明示的に指定)
    type: STRING # layout が other なので type を定義. 通常はファイルパスを表す型.
```

### `layout` の種類

* `long`: 縦持ち形式のテーブル. `columns` で列名と型を定義する.
* `wide`: 横持ち形式のテーブル. `columns` で列名と型を定義する. `data_dependencies.yml` の可変長列定義に対応する場合がある.
* `dictionary`: キーと値のペア. `keys` でキー名と型を定義する.
* `list`: 値のリスト. 通常, `columns` や `keys` は不要.
* `other`: その他の形式. 通常, `columns` や `keys` は不要.
    * `other` は, バイナリファイルや文書ファイルなど, 特定のレイアウトを持たないデータに使用される.

### `columns` の定義 (`layout: long` または `layout: wide` の場合)

テーブル形式データの列情報を定義する.

* `name` (必須): 列名 (文字列).
* `type` (必須): 列のデータ型 (文字列). [想定される型](#type-の定義) を参照.

```yaml
    columns:
      - name: timestamp
        type: DATETIME
      - name: value
        type: DOUBLE
```

### `keys` の定義 (`layout: dictionary` の場合)

辞書形式データのキー情報を定義する.

* `name` (必須): キー名 (文字列).
* `type` (必須): キーに対応する値のデータ型 (文字列). [想定される型](#type-の定義) を参照.

```yaml
    keys:
      - name: mean
        type: DOUBLE
      - name: stddev
        type: DOUBLE
```

### `type` の定義

(`layout: list`, `other` または `columns`/`keys` 内)

データの型を指定する文字列. 以下のような型を想定する (具体的な実装やツールによって解釈は異なる可能性がある).

* `STRING`: 文字列. バイナリファイル等のファイルパスを表す場合もある.
* `INTEGER`: 整数.
* `DOUBLE` or `FLOAT`: 浮動小数点数.
* `BOOLEAN`: 真偽値 (`true`/`false`).
* `DATETIME`: 日時 (ISO 8601形式などを想定).
* `OBJECT` or `MIXED`: 複数の型が混在する場合や複雑な構造 (例: ネストされた辞書).
* その他, ツール固有の型.

`layout` が `list`, `other` の場合は, データ全体の型を指定する.
`columns` や `keys` 内では, 各列やキーに対する型を指定する.

```yaml
    type: STRING # layout が list/other の場合
    columns:
      - name: timestamp
        type: DATETIME # layout が long/wide の場合
      - name: value
        type: DOUBLE
```

```yaml
    keys:
      - name: mean
        type: DOUBLE # layout が dictionary の場合
      - name: stddev
        type: DOUBLE
```

```yaml
    type: INTEGER # layout が list/other の場合
```

## `parameter` セクション

`data_dependencies.yml` で定義された各パラメータの物理的な場所と型を定義するセクション (必須).

* キー: `data_dependencies.yml` の `parameter` セクションで定義されたパラメータ名と一致する必要がある (文字列, 必須).
* 値: 各パラメータの物理的な詳細を定義する辞書. 以下の要素を持つ.
    * `path` (必須): パラメータが定義されているファイル (通常は設定ファイル) の相対パス (文字列). プレースホルダーを使用できる. 同じファイルに複数のパラメータが定義されている場合, 同じパスを複数回記述する.
    * `type` (必須): パラメータのデータ型 (文字列). [想定される型](#type-の定義) を参照.

```yaml
parameter:
  conversion_factor: # パラメータ名 (data_dependencies.yml と一致)
    path: "params/config.yml" # パラメータが定義されているファイル
    type: DOUBLE # パラメータの型
  filter_threshold:
    path: "params/config.yml" # 同じファイルを参照
    type: DOUBLE
  roi_top:
    path: "params/image_processing.yml" # 別のファイルを参照
    type: INTEGER
```
