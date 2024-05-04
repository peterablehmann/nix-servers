{ lib
, config
, ...
}:
let
  inherit (config.lib.topology) mkConnectionRev;
  IPv4 = "135.181.206.213";
  IPv6 = "2a01:4f9:c011:aeba::1";
in
{
  topology.self.interfaces.eth0 = {
    network = "Internet";
    physicalConnections = [ (mkConnectionRev "Internet" "*") ];
  };
  networking = {
    domains = {
      enable = true;
      subDomains."${config.networking.fqdn}" = { };
      baseDomains."${config.networking.domain}" = {
        a.data = IPv4;
        aaaa.data = IPv6;
      };
    };
    useNetworkd = true;
    useDHCP = false;
    hostName = "sync";
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
        "${IPv4}/32"
        "${IPv6}/64"
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
