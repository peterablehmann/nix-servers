{
  config,
  ...
}:
{
  time.timeZone = "Europe/Berlin";
  services = {
    timesyncd.enable = false;
    ntpd-rs = {
      enable = true;
      metrics.enable = true;
      useNetworkingTimeServers = true;
      settings.observability.metrics-exporter-listen = "[::1]:9975";
    };
    vmagent.prometheusConfig.scrape_configs = [
      {
        job_name = "ntpd-exporter";
        scrape_interval = "15s";
        scheme = "http";
        static_configs = [
          {
            targets = [ "[::1]:9975" ];
          }
        ];
      }
    ];
  };
}
