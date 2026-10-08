{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  domain = "vm.xnee.net";
in
{
  sops.secrets = {
    "prometheus/basic_auth" = {
      owner = "victoriametrics";
    };
    "prometheus/slsystems_basic_auth" = {
      owner = "victoriametrics";
    };
  };

  users.users.victoriametrics = {
    isSystemUser = true;
    group = "victoriametrics";
  };
  users.groups.victoriametrics = { };
  systemd.services.victoriametrics.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "victoriametrics";
    Group = "victoriametrics";
  };

  environment.systemPackages = [ pkgs.victoriametrics ];

  security.acme.certs."${domain}" = { };

  networking.domains.subDomains."${domain}" = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    basicAuthFile = pkgs.writeText "basicAuth.txt" ''
      vmrwusr:$2y$05$O4GYxP5rGO.gIMGyvBT8vOZsshTOFCspZi48yTVifO5phlQjEbTgS
    '';
    locations."/api/v1/write" = {
      proxyPass = "http://${config.services.victoriametrics.listenAddress}";
    };
  };

  services = {
    victoriametrics = {
      enable = true;
      extraOptions = [ "-enableTCP6" ];
      listenAddress = "[::1]:9001";
      retentionPeriod = "90d";
      prometheusConfig = {
        global.metric_relabel_configs = [
          {
            source_labels = [ "instance" ];
            target_label = "instance";
            regex = "(.+):(.+)";
            replacement = "$1";
          }
        ];
        scrape_configs = [
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
            scrape_interval = "15s";
            scheme = "http";
            static_configs = [
              {
                targets = [
                  "bbr00.nbg.de.mgmt.as213422.net:9100"
                  "bbr01.nbg.de.mgmt.as213422.net:9100"
                  "bbr01.dus.de.mgmt.as213422.net:9100"
                ];
              }
            ];
          }
          {
            job_name = "node-exporter-slsystems";
            scrape_interval = "15s";
            scheme = "https";
            basic_auth = {
              username = "prometheus";
              password_file = config.sops.secrets."prometheus/slsystems_basic_auth".path;
            };
            static_configs = [
              {
                targets = [
                  "node-exporter.pve-1.slsystems.org"
                  "node-exporter.pve-2.slsystems.org"
                  "node-exporter.pve-3.slsystems.org"
                ];
              }
            ];
          }
          {
            job_name = "frr-exporter";
            scrape_interval = "15s";
            scheme = "http";
            static_configs = [
              {
                targets = [
                  "bbr00.nbg.de.mgmt.as213422.net:9342"
                  "bbr01.nbg.de.mgmt.as213422.net:9342"
                  "bbr01.dus.de.mgmt.as213422.net:9342"
                ];
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
        ];
      };
    };
    vmagent.remoteWrite = {
      url = lib.mkForce "http://${config.services.victoriametrics.listenAddress}/api/v1/write";
      basicAuthUsername = lib.mkForce null;
      basicAuthPasswordFile = lib.mkForce null;
    };
  };
}
