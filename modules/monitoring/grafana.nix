{
  config,
  pkgs,
  inputs,
  ...
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
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[${config.services.grafana.settings.server.http_addr}]:${builtins.toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };

  sops.secrets = {
    "grafana/token" = {
      sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";
      owner = "grafana";
    };
    "grafana/smtp_password" = {
      sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";
      owner = "grafana";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "::1";
        http_port = 3312;
        root_url = "https://${domain}";
        inherit domain;
        enforce_domain = true;
      };
      smtp = {
        enabled = true;
        host = "mail.your-server.de:587";
        user = "monitoring@xnee.net";
        password = "$__file{${config.sops.secrets."grafana/smtp_password".path}}";
        from_address = "monitoring@xnee.net";
        from_name = "monitoring.xnee.net";
      };
      "auth.generic_oauth" = {
        enabled = true;
        name = "Kanidm";
        client_id = "grafana";
        client_secret = "$__file{${config.sops.secrets."grafana/token".path}}";
        scopes = "openid,profile,email,groups";
        auth_url = "https://idm.xnee.net/ui/oauth2";
        token_url = "https://idm.xnee.net/oauth2/token";
        api_url = "https://idm.xnee.net/oauth2/openid/grafana/userinfo";
        use_pkce = true;
        use_refresh_token = true;
        allow_sign_up = true;
        login_attribute_path = "preferred_username";
        groups_attribute_path = "groups";
        role_attribute_path = "contains(grafana_role[*], 'GrafanaAdmin') && 'GrafanaAdmin' || contains(grafana_role[*], 'Admin') && 'Admin' || contains(grafana_role[*], 'Editor') && 'Editor' || 'Viewer'";
        allow_assign_grafana_admin = true;
      };
    };
    provision = {
      datasources.settings.datasources = [
        {
          name = "prometheus";
          url = "http://${config.services.prometheus.listenAddress}:${builtins.toString config.services.prometheus.port}";
          type = "prometheus";
          editable = false;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "BGP.tools";
          type = "file";
          options.path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/peterablehmann/grafana-dashboards/refs/heads/main/bgp-tools-dashboard.json";
            hash = "sha256-chGyjnsP/tt2EciahWAiqYAepTDJtYG+YrFwHsVXf6k=";
          };
        }
        {
          name = "Cloudprober";
          type = "file";
          options.path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/peterablehmann/grafana-dashboards/refs/heads/main/cloudprober.json";
            hash = "sha256-s2+11fWGuaYwq3R0Tpm4jasKM31n7YI1kjqTSpxuYBc=";
          };
        }
        {
          name = "Node-Exporter";
          type = "file";
          options.path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/rfmoz/grafana-dashboards/master/prometheus/node-exporter-full.json";
            hash = "sha256-P326XW/h/z4yydUQ0Jm2e+YtDWkh3Rl17ZlANVjS35s=";
          };
        }
        {
          name = "PowerDNS Recursor";
          type = "file";
          options.path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/peterablehmann/grafana-dashboards/refs/heads/main/pdns-recursor-dashboard.json";
            hash = "sha256-9VXmPJOS8/t68Md/AHis5ssieZkdNJHhvN/vlY4hwrA=";
          };
        }
        {
          name = "Restic REST Server";
          type = "file";
          options.path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/peterablehmann/grafana-dashboards/refs/heads/main/restic-rest-server-dashboard.json";
            hash = "sha256-SiX1E2d8+FQhiqFzog435ImkuiLgONXusKTN3s+UzIc=";
          };
        }
        {
          name = "Routinator";
          type = "file";
          options.path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/peterablehmann/grafana-dashboards/refs/heads/main/routinator-dashboard.json";
            hash = "sha256-BhoMyG5CQaUunoMl09uhmWi46M29xcbpHyfMBxDathk=";
          };
        }
        {
          name = "TLS";
          type = "file";
          options.path = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/peterablehmann/grafana-dashboards/main/tls-cert-dashboard.json";
            hash = "sha256-900X5o5OMc/lIyE4ztb/jJTZoP9XEq//m9Hmks6RZro=";
          };
        }
      ];
    };
  };
}
