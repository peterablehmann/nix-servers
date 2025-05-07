{ config
, inputs
, pkgs
, ...
}:
let
  domain = "paperless.xnee.net";
  pre_consume_script = pkgs.writeShellScript "pre_consume.sh" ''
    echo "[PRE] Checking password state of ''${DOCUMENT_WORKING_PATH}"

    ${pkgs.qpdf}/bin/qpdf --requires-password "''${DOCUMENT_WORKING_PATH}"
    exit_status=$?
    if [ $exit_status -eq 2 ]; then
        echo "[PRE] File not encrypted nor requires password"
            exit 0
    fi
    if [ $exit_status -eq 3 ]; then
        echo "[PRE] File is encrypted but requires no password"
            exit 0
    fi

    echo "[PRE] File requires password"

    echo "[PRE] Try Tax-ID"
    ${pkgs.qpdf}/bin/qpdf --requires-password --password=$(cat ${config.sops.secrets."paperless/taxID".path}) "''${DOCUMENT_WORKING_PATH}"
    exit_status=$?
    if [ $exit_status -eq 3 ]; then
        echo "[PRE] Password correct. Removing password..."
            ${pkgs.qpdf}/bin/qpdf --decrypt --replace-input --password=$(cat ${config.sops.secrets."paperless/taxID".path}) "''${DOCUMENT_WORKING_PATH}"
            echo "[PRE] Successfully removed password"
            [[ -f "$DOCUMENT_WORKING_PATH.~qpdf-orig" ]] && printf '[PRE] Remove .~qpdf-orig' && rm $DOCUMENT_WORKING_PATH.~qpdf-orig
            exit 0
    fi

    echo "[PRE] Could not find password for PDF"
    exit 2
  '';
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.paperless.address}:${builtins.toString config.services.paperless.port}";
    };
  };

  sops.secrets = {
    "paperless/password" = {
      sopsFile = "${inputs.self}/secrets/ymir.yaml";
    };
    "paperless/taxID" = {
      sopsFile = "${inputs.self}/secrets/ymir.yaml";
      owner = "paperless";
    };
    "paperless/backupPassword" = {
      sopsFile = "${inputs.self}/secrets/ymir.yaml";
      owner = "paperless";
    };
    "paperless/environment" = {
      sopsFile = "${inputs.self}/secrets/ymir.yaml";
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
      PAPERLESS_PRE_CONSUME_SCRIPT = pre_consume_script.outPath;
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
        ${config.services.paperless.dataDir}/paperless-manage document_exporter -cd --passphrase \"$(cat ${config.sops.secrets."paperless/backupPassword".path})\" --no-progress-bar ${config.services.paperless.dataDir}/backup
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "paperless";
      };
    };
  };

  backup.paths = [ config.services.paperless.dataDir ];
}
