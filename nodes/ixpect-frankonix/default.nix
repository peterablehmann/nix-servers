{
  inputs,
  ...
}:
{
  imports = [
    inputs.ixpect.nixosModules.default
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

  networking.firewall.trustedInterfaces = [ "enx90a182722eb1" ];

  services = {
    qemuGuest.enable = true;
    redis.servers."".enable = true;
    ixpect = {
      enable = true;
      package = inputs.ixpect.packages.x86_64-linux.ixpect;
      capture.interface = "enx90a182722eb1";
      packetPoolSize = 128;
      redisUrl = "redis://localhost:6379";
      templateDir = ./templates;
      settings = {
        probes = {
          ipv6_router.enable = true;
          ether_type = {
            enable = true;
            allowed_ether_types = [
              2048 # IPv4
              2054 # ARP
              34525 # IPv6
            ];
          };
        };
        event.notifiers.log = {
          enable = true;
          events = [
            "IPV6_ROUTER_ADVERTISEMENT"
            "IPV6_ROUTER_SOLICITATION"
            "ETHER_TYPE_VIOLATION"
          ];
        };
      };
    };
  };
}
