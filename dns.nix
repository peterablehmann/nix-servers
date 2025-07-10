{
  lib,
  ...
}:
{
  defaultTTL = 60;
  zones =
    let
      defaults = {
        "" = {
          mx.data = {
            exchange = "www208.your-server.de";
            preference = 10;
          };
          txt.data = [ "v=spf1 mx -all" ];
          ns.data = [
            "hydrogen.ns.hetzner.com"
            "oxygen.ns.hetzner.com"
            "helium.ns.hetzner.de"
          ];
        };
        "_dmarc" = {
          txt.data = "v=DMARC1; p=reject; rua=mailto:dmarc@xnee.net; ruf=mailto:dmarc@xnee.net; adkim=s; aspf=s; fo=0:1:d:s;";
        };
        "default._domainkey" = {
          txt.data = "v=DKIM1; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAw97egS/syiVvNUBjmHfPBZC5cDOO0gFuQHJglRSS9/NqDkXHGc6oWt2reYknIlXJwmKBpisjvULsy2oKl88M0cfAD2iQn6IJc+FASpfqPZSidvaMQnqSq4vgB8wzyvlMZ/7vXWJFnntwZl5H+nG8C29A4LLIR8JEfNpBt5G3VEJbLq6JWoQ4075XjJNNqSe53usNL521zWR/P3ENuQ5k2BvdsuHAUbE76GVaOS118SlGT0Gb6erid75E0pl+wcSAKgtVths8mP03hhL8CaTU5v1EU3ClJL7IF6BkMDwSKyabiC7ohFpRVrNzykXE7nBEAocItpxf2jpC5zhB0AgnSwIDAQAB";
        };
        "autoconfig".cname.data = "mail.your-server.de";
        "_imaps._tcp".srv.data = {
          priority = 0;
          weight = 100;
          port = 993;
          target = "mail.your-server.de";
        };
        "_pop3s._tcp".srv.data = {
          priority = 0;
          weight = 100;
          port = 995;
          target = "mail.your-server.de";
        };
        "_submission._tcp".srv.data = {
          priority = 0;
          weight = 100;
          port = 587;
          target = "mail.your-server.de";
        };
        "_autodiscover._tcp".srv.data = {
          priority = 0;
          weight = 100;
          port = 443;
          target = "mail.your-server.de";
        };
      };
      www208 = {
        a.data = "78.46.0.148";
        aaaa.data = "2a01:4f8:d0a:2160::2";
      };
    in
    {
      "bigdriver.net" = lib.recursiveUpdate defaults { };
      "hainsacker.de" = lib.recursiveUpdate defaults { };
      "hetzner-offline.de" = lib.recursiveUpdate defaults { };
      "lehmann.ing" = lib.recursiveUpdate defaults { };
      "lehmann.zone" = lib.recursiveUpdate defaults {
        "" = www208;
        "www".cname.data = "lehmann.zone";
        "cloud".cname.data = "nx24177.your-storageshare.de";
      };
      "uic-fahrzeugnummer.de" = lib.recursiveUpdate defaults {
        "" = www208;
        "www".cname.data = "uic-fahrzeugnummer.de";
      };
      "xnee.de" = lib.recursiveUpdate defaults { };
      "xnee.net" = lib.recursiveUpdate defaults {
        "" = www208 // {
          txt.data = [ "TAILSCALE-fMbKHU9GGi8WDXsYeZxJ" ] ++ defaults."".txt.data;
        };
        "www".cname.data = "xnee.net";
        "kvm1" = {
          a.data = "100.85.70.7";
          aaaa.data = "fd7a:115c:a1e0::f701:4607";
        };
        "myrkviar" = {
          a.data = "49.12.178.245";
          aaaa.data = "2a01:4f8:1b7:730::1";
        };
        "*.myrkviar" = {
          a.data = "49.12.178.245";
          aaaa.data = "2a01:4f8:1b7:730::1";
        };
        "oob.myrkviar" = {
          a.data = "172.16.0.2";
          aaaa.data = "fdc5:0f61:83a0::2";
        };
        "idrac.myrkviar" = {
          a.data = "172.16.0.3";
          aaaa.data = "fdc5:0f61:83a0::3";
        };
        "proxmox" = {
          a.data = [ "49.12.178.245" ];
          aaaa.data = [ "2a01:4f8:1b7:730::1" ];
        };
        "fritzbox" = {
          a.data = "192.168.32.1";
          aaaa.data = "2003:a:173b:1000:6b4:feff:feca:b60b";
        };
        "switch1" = {
          a.data = "192.168.32.13";
          aaaa.data = "2003:a:173b:1000::200d";
        };
      };
    };
}
