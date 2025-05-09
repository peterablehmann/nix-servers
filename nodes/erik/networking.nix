{ lib
, config
, ...
}:
let
  inherit (config.lib.topology) mkConnectionRev;
  IPv4 = "192.168.32.11";
  IPv6 = "fde6:bbc7:8946:7387::200b";
in
{
  topology.self.interfaces.eth0 = {
    network = "Internet";
    physicalConnections = [ (mkConnectionRev "Fritz!Box" "*") ];
  };

  networking = {
    hostId = "53d52352";
    domains = {
      enable = true;
      subDomains = {
        "${config.networking.fqdn}" = { };
      };
      baseDomains."${config.networking.domain}" = {
        a.data = IPv4;
        aaaa.data = IPv6;
      };
    };
    useNetworkd = true;
    useDHCP = false;
    hostName = "erik";
    usePredictableInterfaceNames = lib.mkDefault false;
    domain = "xnee.net";
    nameservers = [
      "192.168.32.1"
      "fde6:bbc7:8946:7387:6b4:feff:feca:b60b"
    ];
    timeServers = [ "fde6:bbc7:8946:7387:6b4:feff:feca:b60b" ];
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-wan" = {
        networkConfig.DHCP = "ipv6";
        matchConfig.MACAddress = "d8:5e:d3:12:3f:31";
        address = [
          "${IPv4}/22"
          "${IPv6}/64"
        ];
        routes = [{ Gateway = "192.168.32.1"; }];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
  services.tailscale.extraUpFlags = [ "--advertise-routes=192.168.32.0/22,fde6:bbc7:8946:7387::/64" ];
}
