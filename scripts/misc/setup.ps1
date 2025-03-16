# RTARテンプレート自動セットアップスクリプト (Windows用)

# 管理者権限の確認
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "管理者権限でこのスクリプトを実行することを推奨する"
    Start-Sleep -Seconds 2
}

# 前提条件の確認
$prerequisites = @{
    "Docker"  = { docker --version }
    "Git"     = { git --version }
    "VS Code" = { code --version }
}

$missing = @()
foreach ($tool in $prerequisites.Keys) {
    Write-Host "[$tool] の確認中... " -NoNewline
    try {
        Invoke-Command $prerequisites[$tool] | Out-Null
        Write-Host "OK" -ForegroundColor Green
    }
    catch {
        Write-Host "未インストール" -ForegroundColor Red
        $missing += $tool
    }
}

if ($missing.Count -gt 0) {
    Write-Host "`n以下のツールがインストールされていない:" -ForegroundColor Red
    foreach ($tool in $missing) {
        Write-Host " - $tool" -ForegroundColor Red
    }
    Write-Host "`nセットアップを続行するには, これらのツールをインストールする." -ForegroundColor Red
    exit 1
}

# 0. 設定ファイルの確認
Write-Host "`n[1/5] 設定ファイルの確認" -ForegroundColor Cyan

# 必要なファイルの存在確認
$configFiles = @("env/Dockerfile", "env/python.json", "env/requirements.txt", "env/dvc.json")
$missing = $false

foreach ($file in $configFiles) {
    if (-not (Test-Path $file)) {
        Write-Host "$file が見つかりません. リポジトリに問題があります." -ForegroundColor Red
        $missing = $true
    }
}

if ($missing) {
    Write-Host "必要な設定ファイルが不足しています. リポジトリを確認してください." -ForegroundColor Red
    exit 1
}

# 設定ファイル修正の案内
Write-Host "`n設定ファイルの確認と必要に応じた修正を行ってください:" -ForegroundColor Yellow
Write-Host " - env/python.json: Pythonバージョンとイメージの設定" -ForegroundColor Yellow
Write-Host " - env/requirements.txt: 必要なPythonパッケージを設定 (解析途中でも修正可能)" -ForegroundColor Yellow
Write-Host " - env/dvc.json: DVCリモートの設定" -ForegroundColor Yellow

$answer = Read-Host "設定ファイルを確認・修正しましたか? (y/n)"
if ($answer -ne "y" -and $answer -ne "Y") {
    Write-Host "セットアップを中断します. 設定ファイルを確認・修正後, 再度実行してください." -ForegroundColor Yellow
    exit 0
}

# 1. ディレクトリ構造の生成
Write-Host "`n[2/5] ディレクトリ構造を生成" -ForegroundColor Cyan
. .\scripts\misc\gen_structure.ps1

# 2. Dockerコンテナのビルド
Write-Host "`n[3/5] Dockerコンテナをビルド" -ForegroundColor Cyan

# Dockerイメージのビルド
Write-Host "Dockerイメージをビルド中..." -ForegroundColor Yellow
docker build -t rtar-analysis -f env/Dockerfile env/

Write-Host "解析環境に変更が必要になった場合は, env/requirements.txt を編集し" -ForegroundColor Yellow
Write-Host "docker build -t rtar-analysis -f env/Dockerfile env/ を実行することで更新可能です." -ForegroundColor Yellow

# 3. DVC初期化と設定
Write-Host "`n[4/5] DVCを初期化" -ForegroundColor Cyan

# リポジトリが既にGit初期化されているか確認
if (-not (Test-Path ".git")) {
    Write-Host "Gitリポジトリを初期化" -ForegroundColor Yellow
    git init
}

# DVC初期化（Docker内で実行）
Write-Host "DVCリポジトリを初期化" -ForegroundColor Yellow
docker run --rm -v "${PWD}:/workspace" -w /workspace rtar-analysis bash -c "pip install dvc && dvc init && dvc config core.autostage true"

# DVC設定ファイルの読み込み
if (Test-Path "env/dvc.json") {
    $dvcConfig = Get-Content "env/dvc.json" | ConvertFrom-Json
    $remotePath = $dvcConfig.remote.url
    $remoteName = $dvcConfig.remote.name

    # ローカルリモートの設定
    docker run --rm -v "${PWD}:/workspace" -w /workspace rtar-analysis bash -c "pip install dvc && dvc remote add -d $remoteName $remotePath"
}
else {
    Write-Host "DVC設定ファイルが見つかりません. デフォルト設定を使用します." -ForegroundColor Yellow
    docker run --rm -v "${PWD}:/workspace" -w /workspace rtar-analysis bash -c "pip install dvc && dvc remote add -d local_remote ./data/dvc_repo"
}

# 4. VS Code設定
Write-Host "`n[5/5] VS Code設定を確認" -ForegroundColor Cyan

# VS Codeプロファイルの確認
if (Test-Path "env/rtar.code-profile") {
    Write-Host "VS Codeプロファイルをインポート" -ForegroundColor Yellow
    code --profile-import env/rtar.code-profile
}
else {
    Write-Host "VS Codeプロファイルファイルが見つかりません. デフォルト設定を使用します." -ForegroundColor Yellow
}

# .devcontainerの確認
if (-not (Test-Path ".devcontainer")) {
    Write-Host ".devcontainerディレクトリが見つかりません. 作成します." -ForegroundColor Yellow
    New-Item -Path ".devcontainer" -ItemType Directory -Force | Out-Null

    # 最小限のdevcontainer.jsonを作成
    @"
{
    "name": "RTAR Analysis Environment",
    "dockerFile": "../env/Dockerfile",
    "context": "../env",
    "extensions": [
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-toolsai.jupyter",
        "iterative.dvc"
    ],
    "settings": {
        "python.linting.enabled": true,
        "python.formatting.provider": "black"
    },
    "workspaceMount": "source=\${localWorkspaceFolder},target=/workspace,type=bind",
    "workspaceFolder": "/workspace"
}
"@ | Out-File -FilePath ".devcontainer/devcontainer.json" -Encoding utf8
    Write-Host ".devcontainer.jsonを作成しました" -ForegroundColor Yellow
}

# Git属性ファイルの確認と設定
if (-not (Test-Path ".gitattributes")) {
    Write-Host ".gitattributesファイルが見つかりません. 作成します." -ForegroundColor Yellow
    @"
# .gitattributes
# データファイルをDVCで管理
data/**/*.csv filter=dvc
data/**/*.json filter=dvc
data/**/*.c3d filter=dvc
# テキストファイルの改行コードを自動変換
*.md text
*.py text
*.sh text
*.yaml text
*.yml text
"@ | Out-File -FilePath ".gitattributes" -Encoding utf8
    Write-Host ".gitattributesファイルを作成しました" -ForegroundColor Yellow
}

# セットアップ完了メッセージ
Write-Host "`n✅ セットアップが完了!" -ForegroundColor Green
Write-Host "`n次のステップ:" -ForegroundColor Cyan
Write-Host " 1. VS Codeで左下の「><」アイコンをクリック" -ForegroundColor White
Write-Host " 2. 「Reopen in Container」を選択" -ForegroundColor White
Write-Host " 3. Dockerコンテナ内のVS Code環境が起動するのを待つ" -ForegroundColor White
Write-Host "`n詳細なドキュメントは docs/ ディレクトリを参照." -ForegroundColor Cyan
