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
    hostName = "radicale";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "192.168.48.9";
        prefixLength = 24;
        gateway = "192.168.48.1";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:731::9";
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
      proxyPass = "https://${builtins.elemAt config.services.radicale.settings.server.hosts 0}";
    };
  };

  systemd.services.radicale = {
    serviceConfig = {
      SupplementaryGroups = [ config.security.acme.certs.${config.networking.fqdn}.group ];
      BindReadOnlyPaths = [ config.security.acme.certs.${config.networking.fqdn}.directory ];
    };
  };

  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "[::1]:5232" ];
        ssl = true;
        certificate = "${config.security.acme.certs.${config.networking.fqdn}.directory}/fullchain.pem";
        key = "${config.security.acme.certs.${config.networking.fqdn}.directory}/key.pem";
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = "${./.htpasswd}";
        htpasswd_encryption = "bcrypt";
      };
      rights.type = "owner_only";
      storage = {
        type = "multifilesystem";
        filesystem_folder = "/var/lib/radicale/collections";
      };
    };
  };
  backup.paths = [ "/var/lib/radicale/collections" ];
}
