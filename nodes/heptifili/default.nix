{
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];
  services.qemuGuest.enable = true;

  services.rpcbind.enable = true;
}
