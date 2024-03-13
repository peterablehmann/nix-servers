{ config
, inputs
, ...
}:
{
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  sops.secrets."monitoring/basicAuthFile" = {
    sopsFile = "${inputs.self}/secrets/common.yaml";
    owner = "nginx";
  };

  security.acme = {
    defaults.email = "acme@xnee.net";
    acceptTerms = true;
    certs."${config.networking.fqdn}" = { };
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    virtualHosts."${config.networking.hostName}.${config.networking.domain}" = {
      enableACME = true;
      forceSSL = true;
      locations."/exporters/node-exporter" = {
        proxyPass = "http://${config.services.prometheus.exporters.node.listenAddress}:${builtins.toString config.services.prometheus.exporters.node.port}/";
        proxyWebsockets = true;
        basicAuthFile = config.sops.secrets."monitoring/basicAuthFile".path;
      };
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    listenAddress = "127.0.0.1";
    extraFlags = [ "--web.telemetry-path=\"/exporters/node-exporter\"" ];
    enabledCollectors = [
      "systemd"
    ];
  };
}
