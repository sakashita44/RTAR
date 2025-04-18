# RTARテンプレート ディレクトリ構造生成スクリプト (Windows用)

# 作成するディレクトリ一覧
$directories = @(
    "data/raw",
    "data/processed",
    "data/analysis",
    "data/dvc_repo",
    "exploratory/preprocessing",
    "exploratory/analysis",
    "reports/notebooks",
    "reports/common",
    "scripts/preprocessing",
    "scripts/analysis",
    "scripts/common",
    "scripts/interface",
    "scripts/misc",
    "params",
    "info/dag_images",
    "dvc_stages"
)

Write-Host "ディレクトリ構造を生成..." -ForegroundColor Cyan

# ディレクトリ作成
foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
        Write-Host " + $dir" -ForegroundColor Green
    }
    else {
        Write-Host " - $dir (既に存在)" -ForegroundColor Yellow
    }
}

# パラメータファイルのテンプレート作成
$paramFiles = @{
    "params/preprocessing.yaml" = "# 前処理パラメータ`n# ここに前処理で使用するパラメータを定義"
    "params/analysis.yaml"      = "# 解析パラメータ`n# ここに解析で使用するパラメータを定義"
}

foreach ($file in $paramFiles.Keys) {
    if (-not (Test-Path $file)) {
        $paramFiles[$file] | Out-File -FilePath $file -Encoding utf8
        Write-Host " + $file" -ForegroundColor Green
    }
    else {
        Write-Host " - $file (既に存在)" -ForegroundColor Yellow
    }
}

foreach ($file in $infoFiles.Keys) {
    if (-not (Test-Path $file)) {
        $infoFiles[$file] | Out-File -FilePath $file -Encoding utf8
        Write-Host " + $file" -ForegroundColor Green
    }
    else {
        Write-Host " - $file (既に存在)" -ForegroundColor Yellow
    }
}

# DVCの設定ファイルを作成
if (-not (Test-Path "env/dvc.json")) {
    @"
    {
        "remotePath": "./data/dvc_repo",
        "autoStage": true
    }
"@ | Out-File -FilePath "env/dvc.json" -Encoding utf8
    Write-Host " + env/dvc.json" -ForegroundColor Green
}

# 作成した構造を表示
Write-Host "`n基本的なディレクトリ構造を生成しました." -ForegroundColor Green
