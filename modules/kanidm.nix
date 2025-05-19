{ config
, pkgs
, ...
}:
let
  domain = "idm.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://${config.services.kanidm.serverSettings.bindaddress}";
    };
  };

  systemd.services.kanidm = {
    serviceConfig = {
      SupplementaryGroups = [ config.security.acme.certs.${domain}.group ];
      BindReadOnlyPaths = [ tls-dir ];
      BindPaths = [ "/run/kanidm:/run/kanidm" ];
    };
  };

  services.kanidm = {
    package = pkgs.kanidm_1_6;
    enableClient = true;
    clientSettings = {
      uri = "https://${domain}";
      verify_ca = true;
      verify_hostnames = true;
    };
    enableServer = true;
    serverSettings = {
      version = "2";
      bindaddress = "[::]:8443";
      ldapbindaddress = "[::]:3636";
      tls_chain = "${tls-dir}/fullchain.pem";
      tls_key = "${tls-dir}/key.pem";
      inherit domain;
      origin = "https://${config.services.kanidm.serverSettings.domain}";
      online_backup = {
        path = "/var/lib/kanidm/backups/";
        schedule = "00 22 * * *";
      };
    };
  };
  backup.paths = [ config.services.kanidm.serverSettings.online_backup.path ];
}
