{
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.routinator
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "rpki0";
    domain = "as213422.net";
    provider = "proxmox.xnee.net-as213422";
    network = {
      link.MTUBytes = 1400;
      ipv6 = {
        address = "2a0f:6283:1400:1::5";
        prefixLength = 64;
        gateway = "fe80::1";
      };
    };
  };

  services.qemuGuest.enable = true;

  routinator.domain = "rpki0.${config.metadata.domain}";
}
