{
  config,
  inputs,
  pkgs,
  ...
}:
let
  domain = "paperless.xnee.net";
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[${config.services.paperless.address}]:${builtins.toString config.services.paperless.port}";
    };
  };

  sops.secrets = {
    "paperless/password" = {
      sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";
    };
    "paperless/taxID" = {
      sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";
      owner = "paperless";
    };
    "paperless/backupPassword" = {
      sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";
      owner = "paperless";
    };
    "paperless/environment" = {
      sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";
    };
  };

  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets."paperless/password".path;
    address = "::1";
    port = 28981;
    settings = {
      PAPERLESS_URL = "https://paperless.xnee.net";
      PAPERLESS_TIME_ZONE = "Europe/Berlin";
      PAPERLESS_ADMIN_USER = "peter";
      PAPERLESS_OCR_LANGUAGE = "deu";
      PAPERLESS_OCR_USER_ARGS = {
        "invalidate_digital_signatures" = true;
      };
      PAPERLESS_APPS = "allauth.socialaccount.providers.openid_connect";
      # PAPERLESS_SOCIALACCOUNT_PROVIDERS is set via secret environment
      PAPERLESS_DISABLE_REGULAR_LOGIN = true;
      PAPERLESS_REDIRECT_LOGIN_TO_SSO = true;
    };
    environmentFile = config.sops.secrets."paperless/environment".path;
  };

  systemd = {
    timers.paperless-export = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "23:50";
        Unit = "paperless-export.service";
      };
    };
    services.paperless-export = {
      script = ''
        [[ -d ${config.services.paperless.dataDir}/backup ]] || mkdir ${config.services.paperless.dataDir}/backup
        paperless-manage document_exporter -cd --passphrase \"$(cat ${
          config.sops.secrets."paperless/backupPassword".path
        })\" --no-progress-bar ${config.services.paperless.dataDir}/backup
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "paperless";
      };
      path = [ config.services.paperless.manage ];
    };
  };

  backup.paths = [ config.services.paperless.dataDir ];
}
