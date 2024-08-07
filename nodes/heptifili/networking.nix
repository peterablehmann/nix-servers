{ lib
, config
, ...
}:
let
  inherit (config.lib.topology) mkConnectionRev;
  IPv4 = "192.168.10.10";
  IPv6 = "fde6:bbc7:8946:7387::10:10";
in
{
  topology.self.interfaces.eth0 = {
    network = "Internet";
    physicalConnections = [ (mkConnectionRev "Fritz!Box" "*") ];
  };

  networking = {
    domains = {
      enable = true;
      subDomains = {
        "${config.networking.fqdn}" = { };
      };
      baseDomains."${config.networking.domain}" = {
        cname.data = "ip.heptifili.xnee.net";
      };
    };
    useNetworkd = true;
    useDHCP = false;
    hostName = "heptifili";
    usePredictableInterfaceNames = lib.mkDefault true;
    domain = "xnee.net";
    nameservers = [
      "192.168.10.10"
      "fd00::6b4:feff:feca:b60b"
    ];
    timeServers = [ "fde6:bbc7:8946:7387:6b4:feff:feca:b60b" ];
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-wan" = {
        networkConfig.DHCP = "yes";
        matchConfig.MACAddress = "6c:1f:f7:0c:c1:bb";
        address = [
          "${IPv4}/23"
          "${IPv6}/64"
        ];
        routes = [{ Gateway = "192.168.10.1"; }];
        linkConfig.RequiredForOnline = "routable";
      };
      # Direct link to sleipnir.xnee.net
      "20-lan" = {
        networkConfig.DHCP = "no";
        matchConfig.MACAddress = "6c:1f:f7:0c:c1:bc";
        address = [ "192.168.12.1/30" ];
        linkConfig.RequiredForOnline = "no";
      };
    };
  };
  services.tailscale.extraUpFlags = [ "--advertise-routes=192.168.10.0/23,fde6:bbc7:8946:7387::/64" ];
}
