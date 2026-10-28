{ config, ... }:
let
  domain = "miniflux.xnee.net";
in
{
  security.acme.certs."${domain}" = { };
  networking.domains.subDomains."${domain}" = { };

  services = {
    nginx = {
      virtualHosts."${domain}" = {
        useACMEHost = domain;
        kTLS = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://${config.services.miniflux.config.LISTEN_ADDR}";
          };
        };
      };
    };

    miniflux = {
      enable = true;
      config = {
        BASE_URL = "https://${domain}";
        CREATE_ADMIN = false;
        LISTEN_ADDR = "[::1]:8080";
      };
    };
  };
}
