{ config
, lib
, ...
}:
let
  IPv4 = "10.0.2.1";
  IPv6 = "2a01:4f9:6a:4f6f::201";
in
{
  networking = {
    domains = {
      enable = true;
      subDomains."${config.networking.fqdn}" = { };
      baseDomains."${config.networking.domain}" = {
        # a.data = IPv4;
        aaaa.data = IPv6;
      };
    };
    useNetworkd = true;
    useDHCP = false;
    hostName = "monitoring";
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
        "${IPv4}/8"
        "${IPv6}/64"
      ];
      routes = [
        { routeConfig.Gateway = "fe80::1"; }
        { routeConfig = { Destination = "10.0.0.1"; }; }
        {
          routeConfig = {
            Gateway = "10.0.0.1";
            GatewayOnLink = true;
          };
        }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
