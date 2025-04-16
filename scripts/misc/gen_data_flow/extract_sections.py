import sys
import yaml
from pathlib import Path

def load_yaml(filepath):
    """YAMLファイルを読み込む"""
    with open(filepath, "r", encoding="utf-8") as file:
        return yaml.safe_load(file)

def extract_sections(data_dependencies_path):
    """data_dependencies.ymlから必要なセクションを取得"""
    data_dependencies = load_yaml(data_dependencies_path)

    # 各セクションを取得
    metadata = data_dependencies.get("metadata", {})
    target = data_dependencies.get("target", [])
    data_nodes = data_dependencies.get("data", {})
    parameters = data_dependencies.get("parameter", {})

    return {
        "metadata": metadata,
        "target": target,
        "data": data_nodes,
        "parameter": parameters
    }

# 規定形式のYAMLファイルからセクションをPythonオブジェクトとして取得する関数
def get_sections_as_object(filepath):
    """指定されたYAMLファイルからセクションをPythonオブジェクトとして返す"""
    path = Path(filepath)
    if not path.exists():
        raise FileNotFoundError(f"File not found: {filepath}")
    return extract_sections(filepath)

if __name__ == "__main__":
    try:
        # コマンドライン引数からファイルパスを取得
        if len(sys.argv) != 2:
            print("Usage: python extract_sections.py <data_dependencies.yml>")
            sys.exit(1)

        data_dependencies_path = sys.argv[1]
        sections = get_sections_as_object(data_dependencies_path)

        # セクションを表示
        for section_name, section_data in sections.items():
            print(f"{section_name}: {section_data}")
    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Error parsing YAML file: {e}")
        sys.exit(1)
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
        sys.exit(1)
