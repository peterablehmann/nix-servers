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
      slsvmrwusr:$2y$05$I2Bmkxiw3ioFcdK.uvk/P.iH8pZOljWdrxcKtAY0Ckjj4jjrN2BNu
    '';
    locations."/api/v1/write" = {
      proxyPass = "http://${config.services.victoriametrics.listenAddress}";
    };
  };

  services = {
    victoriametrics = {
      enable = true;
      extraOptions = [
        "-enableTCP6"
        "-dedup.minScrapeInterval=15s"
      ];
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
            job_name = "node-exporter";
            scrape_interval = "15s";
            scheme = "http";
            static_configs = [
              {
                targets = [
                  "bbr00.nbg.de.mgmt.as213422.net:9100"
                  "bbr01.nbg.de.mgmt.as213422.net:9100"
                  "bbr01.dus.de.mgmt.as213422.net:9100"
                  "r1.priv.nbg01.xnee.net:9100"
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
