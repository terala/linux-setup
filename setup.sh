#!/bin/bash
# vim: set ft=shell ts=2 sw=4 expandtab

function ensure_ansible() {
  echo -n "Installing ansible ... "
  if ! command -v ansible &> /dev/null
  then
      if [ -f /etc/fedora-release ]; then
        sudo yum install -y ansible
      else
        sudo apt install -y ansible
      fi
    echo "Done."
  else
    echo "Skipping."
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
