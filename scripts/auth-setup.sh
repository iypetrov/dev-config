#!/bin/bash

curr_dir="$(pwd)"
prj_dir="/root/projects"

do_auth_setup() {
  read -srp "GitHub Personal Access Token: " GH_PAT
  echo
  read -srp "Ansible Vault Password: " ANSIBLE_VAULT_PASSWORD
  echo

  echo "🔧 Setting up auth"
  
  rm -rf /root/.ssh

  git clone https://iypetrov:${GH_PAT}@github.com/iypetrov/vault.git ${prj_dir}/common/vault

  echo "${ANSIBLE_VAULT_PASSWORD}" > /tmp/ansible-vault-pass.txt

  # Only decrypt if directories exist
  if [ -d "${prj_dir}/common/vault/.ssh" ]; then
    find "${prj_dir}/common/vault/.ssh" -type f -exec ansible-vault decrypt --vault-password-file /tmp/ansible-vault-pass.txt {} \;
    ln -sfn "${prj_dir}/common/vault/.ssh" /root
  fi

  if [ -d "${prj_dir}/common/vault/.aws" ]; then
    find "${prj_dir}/common/vault/.aws" -type f -exec ansible-vault decrypt --vault-password-file /tmp/ansible-vault-pass.txt {} \;
    ln -sfn "${prj_dir}/common/vault/.aws" /root
  fi

  cd "${prj_dir}/common/vault"
  git remote set-url origin git@github.com:iypetrov/vault.git
  cd "${curr_dir}"

  rm /tmp/ansible-vault-pass.txt
}

if [[ -d "${prj_dir}/common/vault" ]]; then
  echo "🔕 Auth setup was already done"
  exit 0
fi

if do_auth_setup; then
  echo "✅ Auth setup succeeded"
else
  echo "❌ Auth setup failed"
fi
