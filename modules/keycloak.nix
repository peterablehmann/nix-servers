{
  inputs,
  config,
  ...
}:
let
  domain = "sso.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
in
{
  sops.secrets = {
    "keycloak/dbPassword" = {
      sopsFile = "${inputs.self}/secrets/ymir.yaml";
    };
  };

  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://[${config.services.keycloak.settings.http-host}]:${toString config.services.keycloak.settings.https-port}";
    };
  };

  systemd.services.keycloak = {
    serviceConfig = {
      SupplementaryGroups = [ config.security.acme.certs.${domain}.group ];
      BindReadOnlyPaths = [ tls-dir ];
    };
  };

  services.keycloak = {
    enable = true;
    sslCertificate = "${tls-dir}/fullchain.pem";
    sslCertificateKey = "${tls-dir}/key.pem";
    database = {
      createLocally = true;
      passwordFile = config.sops.secrets."keycloak/dbPassword".path;
    };
    settings = {
      hostname = "sso.xnee.net";
      hostname-backchannel-dynamic = false;
      http-host = "::1";
      https-port = 8333;
    };
  };
}
