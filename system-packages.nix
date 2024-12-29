{ pkgs, inputs, system, ... }:
{
  environment.systemPackages = with pkgs; [
    blueman
    fuse
    git
    inputs.devenv.packages.${system}.default
    inputs.ghostty.packages.${system}.default
    p7zip
    rofi
    runelite
    vim
  ];
}
