{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.immich
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "immich";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "192.168.48.6";
        prefixLength = 24;
        gateway = "192.168.48.1";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:731::6";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:731::1";
      };
    };
  };
}
