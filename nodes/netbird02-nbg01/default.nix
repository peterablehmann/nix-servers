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
    hostName = "netbird02-nbg01";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv6 = {
        address = "2a01:4f8:1b7:735::5";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:735::1";
      };
    };
  };

  sops.secrets."netbird/setupKey" = { };

  networking.firewall.allowedUDPPorts = [
    179 # BGP
    3784 # BFD single-hop
  ];

  services = {
    netbird.clients.router = {
      login = {
        enable = true;
        setupKeyFile = config.sops.secrets."netbird/setupKey".path;
      };
      port = 51833;
    };
    bird = {
      enable = true;
      config = ''
        #Global options

        router id 2181624659;

        log syslog {info,warning,error,fatal};

        timeformat protocol     iso long;

        debug protocols all;
        debug channels all;
        debug tables all;

        watchdog warning 5 s;
        watchdog timeout 30 s;


        #Define tables
        ipv4 table master4 { trie on; }; 
        ipv6 table master6 { trie on; }; 

        # The Device protocol scans for local network interfaces
        protocol device {
          scan time 10;
        }

        # The Kernel protocol syncs BIRD routes with the OS routing table
        protocol kernel {
          ipv4 {
            export filter { if source = RTS_BGP then accept; };
          };
        }

        protocol kernel {
          ipv6 {
            export filter { if source = RTS_BGP then accept; };
          };
        }

        protocol bfd {}

        protocol static v4_netbird {
          ipv4;
          route 100.70.0.0/16 unreachable;
        }

        protocol static v6_netbird {
          ipv6;
          route fd6b:33b1:8a52:136d::/64 unreachable;
        }


        template bgp router {
          local ${config.metadata.network.ipv6.address} as  4200000000;
          bfd on;
          ipv4 {
            next hop self yes;
            extended next hop yes;
            import all;
            export filter { bgp_path.prepend( 4200000000 ); accept;};
          };
          ipv6 {
            next hop self yes;
            import all;
            export filter { bgp_path.prepend( 4200000000 ); accept;};
          };
        }

        protocol bgp r1 from router { neighbor 2a01:4f8:1b7:735::2 as 4200000001; }

        protocol bgp r2 from router { neighbor 2a01:4f8:1b7:735::3 as 4200000001; }
      '';
    };
  };
}
