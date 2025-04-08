# Ubuntu Development Environment

## Environment Variables

The following environment variables can be customized:

- `USER_NAME`: Username in the container (default: `ubuntu`)
- `GROUP_NAME`: Group name in the container (default: `ubuntu`)
- `USER_UID`: User UID (default: `1000`)
- `USER_GID`: Group GID (default: `1000`)
- `USER_PASSWORD`: User password (default: none)
- `GIT_NAME`: Git username (default: `Your Name`)
- `GIT_EMAIL`: Git email address (default: `your.email@example.com`)
- `DOTFILES`: URL of dotfiles repository (default: none)

### BASH Environment Variables

Environment variables with the `BASH_` prefix are stored in `~/.env`.

## Workspace

- `/workspace/$USER_NAME`: Workspace directory for volume mounting 