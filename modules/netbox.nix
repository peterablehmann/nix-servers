{
  config,
  inputs,
  pkgs,
  ...
}:
let
  domain = "netbox.xnee.net";
in
{
  sops.secrets = {
    "netbox/secret_key" = {
      sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";
      owner = "netbox";
      group = "netbox";
    };
    "netbox/environment" = {
      sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";
      owner = "netbox";
      group = "netbox";
    };
  };
  networking.domains.subDomains.${domain} = { };
  security.acme.certs."${domain}" = { };

  services.nginx = {
    enable = true;
    virtualHosts."${domain}" = {
      useACMEHost = domain;
      kTLS = true;
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://${config.services.netbox.listenAddress}:${builtins.toString config.services.netbox.port}";
        };
        "/static/" = {
          alias = "${config.services.netbox.dataDir}/static/";
        };
      };
    };
  };

  services.netbox = {
    enable = true;
    package = pkgs.netbox;
    secretKeyFile = config.sops.secrets."netbox/secret_key".path;
    settings = {
      ALLOWED_HOSTS = [ domain ];
      REMOTE_AUTH_ENABLED = "True";
      REMOTE_AUTH_BACKEND = "social_core.backends.open_id_connect.OpenIdConnectAuth";
      SOCIAL_AUTH_OIDC_DISPLAY = "Kanidm";
      SOCIAL_AUTH_OIDC_OIDC_ENDPOINT = "https://idm.xnee.net/oauth2/openid/netbox";
      SOCIAL_AUTH_OIDC_KEY = "netbox";
      SOCIAL_AUTH_OIDC_JWT_ALGORITHMS = [ "ES256" ];
    };
    extraConfig = ''
      from os import environ
      SOCIAL_AUTH_OIDC_SECRET = environ.get('SOCIAL_AUTH_OIDC_SECRET')
    '';
  };

  systemd.services = {
    netbox.serviceConfig.EnvironmentFile = config.sops.secrets."netbox/environment".path;
    nginx.serviceConfig = {
      SupplementaryGroups = [ config.systemd.services.netbox.serviceConfig.Group ];
      BindReadOnlyPaths = [ config.services.netbox.dataDir ];
    };
  };

  backup.paths = [ config.services.netbox.dataDir ];
}
