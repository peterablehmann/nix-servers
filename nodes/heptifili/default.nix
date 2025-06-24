{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.fernglas
    inputs.self.nixosModules.netbox
    inputs.self.nixosModules.syncthing
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
  ];

  metadata = {
    ipv4 = true;
    ipv6 = true;
  };

  services.qemuGuest.enable = true;
}
