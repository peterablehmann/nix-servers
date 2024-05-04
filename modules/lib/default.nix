{ inputs
, config
, ...
}:
let
  mkResticConfig = { repository, environmentFile ? null, paths, exclude ? [ ] }: {
    user = "root";
    initialize = true;
    inherit repository environmentFile paths exclude;
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
    passwordFile = config.sops.secrets."backup/password".path;
  };
in
{
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
    };

  programs.ssh = {
    extraConfig = ''
      Host u371467.your-storagebox.de
        HostName u371467.your-storagebox.de
        IdentityFile ${config.sops.secrets."backup/ssh-key".path}
    '';
    knownHosts = {
      "u371467.your-storagebox.de".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA5EB5p/5Hp3hGW1oHok+PIOH9Pbn7cnUiGmUEBrCVjnAw+HrKyN8bYVV0dIGllswYXwkG/+bgiBlE6IVIBAq+JwVWu1Sss3KarHY3OvFJUXZoZyRRg/Gc/+LRCE7lyKpwWQ70dbelGRyyJFH36eNv6ySXoUYtGkwlU5IVaHPApOxe4LHPZa/qhSRbPo2hwoh0orCtgejRebNtW5nlx00DNFgsvn8Svz2cIYLxsPVzKgUxs8Zxsxgn+Q/UvR7uq4AbAhyBMLxv7DjJ1pc7PJocuTno2Rw9uMZi1gkjbnmiOh6TTXIEWbnroyIhwc8555uto9melEUmWNQ+C+PwAK+MPw==";
    };
  };

  lib.mkBackup = { paths, exclude ? [ ] }: {
    "${config.networking.hostName}-hetzner" = mkResticConfig { repository = "sftp://u371467-sub2@u371467.your-storagebox.de:22//backup"; inherit paths exclude; };
  };
}
