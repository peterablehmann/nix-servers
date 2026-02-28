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
        proxyWebsockets = true;
        extraConfig = ''
          client_max_body_size 50G;
          proxy_request_buffering off;
          client_body_buffer_size 1024k;
          proxy_read_timeout 600s;
          proxy_send_timeout 600s;
          send_timeout       600s;
        '';
      };
    };

    services.immich = {
      enable = true;
      host = "::1";
      settings.server.externalDomain = "https://${domain}";
      machine-learning.environment."MPLCONFIGDIR" = "${config.services.immich.mediaLocation}/.config/matplotlib";
    };

    backup.paths = [ config.services.immich.mediaLocation ];
  };
}
