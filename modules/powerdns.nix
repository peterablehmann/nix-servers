{
  config,
  inputs,
  ...
}:
{
  networking.firewall = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };

  sops.secrets."powerdns/environment".sopsFile =
    "${inputs.self}/secrets/${config.networking.hostName}.yaml";

  services = {
    powerdns = {
      enable = true;
      secretFile = config.sops.secrets."powerdns/environment".path;
      extraConfig = ''
        launch=gpgsql
        gpgsql-host=localhost
        gpgsql-user=pdns
        gpgsql-password=$PGPASSWD
        gpgsql-dbname=pdns
        gpgsql-port=5432
        local-address=${config.metadata.network.ipv4.address} ${config.metadata.network.ipv6.address}
        webserver=yes
        webserver-address=::1
        webserver-port=8081
      '';
    };

    postgresql = {
      enable = true;
      ensureDatabases = [ "pdns" ];
      ensureUsers = [
        {
          name = "pdns";
          ensureDBOwnership = true;
        }
      ];
    };
  };
}
