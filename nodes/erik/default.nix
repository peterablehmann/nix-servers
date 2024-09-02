{ inputs
, ...
}:
{
  imports = [
    inputs.self.nixosModules.unbound
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
