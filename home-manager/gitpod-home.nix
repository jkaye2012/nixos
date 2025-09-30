{
  pkgs,
  inputs,
  system,
  extra-pkgs,
  ...
}:
{
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "gitpod";
    homeDirectory = "/home/gitpod";

    packages =
      with pkgs;
      [
        bash-language-server
        jq
        taplo
        yaml-language-server

        inputs.devenv.packages.${system}.default
      ]
      ++ extra-pkgs;

    file.".claude/commands".source = ../.claude/commands;
    file.".config/helix/languages.toml".source = ./helix-languages.toml;
  };

  programs.bash = {
    enable = true;
    shellAliases = inputs.devenv.lib.bashAliases;

    profileExtra = ''
      export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
      export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
      export EDITOR=hx
      export GIT_EDITOR=hx

      if [[ -n $SSH_CONNECTION ]]; then cd "$GITPOD_REPO_ROOT"; fi
    '';

    bashrcExtra = ''
      ${(import ./bash-functions.nix).setPrompt}

      export PROMPT_COMMAND=set_prompt
      if [ -f "$HOME/.secrets" ]; then
        . "$HOME/.secrets"
      fi

      ${inputs.devenv.devShells.${system}.default.shellHook}
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
