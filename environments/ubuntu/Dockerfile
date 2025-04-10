FROM ubuntu:latest

# Install common packages and dependencies
RUN apt-get update && \
    apt-get install -y sudo software-properties-common curl wget ca-certificates unzip build-essential \
    ninja-build gettext cmake automake pkg-config libevent-dev libncurses-dev bison byacc bash \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Git
RUN add-apt-repository ppa:git-core/ppa -y && \
    apt-get update && \
    apt-get install -y git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Neovim
RUN git clone https://github.com/neovim/neovim.git && \
    cd neovim && \
    git checkout stable && \
    make CMAKE_BUILD_TYPE=Release && \
    make install && \
    cd .. && rm -rf neovim

# Install tmux
RUN git clone https://github.com/tmux/tmux.git && \
    cd tmux && \
    git checkout 3.5 && \
    sh autogen.sh && \
    ./configure && \
    make && \
    make install && \
    cd .. && rm -rf tmux

# Install Lazygit
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit /usr/local/bin/ && \
    rm -f lazygit lazygit.tar.gz

# Install Node.js
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash && \
    mkdir -p /usr/local/bun && \
    cp -r /root/.bun/* /usr/local/bun/ && \
    ln -sf /usr/local/bun/bin/bun /usr/local/bin/bun && \
    chmod -R 755 /usr/local/bun

# Install Oh-my-bash
RUN git clone https://github.com/ohmybash/oh-my-bash.git /etc/skel/.oh-my-bash && \
    cp /etc/skel/.oh-my-bash/templates/bashrc.osh-template /etc/skel/.bashrc

# Setup workspace and entrypoint
RUN mkdir -p /workspace && chmod 777 /workspace
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]