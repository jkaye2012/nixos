{ pkgs, inputs, ... }:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "jkaye";
    homeDirectory = "/home/jkaye";

    packages = with pkgs; [
      firefox
      gimp
      joplin-desktop
      inputs.devenv.packages.${system}.default
    ];
  };

  programs.alacritty = {
    enable = true;
    settings = import ./alacritty.nix;
  };

  programs.bash = {
    enable = true;
    shellAliases = inputs.devenv.lib.bashAliases;

    profileExtra = ''
      /usr/bin/setxkbmap -option ctrl:swapcaps
      eval $(systemctl --user show-environment | grep SSH_AUTH_SOCK)
      export SSH_AUTH_SOCK
      export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
    '';

    bashrcExtra = ''
      ${(import ./bash-functions.nix).setPrompt}

      export PROMPT_COMMAND=set_prompt
      . "$HOME/.secrets"
    '';
  };

  programs.fzf.enable = true;

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}
