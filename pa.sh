#!/bin/bash
#
echo "ATUALIZANDO O SISTEMA"
sudo apt update -y
sudo apt upgrade -y
#
echo "INSTALANDO PACOTES"
sudo apt install build-essential dpkg-dev libpulse-dev git autoconf libtool -y
#
echo "BAIXANDO ARQUIVO GIT"
git clone https://github.com/sandross89/pulseaudio-module-xrdp.git
#
echo "CONFIGURANDO PULSE AUDIO"
cd ~/pulseaudio-module-xrdp/
scripts/install_pulseaudio_sources_apt_wrapper.sh
cd ~/pulseaudio-module-xrdp
sudo ./bootstrap
sudo ./configure PULSE_DIR=~/pulseaudio.src
make
sudo make install
#
