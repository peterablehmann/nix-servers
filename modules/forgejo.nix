{
  config,
  lib,
  pkgs,
  ...
}:
let
  domain = "git.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs."${domain}" = { };

  services = {
    nginx = {
      enable = true;
      virtualHosts."${domain}" = {
        useACMEHost = domain;
        kTLS = true;
        forceSSL = true;
        extraConfig = ''
          client_max_body_size 512M;
        '';
        locations."/".proxyPass = "http://unix:${config.services.forgejo.settings.server.HTTP_ADDR}";
      };
    };
    forgejo = {
      enable = true;
      package = pkgs.forgejo;
      database.type = "postgres";
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = domain;
          ROOT_URL = "https://${config.services.forgejo.settings.server.DOMAIN}/";
          # SSH_PORT = lib.head config.services.openssh.ports;
          PROTOCOL = "http+unix";
        };
        actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "github";
        };
        webhook = {
          ALLOWED_HOST_LIST = "external,private";
        };
      };
    };
  };
  backup.paths = [
    config.services.forgejo.stateDir
  ];
}
