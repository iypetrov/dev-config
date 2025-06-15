#!/bin/bash

if [[ ! -d "/root/.asdf" ]]; then
    git clone https://github.com/asdf-vm/asdf.git /root/.asdf --branch v0.11.0
fi

. "/root/.asdf/asdf.sh"
. "/root/.asdf/completions/asdf.bash"
while read line; do
    plugin="$(echo "${line}" | cut -d ' ' -f 1)"
    url="$(asdf plugin list all | grep -E "^${plugin}[[:space:]]+" | xargs | cut -d ' ' -f 2)"
    asdf plugin add "${plugin}" "${url}"
done < <(cat /root/.tool-versions | cut -d ' ' -f 1)

asdf install
