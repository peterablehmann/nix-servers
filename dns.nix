{ lib
, ...
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
          txt.data = "v=spf1 mx -all";
          ns.data = [
            "hydrogen.ns.hetzner.com"
            "oxygen.ns.hetzner.com"
            "helium.ns.hetzner.de"
          ];
        };
        "_dmarc" = {
          txt.data = "v=DMARC1;p=quarantine;sp=quarantine;pct=100;rua=mailto:dmarc@xnee.net;ruf=mailto:dmarc@xnee.net;adkim=s;aspf=s;";
        };
        "default2307._domainkey" = {
          txt.data = "v=DKIM1; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArqEeTUiLEckwQlJD5XvIL+x8LHYLWHWoazbOXFd0w+qy/J39sOeXb5y9SrFRaPqT6EZw0vWMqqYTWhVY9N9XICHCMFnh2jdEwtDguN5BSe0AmE/qVQD+IhXbUNDtwycaLaj/a0AzD36zpcihu24BfTTA65pFsDpYhDvkGymayKyQszTwp2ebWlfKGXKYOPkTxAnDPvRqgbfOppLvO6az6uCKoIpAR9y6Db4yY2vBDpnnSMS8t1NST94PgpdfJ5f3F4FaAmVwVUa/lsF7I0trez5HPiHhmItiv1lRMfynJloBvBeeq4Ywam725mpYTXrCh/jzlOUrTa+jVPTFJMV9cwIDAQAB";
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
    in
    {
      "bigdriver.net" = lib.recursiveUpdate defaults { };
      "lehmann.zone" = lib.recursiveUpdate defaults {
        "" = {
          a.data = "78.46.0.148";
          aaaa.data = "2a01:4f8:d0a:2160::2";
        };
        "www".cname.data = "lehmann.zone";
        "cloud".cname.data = "nx24177.your-storageshare.de";
      };
      "uic-fahrzeugnummer.de" = lib.recursiveUpdate defaults {
        "" = {
          a.data = "78.46.0.148";
          aaaa.data = "2a01:4f8:d0a:2160::2";
        };
        "www".cname.data = "uic-fahrzeugnummer.de";
      };
      "xnee.de" = lib.recursiveUpdate defaults { };
      "xnee.net" = lib.recursiveUpdate defaults {
        "fritzbox".cname.data = "pm50yyz373t4yr6i.myfritz.net";
      };
    };
}
