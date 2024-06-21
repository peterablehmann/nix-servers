{ pkgs
, ...
}:
{
  environment.systemPackages = [ pkgs.zfs ];
  networking.hostId = "b36972b5";
  boot = {
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false;
      forceImportAll = false;
      extraPools = [ "data" ];
    };
  };

  services.zfs = {
    autoScrub = {
      enable = true;
      interval = "monthly";
      pools = [ ]; # Empty List scrubs all mounted pools
    };
    autoSnapshot = {
      enable = true;
      flags = "-k -p -u";
      frequent = 4;
      hourly = 24;
      daily = 7;
      monthly = 12;
    };
    trim = {
      enable = true;
      interval = "weekly";
    };
  };
}
