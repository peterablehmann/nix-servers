{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    inputs.self.nixosModules.restic-server
  ];

  metadata = {
    hostName = "storage1";
    domain = "xnee.net";
    provider = "netcup";
    network = {
      ipv4 = {
        address = "152.53.2.13";
        prefixLength = 22;
        gateway = "152.53.0.1";
      };
      ipv6 = {
        address = "2a0a:4cc0:0:1e46::1";
        prefixLength = 64;
        gateway = "fe80::1";
      };
    };
  };
}
