#!/bin/bash

wget https://github.com/asdf-vm/asdf/releases/download/v0.18.0/asdf-v0.18.0-linux-arm64.tar.gz -O /tmp/asdf-v0.18.0-linux-arm64.tar.gz
mkdir -p ~/.local/bin
tar -xvzf /tmp/asdf-v0.18.0-linux-arm64.tar.gz -C ~/.local/bin
source /root/.bashrc
