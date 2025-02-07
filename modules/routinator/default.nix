{ config
, pkgs
, lib
, ...
}:
let
  domain = "routinator.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
in
{
  imports = [ ./routinator.nix ];

  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://[::1]:8323";
    };
  };

  services.routinator.enable = true;
}
