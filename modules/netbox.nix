{ config
, inputs
, ...
}:
let
  domain = "netbox.xnee.net";
in
{
  nixpkgs.config.permittedInsecurePackages = [
    "netbox-3.6.9"
  ];

  sops.secrets."netbox/secret-key" = {
    sopsFile = "${inputs.self}/secrets/ymir.yaml";
    owner = "netbox";
    group = "netbox";
  };
  networking.domains.subDomains.${domain} = { };
  security.acme.certs."${domain}" = { };

  services.nginx = {
    enable = true;
    user = "netbox";
    virtualHosts."${domain}" = {
      enableACME = true;
      forceSSL = true;
      locations = {
        "/" = {
          proxyPass = "http://${config.services.netbox.listenAddress}:${builtins.toString config.services.netbox.port}";
        };
        "/static/" = { alias = "${config.services.netbox.dataDir}/static/"; };
      };
    };
  };

  services.netbox = {
    enable = true;
    secretKeyFile = config.sops.secrets."netbox/secret-key".path;
    settings.ALLOWED_HOSTS = [ domain ];
  };

  backup.paths = [ config.services.netbox.dataDir ];
}
