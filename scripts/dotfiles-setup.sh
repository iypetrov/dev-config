#!/bin/bash

curr_prj="$(pwd)"
prj_dir="/root/projects"

do_dotfiles_setup() {
	mv /root/.bashrc /root/.bashrc.bak
  	mv /root/.tmux/plugins/tpm /root/.tmux/plugins/tpm.bak
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

if do_dotfiles_setup; then
  echo "✅ Dotfiles were configured successfully"
  rm -rf /root/.bashrc.bak
  rm -rf /root/.tmux/plugins/tpm.bak
else
  echo "❌ Dotfiles were NOT configured successfully"
  rm -rf /root/.bashrc
  rm -rf /root/.tmux/plugins/tpm
  mv /root/.bashrc.bak /root/.bashrc
  mv /root/.tmux/plugins/tpm.bak /root/.tmux/plugins/tpm
fi
