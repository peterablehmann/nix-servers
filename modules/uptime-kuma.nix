{ config
, ...
}:
let
  domain = "kuma.xnee.net";
  tls-dir = config.security.acme.certs."${domain}".directory;
in
{
  security.acme.certs."${domain}" = { };
  networking.domains.subDomains.${domain} = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.uptime-kuma.settings.HOST}:${toString config.services.uptime-kuma.settings.PORT}";
    };
  };

  services.uptime-kuma = {
    enable = true;
    appriseSupport = true;
    settings = {
      HOST = "127.0.0.1";
      PORT = "3001";
      # SSL_KEY = "${tls-dir}/key.pem";
      # SSL_CERT = "${tls-dir}/fullchain.pem";
    };
  };
}
