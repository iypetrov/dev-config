#!/bin/bash

if [[ ! -d "/root/.asdf" ]]; then
    git clone https://github.com/asdf-vm/asdf.git /root/.asdf
    source /root/.bashrc
fi

while read plugin; do
    url="$(asdf plugin list all | grep -E "^${plugin}[[:space:]]+" | xargs | cut -d ' ' -f 2)"
    echo "${plugin}"
    echo "${url}"
    asdf plugin add "${plugin}" "${url}"
done < <(cat /root/.tool-versions | cut -d ' ' -f 1)

asdf install
