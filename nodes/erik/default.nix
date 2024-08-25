{ inputs
, ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
