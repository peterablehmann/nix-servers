{
  services.prometheus.exporters.node = {
    enable = true;
    openFirewall = true;
    firewallRules =
      "ip saddr 65.108.0.33 tcp dport 9100 accept
      ip6 saddr 2a01:4f9:6a:4f6f::203 tcp dport 9100 accept
      tcp dport 9100 drop";
    enabledCollectors = [
      "systemd"
    ];
  };
}
