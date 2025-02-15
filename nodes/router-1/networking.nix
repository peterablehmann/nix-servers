{ config
, lib
, ...
}:
let
  inherit (config.lib.topology) mkConnectionRev;
  IPv4 = "192.168.33.2";
  IPv6 = "fde6:bbc7:8946:7387::2102";
in
{
  topology.self.interfaces.eth0 = {
    network = "Internet";
    physicalConnections = [ (mkConnectionRev "Fritz!Box" "*") ];
  };
  networking = {
    hostId = "8d51f3b3";
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
    hostName = "router-1";
    usePredictableInterfaceNames = lib.mkDefault false;
    domain = "xnee.net";
    nameservers = [
      "192.168.32.11"
      "fde6:bbc7:8946:7387::200b"
    ];
    timeServers = [ "fde6:bbc7:8946:7387:6b4:feff:feca:b60b" ];
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    netdevs."212895-route64" = {
      netdevConfig = {
        Name = "gre-212895";
        Kind = "gre";
        MTUBytes = 1480;
      };
      tunnelConfig = {
        Remote = "2a11:6c7:4::1";
        Local = "fde6:bbc7:8946:7387::200b";
      };
    };
    networks = {
      "10-wan" = {
        networkConfig.DHCP = "ipv6";
        matchConfig.MACAddress = "BC:24:11:7F:87:15";
        address = [
          "${IPv4}/22"
          "${IPv6}/64"
        ];
        routes = [{ Gateway = "192.168.32.1"; }];
        linkConfig.RequiredForOnline = "routable";
      };
      "212895-route64" = {
        matchConfig.Name = config.systemd.network.netdevs."212895-route64".netdevConfig.Name;
        address = [
          "100.64.202.174/30"
          "2a11:6c7:f00:b8::2/64"
        ];
      };
    };
  };
}
