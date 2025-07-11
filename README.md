# dev-config

## Overview
This repo holds a bunch of shell scripts for setting up an Ubuntu machine (later than 25.10 and works on both amd64 and arm64) to my target development setup.

## Description
My intention in creating this was that I might change jobs or the company I work at might give me a different laptop with a different OS. I really don't like to waste time setting up a fresh machine to the state I like, so I decided to do it once and reuse it no matter what machine I work on. I achieve this by running all my development work on a VM and using Ubuntu on it.

Someone may ask - when you have the freedom in the VM to run whatever OS, why did you choose Ubuntu over Arch, Fedora, Mint, NixOS, etc.? The real reason is that, for me, it doesn't make much of a difference between them, and I already have Ubuntu on my personal laptop, so there wasn't a super strong reason to pick something else. This may change in the future, but at the moment, I just want a stable distribution and not to think too much about it.

### So how did I make my setup?
Some people like to set up their machines with Ansible or use an OS like NixOS to make the system exactly the way they want with specific packages. I decided to go with a simpler approach. I just have some well-organized shell scripts that install everything I need. But there's one important point about this - my scripts are idempotent, so it doesn't matter how many times I run them, the result should always be the same (when I see some repo is already installed, I don’t try to clone it again; when I see some program is already installed, I skip the reinstallation, and so on).

### So what exactly do I do in my scripts?
- First, I install with apt the dependencies that I don't care too much about their exact version (vim, tmux, jq, ...) - I just want them available on my machine.
- Then I set up my vault private repo where I store my encrypted creds like SSH keys, and so on.
- Then I set up my dotfiles repo, where I hold my configurations for bash, vim, tmux, i3, and a few other small programs.
- Then comes something I was looking for a long time, and it's the reason why I didn’t start this project earlier. I wanted an easy way to install dependencies - not like the ones I install with apt, but the ones I truly care about the version of (Go, Node, Python, Terraform, ...) and how easily I can switch between different versions. I tried [asdf](https://asdf-vm.com), but my experience with it wasn’t that great, so I started to look for another approach. I really liked the Nix approach, but I concluded for myself that at the stage I am in my professional journey (at the time of writing ~3.5 years), there are more important things I want to get better at before diving deeper into perfecting my development setup (like reading books related to software engineering, making side projects, contributing to open source, working on my homelab, and so on...). And one day I found [devbox](https://www.jetify.com/devbox). It is powered by Nix and does only a fraction of what Nix is capable of, but it does exactly what I needed. I simply define a `devbox.json` file with all the dependencies I need, along with their desired versions, and then run a devbox shell where all my target applications are available exactly as specified.
- After that, I clone all the repos I work on, and that’s basically all these scripts do.

## So how do I work
This config is designed to work as a root user. So the first thing I do when I open a terminal is run `sudo su`, and then I start a devbox shell. I have a global `devbox.json` config, not one specific for a project, so that's why in this devbox shell I have everything I want. Also, when I start the devbox shell, it automatically opens tmux, so I’m ready to start working.


## Setup
Before bootsraping make sure to run as root user or with sudo.
```bash
sudo su -
```

If you want to bootstrap your system use
```bash
apt update
apt install -y git open-vm-tools open-vm-tools-desktop
# this line may change depending on what hypervisor you use, in this case it is VMware Fusion
git clone https://github.com/iypetrov/dev-config.git /root/projects/common/dev-config
cd /root/projects/common/dev-config
git remote set-url origin git@github.com:iypetrov/dev-config.git
cd /root
bash /root/projects/common/dev-config/main.sh
```

If you want to reload you config run
```bash
bash /root/projects/common/dev-config/main.sh
```
