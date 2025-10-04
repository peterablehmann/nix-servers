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
    hostName = "factorio";
    domain = "xnee.net";
    provider = "netcup";
    network = {
      ipv4 = {
        address = "159.195.8.19";
        prefixLength = 22;
        gateway = "159.195.8.1";
      };
      ipv6 = {
        address = "2a0a:4cc0:ff:321::1";
        prefixLength = 56;
        gateway = "fe80::1";
      };
    };
  };

  services.qemuGuest.enable = true;
}
