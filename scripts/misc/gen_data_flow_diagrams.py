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
        return ""

    # ノードとエッジの情報を収集
    nodes = {}  # {node_name: node_type} - 'raw', 'step', 'final'のいずれか
    edges = []  # [(from_node, to_node, label)]

    # 生データノードを追加
    raw_data = data_requirements.get("raw_data", {})
    for raw_name in raw_data:
        nodes[raw_name] = "raw"

    # 最終データを追加
    nodes[data_name] = "final"

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
        for output_name in output_data:
            output_sources[output_name] = step_name

    # データフローの構築
    for output_name, source_step in output_sources.items():
        # この出力データを使用するステップを検索
        consumers = input_consumers.get(output_name, [])

        if output_name == data_name:
            # 最終データへのエッジ
            edges.append((source_step, output_name, output_name))
        elif not consumers:
            # 使用されない中間データは表示しない
            pass
        else:
            # 中間データを使用するステップへのエッジ
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
    for node_name, node_type in nodes.items():
        # 中間データはノードとして表示しない
        if node_type not in ["raw", "step", "final"]:
            continue

        node_id[node_name] = chr(65 + counter % 26) + (
            str(counter // 26) if counter >= 26 else ""
        )
        counter += 1

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

    return "\n".join(mermaid)


def generate_all_mermaid(data_requirements):
    """すべての最終データに対するmermaidダイアグラムを生成する"""
    results = {}
    for data_name in data_requirements.get("required_data", {}):
        mermaid = generate_mermaid_for_data(data_name, data_requirements)
        results[data_name] = mermaid

    return results


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
        output_file = yaml_path.parent / "DATA_FLOW_DIAGRAMS.md"

    # YAMLファイルの読み込み
    try:
        data_requirements = load_yaml(yaml_path)
    except Exception as e:
        print(f"YAMLファイルの読み込みエラー: {e}")
        return 1

    # mermaidダイアグラム生成
    mermaid_diagrams = generate_all_mermaid(data_requirements)

    # 出力（標準出力または別ファイル）
    with output_file.open("w", encoding="utf-8") as f:
        f.write("# データフロー図\n\n")
        for data_name, mermaid in mermaid_diagrams.items():
            f.write(f"## {data_name}\n\n")
            f.write("```mermaid\n")
            f.write(mermaid + "\n")
            f.write("```\n\n")

    print(f"mermaidダイアグラムが生成されました: {output_file}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
