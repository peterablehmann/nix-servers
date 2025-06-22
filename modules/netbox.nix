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
  sops.secrets."netbox/secret_key" = {
    sopsFile = "${inputs.self}/secrets/erik.yaml";
    owner = "netbox";
    group = "netbox";
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
    settings.ALLOWED_HOSTS = [ domain ];
  };

  systemd.services.nginx.serviceConfig = {
      SupplementaryGroups = [ config.systemd.services.netbox.serviceConfig.Group ];
      BindReadOnlyPaths = [ config.services.netbox.dataDir ];
    };

  backup.paths = [ config.services.netbox.dataDir ];
}
