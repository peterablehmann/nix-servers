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
}
