#!/usr/bin/env python
# -*- coding: utf-8 -*-

import yaml
import sys
from pathlib import Path


def load_yaml(filepath):
    """YAMLファイルを読み込む"""
    with open(filepath, "r", encoding="utf-8") as file:
        return yaml.safe_load(file)


def generate_mermaid_for_data(data_name, data_requirements):
    """特定の最終データに対するmermaidダイアグラムを生成する"""
    processing = data_requirements.get("processing", {}).get(data_name, {})
    if not processing:
        print(f"Warning: '{data_name}'の処理情報が見つかりません")
        return "", []

    # ノードとエッジの情報を収集
    nodes = {}  # {node_name: node_type} - 'raw', 'step', 'final'のいずれか
    edges = []  # [(from_node, to_node, label)]
    node_details = {}  # {node_name: {type: タイプ, description: 説明, ...}}

    # 生データノードを追加
    raw_data = data_requirements.get("raw_data", {})
    for raw_name, raw_info in raw_data.items():
        nodes[raw_name] = "raw"
        node_details[raw_name] = {
            "type": "生データ",
            "description": raw_info.get("description", ""),
            "format": raw_info.get("format", ""),
            "unit": raw_info.get("unit", ""),
        }

    # 最終データを追加
    required_data = data_requirements.get("required_data", {})
    nodes[data_name] = "final"
    node_details[data_name] = {
        "type": "最終データ",
        "description": required_data.get(data_name, {}).get("description", ""),
        "format": required_data.get(data_name, {}).get("output_format", ""),
        "unit": required_data.get(data_name, {}).get("unit", ""),
        "formula": required_data.get(data_name, {}).get("formula", ""),
    }

    # ステップとデータの収集
    steps_info = {}  # ステップ情報を保持
    output_sources = {}  # 各データの生成元ステップ {data_name: step_name}
    input_consumers = {}  # 各データの使用先ステップのリスト {data_name: [step_name]}

    # データ間の関係を構築
    steps = processing.get("steps", [])
    for step_idx, step in enumerate(steps):
        # ステップが文字列（再利用）の場合の処理
        if isinstance(step, str):
            step_name = step
            # 再利用ステップの詳細情報を検索
            for other_data_name, other_processing in data_requirements.get(
                "processing", {}
            ).items():
                for other_step in other_processing.get("steps", []):
                    if (
                        isinstance(other_step, dict)
                        and other_step.get("name") == step_name
                    ):
                        step = other_step
                        break
        else:
            step_name = step.get("name")

        # ステップ情報を保存
        steps_info[step_name] = step
        nodes[step_name] = "step"

        # ステップの詳細情報を保存
        process_info = step.get("process", [])
        process_desc = "\n".join(process_info) if process_info else ""

        parameters = step.get("parameters", {})
        param_desc = ""
        if isinstance(parameters, list):
            # リスト形式のパラメータ処理
            for param in parameters:
                if isinstance(param, dict):
                    name = param.get("name", "")
                    value = param.get("value", "")
                    unit = param.get("unit", "")
                    param_desc += f"{name}: {value} {unit}\n"
        else:
            # 辞書形式のパラメータ処理
            for param_name, param_info in parameters.items():
                value = param_info.get("value", "")
                unit = param_info.get("unit", "")
                param_desc += f"{param_name}: {value} {unit}\n"

        node_details[step_name] = {
            "type": "処理ステップ",
            "description": process_desc,
            "parameters": param_desc.strip(),
        }

        # 入力データの処理
        input_data = step.get("input_data", [])
        if isinstance(input_data, str):
            input_data = [input_data]

        for input_name in input_data:
            if input_name not in input_consumers:
                input_consumers[input_name] = []
            input_consumers[input_name].append(step_name)

        # 出力データの処理
        output_data = step.get("output_data", {})
        for output_name, output_info in output_data.items():
            output_sources[output_name] = step_name

            # 中間出力データの情報も保存
            if output_name != data_name:
                node_details[output_name] = {
                    "type": "中間データ",
                    "description": output_info.get("description", ""),
                    "format": output_info.get("format", ""),
                    "unit": output_info.get("unit", ""),
                }

    # データフローの構築
    for output_name, source_step in output_sources.items():
        consumers = input_consumers.get(output_name, [])

        # 使用される/最終データ問わず表示する
        if not consumers:
            # 中間データでも使われなくてもノードを残したい場合はこちらでエッジを省略するだけ
            # pass
            edges.append((source_step, output_name, output_name))
        else:
            for consumer_step in consumers:
                edges.append((source_step, consumer_step, output_name))

    # 生データからのエッジを追加
    for raw_name in raw_data:
        if raw_name in input_consumers:
            for consumer_step in input_consumers[raw_name]:
                edges.append((raw_name, consumer_step, ""))

    # mermaidダイアグラムの生成
    mermaid = ["graph TD"]

    # ノードの追加（ステップ、生データ、最終データのみ）
    node_id = {}
    counter = 0
    visible_nodes = []

    for node_name, node_type in nodes.items():
        # 中間データはノードとして表示しない
        if node_type not in ["raw", "step", "final"]:
            continue

        node_id[node_name] = chr(65 + counter % 26) + (
            str(counter // 26) if counter >= 26 else ""
        )
        counter += 1
        visible_nodes.append(node_name)

        if node_type == "raw":
            mermaid.append(f"    {node_id[node_name]}[/{node_name}/]")
        elif node_type == "step":
            mermaid.append(f"    {node_id[node_name]}[{node_name}]")
        elif node_type == "final":
            mermaid.append(f"    {node_id[node_name]}[/{node_name}/]")

    # エッジの追加
    for src, dst, label in edges:
        if src in node_id and dst in node_id:
            edge = f"    {node_id[src]} --> "
            if label:
                edge += f"|{label}| "
            edge += f"{node_id[dst]}"
            mermaid.append(edge)

    # ノード説明表の作成
    node_details_list = []
    for node_name in visible_nodes:
        if node_name in node_details:
            details = node_details[node_name]
            node_id_str = node_id.get(node_name, "")

            # ノードタイプに応じた詳細情報を表に追加
            if (
                details["type"] == "生データ"
                or details["type"] == "最終データ"
                or details["type"] == "中間データ"
            ):
                node_details_list.append(
                    {
                        "id": node_id_str,
                        "name": node_name,
                        "type": details["type"],
                        "description": details["description"],
                        "format": details["format"],
                        "unit": details["unit"],
                        "formula": details.get("formula", ""),
                    }
                )
            elif details["type"] == "処理ステップ":
                node_details_list.append(
                    {
                        "id": node_id_str,
                        "name": node_name,
                        "type": details["type"],
                        "description": details["description"],
                        "parameters": details["parameters"],
                        "format": "",
                        "unit": "",
                        "formula": "",
                    }
                )

    return "\n".join(mermaid), node_details_list


def generate_all_mermaid(data_requirements):
    """すべての最終データに対するmermaidダイアグラムを生成する"""
    results = {}
    details_results = {}

    for data_name in data_requirements.get("required_data", {}):
        mermaid, details = generate_mermaid_for_data(data_name, data_requirements)
        results[data_name] = mermaid
        details_results[data_name] = details

    return results, details_results


def main():
    """メイン処理"""
    # コマンドライン引数からYAMLファイルパスと出力ファイルパスを取得
    if len(sys.argv) > 1:
        yaml_path = Path(sys.argv[1])
    else:
        # デフォルトパス
        yaml_path = Path("info/data_requirements.yml")

    if len(sys.argv) > 2:
        output_file = Path(sys.argv[2])
    else:
        # デフォルト出力ファイルパス
        output_file = yaml_path.parent / "auto_generated/DATA_FLOW_DIAGRAMS.md"

    # YAMLファイルの読み込み
    try:
        data_requirements = load_yaml(yaml_path)
    except Exception as e:
        print(f"YAMLファイルの読み込みエラー: {e}")
        return 1

    # mermaidダイアグラム生成
    mermaid_diagrams, node_details = generate_all_mermaid(data_requirements)

    # 出力（標準出力または別ファイル）
    with output_file.open("w", encoding="utf-8") as f:
        f.write("# 詳細なデータフロー図\n\n")
        for data_name, mermaid in mermaid_diagrams.items():
            f.write(f"## {data_name}\n\n")
            f.write("### フロー図\n\n")
            f.write("```mermaid\n")
            f.write(mermaid + "\n")
            f.write("```\n\n")

            # ノード詳細テーブルの追加
            f.write("### ノード詳細\n\n")

            # 生データノードのテーブル
            f.write("#### 生データ\n\n")
            f.write("| ID | 名前 | 説明 | 形式 | 単位 |\n")
            f.write("|-----|-----|-----|-----|-----|\n")

            raw_nodes = [n for n in node_details[data_name] if n["type"] == "生データ"]
            if raw_nodes:
                for node in raw_nodes:
                    f.write(
                        f"| {node['id']} | {node['name']} | {node['description']} | {node['format']} | {node['unit']} |\n"
                    )
            else:
                f.write("| - | - | - | - | - |\n")

            f.write("\n")

            # 処理ステップノードのテーブル
            f.write("#### 処理ステップ\n\n")
            f.write("| ID | 名前 | 処理内容 | パラメータ |\n")
            f.write("|-----|-----|-----|-----|\n")

            step_nodes = [
                n for n in node_details[data_name] if n["type"] == "処理ステップ"
            ]
            if step_nodes:
                for node in step_nodes:
                    # 改行をHTML形式に変換
                    desc = node["description"].replace("\n", "<br>")
                    params = node["parameters"].replace("\n", "<br>")
                    f.write(f"| {node['id']} | {node['name']} | {desc} | {params} |\n")
            else:
                f.write("| - | - | - | - |\n")

            f.write("\n")

            # 中間データノードのテーブル
            f.write("#### 中間データ\n\n")
            f.write("| 名前 | 説明 | 形式 | 単位 |\n")
            f.write("|-----|-----|-----|-----|\n")

            # 修正: 現在のデータに関連する中間データを取得
            intermediate_nodes = []
            for node in node_details[data_name]:
                if node["type"] == "中間データ":
                    intermediate_nodes.append(
                        {
                            "name": node["name"],
                            "description": node.get("description", ""),
                            "format": node.get("format", ""),
                            "unit": node.get("unit", ""),
                        }
                    )

            if intermediate_nodes:
                for node in intermediate_nodes:
                    f.write(
                        f"| {node['name']} | {node['description']} | {node['format']} | {node['unit']} |\n"
                    )
            else:
                f.write("| - | - | - | - |\n")

            f.write("\n")

            # 最終データノードのテーブル
            f.write("#### 最終データ\n\n")
            f.write("| ID | 名前 | 説明 | 形式 | 単位 | 計算式 |\n")
            f.write("|-----|-----|-----|-----|-----|-----|\n")

            final_nodes = [
                n for n in node_details[data_name] if n["type"] == "最終データ"
            ]
            if final_nodes:
                for node in final_nodes:
                    f.write(
                        f"| {node['id']} | {node['name']} | {node['description']} | {node['format']} | {node['unit']} | {node['formula']} |\n"
                    )
            else:
                f.write("| - | - | - | - | - | - |\n")

            f.write("\n")

    print(f"詳細なデータフロー図が生成されました: {output_file}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
