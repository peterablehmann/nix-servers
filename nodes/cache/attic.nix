{ inputs
, config
, ...
}:
{
  imports = [ inputs.attic.nixosModules.atticd ];


  sops.secrets."atticd/env" = {
    sopsFile = "${inputs.self}/secrets/cache.yaml";
  };

  security.acme = {
    defaults.email = "acme@xnee.net";
    acceptTerms = true;
    certs."cache.xnee.net" = { };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services = {
    atticd = {
      enable = true;
      credentialsFile = config.sops.secrets."atticd/env".path;

      settings = {
        listen = "127.0.0.1:8080";

        storage = {
          type = "s3";
          endpoint = "https://s3.wasabisys.com";
          region = "eu-central-2";
          bucket = "cache-xnee-net";
        };

        # Data chunking
        #
        # Warning: If you change any of the values here, it will be
        # difficult to reuse existing chunks for newly-uploaded NARs
        # since the cutpoints will be different. As a result, the
        # deduplication ratio will suffer for a while after the change.
        chunking = {
          # The minimum NAR size to trigger chunking
          #
          # If 0, chunking is disabled entirely for newly-uploaded NARs.
          # If 1, all NARs are chunked.
          nar-size-threshold = 64 * 1024; # 64 KiB

          # The preferred minimum size of a chunk, in bytes
          min-size = 16 * 1024; # 16 KiB

          # The preferred average size of a chunk, in bytes
          avg-size = 64 * 1024; # 64 KiB

          # The preferred maximum size of a chunk, in bytes
          max-size = 256 * 1024; # 256 KiB
        };
      };
    };

    nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      virtualHosts."cache.xnee.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://${config.services.atticd.settings.listen}";
        };
      };
    };
  };
}
