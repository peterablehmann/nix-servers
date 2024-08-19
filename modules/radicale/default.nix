{ config
, ...
}:
let
  domain = "radicale.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://${builtins.elemAt config.services.radicale.settings.server.hosts 0}";
    };
  };

  systemd.services.radicale = {
    serviceConfig = {
      SupplementaryGroups = [ config.security.acme.certs.${domain}.group ];
      BindReadOnlyPaths = [ tls-dir ];
    };
  };

  services.radicale = {
    enable = true;
    settings = {
      server = {
        hosts = [ "[::1]:5232" ];
        ssl = true;
        certificate = "${tls-dir}/fullchain.pem";
        key = "${tls-dir}/key.pem";
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
