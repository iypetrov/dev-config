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

if ! command -v delta > /dev/null 2>&1; then 
    wget https://github.com/dandavison/delta/releases/download/0.17.0/git-delta_0.17.0_arm64.deb
    dpkg -i git-delta_0.17.0_arm64.deb
    rm git-delta_0.17.0_arm64.deb
fi

"${scripts_dir}"/auth-setup.sh
"${scripts_dir}"/dotfiles-setup.sh
"${scripts_dir}"/devbox.sh

mkdir -p "/home/ipetrov/.config/i3"
cp "/root/projects/common/.dotfiles/.config/i3/config" "/home/ipetrov/.config/i3/config"

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

"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/go-playground.git personal/go-playground
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/aws-playground.git personal/aws-playground
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/k8s-playground.git personal/k8s-playground

cpx_pat="$(tr -d '\n' < /root/projects/common/vault/auth_codes/cpx-gitlab.txt)"
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/terraform/tf-de-gasx.git work/tf-de-gasx
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/terraform/tf-de-lab52.git work/tf-de-lab52
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/terraform/tf-de-lab12.git work/tf-de-lab12
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/terraform/tf-de-lab09.git work/tf-de-lab09
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/salt/salt.git work/salt
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/salt/pillar.git work/pillar
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/Infrastructure/infratools/jfrogpoc.git work/jfrogpoc
