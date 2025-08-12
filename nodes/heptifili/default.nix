{
  inputs,
  ...
}:
{
  imports = [
    inputs.self.nixosModules.netbox
    inputs.self.nixosModules.paperless
    inputs.self.nixosModules.powerdns
    inputs.self.nixosModules.radicale
    inputs.self.nixosModules.restic-server
    inputs.self.nixosModules.syncthing
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "heptifili";
    domain = "xnee.net";
    network = {
      link.MTUBytes = 9216;
      ipv4 = {
        address = "157.90.190.82";
        prefixLength = 29;
        gateway = "157.90.190.81";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:730::3";
        prefixLength = 56;
        gateway = "2a01:4f8:1b7:700::1";
      };
    };
  };

  services.qemuGuest.enable = true;
}
