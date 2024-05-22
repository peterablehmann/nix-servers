{ config
, inputs
, ...
}:
let
  domain = "paperless.xnee.net";
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts."${domain}" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.paperless.address}:${builtins.toString config.services.paperless.port}";
    };
  };

  sops.secrets."paperless/password" = {
    sopsFile = "${inputs.self}/secrets/ymir.yaml";
  };

  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets."paperless/password".path;
    extraConfig = {
      PAPERLESS_ADMIN_USER = "peter";
    };
  };

  backup.paths = [ config.services.paperless.dataDir ];
}
