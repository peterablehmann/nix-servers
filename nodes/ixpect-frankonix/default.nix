{
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "ixpect-frankonix";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "157.90.190.86";
        prefixLength = 29;
        gateway = "157.90.190.81";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:730::8";
        prefixLength = 56;
        gateway = "2a01:4f8:1b7:700::1";
      };
    };
  };

  services.qemuGuest.enable = true;
}
