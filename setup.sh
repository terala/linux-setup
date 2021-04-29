#!/bin/bash
# vim: set ft=shell ts=2 sw=4 expandtab

function install_ansible() {
  echo "Installing ansible"
  sudo apt install -y ansible
}

if ! command -v ansible &> /dev/null
then
  install_ansible
else
  echo "ansible already installed. Skipping."
fi

echo "Installing galaxy roles"
ansible-galaxy role install -r requirements.yml

echo "Installing galaxy collections"
ansible-galaxy collection install -r requirements.yml

echo "Setting up the box"
ansible-playbook --ask-become-pass setup.yml
#ansible-playbook --become  setup.yml

