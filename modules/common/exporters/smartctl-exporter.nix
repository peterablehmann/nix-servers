{
  pkgs,
  config,
  ...
}:
let
  domain = "smartctl-exporter.${config.networking.fqdn}";
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
    kTLS = true;
    locations."/" = {
      proxyPass = "https://${config.services.prometheus.exporters.smartctl.listenAddress}:${builtins.toString config.services.prometheus.exporters.smartctl.port}";
    };
  };

  services.prometheus.exporters.smartctl = {
    enable = true;
    listenAddress = "[::1]";
    port = 9633;
    extraFlags = [
      "--web.config.file=${webConfig}"
    ];
  };
  systemd.services.prometheus-smartctl-exporter.serviceConfig = {
    SupplementaryGroups = [ config.security.acme.certs.${domain}.group ];
    BindReadOnlyPaths = [ tls-dir ];
  };
}
