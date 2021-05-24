#!/bin/bash
# vim: set ft=shell ts=2 sw=4 expandtab

set -e

PATH=$PATH:$HOME/.local/bin

function ensure_ansible() {
  echo -n "Checking for ansible ... "
  if ! command -v ansible &> /dev/null
  then
    echo "Not Found. Installing..."
    curl https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
    python3 /tmp/get-pip.py
    python3 -m pip install ansible
    echo "Done."
  else
    echo "Found."
  fi
}
function install_galaxy_components() {
  echo "Installing galaxy roles"
  ansible-galaxy role install -r requirements.yml

  echo "Installing galaxy collections"
  ansible-galaxy collection install -r requirements.yml
}

function can_sudo_without_password() {
  sudo -n true
  return $?
}

ensure_ansible
install_galaxy_components

echo "Setting up the box"
if [[ can_sudo_without_password -eq 0 ]]; 
then
  ansible-playbook --become setup.yml
else
  ansible-playbook --ask-become-pass setup.yml
fi
