{ config
, inputs
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
    networks = {
      "01-lo" = {
        matchConfig.Name = "lo";
        address = [
          "::1/128"
          "127.0.0.1/8"
          "2a0f:85c1:b7a::c0:1/128"
        ];
      };
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
    };
  };

  sops.secrets."wireguard/wg212895".sopsFile = "${inputs.self}/secrets/router-1.yaml";

  networking.wireguard = {
    enable = true;
    interfaces = {
      "wg212895" = {
        allowedIPsAsRoutes = false;
        privateKeyFile = config.sops.secrets."wireguard/wg212895".path;
        table = "off";
        ips = [ "2a11:6c7:f00:b8::2/64" ];
        peers = [{
          name = "peer";
          publicKey = "NQwTxxs3pvF5yQUDPTR8rw3fr58Zy6Cxw59l8ya1Jyo=";
          endpoint = "2a11:6c7:4::1:44325";
          persistentKeepalive = 30;
          allowedIPs = [ "::/0" ];
        }];
      };
    };
  };
}
