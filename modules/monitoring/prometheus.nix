{ inputs
, lib
, ...
}:
{
  services = {
    prometheus = {
      enable = true;
      port = 9001;
      checkConfig = "syntax-only";
      scrapeConfigs = [
        {
          job_name = "node-exporter";
          scrape_interval = "5s";
          scheme = "http";
          static_configs = [{
            targets = lib.mapAttrsToList (name: host: "${host.config.networking.fqdn}:9100") (
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
