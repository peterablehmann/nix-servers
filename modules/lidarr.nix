{
  config,
  pkgs,
  lib,
  ...
}:
let
  domain = "lidarr.xnee.net";
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
      proxyPass = "http://[${config.services.lidarr.settings.server.bindaddress}]:${builtins.toString config.services.lidarr.settings.server.port}";
    };
  };

  services.lidarr = {
    enable = true;
    settings.server = {
      bindaddress = "::1";
      port = 8686;
    };
  };
}
