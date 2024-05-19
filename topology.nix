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
