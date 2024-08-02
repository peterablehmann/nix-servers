{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.syncthing
    inputs.self.nixosModules.restic-server
    inputs.self.nixosModules.nextcloud
    ./modules/zfs.nix
    ./modules/zfs-exporter.nix
    ./disko.nix
    ./dyndns.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
