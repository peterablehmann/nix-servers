{ config
, pkgs
, lib
, ...
}:
let
  domain = "routinator.xnee.net";
  tls-dir = config.security.acme.certs.${domain}.directory;
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs.${domain} = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://[::1]:8323";
    };
  };

  systemd.services.routinator = {
    description = "Routinator 3000 is free, open-source RPKI Relying Party software made by NLnet Labs.";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    path = with pkgs; [ rsync ];
    serviceConfig = {
      ExecStart = "${lib.getExe pkgs.routinator} server --http-tls=[::1]:8323 --http-tls-key=${tls-dir}/key.pem --http-tls-cert=${tls-dir}/fullchain.pem";
      SupplementaryGroups = [ config.security.acme.certs.${domain}.group ];
      BindReadOnlyPaths = [ tls-dir ];
      User = "routinator";
      Group = "routinator";
    };
  };

  users.users.routinator = {
    createHome = true;
    isSystemUser = true;
    home = "/var/lib/routinator";
    group = "routinator";
  };
  users.groups.routinator = { };
}
