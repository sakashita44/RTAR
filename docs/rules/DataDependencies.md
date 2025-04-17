# Data Dependencies Rule

`data_dependencies.yml` の記述ルール

* [Data Dependencies Rule](#data-dependencies-rule)
    * [概要](#概要)
    * [全体構造](#全体構造)
    * [`metadata` セクション](#metadata-セクション)
    * [`target` セクション](#target-セクション)
    * [`data` セクション](#data-セクション)
        * [可変長列数のデータを定義する場合](#可変長列数のデータを定義する場合)
            * [定義方法](#定義方法)
            * [列名の決定ルール](#列名の決定ルール)
            * [YAML 記述例](#yaml-記述例)
                * [例1: 参照データ (`uid`) が `table` 形式の場合](#例1-参照データ-uid-が-table-形式の場合)
                * [例2: 参照データ (`sensor_ids`) が `list` 形式の場合](#例2-参照データ-sensor_ids-が-list-形式の場合)
                * [例3: 参照データ (`device_map`) が `dictionary` 形式の場合](#例3-参照データ-device_map-が-dictionary-形式の場合)
            * [例4: 参照データが上記以外の形式の場合](#例4-参照データが上記以外の形式の場合)
        * [カスタム `format` の扱い](#カスタム-format-の扱い)
        * [可変長キー数のdictionaryについて](#可変長キー数のdictionaryについて)
            * [ユースケース: 対象ごとの統計量など](#ユースケース-対象ごとの統計量など)
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
計測の結果や, 解析の過程で生成されるデータを定義する.
required_data や required_parameter で他のデータやパラメータとの依存関係を定義することができる.

* キー: 任意のデータ名 (文字列, 必須). この名前はファイル内で一意である必要がある.
* 値: 各データの詳細を定義する辞書.
    * `descriptions` (必須): データの概要や目的を記述するリスト (文字列のリスト).
    * `format` (必須): データの論理的な形式を示す文字列. 特定のファイル拡張子ではない. 以下のような形式を想定する.
        * `table`: 行と列で構成される表形式データ. 時系列データもこれに含まれる.
        * `dictionary`: キーと値のペアで構成されるデータ (JSON, YAML などデータ交換フォーマットを含む).
        * `list`: 順序付けられた値のシーケンス.
        * `single`: 単一の値.
        * `binary`: 画像, 音声, C3D など特定の構造を持つバイナリデータ.
        * `document`: テキスト中心の文書 (プレーンテキスト, HTML, XML など).
    * `unit` (必須): データの単位を示す文字列 (自由記述).
        * `binary`, `document`他, 単位がない場合は`-`
        * `table` 形式の場合は `table` を指定し, `columns` で各列の単位を指定する.
        * `dictionary` 形式の場合は `dictionary` を指定し, `keys` で各キーの単位を指定する.
        * `list` 形式の場合すべての要素の単位が同一になるはずなので, 単位を一つだけ指定する (例: `unit1`).
        * `single` 形式の場合は単位を一つだけ指定する (例: `unit1`).
    * `columns` (任意): データが `table` 形式の場合に列情報を定義するリスト. `format` が `table` の場合は必須.
        * `name` (必須): 列名 (文字列).
            * 列名の末尾に `*` を付けると, その列以降が可変長であることを示す. 詳細は[可変長列数のデータを定義する場合](#可変長列数のデータを定義する場合)を参照.
        * `description` (必須): 列の説明 (文字列). 単位を含む場合は単位も記載する.
        * `key_source` (任意): `name` に `*` が付いており, **かつ参照されるデータ (例: `uid`) の `format` が `table` の場合に必須**. 参照データ内で実際の列名として使用する列の名前を指定する (文字列). (例: `id`). 詳細は[可変長列数のデータを定義する場合](#可変長列数のデータを定義する場合)を参照.
    * `keys` (任意): データが `dictionary` 形式の場合にキー情報を定義するリスト. `format` が `dictionary` の場合は必須.
        * `name` (必須): キー名 (文字列).
        * `description` (必須): キーの説明 (文字列). 単位を含む場合は単位も記載する.
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
    unit: "table" # 単位 (テーブルなので `table`)
    columns: # table 形式の場合必須
      - name: time # 列名
        description: 時間 (s) # 列の説明 (単位含む)
      - name: value
        description: 計測値 (mV)
  dataA:
    descriptions:
      - 説明1
    format: table
    unit: "table"
    required_data: # 依存データ
      - rawA
    required_parameter: # 依存パラメータ
      - parameter1
    process: # 処理手順
      - rawA から不要な列を削除
      - parameter1 を用いてフィルタリング
    columns:
        - name: time
          description: 時間 (s)
        - name: value
          description: 計測値 (mV)
  dataB:
    descriptions:
      - "key1: value1, key2:value2 のような辞書形式のデータ"
    format: dictionary # 辞書形式
    unit: "dictionary" # 単位 (辞書なので `dictionary`)
    required_data:
      - rawA
    required_parameter:
      - parameter2
    process:
      - rawA から必要なデータを抽出
      - parameter2 を用いて変換
    keys: # dictionary の場合は keys を使用
      - name: key1
        description: 説明1
        unit: unit1
      - name: key2
        description: 説明2
        unit: unit2
```

### 可変長列数のデータを定義する場合

`data` セクションの `columns` で, 列数が可変となるデータを定義できる. これは主に, 複数の被験者やセンサーなど, 対象の数によって列数が変わる場合に利用する.

#### 定義方法

1. `format` が `table` のデータ定義内で `columns` を記述する.
2. `columns` リスト内で, 可変長部分の開始を示したい列の `name` の末尾にアスタリスク `*` を付加する (例: `user_id*`).
3. アスタリスクを除いた `name` (例: `user_id`) は, `data` セクションで定義済みの他のデータ名を指す必要がある. このデータを「参照データ」と呼ぶ. 存在しないデータ名を指定しないこと.
4. 参照データの `format` が `table` の場合のみ, `key_source` キーが必須となる. `key_source` には, 参照データ (`table` 形式) の中で, 実際の列名として使用したい値が含まれる列の名前を指定する (例: `id`). 指定した列が参照データに存在することを確認すること.
5. 参照データの `format` が `table` 以外の場合は `key_source` を指定しないこと.

#### 列名の決定ルール

可変長部分の実際の列名は, 参照データの `format` によって決定方法が異なる.

* **参照データの `format` が `table` の場合:**
    * `key_source` キーが必須となる.
    * `key_source` には, 参照データ (`table` 形式) の中で, 実際の列名として使用したい列の名前を指定する.
    * 指定された列 (例: `uid` テーブルの `id` 列) の値が, 可変長部分の列名となる.
* **参照データの `format` が `dictionary` の場合:**
    * `key_source` キーは不要 (指定しても無視される).
    * 参照データのキーが, 可変長部分の列名となる.
* **参照データの `format` が `list` の場合:**
    * `key_source` キーは不要 (指定しても無視される).
    * 参照データに含まれる値そのものが, 可変長部分の列名となる.
* **上記以外の `format` (`single`, `binary`, `document` など) の場合:**
    * これらの形式は通常, 可変長列の列名を生成するための参照元としては使用されない. もし参照元として指定された場合の挙動は未定義またはエラーとするのが適切である.

#### YAML 記述例

##### 例1: 参照データ (`uid`) が `table` 形式の場合

```yaml
data:
  uid:
    descriptions:
      - ユーザー情報
    format: table
    unit: "table"
    columns:
      - name: id # この列の値が列名になる
        description: ユーザーID (文字列)
      - name: group
        description: 所属グループ (文字列)
  experiment_data:
    descriptions:
      - 実験結果
    format: table
    unit: "table" # 各列の単位は description で示す想定
    columns:
      - name: time
        description: 経過時間 (s)
      - name: uid* # 可変長列. 参照データは 'uid'
        description: 各ユーザーの計測値 (mV)
        key_source: id # 'uid' テーブルの 'id' 列の値を列名として使用 (必須)
```

この場合, `experiment_data` の列は `time`, `user001`, `user002`, ... のようになる (もし `uid` テーブルの `id` 列に `user001`, `user002` が含まれていれば).

##### 例2: 参照データ (`sensor_ids`) が `list` 形式の場合

```yaml
data:
  sensor_ids:
    descriptions:
      - 使用したセンサーのIDリスト
    format: list
    unit: "-"
    # list の各要素はセンサーID (例: 'sensorA', 'sensorB') とする
  sensor_readings:
    descriptions:
      - センサー計測値
    format: table
    unit: "table" # 各列の単位は description で示す想定
    columns:
      - name: timestamp
        description: 計測時刻 (iso8601)
      - name: sensor_ids* # 可変長列. 参照データは 'sensor_ids'
        description: 各センサーの計測値 (V)
        # key_source は不要 (sensor_ids の format が list のため).
```

この場合, `sensor_readings` の列は `timestamp`, `sensorA`, `sensorB`, ... のようになる (もし `sensor_ids` リストに `'sensorA'`, `'sensorB'` が含まれていれば).

##### 例3: 参照データ (`device_map`) が `dictionary` 形式の場合

```yaml
data:
  device_map:
    descriptions:
      - デバイス名とIPアドレスのマッピング
    format: dictionary
    unit: "dictionary" # 単位 (辞書なので `dictionary`)
    keys:
      - name: device1
        description: デバイス1のIPアドレス (文字列)
        unit: "-"
      - name: device2
        description: デバイス2のIPアドレス (文字列)
        unit: "-"
    # dictionary の内容は {'device1': '192.168.1.10', 'device2': '192.168.1.11'} などと仮定
  device_status:
    descriptions:
      - デバイスのステータス
    format: table
    unit: "table" # 各列の単位は description で示す想定
    columns:
      - name: check_time
        description: 確認時刻 (iso8601)
      - name: device_map* # 可変長列. 参照データは 'device_map'
        description: 各デバイスのステータス (OK/NG/...)
        # key_source は不要 (device_map の format が dictionary のため).
```

この場合, `device_status` の列は `check_time`, `device1`, `device2`, ... のようになる (もし `device_map` 辞書のキーに `device1`, `device2` が含まれていれば).

#### 例4: 参照データが上記以外の形式の場合

参照データの `format` が `single`, `binary`, `document` などの場合, 可変長列の参照元として指定することは推奨されない.

### カスタム `format` の扱い

`rtar-core` は, このドキュメントで定義されている `format` (`table`, `dictionary`, `list`, `single`, `binary`, `document`) 以外のカスタム `format` 名 (例: `tensor`) が `data_dependencies.yml` に記述されていても, 基本的にエラーとはしない.

ただし, [`rtar-ddeps`](https://github.com/sakashita44/rtar-ddeps) によるバリデーションでは, 未定義の `format` はエラーとなる可能性がある. 将来的には, `rtar-ddeps` にユーザーがローカル設定でカスタム `format` を宣言し, ツールに認識させる機能を追加する予定である. `rtar-core` はその拡張に追従する形で, カスタム `format` の解釈をより適切に行えるように改善する可能性がある.

### 可変長キー数のdictionaryについて

`rtar-core` では, `format: dictionary` のデータにおいて, キーが他のデータに基づいて動的に変化する「可変長キー」の定義は推奨しない. つまり, `keys` リスト内の `name` に `*` を付けるといった記述は許容されない.

この決定には以下の理由がある.

* **意味的な曖昧さ**: `table` の可変長列は「対象（例: センサー）ごとに属性（列）を追加する」というワイド形式データとして比較的明確に解釈できる. 一方, `dictionary` のキーがデータ値から動的に生成されるルールは, 構造の予測を難しくし, データ構造（キー）とデータ値（キー生成に使われる参照データ）の境界が曖昧になりやすい.
* **実装の複雑性**: 可変長キーを正しく解釈・検証するには, 参照データを読み込み, その形式に応じて期待されるキーのリストを動的に生成し, 実際の辞書と比較する複雑なロジックが必要となる. これは `table` の可変長列の扱いよりも複雑である.
* **データモデリング**: キーがデータ値から派生する辞書は, 標準的なデータモデリングでは一般的ではない. 「センサーAの平均」「センサーBの平均」といった構造は, `table` 形式（特に正規化されたロング形式, または可変長列を用いたワイド形式）で表現する方が, データ構造としてより明確かつ堅牢である場合が多い.
* **ツール連携**: データ分析ツールの多くは表形式データを中心に設計されており, キーが動的に変わる辞書よりも `table` 形式の方が一般的に扱いやすい.
* **`data_structure.yml` との整合性**: 物理的なデータ構造を定義する `data_structure.yml` において, キー自体が可変である辞書を具体的に記述することが困難になる.

これらの理由から, ルールの単純さ, 実装の容易さ, データモデリングの明瞭さを優先し, `dictionary` のキーは**固定**とする方針を推奨する.

対象（センサー, 被験者など）に応じてキーが増減するようなデータを表現したい場合は, `format: table` を使用し, 以下のいずれかの方法で定義することを推奨する.

* **可変長列を用いたワイド形式**: [ユースケース: 対象ごとの統計量など](#ユースケース-対象ごとの統計量など) の `sensor_statistics_wide` の例を参照.
* **固定列を用いたロング形式（正規化）**: [ユースケース: 対象ごとの統計量など](#ユースケース-対象ごとの統計量など) の `sensor_statistics_long` の例を参照.

#### ユースケース: 対象ごとの統計量など

センサーごと, 被験者ごとなど, 対象の数に応じて統計量などをまとめたい場合, `dictionary` の可変長キーではなく, `table` の可変長列を使用する. これにより, いわゆる**ワイド形式**のテーブル構造を表現できる.

```yaml
data:
  sensor_ids:
    descriptions:
      - 解析対象のセンサーIDリスト
    format: list
    unit: "-"
    # 例: ['sensorA', 'sensorB', 'sensorC']

  sensor_statistics_wide: # ワイド形式の定義
    descriptions:
      - 各センサーの統計量 (ワイド形式)
    format: table
    unit: "table" # 単位は列の description で示す
    required_data:
      - sensor_ids
      # - (元データ)...
    process:
      - 元データから sensor_ids に含まれる各センサーの統計量を計算
    columns:
      - name: statistic # 統計量の種類 (固定列)
        description: 統計量の種類 (例: 'mean', 'stddev')
      - name: sensor_ids* # 可変長列. 参照データは 'sensor_ids'
        description: 各センサーに対応する統計値 (単位は statistic により異なる)
        # key_source は不要 (sensor_ids の format が list のため)
```

この定義 (sensor_statistics_wide) により, データは以下のようなワイド形式のテーブルとして扱われる.

| statistic | sensorA | sensorB | sensorC |
| --------- | ------- | ------- | ------- |
| mean      | 10.5    | 11.2    | 9.8     |
| stddev    | 1.2     | 1.5     | 1.1     |

代替: 正規化されたロング形式

同じ情報を, 正規化されたロング形式のテーブルとして表現することも可能である. この場合, 可変長列は使用しない.

```yaml
data:
  sensor_statistics_long: # ロング形式の定義
    descriptions:
      - 各センサーの統計量 (正規化されたロング形式)
    format: table
    unit: "table" # value 列の単位は statistic により異なる
    # required_data, process...
    columns:
      - name: sensor_id
        description: センサーID (文字列)
      - name: statistic
        description: 統計量の種類 (文字列, 例: 'mean', 'stddev')
      - name: value
        description: 統計値 (単位は statistic により異なる)
```

この定義 (sensor_statistics_long) により, データは以下のようなロング形式のテーブルとして扱われる.

| sensor_id | statistic | value |
| --------- | --------- | ----- |
| sensorA   | mean      | 10.5  |
| sensorA   | stddev    | 1.2   |
| sensorB   | mean      | 11.2  |
| sensorB   | stddev    | 1.5   |
| sensorC   | mean      | 9.8   |
| sensorC   | stddev    | 1.1   |

data_dependencies.yml では, 解析の文脈に応じてどちらの形式でも定義できる. 可変長列機能は, ワイド形式を直接扱いたい場合に有用である.

## `parameter` セクション

解析で使用するパラメータを定義するセクション (任意).
このセクションに記載のないパラメータは解析で使用できない.
他のデータに依存しない, かつ計測等の結果に基づかず, ユーザーが設定するパラメータを定義する.

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
