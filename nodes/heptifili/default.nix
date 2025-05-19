{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.syncthing
    inputs.self.nixosModules.restic-server
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
  services.qemuGuest.enable = true;

  services.rpcbind.enable = true;
}
