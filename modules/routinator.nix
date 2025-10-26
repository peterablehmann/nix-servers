{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  cfg = config.routinator;
  tls-dir = config.security.acme.certs.${cfg.domain}.directory;
in
{
  options.routinator.domain = mkOption {
    type = types.str;
    description = "The domain name for the Routinator RPKI server.";
  };
  config = {
    networking.domains.subDomains.${cfg.domain} = { };
    security.acme.certs.${cfg.domain} = { };
    services.nginx.virtualHosts."${cfg.domain}" = {
      useACMEHost = cfg.domain;
      kTLS = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "https://[::1]:8323";
      };
    };

    systemd.services.routinator = {
      serviceConfig = {
        SupplementaryGroups = [ config.security.acme.certs.${cfg.domain}.group ];
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
  };
}
