#!/bin/bash

wget -O /tmp/nix-install https://nixos.org/nix/install
chmod +x /tmp/nix-install
/tmp/nix-install --daemon --yes --nix-extra-conf-file ./nix.conf
sudo chown -R gitpod /nix
bash -l -c "nix-channel --add https://nixos.org/channels/nixos-25.05 nixpkgs"
bash -l -c "nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager"
bash -l -c "nix-channel --update"
bash -l -c "nix-shell '<home-manager>' -A install"
rm -rf ~/.config/home-manager/ ~/.bash_profile ~/.bashrc 
ln -s $HOME/.dotfiles $HOME/.config/home-manager
bash -l -c "home-manager switch"
