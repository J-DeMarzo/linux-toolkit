#!/usr/bin/env bash
# user_mgmt.sh
# Simple user management helper for Linux (Ubuntu/Debian/CentOS/RHEL).
# Usage:
#   ./user_mgmt.sh add username "Full Name" "password" "group1,group2"
#   ./user_mgmt.sh del username
#   ./user_mgmt.sh lock username
#   ./user_mgmt.sh unlock username
#   ./user_mgmt.sh info username

set -euo pipefail

command_exists() { command -v "$1" >/dev/null 2>&1; }

if ! command_exists sudo; then
  echo "sudo required but not found. Install sudo or run as root."
  exit 1
fi

ACTION=${1:-help}
USER=${2:-}

add_user() {
  local username="$1"; shift
  local full_name="$1"; shift || true
  local password="${1:-}" ; shift || true
  local groups="${1:-}" ; shift || true

  echo "Creating user: $username"
  sudo useradd -m -s /bin/bash -c "$full_name" "$username" || { echo "useradd failed"; exit 1; }

  if [ -n "$password" ]; then
    echo "$username:$password" | sudo chpasswd
  else
    echo "No password provided. Please set password manually with 'passwd $username'."
  fi

  if [ -n "$groups" ]; then
    IFS=',' read -ra GARR <<< "$groups"
    for g in "${GARR[@]}"; do
      if ! getent group "$g" >/dev/null; then
        echo "Creating group $g"
        sudo groupadd "$g"
      fi
      sudo usermod -aG "$g" "$username"
    done
  fi

  echo "User $username created."
}

delete_user() {
  local username="$1"
  read -p "Are you sure you want to delete user $username and their home directory? [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    sudo deluser --remove-home "$username" 2>/dev/null || sudo userdel -r "$username"
    echo "Deleted $username"
  else
    echo "Abort."
  fi
}

lock_user() {
  sudo usermod -L "$1"
  echo "Locked $1"
}

unlock_user() {
  sudo usermod -U "$1"
  echo "Unlocked $1"
}

user_info() {
  id "$1"
  sudo chage -l "$1" || true
}

case "$ACTION" in
  add) [ -z "$USER" ] && { echo "Missing username"; exit 1; } ; add_user "$USER" "${3:-}" "${4:-}" "${5:-}" ;;
  del|delete) [ -z "$USER" ] && { echo "Missing username"; exit 1; } ; delete_user "$USER" ;;
  lock) [ -z "$USER" ] && { echo "Missing username"; exit 1; } ; lock_user "$USER" ;;
  unlock) [ -z "$USER" ] && { echo "Missing username"; exit 1; } ; unlock_user "$USER" ;;
  info) [ -z "$USER" ] && { echo "Missing username"; exit 1; } ; user_info "$USER" ;;
  *) cat <<EOF
Usage: $0 <command> [args]
Commands:
  add USER "Full Name" [password] [group1,group2]  - Create user
  del USER                                         - Delete user (prompts)
  lock USER                                        - Lock user account
  unlock USER                                      - Unlock user
  info USER                                        - Show uid/gid/groups and password age
EOF
;;
esac
