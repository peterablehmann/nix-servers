{
  config,
  ...
}:
let
  domain = "ntpd-exporter.${config.networking.fqdn}";
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };

  time.timeZone = "Europe/Berlin";
  services = {
    timesyncd.enable = false;
    ntpd-rs = {
      enable = true;
      metrics.enable = true;
      useNetworkingTimeServers = true;
      settings.observability.metrics-exporter-listen = "[::1]:9975";
    };

    nginx.virtualHosts."${domain}" = {
      useACMEHost = domain;
      kTLS = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${config.services.ntpd-rs.settings.observability.metrics-exporter-listen}";
      };
    };
  };
}
