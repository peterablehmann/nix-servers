{ config
, inputs
, pkgs
, ...
}:
let
  domain = "cloud.xnee.net";
in
{
  sops.secrets =
    let
      owner = "nextcloud";
    in
    {
      "nextcloud/adminpass" = {
        sopsFile = "${inputs.self}/secrets/heptifili.yaml";
        inherit owner;
      };
    };

  security.acme = {
    defaults.email = "acme@xnee.net";
    acceptTerms = true;
    certs."${domain}" = { };
  };

  networking.domains.subDomains."${domain}" = { };

  services = {
    nginx.virtualHosts."${domain}" = {
      useACMEHost = domain;
      kTLS = true;
      forceSSL = true;
    };

    mysql = {
      enable = true;
      package = pkgs.mariadb;
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions = {
            "nextcloud.*" = "ALL PRIVILEGES";
          };
        }
        {
          name = "backup";
          ensurePermissions = {
            "*.*" = "SELECT, LOCK TABLES";
          };
        }
      ];
      ensureDatabases = [
        "nextcloud"
      ];
    };

    nextcloud = {
      enable = true;
      package = pkgs.nextcloud29;
      hostName = domain;
      https = true;
      maxUploadSize = "10G";
      configureRedis = true;
      caching.redis = true;
      config = {
        dbtype = "sqlite";
        adminuser = "technikfuzzi";
        adminpassFile = config.sops.secrets."nextcloud/adminpass".path;
      };
      settings = {
        default_phone_region = "DE";
        log_type = "syslog";
        "allow_local_remote_servers" = true;
        "user_oidc"."use_pkce" = true;
        "allow_user_to_change_display_name" = false;
        "lost_password_link" = "disabled";
      };
      appstoreEnable = false;
      extraAppsEnable = true;
      extraApps = {
        "user_oidc" = pkgs.fetchNextcloudApp {
          appName = "user_oidc";
          sha256 = "sha256-8e4xQjOWSVAps6dg4jvN3MGVSOhaOgjPHPpTOgXKFJY=";
          url = "https://github.com/nextcloud-releases/user_oidc/releases/download/v6.0.1/user_oidc-v6.0.1.tar.gz";
          appVersion = "v6.0.1";
          license = "agpl3Only";
        };
        "maps" = pkgs.fetchNextcloudApp {
          appName = "maps";
          sha256 = "sha256-BmXs6Oepwnm+Cviy4awm3S8P9AiJTt1BnAQNb4TxVYE=";
          url = "https://github.com/nextcloud/maps/releases/download/v1.4.0/maps-1.4.0.tar.gz";
          appVersion = "v1.4.0";
          license = "agpl3Only";
        };
        "contacts" = pkgs.fetchNextcloudApp {
          appName = "contacts";
          sha256 = "sha256-48ERJ9DQ9w71encT2XVvcVaV+EbthgExQliKO1sQ+1A=";
          url = "https://github.com/nextcloud-releases/contacts/releases/download/v6.0.0/contacts-v6.0.0.tar.gz";
          appVersion = "v6.0.0";
          license = "agpl3Only";
        };
        "calendar" = pkgs.fetchNextcloudApp {
          appName = "calendar";
          sha256 = "sha256-AcPONkfFTDRd7CQC5d0C7Fr3pKRsQXl8+GhaNlqpgiY=";
          url = "https://github.com/nextcloud-releases/calendar/releases/download/v4.7.15/calendar-v4.7.15.tar.gz";
          appVersion = "v4.7.15";
          license = "agpl3Only";
        };
        "tasks" = pkgs.fetchNextcloudApp {
          appName = "tasks";
          sha256 = "sha256-HitYQcdURUHujRNMF0jKQzvSO93bItisI0emq0yw8p4=";
          url = "https://github.com/nextcloud/tasks/releases/download/v0.16.0/tasks.tar.gz";
          appVersion = "v0.16.0";
          license = "agpl3Only";
        };
      };
    };
  };

  backup.paths = [ config.services.nextcloud.home ];
}
