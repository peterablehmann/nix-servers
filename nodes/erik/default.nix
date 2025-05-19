{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.pdns-recursor
    inputs.self.nixosModules.netbox
    inputs.self.nixosModules.syncthing
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
