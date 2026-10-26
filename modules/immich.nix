{
  config,
  ...
}:
let
  domain = "immich.xnee.net";
in
{
  security.acme.certs.${domain} = { };
  networking.domains.subDomains."${domain}" = { };

  services = {

    nginx.virtualHosts."${domain}" = {
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

    immich = {
      enable = true;
      host = "::1";
      settings.server.externalDomain = "https://${domain}";
    };
  };

  backup.paths = [ config.services.immich.mediaLocation ];
}
