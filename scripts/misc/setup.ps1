<#
.SYNOPSIS
    解析テンプレートの初期セットアップを行うスクリプト
.DESCRIPTION
    Docker を使用して Python 仮想環境を作成し, 必要なライブラリをインストールする
    また, VS Code のプロファイル設定も行う
.NOTES
    前提条件:
    - Docker がインストールされていること
    - Git がインストールされていること
    - VS Code がインストールされていること
#>

# エラーが発生した場合に停止
$ErrorActionPreference = "Stop"

# 現在のディレクトリを取得
$projectRoot = Get-Location

# 前提条件の確認
Write-Host "前提条件の確認を行います..." -ForegroundColor Cyan

# Docker の確認
try {
    docker --version | Out-Null
    Write-Host "✓ Docker が見つかりました" -ForegroundColor Green
}
catch {
    Write-Host "✗ Docker が見つかりません. インストールしてから再実行してください" -ForegroundColor Red
    exit 1
}

# Git の確認
try {
    git --version | Out-Null
    Write-Host "✓ Git が見つかりました" -ForegroundColor Green
}
catch {
    Write-Host "✗ Git が見つかりません. インストールしてから再実行してください" -ForegroundColor Red
    exit 1
}

# VS Code の確認
try {
    code --version | Out-Null
    Write-Host "✓ VS Code が見つかりました" -ForegroundColor Green
}
catch {
    Write-Host "✗ VS Code が見つかりません. インストールしてから再実行してください" -ForegroundColor Red
    exit 1
}

# Docker イメージのビルド
Write-Host "Docker イメージをビルドしています..." -ForegroundColor Cyan

$dockerfilePath = Join-Path -Path $projectRoot -ChildPath "env\Dockerfile"
if (-not (Test-Path $dockerfilePath)) {
    Write-Host "✗ Dockerfile が見つかりません: $dockerfilePath" -ForegroundColor Red
    exit 1
}

docker build -t analysis-template -f $dockerfilePath .
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ Docker イメージのビルドに失敗しました" -ForegroundColor Red
    exit 1
}
Write-Host "✓ Docker イメージのビルドが完了しました" -ForegroundColor Green

# 仮想環境の作成
Write-Host "Python 仮想環境を作成しています..." -ForegroundColor Cyan

# .venv ディレクトリが既に存在する場合は削除
$venvPath = Join-Path -Path $projectRoot -ChildPath ".venv"
if (Test-Path $venvPath) {
    Write-Host "既存の .venv ディレクトリを削除しています..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force $venvPath
}

# Docker コンテナを使用して仮想環境を作成
docker run --rm -v ${projectRoot}:/workspace -w /workspace analysis-template python -m venv .venv
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ 仮想環境の作成に失敗しました" -ForegroundColor Red
    exit 1
}
Write-Host "✓ 仮想環境の作成が完了しました" -ForegroundColor Green

# 必要なライブラリのインストール
Write-Host "必要なライブラリをインストールしています..." -ForegroundColor Cyan

$requirementsPath = Join-Path -Path $projectRoot -ChildPath "env\requirements.txt"
if (-not (Test-Path $requirementsPath)) {
    Write-Host "✗ requirements.txt が見つかりません: $requirementsPath" -ForegroundColor Red
    exit 1
}

# ローカルの仮想環境(venv)を使用してライブラリをインストール
if ($IsWindows) {
    $pipPath = Join-Path -Path $venvPath -ChildPath "Scripts\pip.exe"
    & $pipPath install -r $requirementsPath
}
else {
    # Windows以外の環境用
    $pipPath = Join-Path -Path $venvPath -ChildPath "bin/pip"
    & $pipPath install -r $requirementsPath
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ ライブラリのインストールに失敗しました" -ForegroundColor Red
    exit 1
}
Write-Host "✓ ライブラリのインストールが完了しました" -ForegroundColor Green

# VS Code プロファイルの設定
Write-Host "VS Code プロファイルを設定しています..." -ForegroundColor Cyan

$profilePath = Join-Path -Path $projectRoot -ChildPath "env\analysis.code-profile"
if (-not (Test-Path $profilePath)) {
    Write-Host "✗ VS Code プロファイルが見つかりません: $profilePath" -ForegroundColor Red
    exit 1
}

# VS Codeプロファイルをインポート
Write-Host "VS Code プロファイルをインポートしています..." -ForegroundColor Cyan
try {
    # プロファイルをインポート (VS Codeのバージョンによって異なる可能性あり)
    code --profile "analysis" import $profilePath

    # 必須の拡張機能をインストール
    # (プロファイルでインストールできない場合のフォールバック)
    $extensions = @(
        "ms-python.python",
        "ms-toolsai.jupyter",
        "ms-azuretools.vscode-docker",
        "iterative.dvc"
    )

    foreach ($ext in $extensions) {
        code --install-extension $ext
    }

    Write-Host "✓ VS Code プロファイルの設定が完了しました" -ForegroundColor Green
}
catch {
    Write-Host "! VS Code プロファイルのインポートに問題が発生しました. 拡張機能のみインストールします" -ForegroundColor Yellow

    # 必須の拡張機能をインストール
    $extensions = @(
        "ms-python.python",
        "ms-toolsai.jupyter",
        "ms-azuretools.vscode-docker",
        "iterative.dvc"
    )

    foreach ($ext in $extensions) {
        code --install-extension $ext
    }

    Write-Host "✓ VS Code 拡張機能のインストールが完了しました" -ForegroundColor Green
}

# DVC リモート設定
Write-Host "DVC リモートを設定しています..." -ForegroundColor Cyan

# DVC のインストール確認
try {
    dvc --version | Out-Null
    Write-Host "✓ DVC が見つかりました" -ForegroundColor Green
}
catch {
    Write-Host "! DVC が見つかりません。仮想環境を有効化してインストールすることをお勧めします" -ForegroundColor Yellow
    Write-Host "  .venv\Scripts\Activate.ps1 を実行後、pip install dvc でインストールできます" -ForegroundColor Yellow
}

# DVC リモートディレクトリの作成
$dvcRepoPath = Join-Path -Path $projectRoot -ChildPath "data\dvc_repo"
if (-not (Test-Path $dvcRepoPath)) {
    New-Item -Path $dvcRepoPath -ItemType Directory -Force | Out-Null
    Write-Host "✓ DVCリモート用ディレクトリを作成しました: $dvcRepoPath" -ForegroundColor Green
}
else {
    Write-Host "✓ DVCリモート用ディレクトリが既に存在します: $dvcRepoPath" -ForegroundColor Green
}

# DVC リモート設定
try {
    dvc remote add -d local $dvcRepoPath
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ DVCリモートを設定しました: $dvcRepoPath" -ForegroundColor Green
    }
    else {
        Write-Host "! DVCリモートの設定に失敗しました。後で手動で設定してください" -ForegroundColor Yellow
        Write-Host "  使用コマンド: dvc remote add -d local $dvcRepoPath" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "! DVCリモートの設定に失敗しました。後で手動で設定してください" -ForegroundColor Yellow
    Write-Host "  使用コマンド: dvc remote add -d local $dvcRepoPath" -ForegroundColor Yellow
}

Write-Host "`nセットアップが完了しました！" -ForegroundColor Cyan
Write-Host "仮想環境を有効化するには以下のコマンドを実行してください:" -ForegroundColor Yellow
if ($IsWindows) {
    Write-Host ".venv\Scripts\Activate.ps1" -ForegroundColor White
}
else {
    Write-Host "source .venv/bin/activate" -ForegroundColor White
}

Write-Host "`n使用方法の詳細については docs/Usage.md を参照してください" -ForegroundColor Yellow
