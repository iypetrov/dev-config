#!/bin/bash

curr_dir="$(pwd)"
prj_dir="/projects"
scripts_dir="$(dirname "$(realpath -q "${BASH_SOURCE[0]}")")/scripts"

if [[ ! -d "${prj_dir}/common/vault" ]]; then
    read -srp "GitHub Personal Access Token: " GH_PAT
    echo
    read -srp "Ansible Vault Password: " ANSIBLE_VAULT_PASSWORD
    echo
fi

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
"${scripts_dir}"/apt-install-dep.sh docker.io
"${scripts_dir}"/apt-install-dep.sh docker-buildx
"${scripts_dir}"/apt-install-dep.sh bat
"${scripts_dir}"/apt-install-dep.sh silversearcher-ag
"${scripts_dir}"/apt-install-dep.sh jq
"${scripts_dir}"/apt-install-dep.sh yq
"${scripts_dir}"/apt-install-dep.sh tar
"${scripts_dir}"/apt-install-dep.sh gnupg
"${scripts_dir}"/apt-install-dep.sh postgresql-client
"${scripts_dir}"/apt-install-dep.sh i3
"${scripts_dir}"/apt-install-dep.sh xclip
"${scripts_dir}"/apt-install-dep.sh xsel
"${scripts_dir}"/apt-install-dep.sh tree
"${scripts_dir}"/apt-install-dep.sh keychain
"${scripts_dir}"/apt-install-dep.sh fuse
# "${scripts_dir}"/apt-install-dep.sh libfuse2
"${scripts_dir}"/apt-install-dep.sh git-lfs
"${scripts_dir}"/apt-install-dep.sh ffmpeg
"${scripts_dir}"/apt-install-dep.sh imagemagick
"${scripts_dir}"/apt-install-dep.sh subversion
"${scripts_dir}"/apt-install-dep.sh busybox-static
"${scripts_dir}"/apt-install-dep.sh polybar
"${scripts_dir}"/apt-install-dep.sh rofi
"${scripts_dir}"/apt-install-dep.sh alacritty
"${scripts_dir}"/apt-install-dep.sh graphviz
"${scripts_dir}"/apt-install-dep.sh apache2-utils
"${scripts_dir}"/apt-install-dep.sh mariadb-client

# Font
font_name="JetBrainsMono"
fonts_dir="/home/ipetrov/.local/share/fonts"
if [[ -d "${fonts_dir}/${font_name}" ]]; then
    echo "🔕 Font ${font_name} was already installed"
else
    wget -P "${fonts_dir}" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/${font_name}.zip"
    unzip "${fonts_dir}/${font_name}.zip" -d "${fonts_dir}/${font_name}"
    echo "✅ Font ${font_name} installed successfully"
fi

# Git delta
if ! command -v delta > /dev/null 2>&1; then 
    wget "https://github.com/dandavison/delta/releases/download/0.17.0/git-delta_0.17.0_$(dpkg --print-architecture).deb"
    dpkg -i "git-delta_0.17.0_$(dpkg --print-architecture).deb"
    rm "git-delta_0.17.0_$(dpkg --print-architecture).deb"
fi

# Docker Compose
if ! command -v docker-compose > /dev/null 2>&1; then
    echo "🔧 Installing Docker Compose"
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    docker-compose --version
fi

# Ngrok
if snap list | grep -q "^ngrok\s"; then
    echo "🔕 Skip installing Ngrok, already available"
else
    echo "🔧 Installing Ngrok"
    if snap install ngrok; then
        echo "✅ Ngrok installed successfully"
    else
        echo "❌ Ngrok failed to install"
    fi
fi

# Auth
do_auth_setup() {
    echo "🔧 Setting up auth"

    rm -rf /root/.ssh

    git clone https://iypetrov:${GH_PAT}@github.com/iypetrov/vault.git ${prj_dir}/common/vault

    echo "${ANSIBLE_VAULT_PASSWORD}" > /tmp/ansible-vault-pass.txt

    if [[ -d "${prj_dir}/common/vault/.ssh" ]]; then
        find "${prj_dir}/common/vault/.ssh" -type f -exec ansible-vault decrypt --vault-password-file /tmp/ansible-vault-pass.txt {} \;
        ln -sfn "${prj_dir}/common/vault/.ssh" /root
    fi

    if [[ -d "${prj_dir}/common/vault/.aws" ]]; then
        find "${prj_dir}/common/vault/.aws" -type f -exec ansible-vault decrypt --vault-password-file /tmp/ansible-vault-pass.txt {} \;
        ln -sfn "${prj_dir}/common/vault/.aws" /root
    fi

    if [[ -d "${prj_dir}/common/vault/auth_codes" ]]; then
        find "${prj_dir}/common/vault/auth_codes" -type f -exec ansible-vault decrypt --vault-password-file /tmp/ansible-vault-pass.txt {} \;
    fi

    cd "${prj_dir}/common/vault"
    git remote set-url origin git@github.com:iypetrov/vault.git
    cd "${curr_dir}"

    rm /tmp/ansible-vault-pass.txt
}

if [[ -d "${prj_dir}/common/vault" ]]; then
    echo "🔕 Auth setup was already done"
else
    if do_auth_setup; then
        echo "✅ Auth setup succeeded"
    else
        echo "❌ Auth setup failed"
    fi
fi

# Dotfiles
do_dotfiles_setup() {
    rm -rf /root/.bashrc
    rm -rf /root/.gitconfig
    git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm
    git clone https://iypetrov:${GH_PAT}@github.com/iypetrov/.dotfiles.git "${prj_dir}/common/.dotfiles"
    cd "${prj_dir}/common"
    stow --target=/root .dotfiles
    mkdir -p "/home/ipetrov/.config/i3"
    cp "${prj_dir}/common/.dotfiles/.config/i3/config" "/home/ipetrov/.config/i3/config"
    mkdir -p "/home/ipetrov/.config/alacritty"
    cp "${prj_dir}/common/.dotfiles/.config/alacritty/alacritty.toml" "/home/ipetrov/.config/alacritty/alacritty.toml"
    mkdir -p "/home/ipetrov/.config/rofi"
    cp "${prj_dir}/common/.dotfiles/.config/rofi/config.rasi" "/home/ipetrov/.config/rofi/config.rasi"
    cd "${prj_dir}/common/.dotfiles"
    git remote set-url origin git@github.com:iypetrov/.dotfiles.git
    cd "${curr_dir}"
}

if [[ -d "${prj_dir}/common/.dotfiles" ]]; then
    echo "🔕 Dotfiles were already configured"
else
    echo "🔧 Setting up dotfiles"
    if do_dotfiles_setup; then
        echo "✅ Dotfiles were configured successfully"
    else
        echo "❌ Dotfiles were NOT configured successfully"
    fi
fi

# Devbox
if [[ ! -d "/nix" ]]; then
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
fi

if ! command -v devbox &>/dev/null; then
    curl -fsSL https://get.jetify.com/devbox | bash
fi

devbox install --config /projects/common/dev-config/devbox.json

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

# Set up SSH keys
eval $(keychain --eval --agents ssh id_ed25519_personal id_ed25519_work)
KEYCHAIN_ENV="/root/.keychain/$(hostname)-sh"
if [[ -f "$KEYCHAIN_ENV" ]]; then
    source "$KEYCHAIN_ENV"
fi

# personal repos
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/go-playground.git personal/go-playground
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/aws-playground.git personal/aws-playground
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/k8s-playground.git personal/k8s-playground
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/lambdas.git personal/lambdas
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/o11y-operator.git personal/o11y-operator

# ip812 repos
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/infra.git ip812/infra
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/apps.git ip812/apps
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/go-template.git ip812/go-template
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/lambdas.git ip812/lambdas
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/blog.git ip812/blog
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/terraform-provider-gitsync.git ip812/terraform-provider-gitsync

# oss repos
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/jaeger.git git@github.com:jaegertracing/jaeger.git oss/jaeger
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/jaeger-idl.git git@github.com:jaegertracing/jaeger-idl.git oss/jaeger-idl
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/jaeger-ui.git git@github.com:jaegertracing/jaeger-ui.git oss/jaeger-ui
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/jaeger-operator.git git@github.com:jaegertracing/jaeger-operator.git oss/jaeger-operator
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/helm-charts.git git@github.com:jaegertracing/helm-charts.git oss/jaeger-helm-charts
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/opentelemetry-operator.git git@github.com:open-telemetry/opentelemetry-operator.git oss/opentelemetry-operator
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/opentelemetry-collector-contrib.git git@github.com:open-telemetry/opentelemetry-collector-contrib.git oss/opentelemetry-collector-contrib

"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/gardener.git git@github.com:gardener/gardener.git oss/gardener
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/gardener-extension-shoot-networking-filter.git git@github.com:gardener/gardener-extension-shoot-networking-filter.git oss/gardener-extension-shoot-networking-filter master
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/gardener-extension-provider-aws.git git@github.com:gardener/gardener-extension-provider-aws.git oss/gardener-extension-provider-aws master
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/gardener-extension-otelcol.git git@github.com:gardener/gardener-extension-otelcol.git oss/gardener-extension-otelcol

bash private_repos.sh "${scripts_dir}"
