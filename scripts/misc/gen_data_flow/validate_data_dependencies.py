import yaml
import sys
from pathlib import Path

def load_yaml(filepath):
    """YAMLファイルを読み込む"""
    with open(filepath, "r", encoding="utf-8") as file:
        return yaml.safe_load(file)

def validate_sections_exist(data_dependencies, required_sections):
    """必須セクションが存在するか確認"""
    errors = []
    for section in required_sections:
        if section not in data_dependencies:
            errors.append(f"セクション '{section}' が存在しません")
    return errors

def validate_target_in_data(target, data):
    """targetで指定されたデータがdataセクションに存在するか確認"""
    errors = []
    for target_item in target:
        if target_item not in data:
            errors.append(f"target '{target_item}' がdataセクションに存在しません")
    return errors

def validate_required_data(data):
    """required_dataで指定されたデータがdataセクションに存在するか確認"""
    errors = []
    for data_name, data_details in data.items():
        for required_data in data_details.get("required_data", []):
            if required_data not in data:
                errors.append(f"data '{data_name}' のrequired_data '{required_data}' がdataセクションに存在しません")
    return errors

def validate_required_parameters(data, parameters):
    """required_parameterで指定されたパラメータがparameterセクションに存在するか確認"""
    errors = []
    for data_name, data_details in data.items():
        for required_param in data_details.get("required_parameter", []):
            if required_param not in parameters:
                errors.append(f"data '{data_name}' のrequired_parameter '{required_param}' がparameterセクションに存在しません")
    return errors

def validate_unique_names(data, parameters):
    """データ名とパラメータ名が重複していないか確認"""
    errors = []
    data_names = set(data.keys())
    param_names = set(parameters.keys())
    overlap = data_names & param_names
    if overlap:
        errors.append(f"データ名とパラメータ名が重複しています: {', '.join(overlap)}")
    return errors

def validate_required_fields(data, parameters):
    """必須項目が存在するか確認"""
    warnings = []

    # データの必須項目
    for data_name, data_details in data.items():
        for field in ["description", "format", "unit"]:
            if field not in data_details:
                warnings.append(f"data '{data_name}' に必須項目 '{field}' が存在しません")

    # パラメータの必須項目
    for param_name, param_details in parameters.items():
        for field in ["description", "format", "unit", "value"]:
            if field not in param_details:
                warnings.append(f"parameter '{param_name}' に必須項目 '{field}' が存在しません")

    return warnings

def validate_data_dependencies(data_dependencies):
    """data_dependencies.ymlのバリデーションを実行"""
    errors = []
    warnings = []

    # 必須セクションの確認
    required_sections = ["metadata", "target", "data", "parameter"]
    errors.extend(validate_sections_exist(data_dependencies, required_sections))

    if "data" in data_dependencies and "parameter" in data_dependencies:
        data = data_dependencies["data"]
        parameters = data_dependencies["parameter"]
        target = data_dependencies.get("target", [])

        # targetのデータがdataに存在するか確認
        errors.extend(validate_target_in_data(target, data))

        # required_dataの確認
        errors.extend(validate_required_data(data))

        # required_parameterの確認
        errors.extend(validate_required_parameters(data, parameters))

        # データ名とパラメータ名の重複確認
        errors.extend(validate_unique_names(data, parameters))

        # 必須項目の確認
        warnings.extend(validate_required_fields(data, parameters))

    return errors, warnings

def main():
    if len(sys.argv) < 2:
        print("Usage: python validate_data_dependencies.py <data_dependencies_path>")
        sys.exit(1)

    data_dependencies_path = Path(sys.argv[1])
    if not data_dependencies_path.exists():
        print(f"Error: File not found - {data_dependencies_path}")
        sys.exit(1)

    data_dependencies = load_yaml(data_dependencies_path)
    errors, warnings = validate_data_dependencies(data_dependencies)

    if errors:
        print("Errors:")
        for error in errors:
            print(f"- {error}")
    else:
        print("No errors found.")

    if warnings:
        print("\nWarnings:")
        for warning in warnings:
            print(f"- {warning}")
    else:
        print("No warnings found.")

if __name__ == "__main__":
    main()
