#!/bin/bash

scripts_dir="$(dirname "$(realpath -q "${BASH_SOURCE[0]}")")/scripts"

apt update
"${scripts_dir}"/apt-install-dep.sh curl 
"${scripts_dir}"/apt-install-dep.sh unzip
"${scripts_dir}"/apt-install-dep.sh stow
"${scripts_dir}"/apt-install-dep.sh ansible
"${scripts_dir}"/apt-install-dep.sh sudo
"${scripts_dir}"/apt-install-dep.sh vim-gtk3
"${scripts_dir}"/apt-install-dep.sh tmux
"${scripts_dir}"/apt-install-dep.sh fzf 
"${scripts_dir}"/apt-install-dep.sh build-essential
"${scripts_dir}"/apt-install-dep.sh ripgrep
"${scripts_dir}"/apt-install-dep.sh ca-certificates
"${scripts_dir}"/apt-install-dep.sh openssh-client
"${scripts_dir}"/apt-install-dep.sh make
"${scripts_dir}"/apt-install-dep.sh software-properties-common
"${scripts_dir}"/apt-install-dep.sh lazygit
"${scripts_dir}"/apt-install-dep.sh docker.io
"${scripts_dir}"/apt-install-dep.sh bat
"${scripts_dir}"/apt-install-dep.sh silversearcher-ag
"${scripts_dir}"/apt-install-dep.sh jq
"${scripts_dir}"/apt-install-dep.sh yq
"${scripts_dir}"/apt-install-dep.sh tar
"${scripts_dir}"/apt-install-dep.sh gnupg
"${scripts_dir}"/apt-install-dep.sh postgresql-client
"${scripts_dir}"/apt-install-dep.sh i3

if ! dpkg -s i3 &>/dev/null; then
    ln -s "${prj_dir}/common/.dotfiles/.config/i3/config" "/home/ipetrov/.config/i3/config"
fi

"${scripts_dir}"/auth-setup.sh
"${scripts_dir}"/dotfiles-setup.sh
"${scripts_dir}"/asdf.sh

# Brave
if command -v brave-browser &>/dev/null; then
    echo "🔕 Skip installing Brave, already available"
else
    echo "🔧 Installing Brave browser"
    if curl -fsS https://dl.brave.com/install.sh | sh; then
        echo "✅ Brave browser installed successfully"
    else
        echo "❌ Brave browser failed to install"
    fi
fi

# Postman
if snap list | grep -q "^postman\s"; then
    echo "🔕 Skip installing Postman, already available via snap"
else
    echo "🔧 Installing Postman via snap"
    if snap install postman; then
        echo "✅ Postman installed successfully"
    else
        echo "❌ Postman failed to install"
    fi
fi

# DBeaver
if snap list | grep -q "^dbeaver-ce\s"; then
    echo "🔕 Skip installing DBeaver, already available via snap"
else
    echo "🔧 Installing DBeaver via snap"
    if snap install dbeaver-ce; then
        echo "✅ DBeaver installed successfully"
    else
        echo "❌ DBeaver failed to install"
    fi
fi
