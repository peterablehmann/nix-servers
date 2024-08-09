{ config
, inputs
, pkgs
, ...
}:
let
  domain = "cloud.xnee.net";
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
  };

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

  services.nextcloud = {
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
        sha256 = "sha256-qq7qztHP1uuHtNbmXwM/OqC7/LUW2WpZE4okvqYJqCQ=";
        url = "https://github.com/nextcloud-releases/user_oidc/releases/download/v6.0.1/user_oidc-v6.0.1.tar.gz";
        appVersion = "v6.0.1";
        license = "agpl3Only";
      };
      "maps" = pkgs.fetchNextcloudApp {
        appName = "maps";
        sha256 = "sha256-LOQBR3LM7artg9PyD8JFVO/FKVnitALDulXelvPQFb8=";
        url = "https://github.com/nextcloud/maps/releases/download/v1.4.0/maps-1.4.0.tar.gz";
        appVersion = "v1.4.0";
        license = "agpl3Only";
      };
      "contacts" = pkgs.fetchNextcloudApp {
        appName = "contacts";
        sha256 = "sha256-GfITU8ZnB5zK/ajo83dDqPKet/oQMo50y5V0dw4Zt3s=";
        url = "https://github.com/nextcloud-releases/contacts/releases/download/v6.0.0/contacts-v6.0.0.tar.gz";
        appVersion = "v6.0.0";
        license = "agpl3Only";
      };
      "calendar" = pkgs.fetchNextcloudApp {
        appName = "calendar";
        sha256 = "sha256-sipXeyOL4OhENz7V2beFeSYBAoFZdCWtqftIy0lsqEY=";
        url = "https://github.com/nextcloud-releases/calendar/releases/download/v4.7.15/calendar-v4.7.15.tar.gz";
        appVersion = "v4.7.15";
        license = "agpl3Only";
      };
      "tasks" = pkgs.fetchNextcloudApp {
        appName = "tasks";
        sha256 = "sha256-L68ughpLad4cr5utOPwefu2yoOgRvnJibqfKmarGXLw=";
        url = "https://github.com/nextcloud/tasks/releases/download/v0.16.0/tasks.tar.gz";
        appVersion = "v0.16.0";
        license = "agpl3Only";
      };
    };
  };

  backup.paths = [ config.services.nextcloud.home ];  
}
