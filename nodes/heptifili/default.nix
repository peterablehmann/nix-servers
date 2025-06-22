{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.syncthing
    inputs.self.nixosModules.netbox
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  metadata = {
    ipv4 = false;
    ipv6 = true;
  };

  services.qemuGuest.enable = true;
}
