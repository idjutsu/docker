#!/bin/bash
set -e

# User setup
configure_user_account() {
  if [[ "$USER_UID" == "1000" && "$USER_NAME" != "ubuntu" ]]; then
    usermod -l "$USER_NAME" ubuntu
    groupmod -n "$GROUP_NAME" ubuntu
    if [[ -d "/home/ubuntu" ]]; then
      mv /home/ubuntu "/home/$USER_NAME"
      chown -R "$USER_NAME:$GROUP_NAME" "/home/$USER_NAME"
      usermod -d "/home/$USER_NAME" "$USER_NAME"
    fi
  else
    if ! getent passwd "$USER_UID" > /dev/null; then
      groupadd -g "$USER_GID" "$GROUP_NAME" || true
      useradd -m -s /bin/bash -u "$USER_UID" -g "$USER_GID" "$USER_NAME" || true
    fi
  fi

  if [[ -n "$USER_PASSWORD" ]]; then
    echo "$USER_NAME:$USER_PASSWORD" | chpasswd
  else
    passwd -d "$USER_NAME" > /dev/null
  fi

  if getent group sudo > /dev/null; then
    usermod -aG sudo "$USER_NAME"
    echo "$USER_NAME ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/$USER_NAME"
    chmod 0440 "/etc/sudoers.d/$USER_NAME"
  fi
}

# Create ~/.env file with necessary environment variables
create_bash_environment_file() {
  local env_path="/home/${USER_NAME}/.bash.env"
  echo "Writing environment variables to $env_path..."
  env | grep "^BASH_" | sed 's/^BASH_//' > "$env_path"
  chmod 600 "$env_path"
  chown "${USER_NAME}:${GROUP_NAME}" "$env_path"
  echo ".bash.env file created at $env_path"
}

# Git configuration
configure_git_settings() {
  if [[ -n "$GIT_NAME" && -n "$GIT_EMAIL" ]]; then
    su - "$USER_NAME" -c "git config --global user.name '$GIT_NAME' && \
                        git config --global user.email '$GIT_EMAIL' && \
                        git config --global core.editor 'nvim' && \
                        git config --global init.defaultBranch 'main' && \
                        git config --global pull.rebase false && \
                        git config --global color.ui auto"
  fi
}

clone_and_execute_dotfiles() {
  if [[ -n "$DOTFILES" ]]; then
    su - "$USER_NAME" -c "git clone $DOTFILES /home/$USER_NAME/dotfiles && \
                        chmod +x /home/$USER_NAME/dotfiles/setup.sh && \
                        /home/$USER_NAME/dotfiles/setup.sh"
  fi
}

# Oh-my-bash setup
install_oh_my_bash() {
  local home_dir="/home/${USER_NAME}"
  if [[ ! -d "${home_dir}/.oh-my-bash" ]]; then
    mkdir -p "${home_dir}/.oh-my-bash"
    cp -r /etc/skel/.oh-my-bash/* "${home_dir}/.oh-my-bash/"
    chown -R "${USER_NAME}:${GROUP_NAME}" "${home_dir}/.oh-my-bash"
  fi
}

# Workspace setup
initialize_workspace() {
  local workspace_dir="/workspace/${USER_NAME}"
  mkdir -p "$workspace_dir"
  chown -R "${USER_NAME}:${GROUP_NAME}" "$workspace_dir"
}

# Main process
main() {
  echo "Starting setup: User '$USER_NAME' (UID:$USER_UID)"
  configure_user_account
  create_bash_environment_file
  configure_git_settings
  clone_and_execute_dotfiles
  install_oh_my_bash
  initialize_workspace

  for var in $(env | grep '^BASH_' | cut -d= -f1); do
    unset "$var"
  done

  unset USER_NAME USER_UID USER_GID USER_PASSWORD
  unset GIT_NAME GIT_EMAIL DOTFILES GROUP_NAME

  echo "Setup completed"
  exec "$@"
}

main "$@"