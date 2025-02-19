{ config
, inputs
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

  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

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
    domain = "as213422.net";
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
    networks = {
      "01-lo" = {
        matchConfig.Name = "lo";
        address = [ "2a0f:85c1:b7a::c0:1/128" ];
      };
      "10-wan" = {
        networkConfig.DHCP = "no";
        matchConfig.Name = "eth0";
        address = [
          "${IPv4}/32"
          "${IPv6}/128"
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
  };

  sops.secrets."wireguard/wg212895".sopsFile = "${inputs.self}/secrets/router-1.yaml";
  sops.secrets."wireguard/wg213416".sopsFile = "${inputs.self}/secrets/router-1.yaml";

  networking.wireguard = {
    enable = true;
    interfaces = {
      "wg212895" = {
        allowedIPsAsRoutes = false;
        privateKeyFile = config.sops.secrets."wireguard/wg212895".path;
        table = "off";
        ips = [
          "fe80::21:2895/64"
          "2a11:6c7:f00:b8::2/64"
        ];
        peers = [{
          name = "peer";
          publicKey = "lgxXREeixNDJ0zdTTSvTgKI1hZuTAxyGvM0NVAad5TI=";
          endpoint = "2a11:6c7:4::1:44393";
          persistentKeepalive = 30;
          allowedIPs = [ "::/0" ];
        }];
      };
      "wg213416" = {
        listenPort = 60000;
        allowedIPsAsRoutes = false;
        privateKeyFile = config.sops.secrets."wireguard/wg213416".path;
        table = "off";
        ips = [
          "fe80::21:3416/64"
          "2a0f:85c1:b7a::c1:0/127"
        ];
        peers = [{
          name = "peer";
          publicKey = "tBisp7mr50xOpdaIO9PoYoYpU+HaRaWF2b8o0+BrmCs=";
          endpoint = "[2a01:4f8:221:3401::100]:60000";
          persistentKeepalive = 30;
          allowedIPs = [ "::/0" ];
        }];
      };
    };
  };
}
