# ドキュメント記述ルール

`info/`以下のドキュメント記述ルール

## DATA_REQUIREMENTS.md記述ルール

DATA_REQUIREMENTS.mdは, 最終データや生データ, データ加工を定義するドキュメント．

* 研究に必要なデータの形式や項目を明確化
* 中間データの内容や加工手順を整理
* 解析全体のデータフローを把握

### ドキュメント構成

以下の構成で記述する

1. 目的
1. 備考
1. 最終データのプロトタイプ宣言
1. 生データの宣言
1. データ加工の記述
1. 特殊なデータ形式の記述

ここで，最終データのプロトタイプ宣言，生データの宣言，データ加工の記述は，それぞれの宣言形式を持つ．

* "()"で囲まれた部分は，一般的なプログラミング言語における型宣言のようなもので，その後に続くデータの内容を示す．
* 必ず型宣言とデータの内容をセットで，構文に従って記述する．
* 各要素は，必要に応じて複数記述する．
* 各要素の内容は自然言語で記述する．

各項目の詳細は以下

#### 目的，備考，特殊なデータ形式の記述

* 目的: ドキュメントの目的や意義を記載 (自由記述)
* 備考: 用語定義やその他の補足情報を記載 (自由記述)
* 特殊なデータ形式の記述: 特殊なデータ形式の記述を記載 (自由記述)，markdownのリンクを利用して参照することが望ましい

#### 最終データのプロトタイプ宣言

以下の要素を含めて最終データを定義する

* 宣言形式: `最終データ`
* 要素:
    * `概要` … データの目的や意味を記載
    * `要求データ` … 必須となる前段のデータ名や種類
    * `出力形式` … 最終データの形式と単位
    * `計算式` … 物理モデルなどで利用する式を明示

構文

```markdown
(最終データ) データ名
    (概要): データの目的や意味
    (要求データ): 必須となる前段のデータ名
    (出力形式): データの形式と単位
    (計算式): 物理モデルなどで利用する式
```

#### 生データの宣言

以下の要素を含めて生データを定義する

* 宣言形式: `生データ`
* 要素:
    * `概要` … データの内容
    * `形式` … ファイルタイプ(csv, txtなど)や構造
    * `単位` … データの単位など

構文

```markdown
(生データ) データ名
    (概要): データの内容
    (形式): ファイルタイプ(csv, txtなど)や構造
    (単位): データの単位など
```

#### データ加工の記述

以下の要素を含めて，1つの最終データに対して1つのデータ加工を定義する．
そのためデータ加工の名前は最終データ名と一致させる．

* 宣言形式: `データ加工`
* ステップ単位で説明し, ステップ名を参照して再利用可能にする
    * このためにステップ名は一意である必要がある
* ステップには以下を含む
    * ただし既存のステップを参照する場合はステップ名をダブルクォーテーションで囲んで記述し，その他の要素は省略する

    * 宣言形式: `ステップ`
    * 要素:
        * `入力データ` … ステップで利用するデータ
        * `処理` … 手続き型の手順や演算
        * `出力データ` … 中間データまたは最終データに相当
        * `出力形式` … 出力データの形式や単位
        * `パラメータ` … しきい値や特別な変数
        * `備考` … その他の情報

構文

```markdown
(データ加工) 対応する最終データ名
    (ステップ) ステップ名
        (入力データ): 入力データ名
        (処理): 処理内容
        (出力データ): 出力データ名
        (出力形式): 出力データの形式
        (パラメータ): パラメータ名

    (ステップ) "既存のステップ名"

    (ステップ) ステップ名
        (入力データ): 入力データ名1
        (入力データ): 入力データ名2
        (処理): 処理内容1
        (処理): 処理内容2
        (出力データ): 出力データ名
        (出力形式): 出力データの形式
        (パラメータ): パラメータ名1
        (パラメータ): パラメータ名2
        (備考): その他の情報
```

### 記述例

以下の例では, conditionAとconditionBの関係を明らかにするためのデータを整理している．
簡略化のため単位の整合性等は考慮していない．

```markdown
# 解析データ定義

`docs/DocumentationRules.md`に記載のルールに従って記述．

## 目次

1. [目的](#目的)
1. [備考](#備考)
1. [最終データのプロトタイプ宣言](#最終データのプロトタイプ宣言)
1. [生データの宣言](#生データの宣言)
1. [データ加工の記述](#データ加工の記述)
1. [特殊なデータ形式の記述](#特殊なデータ形式の記述)

## 目的

* conditionAとconditionBの関係を明らかにするためのデータを整理

## 備考

* 用語
    * conditionA: 条件A
    * conditionB: 条件B

## 最終データのプロトタイプ宣言

### metricX

(最終データ) metricX
    (概要): conditionAとconditionBの関係を示す指標
    (要求データ): singleA, singleB
    (出力形式): {trial_id, metricX}の2列のテーブル, metricXは単位なし
    (計算式): metricX = singleA * singleB

### ts_metricY

(最終データ) ts_metricY
    (概要): conditionAとconditionBから計算される時系列データ
    (要求データ): ts_processedA, singleB
    (出力形式): [metricYのデータ形式定義](#ts_metricYのデータ形式)を参照
    (計算式): ts_metricY(t) = ts_processedA(t) * singleB

## 生データの宣言

### rawA

(生データ) rawA
    (概要): conditionAの生データ
    (形式): trial_id毎のcsv, 各ファイルは{time, rawA}の2列
    (単位): sec, Nm

### rawB

(生データ) rawB
    (概要): conditionBの生データ
    (形式): csv, {trial_id, rawB}の2列
    (単位): m

## データ加工の記述

### Generate metricX

(データ加工) metricX
    (ステップ) cut_A
        (入力データ): rawA
        (処理): rawAの最初の10秒をカット
        (出力データ): cut_edA
        (出力形式): {time, cut_edA}の2列のテーブル
        (パラメータ): なし

    (ステップ) calc_single_A
        (入力データ): cut_edA
        (処理): cut_edAの時間平均としてsingleAを計算
        (出力データ): singleA
        (出力形式): trial_id毎のsingleAのテーブル, 単位はNm
        (パラメータ): なし

    (ステップ) calc_single_B
        (入力データ): rawB
        (処理): rawBからsingleBを計算
        (出力データ): singleB
        (出力形式): trial_id毎のsingleBのテーブル, 単位はなし
        (パラメータ): coefficientK
        (パラメータ): coefficientL

    (ステップ) calc_metric_X
        (入力データ): singleA, singleB
        (処理): singleAとsingleBの積としてmetricXを計算
        (出力データ): metricX
        (出力形式): 定義通り
        (パラメータ): なし

<mermaid>
graph TD
    A[/rawA/] --> B[cut_A]
    B --> |cut_edA| C[calc_single_A]
    D[/rawB/] --> E[calc_single_B]
    C --> |singleA| F[calc_metric_X]
    E --> |singleB| F
    F --> G[/metricX/]
</mermaid>

### Generate ts_metricY

(データ加工) ts_metricY
    (ステップ) "cut_A"

    (ステップ) "calc_single_A"

    (ステップ) "calc_single_B"

    (ステップ) calc_ts_processed_A
        (入力データ): cut_edA, singleA
        (処理): 各時刻においてcut_edAをsingleAで割ってts_processedAを計算
        (出力データ): ts_processedA
        (パラメータ): なし

    (ステップ) calc_ts_metric_Y
        (入力データ): ts_processedA, singleB
        (処理): ts_processedAとsingleBの積としてts_metricYを計算
        (出力データ): ts_metricY
        (出力形式): 定義通り
        (パラメータ): なし

<mermaid>
graph TD
    A[/rawA/] --> B[cut_A]
    B --> |cut_edA| C[calc_single_A]
    D[/rawB/] --> E[calc_single_B]
    B --> |cut_edA| F[calc_ts_processed_A]
    C --> |singleA| F
    F --> |ts_processedA| G[calc_ts_metric_Y]
    E --> |singleB| G
    G --> H[/ts_metricY/]
</mermaid>

## 特殊なデータ形式の記述

### ts_metricYのデータ形式

| time | ts_metricY |
| ---- | ---------- |
| 11   | value1     |
| 12   | value2     |
| ...  | ...        |

* time: 時刻 (sec)
* ts_metricY: metricYの値 (単位なし)

```
