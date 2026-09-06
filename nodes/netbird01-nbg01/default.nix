{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "netbird01-nbg01";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "192.168.48.4";
        prefixLength = 24;
        gateway = "192.168.48.1";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:731::4";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:731::1";
      };
    };
  };

  sops.secrets."netbird/setupKey" = {};

  services = {
    qemuGuest.enable = true;
    netbird.clients.router = {
      login = {
        enable = true;
        setupKeyFile = config.sops.secrets."netbird/setupKey".path;
      };
      environment = {
        "NB_ENABLE_LOCAL_FORWARDING" = "true";
      };
      port = 51833;
    };
  };
}
