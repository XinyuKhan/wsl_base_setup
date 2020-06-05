#!/bin/bash

# only run as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

echo "->>>>>>>>>> Base Setup <<<<<<<<<<"

CALL_USER=${SUDO_USER:-${USER}}

sudo -H -u $CALL_USER bash -c ' \
    cp -rf ./resources /tmp/ \
'

# !! installing software utils..

echo "----> installing software utils.."
mv -f /etc/apt/sources.list /etc/apt/sources.list.bak
mv -f /tmp/resources/sources.list.trusted /etc/apt/sources.list

apt update && apt install -y ca-certificates

mv -f /etc/apt/sources.list /etc/apt/sources.list.trusted.bak
mv -f /tmp/resources/sources.list /etc/apt/sources.list



apt update && apt install -y\
    vim git python3.5 python3-pip openssh-server \
    unzip unrar wget curl libgl1-mesa-dev\
    software-properties-common apt-transport-https zsh \
    python3-tk mesa-utils libpcre3-dev xvfb clang cmake sudo;  \


dpkg-reconfigure openssh-server

echo $CALL_USER
ZSH_COFIG_SED_SCRIPT="s/##ZSH_USER##/$CALL_USER/"
CALL_USER_SCRIPT="sed -ri '$ZSH_COFIG_SED_SCRIPT' /tmp/resources/zshrc"
sudo -H -u $CALL_USER bash -c "$CALL_USER_SCRIPT"
CALL_USER_SCRIPT="cp -f /tmp/resources/zshrc /home/$CALL_USER/.zshrc"
sudo -H -u $CALL_USER bash -c "$CALL_USER_SCRIPT"
CALL_USER_SCRIPT="unzip -o /tmp/resources/oh-my-zsh.zip -d /home/$CALL_USER/.oh-my-zsh"
sudo -H -u $CALL_USER bash -c "$CALL_USER_SCRIPT"
CALL_USER_SCRIPT="cp -f /tmp/resources/vimrc /home/$CALL_USER/.vimrc"
sudo -H -u $CALL_USER bash -c "$CALL_USER_SCRIPT"
CALL_USER_SCRIPT="unzip -o /tmp/resources/vim.zip -d /home/$CALL_USER/.vim"
sudo -H -u $CALL_USER bash -c "$CALL_USER_SCRIPT"

chsh -s /bin/zsh $CALL_USER


# unzip -f /tmp/resources/oh-my-zsh.zip -d /home/$CALL_USER/.oh-my-zsh;chsh -s /bin/zsh;cp -f /tmp/resources/vimrc /home/$CALL_USER/.vimrc;unzip -f /tmp/resources/vim.zip -d /home/$CALL_USER/.vim;"

SSHD_CONFIG=/etc/ssh/sshd_config
sed -ri 's/^#?PasswordAuthentication\s+.*/PasswordAuthentication yes/' ${SSHD_CONFIG}
grep -q "AllowUsers ${CALL_USER}" ${SSHD_CONFIG} || echo "AllowUsers ${CALL_USER}" >> ${SSHD_CONFIG}

apt clean -y;

rm -rf /tmp/resources
