{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.pathvector
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
