#### python
# filepath: tests/test_validate_data_dependencies.py
import pytest
from pathlib import Path
from scripts.misc.gen_data_flow.validate_data_dependencies import (
    load_yaml,
    validate_data_dependencies,
)

@pytest.mark.parametrize("test_file, expected_errors, expected_warnings", [
    ("tests/data_specifications/test_data_dependencies_normal.yml", 0, 0),
    # ("tests/data_specifications/test_data_dependencies_case1.yml", 1, 0),
    # ("tests/data_specifications/test_data_dependencies_case2.yml", 1, 1),
])
def test_validate_data_dependencies(test_file, expected_errors, expected_warnings):
    data_dependencies = load_yaml(Path(test_file))
    errors, warnings = validate_data_dependencies(data_dependencies)
    assert len(errors) == expected_errors
    assert len(warnings) == expected_warnings
