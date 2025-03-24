FROM ubuntu:22.04

# ========================
# ビルド時引数（オプション）
# ========================
ARG UID=1000
ARG GID=1000
ARG USERNAME=myuser
ARG PASSWORD=password
ARG GIT_USERNAME
ARG GIT_EMAIL
ARG DOTFILES

# ========================
# 実行時も使えるように ENV に設定
# ========================
ENV UID=${UID} \
    GID=${GID} \
    USERNAME=${USERNAME} \
    PASSWORD=${PASSWORD} \
    GIT_USERNAME=${GIT_USERNAME} \
    GIT_EMAIL=${GIT_EMAIL} \
    DEBIAN_FRONTEND=noninteractive \
    PATH="/opt/nvim-linux64/bin:$PATH"

# ========================
# 必要なパッケージをインストール
# ========================
RUN apt update && apt install -y \
    sudo curl software-properties-common gnupg2 \
    bash-completion cmake unzip zip build-essential \
    pkg-config libevent-dev libncurses-dev bison git && \
    rm -rf /var/lib/apt/lists/*

# ========================
# ユーザーとグループの作成（ビルド時）
# ========================
RUN groupadd -g ${GID} ${USERNAME} && \
    useradd -m -s /bin/bash -u ${UID} -g ${GID} -G sudo ${USERNAME} && \
    echo "${USERNAME}:${PASSWORD}" | chpasswd && \
    echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# ========================
# Node.js v22 のインストール
# ========================
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - && \
    sudo apt update && sudo apt install -y nodejs && \
    sudo apt clean

# ========================
# tmux 3.5a をソースからビルド
# ========================
RUN curl -LO https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz && \
    tar -xzf tmux-3.5a.tar.gz && cd tmux-3.5a && \
    ./configure && make && sudo make install && \
    cd .. && rm -rf tmux-3.5a*

# ========================
# Neovim 0.10.3 をダウンロード＆展開
# ========================
RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.10.3/nvim-linux64.tar.gz && \
    sudo rm -rf /opt/nvim && \
    sudo tar -C /opt -xzf nvim-linux64.tar.gz && rm nvim-linux64.tar.gz

# ========================
# Lazygit 最新版のインストール
# ========================
RUN LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+' ) && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    sudo tar -xf lazygit.tar.gz -C /usr/local/bin lazygit && rm lazygit.tar.gz

# ========================
# oh-my-bash のインストール
# ========================
RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" || true && \
    sed -i 's/^OSH_THEME=.*/OSH_THEME="agnoster"/' ~/.bashrc

# ========================
# Git 設定と dotfiles 適用（条件付き）
# ========================
RUN if [ -n "${GIT_USERNAME}" ] && [ -n "${GIT_EMAIL}" ]; then \
        echo "Setting git user.name and user.email..." && \
        git config --global user.name "${GIT_USERNAME}" && \
        git config --global user.email "${GIT_EMAIL}" ; \
    else \
        echo "GIT_USERNAME and/or GIT_EMAIL not set. Skipping git config."; \
    fi && \
    if [ -n "${DOTFILES}" ]; then \
        echo "DOTFILES is set. Cloning and applying dotfiles from ${DOTFILES}..." && \
        git clone "${DOTFILES}" ~/dotfiles && \
        cp ~/dotfiles/bashrc ~/.bashrc && \
        cp ~/dotfiles/.inputrc ~/.inputrc && \
        cp ~/dotfiles/tmux.conf ~/.tmux.conf && \
        mkdir -p ~/.config && \
        cp -r ~/dotfiles/nvim ~/.config/ ; \
    else \
        echo "DOTFILES not set. Skipping dotfiles setup."; \
    fi
