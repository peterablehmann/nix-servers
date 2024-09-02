{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = [ "eth0" ];
        access-control = [ 
          "192.168.32.0/22 allow"
          "fde6:bbc7:8946::/48 allow"
        ];
        use-syslog = true;
      };
      forward-zone = [
        {
          name = ".";
          #forward-addr = "9.9.9.9#dns.quad9.net";
          forward-addr = [ 
            "9.9.9.9#dns.quad9.net"
            "149.112.112.112#dns.quad9.net"
            "2620:fe::fe#dns.quad9.net"
            "2620:fe::9#dns.quad9.net"
          ];
          forward-tls-upstream = true;
        }
      ];
    };
  };
}
