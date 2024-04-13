{ lib
, config
, ...
}:
let
  inherit (config.lib.topology) mkConnectionRev;
in
{
  topology.self.interfaces.eth0 = {
    network = "Internet";
    physicalConnections = [ (mkConnectionRev "Internet" "*") ];
  };
  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "cache";
    usePredictableInterfaceNames = lib.mkDefault false;
    domain = "xnee.net";
    nameservers = [
      #HETZNER
      "2a01:4ff:ff00::add:2"
      "2a01:4ff:ff00::add:1"
    ];
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    networks."10-wan" = {
      networkConfig.DHCP = "no";
      matchConfig.Name = "eth0";
      address = [
        "2a01:4f8:c2c:17c9::1/64"
        "128.140.9.158/32"
      ];
      routes = [
        { routeConfig.Gateway = "fe80::1"; }
        { routeConfig = { Destination = "172.31.1.1"; }; }
        {
          routeConfig = {
            Gateway = "172.31.1.1";
            GatewayOnLink = true;
          };
        }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
