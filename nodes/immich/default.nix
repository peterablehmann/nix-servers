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
    hostName = "immich";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "192.168.48.12";
        prefixLength = 24;
        gateway = "192.168.48.1";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:731::c";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:731::1";
      };
    };
  };
  services.qemuGuest.enable = true;

  security.acme.certs.${config.networking.fqdn} = { };
  services.nginx.virtualHosts."${config.networking.fqdn}" = {
    useACMEHost = config.networking.fqdn;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[${config.services.immich.host}]:${builtins.toString config.services.immich.port}";
      proxyWebsockets = true;
      extraConfig = ''
        client_max_body_size 50G;
        proxy_request_buffering off;
        client_body_buffer_size 1024k;
        proxy_read_timeout 600s;
        proxy_send_timeout 600s;
        send_timeout       600s;
      '';
    };
  };

  services.immich = {
    enable = true;
    host = "::1";
    settings.server.externalDomain = "https://${config.networking.fqdn}";
  };

  backup.paths = [ config.services.immich.mediaLocation ];
}
