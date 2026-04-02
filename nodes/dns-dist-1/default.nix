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
    hostName = "dns-dist-1";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv6 = {
        address = "2a01:4f8:1b7:730::10";
        prefixLength = 56;
        gateway = "2a01:4f8:1b7:700::1";
      };
    };
  };
}
