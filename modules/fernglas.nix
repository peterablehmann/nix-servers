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
          peers = {
            "2a0f:85c1:b7a::c0:1" = { };
            "2a01:4f8:1c1e:8464::1" = { };
            "2a0f:85c1:b7a::c0:2" = { };
            "2a01:4f8:1c1b:fec6::1" = { };
            "2a0f:85c1:b7a::c0:4" = { };
            "2a0c:b640:10::2:38" = { };
            "2a0f:85c1:b7a::c0:5" = { };
            "2a14:7c0:7000:312::1" = { };
            "2a0f:85c1:b7a::c0:6" = { };
            "2a01:4f8:1b7:730::2" = { };
          };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ bmpPort ];
}
