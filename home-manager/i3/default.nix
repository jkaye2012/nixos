
{
  lib,
  pkgs,
  ...
}:
let
  mod = "Mod4";
in {
  xresources.properties = {
    "Xcursor.size" = 16;
  };

  xsession = {
    enable = true;
    # profileExtra = ''
    #   xmodmap ~/.xmodmap
    # '';
    windowManager.i3 = {
      enable = true;
      config = {
        modifier = mod;

        fonts = { names = ["DejaVu Sans Mono" "FontAwesome 6"]; };

        startup = [
          # { command = "xmodmap ~/.xmodmap"; always = true; notification = false; }
          # { command = "exec --no-startup-id /usr/bin/setxkbmap -option 'ctrl:swapcaps'"; always = true; notification = false; }
          { command = "${pkgs.networkmanagerapplet}/bin/nm-applet"; always = true; notification = false; }
          { command = "${pkgs.xfce.xfce4-clipman-plugin}/bin/xfce4-clipman"; always = true; notification = false; }
          { command = "${pkgs.mate.mate-power-manager}/bin/mate-power-manager"; always = true; notification = false; }
        ];

        keybindings = lib.mkOptionDefault {
          "${mod}+d" = "exec ${pkgs.rofi}/bin/rofi -show run";
          "${mod}+Shift+d" = "exec ${pkgs.rofi}/bin/rofi -show window";
          "Print" = "exec ${pkgs.xfce.xfce4-screenshooter}/bin/xfce4-screenshooter -c -r -s /home/jkaye/Pictures/Screenshots";
          # "${mod}+x" = "exec sh -c '${pkgs.maim}/bin/maim -s | xclip -selection clipboard -t image/png'";
          # "${mod}+Shift+x" = "exec sh -c '${pkgs.i3lock}/bin/i3lock -c 222222 & sleep 5 && xset dpms force of'";

          "${mod}+x" = "exec i3lock -c 000000";

          # Focus
          "${mod}+j" = "focus left";
          "${mod}+k" = "focus down";
          "${mod}+l" = "focus up";
          "${mod}+semicolon" = "focus right";

          # Move
          "${mod}+Shift+j" = "move left";
          "${mod}+Shift+k" = "move down";
          "${mod}+Shift+l" = "move up";
          "${mod}+Shift+semicolon" = "move right";
        };

        bars = [
          {
            position = "top";
            statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs ${./i3status-rust.toml}";
            trayOutput = "primary";
          }
        ];
      };
    };
  };
}# {

#   home = {
#     username = "jkaye";
#     homeDirectory = "/home/jkaye";

#     packages = with pkgs; [
#       chromium
#       firefox
#       gimp
#       joplin-desktop
#       nemo
#       spotify
#       xrdp

#       inputs.devenv.packages.${system}.default
#     ] ++ extra-pkgs;

#     file.".config/helix/languages.toml".source = ./helix-languages.toml;
#   };

#   programs.alacritty = {
#     enable = true;
#     settings = import ./alacritty.nix;
#   };

#   programs.bash = {
#     enable = true;
#     shellAliases = inputs.devenv.lib.bashAliases;

#     profileExtra = ''
#       /usr/bin/setxkbmap -option ctrl:swapcaps
#       eval $(systemctl --user show-environment | grep SSH_AUTH_SOCK)
#       export SSH_AUTH_SOCK
#       export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
#       export XDG_DATA_DIRS="$HOME/.nix-profile/share:$XDG_DATA_DIRS"
#     '';

#     bashrcExtra = ''
#       ${(import ./bash-functions.nix).setPrompt}

#       export PROMPT_COMMAND=set_prompt
#       if [ -f "$HOME/.secrets" ]; then
#         . "$HOME/.secrets"
#       fi

#       ${inputs.devenv.devShells.${system}.default.shellHook}
#     '';
#   };

#   programs.fzf.enable = true;

#   programs.git = {
#     enable = true;
#     ignores = [
#       "lsp-ai-chat.md"
#     ];
#   };

#   programs.home-manager.enable = true;

#   home.stateVersion = "24.05";
# }
