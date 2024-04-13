{ config
, ...
}:
let
  inherit (config.lib.topology) mkConnection;
  inherit (config.lib.topology) mkConnectionRev;
  inherit (config.lib.topology) mkInternet;
in
{
  networks = {
    "Proxmox" = {
      name = "Proxmox";
      cidrv4 = "10.0.0.0/8";
      cidrv6 = "2a01:4f9:6a:4f6f::/64";
    };
    "Internet" = {
      name = "Internet";
      style = {
        primaryColor = "#FFFFFF";
        pattern = "solid";
      };
    };
    "Home" = {
      name = "Home";
      style = {
        primaryColor = "#E67850";
        pattern = "solid";
      };
    };
    "tailnet" = {
      name = "tailnet";
      style = {
        primaryColor = "#38761D";
        secondaryColor = null;
        pattern = "dotted";
      };
    };
  };
  nodes = {
    "Internet" = mkInternet { };
    "proxmox.xnee.de" = {
      deviceType = "device";
      hardware.info = "AX41-NVMe";
      interfaces = {
        "enp9s0" = {
          network = "Internet";
          addresses = [ "65.108.0.24" "2a01:4f9:6a:4f6f::1" ];
          physicalConnections = [ (mkConnectionRev "Internet" "*") ];
        };
        "vmbr0" = {
          virtual = true;
          addresses = [ "10.0.0.1" "2a01:4f9:6a:4f6f::1" ];
          network = "Proxmox";
          physicalConnections = [
            (mkConnection "monitoring" "eth0")
          ];
        };
      };
    };
    "Fritz!Box" = {
      deviceType = "router";
      hardware.image = ./media/fritzbox_7590.png;
      interfaces = {
        "SFP" = {
          physicalConnections = [ (mkConnectionRev "Internet" "*") ];
          network = "Internet";
        };
        "WAN/LAN 5" = {
          network = "Home";
        };
        "LAN 1" = {
          network = "Home";
        };
        "LAN 2" = {
          network = "Home";
        };
        "LAN 3" = {
          network = "Home";
        };
        "LAN 4" = {
          network = "Home";
        };
      };
    };
  };
}
