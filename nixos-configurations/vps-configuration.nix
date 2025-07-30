{ pkgs, hostname, ... }:
{
  imports = [
    ../hardware-configurations/${hostname}.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking = {
    hostName = hostname;
    dhcpcd.IPv6rs = true;
    dhcpcd.persistent = true;
    interfaces.ens3.tempAddress = "disabled";
    firewall.allowedTCPPorts = [ 22 ];
    tempAddresses = "disabled";
  };

  services.openssh = {
    enable = true;

    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };

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

    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDdmVTIFpeY8sXxJupx5egTsb7jnkxkaz7li68RHjF03tDb/9WwpgrIFNcAXR114AlOqIz71s6egkrSG7mPRyVt1cNTjEouwCQDXKE0SZJRibhIxlgL2htRfPIj9xrUjehm8US8csioI2x7ymMi+u0qYv4jxW06eVvemHOvB4MN7RhxAnqNiXik/ng2JglgW3znG7KEbmFvARJqsXFCE7W/G/gS/veOkEumjnyHioz+x8SFe0Nm8cjHH0GBH1ueGP5uhtiGqI84/khMDFAga7iEC7FmWRQlb79F1Oc0lit6Iw+TPWt5s9KLE07wP2AsBG3lRx7PIdzuqHYFaU6qsLYRATtYRv8IPjeU60yBIR6NMLB4EWYVoD/PEAT/LJtaNKvvsXs0lt6WUr5BKQGPz4n1GTZlHMh5gYeHCnd0hzu/zai7rNSC5wHSRgsOPHjQm3wC0LkJ2WiMnRBO4djbWOtUhGOssVqi4H7fAd1ves2rJdVj0tbUfg5ucVcZX/U7b+0= jkaye@jkaye-framework"
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
