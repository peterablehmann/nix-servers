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
        address = "157.90.190.84";
        prefixLength = 29;
        gateway = "157.90.190.81";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:730::9";
        prefixLength = 56;
        gateway = "2a01:4f8:1b7:700::1";
      };
    };
  };
  systemd.network = {
    enable = true;
    networks = {
      "20-mgmt" = {
        networkConfig = {
          DHCP = false;
          IPv6AcceptRA = false;
        };
        matchConfig.Name = "enp0s19";
        address = [ "192.168.104.2" ];
      };
    };
  };
  services.tailscale.extraUpFlags = [ "--advertise-routes=192.168.104.0/24" ];
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
