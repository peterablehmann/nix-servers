{ inputs
, ...
}:
{
  imports = [
    ./modules/zfs.nix
    ./disko.nix
    ./dyndns.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
}
