{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.pdns-recursor
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
