{ config, inputs, ... }:

let
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
          collector_type = "Bgp";
          bind = "[::]:179";
          default_peer_config = {
            asn = 65000;
            router_id = "255.255.255.255";
          };
          peers = {
            "2a0f:85c1:b7a::c0:1" = { };
            "2a0f:85c1:b7a::c0:2" = { };
            "2a0f:85c1:b7a::c0:4" = { };
            "2a0f:85c1:b7a::c0:5" = { };
            "2a0f:85c1:b7a::c0:6" = { };
          };
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 179 ];
}
