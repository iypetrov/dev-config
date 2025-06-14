#!/bin/bash

curr_prj="$(pwd)"
prj_dir="/root/projects"

do_dotfiles_setup() {
	mv /root/.bashrc /root/.bashrc.bak
	set -e
	git clone https://github.com/tmux-plugins/tpm /root/.tmux/plugins/tpm
	git clone git@github.com:iypetrov/.dotfiles.git /root/projects/common/.dotfiles
	cd /root/projects/common
	stow --target=/root .dotfiles
 	cd "${curr_prj}"
}

if [[ -d "${prj_dir}/common/.dotfiles" ]]; then
  echo "🔕 Dotfiles were already configured"
  exit 0
fi

echo "🔧 Setting up dotfiles"
if do_dotfiles_setup; then
  echo "✅ Dotfiles were configured successfully"
  rm -rf /root/.bashrc.bak
else
  echo "❌ Dotfiles were NOT configured successfully"
  rm -rf /root/.bashrc
  mv /root/.bashrc.bak /root/.bashrc
fi
