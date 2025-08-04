{
  config,
  inputs,
  lib,
  ...
}:
let
  cfg = config.backup;
  mkResticConfig =
    {
      repository,
      environmentFile ? null,
      paths,
      exclude,
    }:
    {
      user = "root";
      initialize = true;
      inherit
        repository
        environmentFile
        paths
        exclude
        ;
      timerConfig = {
        OnCalendar = "*:00,30:00";
        Persistent = true;
        RandomizedDelaySec = "5m";
      };
      passwordFile = config.sops.secrets."backup/password".path;
    };
in
{
  options.backup = {
    paths = lib.mkOption {
      default = [ ];
    };
    exclude = lib.mkOption {
      default = [ ];
    };
  };

  config = lib.mkIf (cfg.paths != [ ]) {
    sops.secrets =
      let
        sopsFile = "${inputs.self}/secrets/common.yaml";
      in
      {
        "backup/ssh-key" = {
          inherit sopsFile;
        };
        "backup/password" = {
          inherit sopsFile;
        };
        "backup/wasabi" = {
          inherit sopsFile;
        };
        "backup/restic-server" = {
          inherit sopsFile;
        };
        "backup/hetzner-s3" = {
          inherit sopsFile;
        };
      };

    programs.ssh = {
      extraConfig = ''
        Host u371467.your-storagebox.de
          HostName u371467.your-storagebox.de
          IdentityFile ${config.sops.secrets."backup/ssh-key".path}
      '';
      knownHosts = {
        "u371467.your-storagebox.de".publicKey =
          "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
      };
    };
    services.restic.backups = {
      "hetzner" = mkResticConfig {
        repository = "sftp://u371467-sub2@u371467.your-storagebox.de:22//backup";
        inherit (cfg) paths exclude;
      };
      "wasabi" = mkResticConfig {
        repository = "s3:https://s3.eu-central-2.wasabisys.com/backup-xnee-net";
        environmentFile = config.sops.secrets."backup/wasabi".path;
        inherit (cfg) paths exclude;
      };
      "hetzner-s3" = mkResticConfig {
        repository = "s3:https://nbg1.your-objectstorage.com/backup-xnee-net";
        environmentFile = config.sops.secrets."backup/hetzner-s3".path;
        inherit (cfg) paths exclude;
      };
    }
    // (builtins.listToAttrs (
      lib.mapAttrsToList
        (name: host: {
          name = "${host.config.networking.hostName}";
          value = mkResticConfig {
            repository = "rest:https://restic.${host.config.networking.fqdn}/nix-servers";
            environmentFile = config.sops.secrets."backup/restic-server".path;
            inherit (cfg) paths exclude;
          };
        })
        (
          lib.filterAttrs (
            name: host:
            (host.config.networking.fqdn != config.networking.fqdn && host.config.services.restic.server.enable)
          ) inputs.self.nixosConfigurations
        )
    ));
  };
}
