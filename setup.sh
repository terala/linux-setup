#!/bin/bash
# vim: set ft=shell ts=2 sw=4 expandtab

set -e

PATH=$PATH:$HOME/.local/bin

function ensure_pipx() {
  echo -n "Checking for pipx ... "
  if grep -q "ID=ubuntu" /etc/os-release; then
    consent=""
  else
    consent="-y"
  fi
  if ! command -v pipx &> /dev/null
  then
    pkcon install $consent pipx python3-psutil
    echo "Done."
  else
    echo "Found."
  fi
}


function ensure_ansible() {
  echo -n "Checking for ansible ... "
  if ! command -v ansible &> /dev/null
  then
    echo "Not Found. Installing..."
    ensure_pipx

    pipx install --include-deps ansible jmespath
    pipx inject ansible jmespath
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
if can_sudo_without_password; 
then
  ansible-playbook --become setup.yml
else
  ansible-playbook --ask-become-pass setup.yml
fi
