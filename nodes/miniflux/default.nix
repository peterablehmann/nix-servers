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
    hostName = "miniflux";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "192.168.48.13";
        prefixLength = 24;
        gateway = "192.168.48.1";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:731::d";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:731::1";
      };
    };
  };
  services.qemuGuest.enable = true;

  security.acme.certs."${config.networking.fqdn}" = { };

  services.nginx = {
    enable = true;
    virtualHosts."${config.networking.fqdn}" = {
      useACMEHost = config.networking.fqdn;
      kTLS = true;
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://${config.services.miniflux.config.LISTEN_ADDR}";
        };
      };
    };
  };

  services.miniflux = {
    enable = true;
    config = {
      BASE_URL = "https://${config.networking.fqdn}";
      CREATE_ADMIN = false;
      LISTEN_ADDR = "[::1]:8080";
    };
  };
}
