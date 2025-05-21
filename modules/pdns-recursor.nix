{
  config,
  ...
}:
let
  domain = "dns-rec.${config.networking.hostName}.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
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
        proxyPass = "http://[${config.services.pdns-recursor.api.address}]:${builtins.toString config.services.pdns-recursor.api.port}";
      };
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
  services.pdns-recursor = {
    enable = true;
    serveRFC1918 = true;
    dnssecValidation = "validate";
    dns = {
      allowFrom = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "100.64.0.0/10"
        "169.254.0.0/16"
        "192.168.0.0/16"
        "172.16.0.0/12"
        "::1/128"
        "fc00::/7"
        "fe80::/10"
      ];
      address = [
        "192.168.33.1"
        "2003:a:173b:1000::2101"
      ];
    };
    api.address = "::1";
    settings =
      let
        hetzner-nameserver = "213.133.100.98;2a01:4f8:0:1::add:1098;88.198.229.192;2a01:4f8:0:1::add:2992;193.47.99.5;2001:67c:192c::add:5";
      in
      {
        webserver = true;
        webserver-password = "$scrypt$ln=10,p=1,r=8$LHDOmP4OhG7E86Z6QtsXqQ==$cZlgiI+Y1gFqKh9pvNbJPm74oCs9Wsaqd0JyliSAPQE=";
        forward-zones = [
          "bigdriver.net=${hetzner-nameserver}"
          "hainsacker.de=${hetzner-nameserver}"
          "lehmann.ing=${hetzner-nameserver}"
          "lehmann.zone=${hetzner-nameserver}"
          "uic-fahrzeugnummer.de=${hetzner-nameserver}"
          "xnee.de=${hetzner-nameserver}"
          "xnee.net=${hetzner-nameserver}"
        ];
      };
  };
}
