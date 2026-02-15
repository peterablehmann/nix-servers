{
  config,
  inputs,
  pkgs,
  ...
}:
let
  domain = "sso.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services = {
    nginx.virtualHosts."${domain}" = {
      useACMEHost = domain;
      kTLS = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://[${config.services.pocket-id.settings.HOST}]:${builtins.toString config.services.pocket-id.settings.PORT}";
        extraConfig = ''
          proxy_busy_buffers_size   512k;
          proxy_buffers   4 512k;
          proxy_buffer_size   256k;
        '';
      };
    };

    pocket-id = {
      enable = true;
      environmentFile = config.sops.secrets."pocket-id/environment".path;
      settings = {
        HOST = "::1";
        PORT = 1411;
        TRUST_PROXY = true;
        APP_URL = "https://sso.xnee.net";
        ANALYTICS_DISABLED = true;
        UI_CONFIG_DISABLED = true;
        EMAILS_VERIFIED = true; # Emails are always shown as verified as I do manual user creation
        # Mail
        SMTP_HOST = "mail.your-server.de";
        SMTP_PORT = 587;
        SMTP_TLS = "TLS";
        SMTP_FROM = "sso+noreply@xnee.net";
        SMTP_USER = "noreply@xnee.net";
        EMAIL_VERIFICATION_ENABLED = true;
        EMAIL_ONE_TIME_ACCESS_AS_ADMIN_ENABLED = true;
        EMAIL_API_KEY_EXPIRATION_ENABLED = true;
        METRICS_ENABLED = true;
      };
    };
  };

  sops.secrets."pocket-id/environment" = {
    sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";
  };

  backup.paths = [ config.services.pocket-id.dataDir ];
}
