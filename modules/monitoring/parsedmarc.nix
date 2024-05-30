{ config
, inputs
, ...
}:
{
  sops.secrets."parsedmarc/mail/password" = {
    neededForUsers = true;
    sopsFile = "${inputs.self}/secrets/ymir.yaml";
  };
  sops.secrets."parsedmarc/maxmind/licensekey" = {
    neededForUsers = true;
    sopsFile = "${inputs.self}/secrets/ymir.yaml";
  };

  services = {
    parsedmarc = {
      enable = true;
      settings = {
        imap = {
          host = "mail.your-server.de";
          port = 993;
          ssl = true;
          user = "dmarc@xnee.net";
          password = config.sops.secrets."parsedmarc/mail/password".path;
        };
      };
    };
    geoipupdate.settings = {
      AccountID = 934098;
      LicenseKey = config.sops.secrets."parsedmarc/maxmind/licensekey".path;
    };
  };
}
