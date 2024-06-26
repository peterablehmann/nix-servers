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
  };

  services.paperless = {
    enable = true;
    passwordFile = config.sops.secrets."paperless/password".path;
    settings = {
      PAPERLESS_ADMIN_USER = "peter";
      PAPERLESS_PRE_CONSUME_SCRIPT = pre_consume_script.outPath;
      PAPERLESS_OCR_USER_ARGS = {
        "invalidate_digital_signatures" = true;
      };
    };
  };

  backup.paths = [ config.services.paperless.dataDir ];
}
