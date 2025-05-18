{ lib
, config
, ...
}:
let
  inherit (config.lib.topology) mkConnectionRev;
  IPv4 = "192.168.33.1";
  IPv6 = "2003:a:173b:1000::2101";
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
        aaaa.data = IPv6;
      };
    };
    useNetworkd = true;
    useDHCP = false;
    hostName = "heptifili";
    usePredictableInterfaceNames = lib.mkDefault false;
    domain = "xnee.net";
    nameservers = [
      "192.168.32.11"
      "2003:a:173b:1000::200b"
    ];
    timeServers = [ "fde6:bbc7:8946:7387:6b4:feff:feca:b60b" ];
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    networks = {
      "10-wan" = {
        networkConfig.DHCP = "no";
        matchConfig.Name = "eth0";
        address = [
          "${IPv4}/22"
          "${IPv6}/64"
        ];
        routes = [
          { Gateway = "192.168.32.1"; }
          { Gateway = "fe80::6b4:feff:feca:b60b"; }
        ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
  services.tailscale.extraUpFlags = [ "--advertise-routes=192.168.32.0/22,fde6:bbc7:8946:7387::/64" ];
}
