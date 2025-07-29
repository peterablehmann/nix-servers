{ config, inputs, ... }:
let
  domain = "sso.xnee.net";
in
{
  imports = [ inputs.authentik-nix.nixosModules.default ];

  networking.domains.subDomains.${domain} = { };
  security.acme.certs."${domain}" = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.authentik.settings.listen.http}";
      recommendedUwsgiSettings = true;
      proxyWebsockets = true;
    };
  };

  sops.secrets."authentik/environment".sopsFile =
    "${inputs.self}/secrets/${config.networking.hostName}.yaml";

  services.authentik = {
    enable = true;
    environmentFile = config.sops.secrets."authentik/environment".path;
    settings = {
      email = {
        host = "mail.your-server.de";
        port = 587;
        username = "sso@xnee.net";
        use_tls = true;
        use_ssl = false;
        from = "sso@xnee.net";
      };
      listen.http = "[::1]:9000";
      disable_startup_analytics = true;
      avatars = "initials";
    };
  };

}
