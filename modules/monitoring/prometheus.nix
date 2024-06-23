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
      retentionTime = "90d";
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
          job_name = "zfs-exporter";
          scrape_interval = "30s";
          scheme = "https";
          basic_auth = {
            username = "prometheus";
            password_file = config.sops.secrets."prometheus/basic_auth".path;
          };
          static_configs = [{
            targets = lib.mapAttrsToList (name: host: "zfs-exporter.${host.config.networking.fqdn}") (
              lib.filterAttrs (name: host: host.config.services.prometheus.exporters.zfs.enable) inputs.self.nixosConfigurations
            );
          }];
        }
        {
          job_name = "certs";
          scrape_interval = "5m";
          basic_auth = {
            username = "prometheus";
            password_file = config.sops.secrets."prometheus/basic_auth".path;
          };
          metrics_path = "/probe";
          params = {
            module = [ "certs" ];
          };
          static_configs = [{
            targets = lib.flatten (lib.mapAttrsToList (n: v: builtins.attrNames v.config.security.acme.certs) inputs.self.nixosConfigurations);
          }];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__param_target" ];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = "blackbox.xnee.net";
            }
          ];
        }
        {
          job_name = "blackbox_exporter";
          scrape_interval = "1m";
          basic_auth = {
            username = "prometheus";
            password_file = config.sops.secrets."prometheus/basic_auth".path;
          };
          static_configs = [{
            targets = [ "blackbox.xnee.net" ];
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
