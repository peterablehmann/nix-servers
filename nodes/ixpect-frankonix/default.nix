{
  config,
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
      ipv6 = {
        address = "2a01:4f8:1b7:730::8";
        prefixLength = 56;
        gateway = "2a01:4f8:1b7:700::1";
      };
    };
  };

  sops.secrets."mail/pass".sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";

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
          arp_bogon = {
            enable = true;
            prefixes = [
              "193.34.203.192/26"
            ];
          };
          arp_neighbor = {
            enable = true;
            dynamic_enable = true;
          };
          bum_rate = {
            enable = true;
            window = "15s";
            thresholds = {
              broadcast = 500;
              multicast = 500;
              unicast = 500;
            };
          };
          ether_type = {
            enable = true;
            allowed_ether_types = [
              2048 # IPv4
              2054 # ARP
              34525 # IPv6
            ];
          };
          ipv6_bogon = {
            enable = true;
            prefixes = [
              "2001:7f8:15b:1::/64"
              "fe80::/10"
            ];
            ignore_link_local = true;
          };
          ipv6_neighbor = {
            enable = true;
            dynamic_enable = true;
          };
          ipv6_router.enable = true;
          stp.enable = true;
        };
        event.notifiers = {
          log = {
            enable = true;
            events = [
              "ARP_BOGON_SOURCE"
              "ARP_BOGON_TARGET"
              "ARP_NEIGHBOR_NEW_DYNAMIC"
              "ARP_NEIGHBOR_SPOOFED_DYNAMIC"
              "ARP_NEIGHBOR_SPOOFED_STATIC"
              "ARP_NEIGHBOR_UNKNOWN"
              "BUM_RATE_BROADCAST_EXCEEDED"
              "BUM_RATE_MULTICAST_EXCEEDED"
              "BUM_RATE_UNICAST_EXCEEDED"
              "ETHER_TYPE_VIOLATION"
              "IPV6_BOGON_SOURCE"
              "IPV6_BOGON_TARGET"
              "IPV6_NEIGHBOR_NEW_DYNAMIC"
              "IPV6_NEIGHBOR_SPOOFED_DYNAMIC"
              "IPV6_NEIGHBOR_SPOOFED_STATIC"
              "IPV6_NEIGHBOR_UNKNOWN"
              "IPV6_ROUTER_ADVERTISEMENT"
              "IPV6_ROUTER_SOLICITATION"
              "STP_PACKET_FOUND"
            ];
          };
          email = {
            enable = true;
            smtp = {
              host = "mail.your-server.de";
              port = 587;
              encryption = "TLS";
              auth = {
                mechanism = "PLAIN";
                user = "noreply@xnee.net";
                pass.file = config.sops.secrets."mail/pass".path;
              };
            };
            from = "noreply+ixpect@xnee.net";
            channels = [
              {
                to = [ "alert@as213422.net" ];
                events = [ "IPV6_ROUTER_ADVERTISEMENT" ];
              }
            ];
          };
        };
      };
    };
  };
}
