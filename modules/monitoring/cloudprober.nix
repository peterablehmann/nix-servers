{ config, pkgs, ... }:
let
  domain = "cloudprober.${config.networking.hostName}.xnee.net";
  cloudprober = pkgs.callPackage ./cloudprober-pkgs.nix { };
in
{
  imports = [
    ./cloudprober-module.nix
  ];

  security.acme.certs."${domain}" = { };

  networking.domains.subDomains."${domain}" = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/".proxyPass = "http://${config.services.cloudprober.settings.host}:9313";
  };

  services.cloudprober = {
    enable = true;
    package = cloudprober;
    settings = {
      host = "[::1]";
      probe = [
        {
          name = "ping";
          type = "PING";
          targets.host_names = "1.1.1.1,9.9.9.9,hetzner.com";
        }
        {
          name = "cert";
          type = "HTTP";
          http_probe = {
            scheme = "HTTPS";
            method = "GET";
          };
          targets.host_names = "hetzner.com";
        }
      ];
    };
  };
}
