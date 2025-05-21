{
  config,
  ...
}:
let
  domain = "immich.xnee.net";
in
{
  security.acme.certs."${domain}" = { };
  networking.domains.subDomains.${domain} = { };

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
    mediaLocation = "/var/lib/immich";
    host = "::1";
    port = 2283;
    redis.enable = true;
    database = {
      enable = true;
      createDB = true;
    };
    settings.server.externalDomain = "https://${domain}";
    machine-learning.enable = true;
  };

  backup.paths = [ config.services.immich.mediaLocation ];
}
