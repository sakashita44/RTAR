# How to install

## メモ

* 前提: Docker, Git, VS Code がローカルにインストールされていること
* まずリポジトリをクローンする
* Docker内にインストールされているPythonを使用して，ローカル環境に.venvを作成する
* venvのpipを使用して，必要なライブラリをインストールする (requirements.txt)
* env/analysis.code-profileを使用してVS Codeのprofileを設定する
    * ワークスペース設定はリポジトリクローン時に自動で設定される (.vscode/settings.jsonが作成される)

* 完全に前提条件を満たした環境であれば，installスクリプトから一括でセットアップが可能
* その他の環境でのセットアップは，installスクリプトを参考に手動で行う
