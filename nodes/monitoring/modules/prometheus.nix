{ inputs
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
          scheme = "http";
          static_configs = [{
            targets = [
              "cache.xnee.net:9100"
              "mns.xnee.net:9100"
              "monitoring.xnee.net:9100"
              "sync.xnee.de:9100"
            ];
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
