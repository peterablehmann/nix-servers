{ config, inputs, ... }:

let
  bmpPort = 11019;
  domain = "fernglas.xnee.net";
in
{
  imports = [
    inputs.fernglas.nixosModules.default
  ];

  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations = {
      "/".root = inputs.fernglas.packages.${config.nixpkgs.hostPlatform.system}.fernglas-frontend;
      "/api/".proxyPass = "http://${config.services.fernglas.settings.api.bind}";
    };
  };

  services.fernglas = {
    enable = true;
    settings = {
      api.bind = "[::1]:3000";
      collectors = {
        default = {
          collector_type = "Bmp";
          bind = "[::]:${toString bmpPort}";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ bmpPort ];
}
