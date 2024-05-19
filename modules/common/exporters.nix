{
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    firewallRules =
      "ip saddr 128.140.9.158 tcp dport 9100 accept
      ip6 saddr 2a01:4f8:c2c:17c9::1 tcp dport 9100 accept
      tcp dport 9100 drop";
    enabledCollectors = [
      "systemd"
    ];
  };
}
