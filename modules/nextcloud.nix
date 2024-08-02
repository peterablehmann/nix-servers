{ config
, inputs
, pkgs
, ...
}:
let
  domain = "cloud.xnee.net";
in
{
  security.acme = {
    defaults.email = "acme@xnee.net";
    acceptTerms = true;
    certs."${domain}" = { };
  };

  networking.domains.subDomains."${domain}" = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    forceSSL = true;
  };

  sops.secrets = let
    owner = "nextcloud";
  in
  {
    "nextcloud/adminpass" = {
      sopsFile = "${inputs.self}/secrets/heptifili.yaml";
      inherit owner;
    };
  };

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    hostName = domain;
    https = true;
    maxUploadSize = "10G";
    configureRedis = true;
    caching.redis = true;
    config = {
      dbtype = "sqlite";
      adminuser = "technikfuzzi";
      adminpassFile = config.sops.secrets."nextcloud/adminpass".path;
    };
    settings = {
      default_phone_region = "DE";
      log_type = "syslog";
    };
  };
}
