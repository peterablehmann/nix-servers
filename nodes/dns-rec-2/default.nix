{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "dns-rec-2";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv6 = {
        address = "2a01:4f8:1b7:730::13";
        prefixLength = 56;
        gateway = "2a01:4f8:1b7:700::1";
      };
    };
  };
}
