#!/bin/bash

if [[ ! -d "/nix" ]]; then
    sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
fi

if ! command -v devbox &>/dev/null; then
    curl -fsSL https://get.jetify.com/devbox | bash
fi

devbox install --config /root/projects/common/.dotfiles/devbox.json
