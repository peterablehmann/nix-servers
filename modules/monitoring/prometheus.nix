{ config
, inputs
, lib
, ...
}:
{
  sops.secrets."prometheus/basic_auth" = {
    sopsFile = "${inputs.self}/secrets/ymir.yaml";
    owner = "prometheus";
  };

  services = {
    prometheus = {
      enable = true;
      port = 9001;
      checkConfig = "syntax-only";
      scrapeConfigs = [
        {
          job_name = "node-exporter";
          scrape_interval = "5s";
          scheme = "https";
          basic_auth = {
            username = "prometheus";
            password_file = config.sops.secrets."prometheus/basic_auth".path;
          };
          static_configs = [{
            targets = lib.mapAttrsToList (name: host: "node-exporter.${host.config.networking.fqdn}") (
              lib.filterAttrs (name: host: host.config.services.prometheus.exporters.node.enable) inputs.self.nixosConfigurations
            );
          }];
        }
        {
          job_name = "prometheus";
          scrape_interval = "5s";
          scheme = "http";
          static_configs = [{
            targets = [
              "monitoring.xnee.net:9001"
            ];
          }];
        }
      ];
    };
  };
}
