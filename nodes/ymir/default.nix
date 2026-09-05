{
  config,
  inputs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
    inputs.self.nixosModules.monitoring
    inputs.self.nixosModules.kanidm
    inputs.self.nixosModules.pocket-id
    inputs.self.nixosModules.routinator
  ];

  metadata = {
    hostName = "ymir";
    domain = "xnee.net";
    provider = "hetzner-cloud";
    network = {
      ipv4 = {
        address = "128.140.9.158";
        prefixLength = 32;
        gateway = "172.31.1.1";
      };
      ipv6 = {
        address = "2a01:4f8:c2c:17c9::1";
        prefixLength = 64;
        gateway = "fe80::1";
      };
    };
  };

  routinator.domain = "routinator.${config.metadata.domain}";
}
