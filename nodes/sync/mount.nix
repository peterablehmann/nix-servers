{ inputs
, pkgs
, config
, ...
}:
{
  sops.secrets."storagebox" = {
    neededForUsers = true;
    sopsFile = "${inputs.self}/secrets/mount.sync.yaml";
  };
  environment.systemPackages = [ pkgs.cifs-utils ];
  fileSystems."/mnt/share" = {
    device = "//u351929.your-storagebox.de/backup";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in
      [ "${automount_opts},uid=237,credentials=${config.sops.secrets."storagebox".path}" ];
  };
}
