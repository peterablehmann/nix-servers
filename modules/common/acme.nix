{
  config,
  inputs,
  ...
}:
{
  sops.secrets."acme/environment" = {
    sopsFile = "${inputs.self}/secrets/common.yaml";
  };
  security.acme = {
    defaults = {
      email = "acme@xnee.net";
      dnsProvider = "hetzner";
      environmentFile = config.sops.secrets."acme/environment".path;
    };
    acceptTerms = true;
  };
}
