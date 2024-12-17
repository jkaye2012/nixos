{ pkgs, ... }: 
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
      joplin-desktop
    ];
  };

  programs.alacritty = {
    enable = true;
    settings = import ./alacritty.nix;
  };

  programs.bash = {
    enable = true;
    shellAliases = import ./aliases.nix;
  };

  programs.fzf.enable = true;

  programs.home-manager.enable = true;

  home.stateVersion = "24.05";
}
