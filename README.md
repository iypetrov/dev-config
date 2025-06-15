# dev-config

Before bootsraping make sure to run as root user or with sudo.
```bash
sudo su
```

If you want to bootstrap your system use
```bash
apt update
apt install -y git open-vm-tools open-vm-tools-desktop
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
