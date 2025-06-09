{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    ;
in
{
  config = mkIf config.services.mysql.enable {
    services.mysqlBackup = {
      enable = true;
      calendar = "*:55,25:00";
      databases = config.services.mysql.ensureDatabases;
    };

    backup.paths = [ config.services.mysql.location ];
  };
}
