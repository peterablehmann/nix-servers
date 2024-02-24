{config
, inputs
, ...
}:
let
  domain = "monitoring.xnee.net";
in
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
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__address__";
              replacement = "metrics.$1";
            }
          ];
          metrics_path = "/node";
          basic_auth = {
            username = "prometheus";
            password_file = config.sops.secrets."basicAuth/password".path;
          };
        }
      ];
    };
  };
}
