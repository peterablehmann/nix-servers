{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.syncthing
    inputs.self.nixosModules.restic-server
    ./modules/zfs.nix
    ./modules/zfs-exporter.nix
    ./disko.nix
    ./dyndns.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
