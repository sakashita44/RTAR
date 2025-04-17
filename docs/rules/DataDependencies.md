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
        * `dictionary` 形式の場合は各キーの値に対して単位を指定することが望ましい
            * 例: `key1:unit1, key2:unit2`
        * `list` 形式の場合すべての要素の単位が同一になるはずなので, 単位を一つだけ指定する (例: `unit1`).
        * `single` 形式の場合は単位を一つだけ指定する (例: `unit1`).
    * `columns` (任意): データが `table` 形式の場合に列情報を定義するリスト. `format` が `table` の場合は必須.
        * `name` (必須): 列名 (文字列).
            * 列名の末尾に `*` を付けると, その列以降が可変長であることを示す. 詳細は[可変長列数のデータを定義する場合](#可変長列数のデータを定義する場合)を参照.
        * `description` (必須): 列の説明 (文字列). 単位を含む場合は単位も記載する.
        * `key_source` (任意): `name` に `*` が付いており, **かつ参照されるデータ (例: `uid`) の `format` が `table` の場合に必須**. 参照データ内で実際の列名として使用する列の名前を指定する (文字列). (例: `id`). 詳細は[可変長列数のデータを定義する場合](#可変長列数のデータを定義する場合)を参照.
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
    unit: "key1:unit1, key2:unit2" # 辞書のキーに対する単位(自由記述)
    required_data:
      - rawA
    required_parameter:
      - parameter2
    process:
      - rawA から必要なデータを抽出
      - parameter2 を用いて変換
    # dictionary の場合は columns は不要
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
    * `key_source` で指定された列の値が, 可変長部分の列名となる.
    * 例: 参照データ `uid` (`format: table`) の `key_source: id` と指定した場合, `uid` テーブルの `id` 列の値 (`user001`, `user002`, ...) が列名になる.
* **参照データの `format` が `dictionary` の場合:**
    * 参照データのキーが, 可変長部分の列名となる.
    * 例: 参照データ `device_map` (`format: dictionary`) を指定した場合, `device_map` のキー (`device1`, `device2`, ...) が列名になる.
* **参照データの `format` が `list` の場合:**
    * 参照データに含まれる値そのものが, 可変長部分の列名となる.
    * 例: 参照データ `sensor_ids` (`format: list`) を指定した場合, `sensor_ids` の要素 (`sensorA`, `sensorB`, ...) が列名になる.
* **上記以外の `format` (`single`, `binary`, `document` など) の場合:**
    * これらの形式を参照データとして指定すること自体は可能だが, 通常, 列名の参照元としては不適切であるため, 意図した動作か確認が必要となる.

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
        description: 各ユーザーの計測値 (mV) # 単位を追記
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
        description: 各センサーの計測値 (V) # 単位を追記
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

```yaml
data:
  ref_single:
    descriptions: ["単一値"]
    format: single
    unit: "-"
  table_warning:
    descriptions: ["注意: 参照先 format が single"]
    format: table
    unit: "table"
    columns:
      - name: time
        description: "時間"
      - name: ref_single* # 注意: 参照先 format が single
        description: "参照先 single"
        # key_source は不要.
```

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
