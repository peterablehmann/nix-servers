{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.pdns-recursor
    inputs.self.nixosModules.netbox
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
