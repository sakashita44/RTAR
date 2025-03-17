# ベースイメージとして設定ファイル(/env/python.json)で指定されたPythonを使用
ARG PYTHON_IMAGE=python:3.12-slim
FROM ${PYTHON_IMAGE}

# 作業ディレクトリの設定
WORKDIR /workspace

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    graphviz \
    libatlas-base-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Python関連パッケージの更新
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /tmp/requirements.txt

# 作業ディレクトリ
WORKDIR /workspace

# コンテナ起動時のコマンド設定
CMD ["/bin/bash"]
