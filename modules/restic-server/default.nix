{ config
, ...
}:
let
  domain = "restic.${config.networking.hostName}.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
in
{
  security.acme.certs."${domain}" = { };
  networking.domains.subDomains.${domain} = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://${config.services.restic.server.listenAddress}";
      extraConfig = "client_max_body_size 10G;";
    };
  };

  systemd.services.restic-rest-server = {
    serviceConfig = {
      SupplementaryGroups = [ config.security.acme.certs.${domain}.group ];
      BindReadOnlyPaths = [ tls-dir ];
    };
  };

  services.restic.server = {
    enable = true;
    dataDir = "/var/lib/restic";
    appendOnly = true;
    listenAddress = "[::1]:8000";
    privateRepos = true;
    extraFlags = [
      "--htpasswd-file=${./.htpasswd}"
      "--tls"
      "--tls-cert=${tls-dir}/fullchain.pem"
      "--tls-key=${tls-dir}/key.pem"
      ];
  };
}
