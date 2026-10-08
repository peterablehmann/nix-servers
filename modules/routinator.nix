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
        proxyPass = "http://[::1]:8323";
      };
    };

    systemd.services.routinator = {
      serviceConfig = {
        SupplementaryGroups = [ config.security.acme.certs.${cfg.domain}.group ];
        BindReadOnlyPaths = [ tls-dir ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 8282 ];

    services = {
      routinator = {
        enable = true;
        settings = {
          http-listen = [ "[::1]:8323" ];
          rtr-listen = [ "[::]:8282" ];
          enable-aspa = true;
        };
      };
      vmagent.prometheusConfig.scrape_configs = [
        {
          job_name = "routinator";
          scrape_interval = "15s";
          scheme = "http";
          metric_relabel_configs = [
            {
              target_label = "instance";
              replacement = "${cfg.domain}";
            }
          ];
          static_configs = [
            {
              targets = [ "[::1]:8323" ];
            }
          ];
        }
      ];
    };
  };
}
