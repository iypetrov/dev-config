#!/bin/bash

scripts_dir="$(dirname "$(realpath -q "${BASH_SOURCE[0]}")")/scripts"

"${scripts_dir}"/apt-install-dep.sh git
