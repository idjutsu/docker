#!/bin/bash
set -e

# ユーザー設定
setup_user() {
  # UID 1000のubuntuユーザーをリネームする場合
  if [[ "$USER_UID" == "1000" && "$USER_NAME" != "ubuntu" ]]; then
    usermod -l "$USER_NAME" ubuntu
    groupmod -n "$GROUP_NAME" ubuntu
    
    # ホームディレクトリの処理
    if [[ -d "/home/ubuntu" ]]; then
      mkdir -p "/home/$USER_NAME"
      cp -r /home/ubuntu/. "/home/$USER_NAME/"
      chown -R "$USER_NAME:$GROUP_NAME" "/home/$USER_NAME"
      rm -rf /home/ubuntu
      usermod -d "/home/$USER_NAME" "$USER_NAME"
    fi
  else
    # 新規ユーザー作成
    if ! getent passwd "$USER_UID" > /dev/null 2>&1; then
      groupadd -g "$USER_GID" "$GROUP_NAME" 2>/dev/null || true
      useradd -m -s /bin/bash -u "$USER_UID" -g "$USER_GID" "$USER_NAME" 2>/dev/null || true
    fi
  fi

  # パスワード設定
  if [[ -n "$USER_PASSWORD" ]]; then
    echo "$USER_NAME:$USER_PASSWORD" | chpasswd
  else
    passwd -d "$USER_NAME" >/dev/null 2>&1
  fi

  # sudo権限の設定
  if getent group sudo > /dev/null 2>&1; then
    usermod -aG sudo "$USER_NAME"
    echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$USER_NAME"
    chmod 0440 "/etc/sudoers.d/$USER_NAME"
  fi
}

# 設定ファイルの構成
setup_dotfiles() {
  local home_dir="/home/${USER_NAME}"

  # .bashrcファイルの設定
  if [[ ! -f "${home_dir}/.bashrc" ]]; then
    cp /etc/skel/.bashrc "${home_dir}/.bashrc"
    chown "${USER_NAME}:${GROUP_NAME}" "${home_dir}/.bashrc"
  fi

  # Oh-my-bashの設定
  if [[ ! -d "${home_dir}/.oh-my-bash" ]]; then
    mkdir -p "${home_dir}/.oh-my-bash"
    cp -r /etc/skel/.oh-my-bash/* "${home_dir}/.oh-my-bash/"
    chown -R "${USER_NAME}:${GROUP_NAME}" "${home_dir}/.oh-my-bash"
  fi

  # Git設定
  if [[ -n "$GIT_NAME" && -n "$GIT_EMAIL" ]]; then
    su - "${USER_NAME}" -c "git config --global user.name \"$GIT_NAME\" && \
                        git config --global user.email \"$GIT_EMAIL\" && \
                        git config --global core.editor \"nvim\" && \
                        git config --global init.defaultBranch \"main\" && \
                        git config --global pull.rebase false && \
                        git config --global color.ui auto"
  fi

  # dotfilesリポジトリのクローンと設定
  if [[ -n "$DOTFILES" ]]; then
    su - "${USER_NAME}" -c "git clone $DOTFILES ${home_dir}/dotfiles"
    
    if [[ -d "${home_dir}/dotfiles" ]]; then
      local dotfiles_dir="${home_dir}/dotfiles"
      
      # 各設定ファイルのシンボリックリンク作成
      [[ -f "${dotfiles_dir}/bashrc" ]] && \
        rm -f "${home_dir}/.bashrc" && \
        ln -sf "${dotfiles_dir}/bashrc" "${home_dir}/.bashrc"
        
      [[ -f "${dotfiles_dir}/tmux.conf" ]] && \
        ln -sf "${dotfiles_dir}/tmux.conf" "${home_dir}/.tmux.conf"
        
      [[ -d "${dotfiles_dir}/nvim" ]] && \
        mkdir -p "${home_dir}/.config" && \
        ln -sf "${dotfiles_dir}/nvim" "${home_dir}/.config/nvim"
        
      [[ -f "${dotfiles_dir}/inputrc" ]] && \
        ln -sf "${dotfiles_dir}/inputrc" "${home_dir}/.inputrc"
      
      # 所有権設定
      chown -R "${USER_NAME}:${GROUP_NAME}" "${home_dir}/.config" 2>/dev/null || true
      chown -h "${USER_NAME}:${GROUP_NAME}" "${home_dir}/.bashrc" "${home_dir}/.tmux.conf" "${home_dir}/.inputrc" 2>/dev/null || true
    fi
  fi
}

# ワークスペースの設定
setup_workspace() {
  local workspace_dir="/workspace/${USER_NAME}"
  mkdir -p "$workspace_dir"
  chown -R "${USER_NAME}:${GROUP_NAME}" "$workspace_dir"
}

# メイン処理
main() {
  echo "セットアップ開始: ユーザー '$USER_NAME' (UID:$USER_UID)"
  setup_user
  setup_dotfiles
  setup_workspace
  echo "セットアップ完了"
  
  exec "$@"
}

main "$@"