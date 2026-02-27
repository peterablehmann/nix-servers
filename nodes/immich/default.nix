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
      ipv6 = {
        address = "2a01:4f8:1b7:730::6";
        prefixLength = 56;
        gateway = "2a01:4f8:1b7:700::1";
      };
    };
  };
}
