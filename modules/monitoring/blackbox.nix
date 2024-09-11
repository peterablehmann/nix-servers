{ pkgs
, config
, ...
}:
let
  domain = "blackbox.xnee.net";
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
  security.acme.certs."${domain}" = { };
  networking.domains.subDomains."${domain}" = { };
  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "https://localhost:${builtins.toString config.services.prometheus.exporters.blackbox.port }";
    };
  };

  services.prometheus.exporters.blackbox = {
    enable = true;
    port = 3044;
    extraFlags = [
      "--web.config.file=${webConfig}"
    ];
    configFile = (pkgs.formats.yaml { }).generate "blackbox.yml" {
      modules = {
        certs = {
          prober = "http";
          http = {
            method = "GET";
            fail_if_not_ssl = true;
            preferred_ip_protocol = "ip6";
            ip_protocol_fallback = true;
          };
        };
      };
    };
  };

  systemd.services.prometheus-blackbox-exporter.serviceConfig = {
    SupplementaryGroups = [ config.security.acme.certs.${domain}.group ];
    BindReadOnlyPaths = [ tls-dir ];
  };
}
