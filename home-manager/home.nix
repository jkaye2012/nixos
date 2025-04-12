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
      chromium
      firefox
      gimp
      joplin-desktop
      nemo
      spotify
      xrdp

      inputs.devenv.packages.${system}.default
    ];

    file.".config/helix/languages.toml".source = ./helix-languages.toml;
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
      export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
    '';

    bashrcExtra = ''
      ${(import ./bash-functions.nix).setPrompt}

      export PROMPT_COMMAND=set_prompt
      . "$HOME/.secrets"
    '';
  };

  programs.fzf.enable = true;

  programs.git = {
    enable = true;
    ignores = [
      "lsp-ai-chat.md"
    ];
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}
