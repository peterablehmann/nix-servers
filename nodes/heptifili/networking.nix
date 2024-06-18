{ lib
, config
, ...
}:
let
  inherit (config.lib.topology) mkConnectionRev;
  IPv4 = "192.168.10.10";
  IPv6 = "fd00::10:10";
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
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    networks."10-wan" = {
      networkConfig.DHCP = "yes";
      matchConfig.Name = "enp87s0";
      address = [
        "${IPv4}/23"
        "${IPv6}/64"
      ];
      routes = [{ Gateway = "192.168.10.1"; }];
      linkConfig.RequiredForOnline = "routable";
    };
  };
}
