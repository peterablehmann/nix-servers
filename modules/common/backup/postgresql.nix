{ config, lib, ... }:
let
  inherit (lib)
    mkIf
    ;
in
{
  config = mkIf config.services.postgresql.enable {
    services.postgresqlBackup = {
      enable = true;
      startAt = "*:55,25:00";
      databases = config.services.postgresql.ensureDatabases;
    };

    backup.paths = [ config.services.postgresqlBackup.location ];
  };
}
