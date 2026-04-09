#!/bin/bash

if id nixbld &>/dev/null; then
  echo "Deleting user nixbld"
  sudo userdel nixbld
fi

if getent group nixbld &>/dev/null; then
  echo "Deleting group nixbld"
  sudo groupdel nixbld
fi

for i in {1..32}; do
  if id "nixbld$i" &>/dev/null; then
    echo "Deleting user nixbld$i"
    sudo userdel "nixbld$i"
  fi
done

wget -O /tmp/nix-install https://nixos.org/nix/install
chmod +x /tmp/nix-install
/tmp/nix-install --daemon --yes --nix-extra-conf-file "$HOME/.private-dotfiles/nix.conf"
sudo chown -R gitpod /nix
bash -l -c "nix-channel --add https://nixos.org/channels/nixos-25.11 nixpkgs &&
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager &&
nix-channel --update &&
nix-shell '<home-manager>' -A install &&
rm -rf ~/.config/home-manager/ ~/.bash_profile ~/.bashrc  &&
ln -s $HOME/.private-dotfiles $HOME/.config/home-manager &&
home-manager switch -b bak"
