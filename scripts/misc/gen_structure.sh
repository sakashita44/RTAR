#!/bin/bash
# filepath: scripts/misc/gen_structure.sh
# RTARテンプレート ディレクトリ構造生成スクリプト (Linux/Mac用)

# 色の定義
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 作成するディレクトリ一覧
directories=(
    "data/raw"
    "data/processed"
    "data/analysis"
    "data/dvc_repo"
    "exploratory/preprocessing"
    "exploratory/analysis"
    "reports/notebooks"
    "reports/common"
    "scripts/preprocessing"
    "scripts/analysis"
    "scripts/common"
    "scripts/interface"
    "scripts/misc"
    "params"
    "info/dag_images"
    "dvc_stages"
)

echo -e "${CYAN}ディレクトリ構造を生成...${NC}"

# ディレクトリ作成
for dir in "${directories[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        echo -e " + ${GREEN}$dir${NC}"
    else
        echo -e " - ${YELLOW}$dir${NC} (既に存在)"
    fi
done

# パラメータファイルのテンプレート作成
declare -A paramFiles
paramFiles["params/preprocessing.yaml"]="# 前処理パラメータ\n# ここに前処理で使用するパラメータを定義"
paramFiles["params/analysis.yaml"]="# 解析パラメータ\n# ここに解析で使用するパラメータを定義"

for file in "${!paramFiles[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${paramFiles[$file]}" > "$file"
        echo -e " + ${GREEN}$file${NC}"
    else
        echo -e " - ${YELLOW}$file${NC} (既に存在)"
    fi
done

# 情報ファイルのテンプレート作成
declare -A infoFiles
infoFiles["info/PROCESS_OVERVIEW.md"]="# 処理経路概要\n\nこのドキュメントでは, データ処理のフローと手順を記録する.\n\n## 処理フロー\n\n\`\`\`mermaid\ngraph TD\n  A[生データ] --> B[前処理]\n  B --> C[解析]\n  C --> D[出力]\n\`\`\`"
infoFiles["info/VERSION_MAPPING.md"]="# バージョン対応表\n\nこのドキュメントでは, コードとデータのバージョン対応を記録する.\n\n| バージョン | 日付 | 説明 | コミット | データハッシュ |\n|----------|------|------|---------|------------|\n| v0.1.0   | YYYY-MM-DD | 初期設定 | - | - |"

for file in "${!infoFiles[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${infoFiles[$file]}" > "$file"
        echo -e " + ${GREEN}$file${NC}"
    else
        echo -e " - ${YELLOW}$file${NC} (既に存在)"
    fi
done

# サンプルデータの作成
sample_data_dir="data/raw/sample"
if [ ! -d "$sample_data_dir" ]; then
    mkdir -p "$sample_data_dir"

    # サンプルCSVデータの作成
    cat > "$sample_data_dir/data.csv" << EOF
id,name,value
1,item1,10.5
2,item2,20.3
3,item3,15.7
4,item4,30.1
5,item5,25.9
EOF
    echo -e " + ${GREEN}$sample_data_dir/data.csv${NC} (サンプルデータ)"
fi

# DVCの設定ファイルを作成
if [ ! -f "env/dvc.json" ]; then
    cat > "env/dvc.json" << EOF
{
    "remotePath": "./data/dvc_repo",
    "autoStage": true
}
EOF
    echo -e " + ${GREEN}env/dvc.json${NC}"
fi

# 作成した構造を表示
echo -e "\n${GREEN}基本的なディレクトリ構造を生成しました.${NC}"
