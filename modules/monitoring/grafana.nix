{ config
, pkgs
, ...
}:
let
  domain = "monitoring.xnee.net";
in
{
  security.acme = {
    defaults.email = "acme@xnee.net";
    acceptTerms = true;
    certs."${domain}" = { };
  };

  networking.domains.subDomains."${domain}" = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.grafana.settings.server.http_addr}:${builtins.toString config.services.grafana.settings.server.http_port }";
      proxyWebsockets = true;
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3312;
        inherit domain;
        enforce_domain = true;
      };
    };
    provision = {
      datasources.settings.datasources = [
        {
          name = "prometheus";
          url = "http://localhost:9001";
          type = "prometheus";
          editable = false;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "Node-Exporter";
          type = "file";
          options.path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/rfmoz/grafana-dashboards/master/prometheus/node-exporter-full.json";
            hash = "sha256-1DE1aaanRHHeCOMWDGdOS1wBXxOF84UXAjJzT5Ek6mM=";
          };
        }
        {
          name = "TLS";
          type = "file";
          options.path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/peterablehmann/grafana-dashboards/main/tls-cert-dashboard.json";
            hash = "sha256-iu1huuK9ebEgcf8A3qM92N0rq7rr7uM6oynzDY/wv7M=";
          };
        }
      ];
    };
  };
}
