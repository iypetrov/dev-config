#!/bin/bash

curr_prj="$(pwd)"
prj_dir="/root/projects"

do_dotfiles_setup() {
  	read -srp "GitHub Personal Access Token: " GH_PAT
  	echo
   	rm -rf /root/.bashrc
    rm -rf /root/.gitconfig
   	rm -rf /home/ipetrov/.bashrc
	git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm
	git clone https://iypetrov:${GH_PAT}@github.com/iypetrov/.dotfiles.git "${prj_dir}/common/.dotfiles"
  	cd "${prj_dir}/common"
	stow --target=/root .dotfiles
    sudo -u ipetrov stow --target=/home/ipetrov bash
 	cd "${prj_dir}/common/.dotfiles"
  	git remote set-url origin git@github.com:iypetrov/.dotfiles.git
 	cd "${curr_prj}"
}

if [[ -d "${prj_dir}/common/.dotfiles" ]]; then
  echo "🔕 Dotfiles were already configured"
  exit 0
fi

echo "🔧 Setting up dotfiles"
if do_dotfiles_setup; then
  echo "✅ Dotfiles were configured successfully"
else
  echo "❌ Dotfiles were NOT configured successfully"
fi
