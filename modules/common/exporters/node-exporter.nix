{
  pkgs,
  config,
  ...
}:
{
  services.vmagent.prometheusConfig.scrape_configs = [
    {
      job_name = "node-exporter";
      scrape_interval = "15s";
      scheme = "http";
      static_configs = [
        {
          targets = [ "[::1]:3043" ];
        }
      ];
    }
  ];
  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "[::1]";
    port = 3043;
    enabledCollectors = [
      "ethtool"
      "systemd"
    ];
  };
}
