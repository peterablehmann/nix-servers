{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.netbox
    inputs.self.nixosModules.syncthing
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
