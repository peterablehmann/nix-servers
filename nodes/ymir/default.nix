{
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
    inputs.self.nixosModules.monitoring
    inputs.self.nixosModules.kanidm
    inputs.self.nixosModules.paperless
    inputs.self.nixosModules.radicale
    inputs.self.nixosModules.routinator
  ];

  metadata = {
    ipv4 = true;
    ipv6 = true;
  };
}
