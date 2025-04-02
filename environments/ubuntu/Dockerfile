FROM ubuntu:latest

# 共通パッケージのインストール
RUN apt-get update && apt-get install -y \
    sudo \
    software-properties-common \
    curl \
    wget \
    ca-certificates \
    unzip \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Gitの最新版をインストール
RUN add-apt-repository ppa:git-core/ppa -y \
    && apt-get update \
    && apt-get install -y git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Neovim (最新安定版)
RUN apt-get update && apt-get install -y \
    ninja-build \
    gettext \
    cmake \
    && git clone https://github.com/neovim/neovim.git \
    && cd neovim \
    && git checkout stable \
    && make CMAKE_BUILD_TYPE=Release \
    && make install \
    && cd .. \
    && rm -rf neovim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# tmux 3.5
RUN apt-get update && apt-get install -y \
    automake \
    pkg-config \
    libevent-dev \
    libncurses-dev \
    bison \
    byacc \
    && git clone https://github.com/tmux/tmux.git \
    && cd tmux \
    && git checkout 3.5 \
    && sh autogen.sh \
    && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -rf tmux \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Lazygit (最新安定版)
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') \
    && curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" \
    && tar xf lazygit.tar.gz lazygit \
    && install lazygit /usr/local/bin/ \
    && rm -f lazygit lazygit.tar.gz

# Oh-my-bash (ユーザー環境用)
RUN apt-get update && apt-get install -y \
    bash \
    && mkdir -p /etc/skel/.oh-my-bash \
    && git clone https://github.com/ohmybash/oh-my-bash.git /etc/skel/.oh-my-bash \
    && cp /etc/skel/.oh-my-bash/templates/bashrc.osh-template /etc/skel/.bashrc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Node.js (LTS)
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Bun (最新安定版)
RUN curl -fsSL https://bun.sh/install | bash \
    && mkdir -p /usr/local/bun \
    && cp -r /root/.bun/* /usr/local/bun/ \
    && ln -sf /usr/local/bun/bin/bun /usr/local/bin/bun \
    && chmod -R 755 /usr/local/bun

# 作業ディレクトリとエントリーポイント設定
RUN mkdir -p /workspace && chmod 777 /workspace
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
