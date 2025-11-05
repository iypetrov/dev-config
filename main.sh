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
"${scripts_dir}"/apt-install-dep.sh xclip
"${scripts_dir}"/apt-install-dep.sh tree
"${scripts_dir}"/apt-install-dep.sh keychain
"${scripts_dir}"/apt-install-dep.sh fuse
"${scripts_dir}"/apt-install-dep.sh libfuse2
"${scripts_dir}"/apt-install-dep.sh git-lfs
"${scripts_dir}"/apt-install-dep.sh ffmpeg
"${scripts_dir}"/apt-install-dep.sh imagemagick
"${scripts_dir}"/apt-install-dep.sh subversion
"${scripts_dir}"/apt-install-dep.sh busybox-static

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
    cp "/projects/common/.dotfiles/.config/i3/config" "/home/ipetrov/.config/i3/config"
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
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/state-exam.git personal/state-exam
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/static-site-generator.git personal/static-site-generator
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/lambdas.git personal/lambdas
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/ansible-with-tailscale.git personal/ansible-with-tailscale
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/sopra-steria-dev-team-day-bash-scripts.git personal/sopra-steria-dev-team-day-bash-scripts
"${scripts_dir}"/clone-repo.sh git@github.com:iypetrov/sopra-steria-dev-team-day-containers-anatomy.git personal/sopra-steria-dev-team-day-containers-anatomy

# ip812 repos
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/infra.git ip812/infra
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/apps.git ip812/apps
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/go-template.git ip812/go-template
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/lambdas.git ip812/lambdas
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/blog.git ip812/blog
"${scripts_dir}"/clone-repo.sh git@github.com:ip812/terraform-provider-gitsync.git ip812/terraform-provider-gitsync

# avalon repos
"${scripts_dir}"/clone-repo.sh git@github.com:avalonpharma/infra.git avalonpharma/infra
"${scripts_dir}"/clone-repo.sh git@github.com:avalonpharma/avalon-fullstack.git avalonpharma/avalon-fullstack

# oss repos
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/jaeger.git git@github.com:jaegertracing/jaeger.git oss/jaeger
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/jaeger-idl.git git@github.com:jaegertracing/jaeger-idl.git oss/jaeger-idl
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/jaeger-ui.git git@github.com:jaegertracing/jaeger-ui.git oss/jaeger-ui
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/jaeger-operator.git git@github.com:jaegertracing/jaeger-operator.git oss/jaeger-operator
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/helm-charts.git git@github.com:jaegertracing/helm-charts.git oss/jaeger-helm-charts
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/opentelemetry-operator.git git@github.com:open-telemetry/opentelemetry-operator.git oss/opentelemetry-operator
"${scripts_dir}"/clone-forked-repo.sh git@github.com:iypetrov/opentelemetry-collector-contrib.git git@github.com:open-telemetry/opentelemetry-collector-contrib.git oss/opentelemetry-collector-contrib
"${scripts_dir}"/clone-repo.sh https://github.com/terraform-aws-modules/terraform-aws-vpc.git oss/terraform-aws-vpc
"${scripts_dir}"/clone-repo.sh https://github.com/terraform-aws-modules/terraform-aws-eks.git oss/terraform-aws-eks
"${scripts_dir}"/clone-repo.sh https://github.com/aws/karpenter-provider-aws.git oss/karpenter-provider-aws
"${scripts_dir}"/clone-repo.sh https://github.com/grafana/alloy-scenarios.git oss/alloy-scenarios
"${scripts_dir}"/clone-repo.sh https://github.com/grafana/k8s-monitoring-helm.git oss/k8s-monitoring-helm

# work repos
cpx_pat="$(tr -d '\n' < /projects/common/vault/auth_codes/cpx-gitlab.txt)"
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/sofia-devs/expense-report/expense-report-be.git work/expense-report-be
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/sofia-devs/expense-report/expense-report-fe.git work/expense-report-fe
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/sofia-devs/expense-report/anonymizing-pg-data.git work/anonymizing-pg-data
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/sofia-devs/icv/icv-be.git work/icv-be
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/sofia-devs/icv/icv-fe.git work/icv-fe

"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/terraform/tf-de-gasx.git work/tf-de-gasx
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/terraform/tf-de-lab52.git work/tf-de-lab52
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/terraform/tf-de-lab12.git work/tf-de-lab12
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/terraform/tf-de-lab09.git work/tf-de-lab09
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/salt/salt.git work/salt
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/salt/pillar.git work/pillar
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/elk.git work/elk
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/status-page.git work/status-page
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/tools.git work/tools
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/lambdas.git work/lambdas

"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/sick.git work/sick
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/Infrastructure/infratools/jfrogpoc.git work/jfrogpoc
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/portal/qa/q00-cpx-sup-cd.git work/q00-cpx-sup-cd
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/portal/qa/q00-cpx-sso-cd.git work/q00-cpx-sso-cd
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/portal/qa/qa-cpx-tso-cd.git work/qa-cpx-tso-cd
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/cpx.energy/releasenotes.git work/releasenotes
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/cpx.energy/sso/clui-clws-containerizer-sso.git work/clui-clws-containerizer-sso
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/cpx.energy/sup/clui-clws-containerizer-sup.git work/clui-clws-containerizer-sup
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/cpx.energy/tso/clui-clws-containerizer-tso.git work/clui-clws-containerizer-tso
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/cpx.energy/bam/deploy.git work/bam-deploy
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/cpx.energy/sso/deploy.git work/sso-deploy
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/cpx.energy/sup/deploy.git work/sup-deploy
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/cpx.energy/tso/deploy.git work/tso-deploy
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/Infrastructure/infratools/dbs-investigation.git work/dbs-investigation
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/Infrastructure/infratools/infratools-ci-components.git work/infratools-ci-components
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/Infrastructure/infratools/migration-innersource-oci-to-aws-ecr-poc.git work/migration-innersource-oci-to-aws-ecr-poc
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GXrestricted/infrastructure/apps.git work/apps
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/Infrastructure/infratools/apps-poc.git work/apps-poc
"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/tools/keycloak.git work/keycloak

"${scripts_dir}"/clone-repo.sh https://ilia.petrov:${cpx_pat}@innersource.soprasteria.com/ENER-GX/Core-X/secrets-manager-crud-poc.git work/secrets-manager-crud-poc
