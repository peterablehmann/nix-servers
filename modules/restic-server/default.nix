{ config
, ...
}:
let
  domain = "restic.${config.networking.hostName}.xnee.net";
in
{
  security.acme.certs."${domain}" = { };
  networking.domains.subDomains.${domain} = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.restic.server.listenAddress}";
    };
  };

  services.restic.server = {
    enable = true;
    dataDir = "/var/lib/restic";
    appendOnly = true;
    listenAddress = "127.0.0.1:8000";
    privateRepos = true;
    extraFlags = [ "--htpasswd-file=${./.htpasswd}" ];
  };
}
