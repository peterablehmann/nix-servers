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

  systemd.services.routinator = {
    serviceConfig = {
      SupplementaryGroups = [ config.security.acme.certs.${domain}.group ];
      BindReadOnlyPaths = [ tls-dir ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8282 ];

  services.routinator = {
    enable = true;
    settings = {
      http-tls-listen = [ "[::1]:8323" ];
      http-tls-key = "${tls-dir}/key.pem";
      http-tls-cert = "${tls-dir}/fullchain.pem";
      rtr-listen = [ "[::]:8282" ];
    };
  };
}
