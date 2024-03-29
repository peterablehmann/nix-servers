{ config
, inputs
, ...
}:
{
  sops.secrets."basicAuth/password" = {
    sopsFile = "${inputs.self}/secrets/monitoring.yaml";
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
          static_configs = [{
            targets = [
              "mns.xnee.net"
              "monitoring.xnee.net"
              "sync.xnee.de"
            ];
          }];
          metrics_path = "/exporters/node-exporter/metrics";
          basic_auth = {
            username = "prometheus";
            password_file = config.sops.secrets."basicAuth/password".path;
          };
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
