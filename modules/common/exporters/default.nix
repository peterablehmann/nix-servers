{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./cloudprober
    ./node-exporter.nix
    ./smartctl-exporter.nix
  ];

  sops.secrets."vmagent/remoteWriteBasicAuth" = {
    sopsFile = "${inputs.self}/secrets/common.yaml";
    owner = "vmagent";
  };

  users.users.vmagent = {
    isSystemUser = true;
    group = "vmagent";
  };
  users.groups.vmagent = { };
  systemd.services.vmagent.serviceConfig = {
    DynamicUser = lib.mkForce false;
    User = "vmagent";
    Group = "vmagent";
  };

  environment.systemPackages = [ pkgs.victoriametrics ];

  services.vmagent = {
    enable = true;
    extraArgs = [
      "-enableTCP6"
      "-remoteWrite.basicAuth.passwordFile=${config.sops.secrets."vmagent/remoteWriteBasicAuth".path}"
    ];
    remoteWrite = {
      url = "https://vm.xnee.net/api/v1/write";
      basicAuthUsername = "vmrwusr";
      # basicAuthPasswordFile = config.sops.secrets."vmagent/remoteWriteBasicAuth".path;
    };
    prometheusConfig = {
      global.metric_relabel_configs = [
        {
          target_label = "instance";
          replacement = "${config.networking.fqdn}";
        }
      ];
    };
  };
}
