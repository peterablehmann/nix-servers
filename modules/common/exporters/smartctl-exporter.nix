{
  pkgs,
  config,
  ...
}:
{
  services.vmagent.prometheusConfig.scrape_configs = [
    {
      job_name = "smartctl-exporter";
      scrape_interval = "15s";
      scheme = "http";
      static_configs = [
        {
          targets = [ "[::1]:9633" ];
        }
      ];
    }
  ];

  services.prometheus.exporters.smartctl = {
    enable = true;
    listenAddress = "[::1]";
    port = 9633;
  };
}
