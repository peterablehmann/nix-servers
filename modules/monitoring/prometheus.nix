{
  config,
  inputs,
  lib,
  ...
}:
{
  sops.secrets = {
    "prometheus/basic_auth" = {
      sopsFile = "${inputs.self}/secrets/ymir.yaml";
      owner = "prometheus";
    };
    "prometheus/mmp_basic_auth" = {
      sopsFile = "${inputs.self}/secrets/ymir.yaml";
      owner = "prometheus";
    };
  };

  services = {
    prometheus = {
      enable = true;
      listenAddress = "[::1]";
      port = 9001;
      checkConfig = "syntax-only";
      retentionTime = "90d";
      scrapeConfigs = [
        {
          job_name = "bgp-tools";
          scrape_interval = "10s";
          scheme = "https";
          metrics_path = "/prom/e0906115-d67d-4769-89e5-bf95748fa348";
          static_configs = [
            {
              targets = [ "prometheus.bgp.tools" ];
            }
          ];
        }
        {
          job_name = "node-exporter";
          scrape_interval = "5s";
          scheme = "https";
          basic_auth = {
            username = "prometheus";
            password_file = config.sops.secrets."prometheus/basic_auth".path;
          };
          static_configs = [
            {
              targets = [
                "node-exporter.myrkviar.xnee.net"
              ]
              ++ lib.mapAttrsToList (name: host: "node-exporter.${host.config.networking.fqdn}") (
                lib.filterAttrs (
                  name: host: host.config.services.prometheus.exporters.node.enable
                ) inputs.self.nixosConfigurations
              );
            }
          ];
        }
        {
          job_name = "node-exporter-as213422";
          scrape_interval = "5s";
          scheme = "http";
          static_configs = [
            {
              targets = [
                "access0.mgmt.as213422.net:9100"
                "core0.mgmt.as213422.net:9100"
                "core1.mgmt.as213422.net:9100"
                "edge0.mgmt.as213422.net:9100"
                "edge1.mgmt.as213422.net:9100"
                "edge2.mgmt.as213422.net:9100"
                "edge3.mgmt.as213422.net:9100"
              ];
            }
          ];
        }
        {
          job_name = "cloudprober";
          scrape_interval = "5s";
          scheme = "https";
          static_configs = [
            {
              targets = lib.mapAttrsToList (name: host: "cloudprober.${host.config.networking.fqdn}") (
                lib.filterAttrs (
                  name: host: host.config.services.cloudprober.enable
                ) inputs.self.nixosConfigurations
              );
            }
          ];
        }
        {
          job_name = "frr-exporter";
          scrape_interval = "5s";
          scheme = "http";
          static_configs = [
            {
              targets = [
                "access0.mgmt.as213422.net:9342"
                "core0.mgmt.as213422.net:9342"
                "core1.mgmt.as213422.net:9342"
                "edge0.mgmt.as213422.net:9342"
                "edge1.mgmt.as213422.net:9342"
                "edge2.mgmt.as213422.net:9342"
                "edge3.mgmt.as213422.net:9342"
              ];
            }
          ];
          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              regex = "(.*):\d+";
              target_label = "instance";
            }
          ];
        }
        {
          job_name = "offline-kollektiv-mmp";
          scrape_interval = "30s";
          scheme = "https";
          basic_auth = {
            username = "monitoring";
            password_file = config.sops.secrets."prometheus/mmp_basic_auth".path;
          };
          static_configs = [
            {
              targets = [
                "pdu01.nbg01.infra.aq0.de"
                "pdu02.nbg01.infra.aq0.de"
              ];
            }
          ];
        }
        {
          job_name = "smartctl-exporter";
          scrape_interval = "5m";
          scheme = "https";
          basic_auth = {
            username = "prometheus";
            password_file = config.sops.secrets."prometheus/basic_auth".path;
          };
          static_configs = [
            {
              targets = lib.mapAttrsToList (name: host: "smartctl-exporter.${host.config.networking.fqdn}") (
                lib.filterAttrs (
                  name: host: host.config.services.prometheus.exporters.smartctl.enable
                ) inputs.self.nixosConfigurations
              );
            }
          ];
        }
        {
          job_name = "transceiver-exporter";
          scrape_interval = "5s";
          scheme = "https";
          basic_auth = {
            username = "prometheus";
            password_file = config.sops.secrets."prometheus/basic_auth".path;
          };
          static_configs = [ { targets = [ "transceiver-exporter.myrkviar.xnee.net" ]; } ];
        }
        {
          job_name = "zfs-exporter";
          scrape_interval = "30s";
          scheme = "https";
          basic_auth = {
            username = "prometheus";
            password_file = config.sops.secrets."prometheus/basic_auth".path;
          };
          static_configs = [
            {
              targets = lib.mapAttrsToList (name: host: "zfs-exporter.${host.config.networking.fqdn}") (
                lib.filterAttrs (
                  name: host: host.config.services.prometheus.exporters.zfs.enable
                ) inputs.self.nixosConfigurations
              );
            }
          ];
        }
        {
          job_name = "restic";
          scrape_interval = "5s";
          scheme = "https";
          basic_auth = {
            username = "metrics";
            password_file = config.sops.secrets."prometheus/basic_auth".path;
          };
          static_configs = [
            {
              targets = lib.mapAttrsToList (name: host: "restic.${host.config.networking.fqdn}") (
                lib.filterAttrs (
                  name: host: host.config.services.restic.server.enable
                ) inputs.self.nixosConfigurations
              );
            }
          ];
        }
        {
          job_name = "routinator";
          scrape_interval = "2m";
          scheme = "https";
          static_configs = [
            {
              targets = [ "routinator.xnee.net" ];
            }
          ];
        }
        {
          job_name = "pdns-recursor";
          scrape_interval = "5s";
          scheme = "https";
          basic_auth = {
            username = "#";
            password_file = config.sops.secrets."prometheus/basic_auth".path;
          };
          static_configs = [
            {
              targets = lib.mapAttrsToList (name: host: "dns-rec.${host.config.networking.fqdn}") (
                lib.filterAttrs (
                  name: host: host.config.services.pdns-recursor.enable
                ) inputs.self.nixosConfigurations
              );
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
          static_configs = [
            {
              targets = [ "blackbox.xnee.net" ];
            }
          ];
        }
        {
          job_name = "prometheus";
          scrape_interval = "5s";
          scheme = "http";
          static_configs = [
            {
              targets = [
                "monitoring.xnee.net:9001"
              ];
            }
          ];
        }
      ];
    };
  };
}
