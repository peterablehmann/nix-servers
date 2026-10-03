{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "netbox";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "192.168.48.8";
        prefixLength = 24;
        gateway = "192.168.48.1";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:731::8";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:731::1";
      };
    };
  };
  sops.secrets = {
    "netbox/secret_key" = {
      owner = "netbox";
      group = "netbox";
    };
    "netbox/environment" = {
      owner = "netbox";
      group = "netbox";
    };
  };

  security.acme.certs."${config.networking.fqdn}" = { };

  services = {
    qemuGuest.enable = true;
    nginx = {
      enable = true;
      virtualHosts."${config.networking.fqdn}" = {
        useACMEHost = config.networking.fqdn;
        kTLS = true;
        forceSSL = true;
        locations = {
          "/" = {
            proxyPass = "http://${config.services.netbox.bind}";
          };
          "/static/" = {
            alias = "${config.services.netbox.dataDir}/static/";
          };
        };
      };
    };

    netbox = {
      enable = true;
      package = pkgs.netbox;
      secretKeyFile = config.sops.secrets."netbox/secret_key".path;
      plugins = python3Packages: with pkgs.netboxPlugins; [ netbox-topology-views ];
      settings = {
        ALLOWED_HOSTS = [ config.networking.fqdn ];
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
