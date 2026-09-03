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
    hostName = "stigr";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "157.90.190.83";
        prefixLength = 29;
        gateway = "157.90.190.81";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:730::b";
        prefixLength = 56;
        gateway = "2a01:4f8:1b7:700::1";
      };
    };
  };

  services = {
    qemuGuest.enable = true;
    nginx.defaultListenAddresses = [ "[::1]" ];
    haproxy = {
      enable = true;
      config = ''
        frontend http-in
          mode tcp
          tcp-request inspect-delay 5s
          bind ${config.metadata.network.ipv4.address}:80
          bind [${config.metadata.network.ipv6.address}]:80
          default_backend http-local

        frontend https-in
          mode tcp
          tcp-request inspect-delay 5s
          bind ${config.metadata.network.ipv4.address}:443
          bind [${config.metadata.network.ipv6.address}]:443
          default_backend https-local

        backend http-local
          server local [::1]:80

        backend https-local
          server local [::1]:443
      '';
    };
  };
}
