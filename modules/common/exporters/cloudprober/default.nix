{
  config,
  inputs,
  lib,
  ...
}:
let
  domain = "cloudprober.${config.networking.hostName}.xnee.net";
in
{
  imports = [
    ./cloudprober-module.nix
  ];

  security.acme.certs."${domain}" = { };

  networking.domains.subDomains."${domain}" = { };

  services.nginx.virtualHosts."${domain}" = {
    useACMEHost = domain;
    kTLS = true;
    forceSSL = true;
    locations."/".proxyPass = "http://${config.services.cloudprober.settings.host}:9313";
  };

  services.cloudprober = {
    enable = true;
    settings = {
      host = "[::1]";
      probe = [
        {
          name = "pingv4";
          type = "PING";
          ip_version = "IPV4";
          targets = {
            host_names = lib.strings.concatStrings (
              lib.strings.intersperse "," (
                lib.mapAttrsToList (name: host: "${host.config.networking.fqdn}") (
                  lib.filterAttrs (
                    name: host: (host.config.networking.fqdn != config.networking.fqdn)
                  ) inputs.self.nixosConfigurations
                )
              )
            );
          };
        }
        {
          name = "pinglb";
          type = "PING";
          targets.file_targets.file_path = "${./targets.nbg1.json}";
        }
        {
          name = "pingv6";
          type = "PING";
          ip_version = "IPV6";
          targets = {
            host_names = lib.strings.concatStrings (
              lib.strings.intersperse "," (
                lib.mapAttrsToList (name: host: "${host.config.networking.fqdn}") (
                  lib.filterAttrs (
                    name: host: (host.config.networking.fqdn != config.networking.fqdn)
                  ) inputs.self.nixosConfigurations
                )
              )
            );
          };
        }
        {
          name = "cert";
          type = "HTTP";
          http_probe = {
            scheme = "HTTPS";
            method = "GET";
          };
          targets.host_names = lib.strings.concatStrings (
            lib.strings.intersperse "," (
              [ "hetzner.com" ]
              ++ lib.flatten (
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
