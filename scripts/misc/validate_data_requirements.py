#!/usr/bin/env python
# -*- coding: utf-8 -*-

import yaml
import sys
import os
from typing import Dict, List, Any, Set, Tuple


class YamlValidator:
    """data_requirements.yml の検証クラス"""

    def __init__(self, yaml_path: str):
        """初期化

        Args:
            yaml_path: 検証するYAMLファイルのパス
        """
        self.yaml_path = yaml_path
        self.yaml_data = None
        self.errors = []
        self.warnings = []

        # 収集したデータ名のセット
        self.all_data_names = set()
        self.raw_data_names = set()
        self.required_data_names = set()
        self.step_names = set()
        self.output_data_names = set()

    def load_yaml(self) -> bool:
        """YAMLファイルの読み込み

        Returns:
            bool: 読み込み成功したかどうか
        """
        try:
            with open(self.yaml_path, "r", encoding="utf-8") as file:
                self.yaml_data = yaml.safe_load(file)
            return True
        except Exception as e:
            self.errors.append(f"YAMLファイルの読み込みエラー: {str(e)}")
            return False

    def validate(self) -> bool:
        """YAMLデータの検証

        Returns:
            bool: 検証に成功したかどうか
        """
        if not self.load_yaml():
            return False

        # 必須セクションのチェック
        if not self._check_required_sections():
            return False

        # データ名の収集
        self._collect_data_names()

        # データ名の重複チェック
        self._check_duplicate_names()

        # 参照整合性のチェック
        self._check_reference_integrity()

        # 必須プロパティのチェック
        self._check_required_properties()

        return len(self.errors) == 0

    def _check_required_sections(self) -> bool:
        """必須セクションの存在確認

        Returns:
            bool: 必須セクションが存在するかどうか
        """
        required_sections = ["required_data", "raw_data", "processing"]
        for section in required_sections:
            if section not in self.yaml_data:
                self.errors.append(f"必須セクション '{section}' がありません")
                return False

        return True

    def _collect_data_names(self) -> None:
        """すべてのデータ名を収集"""
        # 最終データ名を収集
        for name in self.yaml_data.get("required_data", {}):
            self.required_data_names.add(name)
            self.all_data_names.add(name)

        # 生データ名を収集
        for name in self.yaml_data.get("raw_data", {}):
            self.raw_data_names.add(name)
            self.all_data_names.add(name)

        # 処理ステップ名と出力データ名を収集
        for data_name, processing in self.yaml_data.get("processing", {}).items():
            for step in processing.get("steps", []):
                if isinstance(step, str):
                    # ステップ名のみの場合
                    self.step_names.add(step)
                    self.all_data_names.add(step)
                elif isinstance(step, dict) and "name" in step:
                    # ステップの詳細が記述されている場合
                    step_name = step["name"]
                    self.step_names.add(step_name)
                    self.all_data_names.add(step_name)

                    # 出力データ名を収集
                    for output_name in step.get("output_data", {}):
                        self.output_data_names.add(output_name)
                        self.all_data_names.add(output_name)

    def _check_duplicate_names(self) -> None:
        """データ名の重複チェック"""
        # 各カテゴリ内での重複をチェック
        self._check_duplicates_in_set(self.required_data_names, "最終データ")
        self._check_duplicates_in_set(self.raw_data_names, "生データ")
        self._check_duplicates_in_set(self.step_names, "ステップ")

        # カテゴリ間での重複をチェック
        self._check_overlap(
            self.required_data_names, self.raw_data_names, "最終データ", "生データ"
        )
        self._check_overlap(
            self.required_data_names, self.step_names, "最終データ", "ステップ"
        )
        self._check_overlap(
            self.raw_data_names, self.step_names, "生データ", "ステップ"
        )

    def _check_duplicates_in_set(self, name_set: Set[str], category: str) -> None:
        """セット内での重複チェック"""
        seen = set()
        for name in name_set:
            if name in seen:
                self.errors.append(f"{category}名 '{name}' が重複しています")
            seen.add(name)

    def _check_overlap(
        self, set1: Set[str], set2: Set[str], cat1: str, cat2: str
    ) -> None:
        """2つのセット間での重複チェック"""
        overlap = set1.intersection(set2)
        for name in overlap:
            self.errors.append(
                f"{cat1}名 '{name}' と {cat2}名 '{name}' が重複しています"
            )

    def _check_reference_integrity(self) -> None:
        """参照整合性のチェック"""
        # 最終データの入力データ参照チェック
        for name, data in self.yaml_data.get("required_data", {}).items():
            input_data = data.get("input_data", [])
            if isinstance(input_data, str):
                input_data = [input_data]

            for input_name in input_data:
                if input_name not in self.all_data_names:
                    self.errors.append(
                        f"最終データ '{name}' が存在しない入力データ '{input_name}' を参照しています"
                    )

        # 処理ステップの入力データ参照チェック
        for data_name, processing in self.yaml_data.get("processing", {}).items():
            # まず、最終データ名の存在確認
            if data_name not in self.required_data_names:
                self.errors.append(
                    f"処理 '{data_name}' で指定された最終データが存在しません"
                )

            for step in processing.get("steps", []):
                if isinstance(step, str):
                    # ステップ名のみの場合、他の処理で定義されているか確認
                    step_name = step
                    step_found = False

                    for other_data_name, other_processing in self.yaml_data.get(
                        "processing", {}
                    ).items():
                        for other_step in other_processing.get("steps", []):
                            if (
                                isinstance(other_step, dict)
                                and other_step.get("name") == step_name
                            ):
                                step_found = True
                                break

                    if not step_found:
                        self.errors.append(
                            f"処理 '{data_name}' が存在しないステップ '{step_name}' を参照しています"
                        )

                elif isinstance(step, dict) and "name" in step:
                    # ステップの詳細が記述されている場合
                    step_name = step["name"]
                    input_data = step.get("input_data", [])

                    if isinstance(input_data, str):
                        input_data = [input_data]

                    for input_name in input_data:
                        if input_name not in self.all_data_names:
                            self.errors.append(
                                f"ステップ '{step_name}' が存在しない入力データ '{input_name}' を参照しています"
                            )

    def _check_required_properties(self) -> None:
        """必須プロパティのチェック"""
        # 最終データの必須プロパティ
        for name, data in self.yaml_data.get("required_data", {}).items():
            if "input_data" not in data:
                self.errors.append(
                    f"最終データ '{name}' に必須プロパティ 'input_data' がありません"
                )

        # 処理ステップの必須プロパティ
        for data_name, processing in self.yaml_data.get("processing", {}).items():
            for step in processing.get("steps", []):
                if isinstance(step, dict):
                    if "name" not in step:
                        self.errors.append(
                            f"処理 '{data_name}' のステップに必須プロパティ 'name' がありません"
                        )
                        continue

                    step_name = step["name"]

                    if "input_data" not in step:
                        self.errors.append(
                            f"ステップ '{step_name}' に必須プロパティ 'input_data' がありません"
                        )

                    if "output_data" not in step:
                        self.errors.append(
                            f"ステップ '{step_name}' に必須プロパティ 'output_data' がありません"
                        )

    def print_results(self) -> None:
        """検証結果の表示"""
        if self.errors:
            print("エラー:")
            for error in self.errors:
                print(f"  - {error}")

        if self.warnings:
            print("\n警告:")
            for warning in self.warnings:
                print(f"  - {warning}")

        if not self.errors and not self.warnings:
            print("検証に成功しました。問題は見つかりませんでした。")
        elif not self.errors:
            print("\n警告はありますが、重大な問題は見つかりませんでした。")


def main():
    """メイン処理"""
    # コマンドライン引数からYAMLファイルパスを取得
    if len(sys.argv) > 1:
        yaml_path = sys.argv[1]
    else:
        # デフォルトパス
        yaml_path = "info/data_requirements.yml"

    # ファイルの存在確認
    if not os.path.exists(yaml_path):
        print(f"エラー: ファイル '{yaml_path}' が見つかりません。")
        return 1

    # バリデーション実行
    validator = YamlValidator(yaml_path)
    is_valid = validator.validate()
    validator.print_results()

    return 0 if is_valid else 1


if __name__ == "__main__":
    sys.exit(main())
