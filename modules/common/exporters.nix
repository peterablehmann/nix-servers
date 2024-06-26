{ pkgs
, config
, ...
}:
let
  domain = "node-exporter.${config.networking.fqdn}";
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
  security.acme.certs."${domain}" = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://localhost:${builtins.toString config.services.prometheus.exporters.node.port }";
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    port = 3043;
    enabledCollectors = [
      "systemd"
    ];
    extraFlags = [
      "--web.config.file=${webConfig}"
    ];
  };
  systemd.services.prometheus-node-exporter.serviceConfig = {
    SupplementaryGroups = [ config.security.acme.certs.${domain}.group ];
    BindReadOnlyPaths = [ tls-dir ];
  };
}
