{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  domain = "immich.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
in
{
  config = {
    networking.domains.subDomains.${domain} = { };
    security.acme.certs.${domain} = { };
    services.nginx.virtualHosts."${domain}" = {
      useACMEHost = domain;
      kTLS = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://[${config.services.immich.host}]:${builtins.toString config.services.immich.port}";
      };
    };

    services.immich = {
      enable = true;
      host = "::1";
      settings.server.externalDomain = "https://${domain}";
    };

    backup.paths = [ config.services.immich.mediaLocation ];
  };
}
