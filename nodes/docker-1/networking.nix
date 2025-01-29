{ config
, lib
, ...
}:
let
  inherit (config.lib.topology) mkConnectionRev;
  IPv4 = "188.245.209.125";
  IPv6 = "2a01:4f8:1c1e:8464::1";
in
{
  topology.self.interfaces.eth0 = {
    network = "Internet";
    physicalConnections = [ (mkConnectionRev "Internet" "*") ];
  };
  networking = {
    hostId = "f8d512a2";
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
    hostName = "docker-1";
    usePredictableInterfaceNames = lib.mkDefault false;
    domain = "xnee.net";
    nameservers = [
      "185.12.64.1"
      "185.12.64.2"
      "2a01:4ff:ff00::add:1"
      "2a01:4ff:ff00::add:2"
    ];
    timeServers = [ "ntp.hetzner.com" ];
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
        { Gateway = "fe80::1"; }
        { Destination = "172.31.1.1"; }
        {
          Gateway = "172.31.1.1";
          GatewayOnLink = true;
        }
      ];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  services.tailscale.extraUpFlags = [ "--accept-routes" ];
}
