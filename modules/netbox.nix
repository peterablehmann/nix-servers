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
    plugins = python3Packages: with python3Packages; [ netbox-topology-views ];
    settings = {
      ALLOWED_HOSTS = [ domain ];
      # Remote authentication support
      REMOTE_AUTH_ENABLED = true;
      REMOTE_AUTH_BACKEND = "social_core.backends.open_id_connect.OpenIdConnectAuth";
      REMOTE_AUTH_HEADER = "HTTP_REMOTE_USER";
      REMOTE_AUTH_USER_FIRST_NAME = "HTTP_REMOTE_USER_FIRST_NAME";
      REMOTE_AUTH_USER_LAST_NAME = "HTTP_REMOTE_USER_LAST_NAME";
      REMOTE_AUTH_USER_EMAIL = "HTTP_REMOTE_USER_EMAIL";
      REMOTE_AUTH_AUTO_CREATE_USER = true;
      SOCIAL_AUTH_OIDC_ENDPOINT = "https://sso.xnee.net";
      SOCIAL_AUTH_OIDC_KEY = "981052f1-1325-4d6c-8dc6-bbbc706f0c83";
      LOGOUT_REDIRECT_URL = "https://netbox.xnee.net";
      PLUGINS = [ "netbox_topology_views" ];
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
