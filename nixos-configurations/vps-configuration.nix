{ pkgs, hostname, ... }:
{
  imports = [
    ../hardware-configurations/${hostname}.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = hostname;
  networking.dhcpcd.IPv6rs = true;
  networking.dhcpcd.persistent = true;
  networking.tempAddresses = "disabled";
  networking.interfaces.ens3.tempAddress = "disabled";

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.X11Forwarding = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  time.timeZone = "America/Denver";

  environment.variables = {
    "COLORTERM" = "truecolor";
  };

  users.users.root = {
    isNormalUser = false;
  };

  users.users.jkaye = {
    isNormalUser = true;
    description = "Jordan Kaye";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
