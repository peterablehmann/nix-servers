{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.syncthing
    inputs.self.nixosModules.restic-server
    inputs.self.nixosModules.immich
    ./disko.nix
    ./dyndns.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
  services.qemuGuest.enable = true;
}
