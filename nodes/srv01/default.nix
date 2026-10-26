{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    inputs.self.nixosModules.immich
  ];

  metadata = {
    hostName = "srv01";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "157.90.190.82";
        prefixLength = 29;
      };
      ipv6 = {
        address = "2a01:4f8:1b7:732::5";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:732::1";
      };
    };
  };
}
