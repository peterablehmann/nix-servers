{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "workstation-server";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        dns = false;
        address = "192.168.48.5";
        prefixLength = 24;
        gateway = "192.168.48.1";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:731::5";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:731::1";
      };
    };
  };
  services.qemuGuest.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    git
    nil
    npins
    shellcheck
    wireguard-tools
    jdk
    jujutsu
    (pkgs.callPackage ./vyconfigure.nix { })
    go
    golangci-lint
    gopls
    go-tools
  ];

  virtualisation.podman.enable = true;
}
