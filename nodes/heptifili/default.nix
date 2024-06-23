{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.syncthing
    ./modules/zfs.nix
    ./modules/zfs-exporter.nix
    ./disko.nix
    ./dyndns.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
