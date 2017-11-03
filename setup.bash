#!/bin/bash -eu

echo "export LANG=ja_JP.UTF-8" >> $HOME/.bashrc

echo "==================== ADD APT-KEYS ===================="
wget -q https://www.ubuntulinux.jp/ubuntu-ja-archive-keyring.gpg -O- | sudo apt-key add -
wget -q https://www.ubuntulinux.jp/ubuntu-jp-ppa-keyring.gpg -O- | sudo apt-key add -

echo "==================== ADD APT-SOUCES ===================="
sudo wget https://www.ubuntulinux.jp/sources.list.d/artful.list -O /etc/apt/sources.list.d/ubuntu-ja.list

echo "==================== UPDATE OS AND PACKAGES ===================="
sudo apt update -y
sudo apt dist-upgrade -y

echo "==================== INSTALL JAPANESE-PACKAGES ===================="
sudo apt install -y ubuntu-defaults-ja

echo "==================== FINISHED ===================="
echo "--> The setup was finished."
echo "--> This machine is rebooted automatically by soon."
sleep 10
sudo systemctl reboot -i
