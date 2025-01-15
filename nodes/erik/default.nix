{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.pdns-recursor
    inputs.self.nixosModules.fah
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
