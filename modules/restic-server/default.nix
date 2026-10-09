{
  config,
  ...
}:
let
  domain = "restic.${config.networking.fqdn}";
  tls-dir = config.security.acme.certs.${domain}.directory;
in
{
  security.acme.certs."${domain}" = { };
  networking.domains.subDomains.${domain} = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations = {
      "/" = {
        proxyPass = "http://${config.services.restic.server.listenAddress}";
        extraConfig = "client_max_body_size 10G;";
      };
      "/metrics" = {
        return = "404";
      };
    };
  };

  services = {
    restic.server = {
      enable = true;
      dataDir = "/var/lib/restic";
      appendOnly = true;
      listenAddress = "[::1]:8000";
      privateRepos = true;
      extraFlags = [
        "--htpasswd-file=${./.htpasswd}"
        "--prometheus"
        "--prometheus-no-auth"
      ];
    };
    vmagent.prometheusConfig.scrape_configs = [
      {
        job_name = "restic-server";
        scrape_interval = "15s";
        scheme = "http";
        static_configs = [
          {
            targets = [ config.services.restic.server.listenAddress ];
          }
        ];
      }
    ];
  };
}
