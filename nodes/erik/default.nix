{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.netbox
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
