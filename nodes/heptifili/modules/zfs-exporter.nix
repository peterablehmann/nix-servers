{ pkgs
, config
, ...
}:
let
  domain = "zfs-exporter.${config.networking.fqdn}";
  tls-dir = config.security.acme.certs.${domain}.directory;
  webConfig = pkgs.writeTextFile {
    name = "web-config.yml";
    text = ''
      tls_server_config:
        cert_file: ${tls-dir}/fullchain.pem
        key_file: ${tls-dir}/key.pem
      basic_auth_users:
        prometheus: $2y$10$XnqpKDYhGVLgQaKzv8Lm9.0hZagMN7UB9Q/mIDU3t4tE4nBwYXnYC
    '';
  };
in
{
  networking.domains.subDomains.${domain} = { };
  security.acme.certs."${domain}" = { webroot = null; dnsProvider = "hetzner"; };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://${config.services.prometheus.exporters.zfs.listenAddress}:${builtins.toString config.services.prometheus.exporters.zfs.port }";
    };
  };

  services.prometheus.exporters.zfs = {
    enable = true;
    listenAddress = "127.0.0.1";
    extraFlags = [
      "--web.config.file=${webConfig}"
    ];
  };
  systemd.services.prometheus-zfs-exporter.serviceConfig = {
    SupplementaryGroups = [ config.security.acme.certs.${domain}.group ];
    BindReadOnlyPaths = [ tls-dir ];
  };
}
