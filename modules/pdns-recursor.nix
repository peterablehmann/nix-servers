{
  config,
  ...
}:
let
  domain = "dns-rec.${config.networking.hostName}.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
  mkForwardZone = zone: {
    inherit zone;
    forwarders = [
      # hydrogen.ns.hetzner.com
      "213.133.100.98"
      "2a01:4f8:0:1::add:1098"
      # oxygen.ns.hetzner.com
      "88.198.229.192"
      "2a01:4f8:0:1::add:2992"
      # helium.ns.hetzner.de
      "193.47.99.5"
      "2001:67c:192c::add:5"
    ];
  };
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations = {
      "/" = {
        return = "404";
      };
      "/metrics" = {
        proxyPass = "http://[${config.services.pdns-recursor.yaml-settings.webservice.address}]:${builtins.toString config.services.pdns-recursor.yaml-settings.webservice.port}";
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
  services.pdns-recursor = {
    enable = true;
    yaml-settings = {
      incoming = {
        listen = [
          "192.168.33.1"
          "2003:a:173b:1000::2101"
        ];
        allow_from = [
          "127.0.0.0/8"
          "192.168.32.0/22"
          "::1/128"
          "fe80::/10"
          "fc00::/7"
          "2003:a:173b:1000::/56"
        ];
      };
      outgoing.source_address = [
        "192.168.33.1"
        "2003:a:173b:1000::2101"
      ];
      dnssec.validation = "validate";
      recursor = {
        serve_rfc1918 = true;
        serve_rfc6303 = true;
        forward_zones = builtins.map mkForwardZone [
          "bigdriver.net"
          "hainsacker.de"
          "lehmann.ing"
          "lehmann.zone"
          "uic-fahrzeugnummer.de"
          "xnee.de"
          "xnee.net"
        ];
      };
      webservice = {
        webserver = true;
        address = "::1";
        port = 8082;
        password = "$scrypt$ln=10,p=1,r=8$LHDOmP4OhG7E86Z6QtsXqQ==$cZlgiI+Y1gFqKh9pvNbJPm74oCs9Wsaqd0JyliSAPQE=";
      };
    };
  };
}
