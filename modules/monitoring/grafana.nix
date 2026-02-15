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
        user = "noreply@xnee.net";
        password = "$__file{${config.sops.secrets."grafana/smtp_password".path}}";
        from_address = "monitoring+noreply@xnee.net";
        from_name = "monitoring.xnee.net";
      };
      "auth.generic_oauth" = {
        enabled = true;
        name = "sso.xnee.net";
        client_id = "da875475-b74f-4def-8589-8f78ca7d7939";
        client_secret = "$__file{${config.sops.secrets."grafana/token".path}}";
        scopes = "openid,profile,email,groups";
        auth_url = "https://sso.xnee.net/authorize";
        token_url = "https://sso.xnee.net/api/oidc/token";
        api_url = "https://sso.xnee.net/api/oidc/userinfo";
        use_pkce = true;
        use_refresh_token = true;
        allow_sign_up = true;
        login_attribute_path = "preferred_username";
        groups_attribute_path = "groups";
        role_attribute_path = "contains(groups[*], 'monitoring_admins') && 'Admin' || contains(groups[*], 'monitoring_editors') && 'Editor' || 'Viewer'";
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
            hash = "sha256-Y+zsL4I+K3/j2+YoGU/JFp7cYWOhIvil/KkIF/M22fQ=";
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
