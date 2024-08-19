{ inputs
, ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    ./networking.nix
    inputs.self.nixosModules.monitoring
    inputs.self.nixosModules.kanidm
    inputs.self.nixosModules.keycloak
    inputs.self.nixosModules.paperless
    inputs.self.nixosModules.radicale
  ];
}
