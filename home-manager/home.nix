{
  pkgs,
  inputs,
  system,
  extra-pkgs,
  extra-aliases,
  ...
}:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "jkaye";
    homeDirectory = "/home/jkaye";
    sessionPath = [
      "$HOME/.local/bin"
    ];

    packages =
      with pkgs;
      [
        bash-language-server
        chromium
        firefox
        gimp
        joplin-desktop
        nemo
        jq
        spotify
        taplo
        xrdp
        yaml-language-server

        inputs.devenv.packages.${system}.default
      ]
      ++ extra-pkgs;

    file.".claude/commands".source = ../.claude/commands;
    file.".config/helix/languages.toml".source = ./helix-languages.toml;
  };

  programs.bash = {
    enable = true;
    shellAliases = inputs.devenv.lib.bashAliases // extra-aliases;

    profileExtra = ''
      if command -v setxkbmap >/dev/null 2>&1; then
        setxkbmap -option ctrl:swapcaps
      fi
      eval $(systemctl --user show-environment | grep SSH_AUTH_SOCK)
      export SSH_AUTH_SOCK
      export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
      export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
    '';

    bashrcExtra = ''
      ${(import ./bash-functions.nix).setPrompt}

      export PROMPT_COMMAND=set_prompt
      if [ -f "$HOME/.secrets" ]; then
        . "$HOME/.secrets"
      fi

      ${inputs.devenv.devShells.${system}.basic.shellHook}
    '';
  };

  programs.ssh = {
    enable = true;
    serverAliveInterval = 240;
    controlPath = "~/.ssh/master-%C";
    includes = [
      "code_gitpod.d/config"
    ];

    matchBlocks."*" = {
      forwardX11 = true;
      setEnv = {
        "TERM" = "xterm-256color";
      };
    };
  };

  programs.fzf.enable = true;

  programs.git = {
    enable = true;
    userName = "Jordan Kaye";
    userEmail = "jordan.kaye2@gmail.com";
    ignores = [
      "lsp-ai-chat.md"
    ];
  };

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}
