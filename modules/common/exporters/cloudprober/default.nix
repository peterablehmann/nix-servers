{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [
    ./cloudprober-module.nix
  ];

  services.vmagent.prometheusConfig.scrape_configs = [
    {
      job_name = "cloudprober";
      scrape_interval = "15s";
      scheme = "http";
      static_configs = [
        {
          targets = [ "[::1]:9313" ];
        }
      ];
    }
  ];

  services.cloudprober = {
    enable = true;
    settings = {
      host = "::1";
      probe = [
        (lib.mkIf (config.metadata.network.ipv4.address != null) {
          name = "pingv4";
          type = "PING";
          ip_version = "IPV4";
          targets = {
            host_names = lib.strings.concatStrings (
              lib.strings.intersperse "," (
                lib.mapAttrsToList (name: host: "${host.config.networking.fqdn}") (
                  lib.filterAttrs (
                    name: host:
                    (
                      host.config.networking.fqdn != config.networking.fqdn
                      && host.config.metadata.network.ipv4.address != null
                    )
                  ) inputs.self.nixosConfigurations
                )
              )
            );
          };
        })
        (lib.mkIf (config.metadata.network.ipv6.address != null) {
          name = "pingv6";
          type = "PING";
          ip_version = "IPV6";
          targets = {
            host_names = lib.strings.concatStrings (
              lib.strings.intersperse "," (
                lib.mapAttrsToList (name: host: "${host.config.networking.fqdn}") (
                  lib.filterAttrs (
                    name: host:
                    (
                      host.config.networking.fqdn != config.networking.fqdn
                      && host.config.metadata.network.ipv6.address != null
                    )
                  ) inputs.self.nixosConfigurations
                )
              )
            );
          };
        })
        {
          name = "cert";
          type = "HTTP";
          http_probe = {
            scheme = "HTTPS";
            method = "GET";
          };
          interval_msec = 3600000;
          targets.host_names = lib.strings.concatStrings (
            lib.strings.intersperse "," (
              lib.flatten (
                lib.mapAttrsToList (
                  n: v: builtins.attrNames v.config.security.acme.certs
                ) inputs.self.nixosConfigurations
              )
            )
          );
        }
      ];
    };
  };
}
