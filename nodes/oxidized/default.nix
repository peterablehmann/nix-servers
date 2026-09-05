{
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./disko.nix
    ./hardware-configuration.nix
  ];

  metadata = {
    hostName = "oxidized";
    domain = "xnee.net";
    provider = "proxmox.xnee.net";
    network = {
      ipv4 = {
        address = "192.168.48.10";
        prefixLength = 24;
        gateway = "192.168.48.1";
      };
      ipv6 = {
        address = "2a01:4f8:1b7:731::a";
        prefixLength = 64;
        gateway = "2a01:4f8:1b7:731::1";
      };
    };
  };
  services.qemuGuest.enable = true;

  sops.secrets = {
    "oxidized/ssh_key" = {
      sopsFile = "${inputs.self}/secrets/${config.networking.hostName}.yaml";
      owner = config.services.oxidized.user;
      inherit (config.services.oxidized) group;
      path = "${config.services.oxidized.dataDir}/.ssh/id_ed25519";
    };
  };
  security.acme.certs."${config.networking.fqdn}" = { };

  services.nginx = {
    enable = true;
    virtualHosts."${config.networking.fqdn}" = {
      useACMEHost = config.networking.fqdn;
      kTLS = true;
      forceSSL = true;
      basicAuthFile = pkgs.writeText "basicAuth.txt" ''
        admin:$2y$05$qUQxKmRMxc3d9mfDgYfHLupdJ3dnCmEQi6ANGrtUOJfD86CkpN7HK
      '';
      locations = {
        "/" = {
          proxyPass = "http://[::1]:8888";
        };
      };
    };
  };

  services.oxidized = {
    enable = true;
    configFile = pkgs.writeText "oxidized-config.yml" ''
      ---
      username: oxi
      resolve_dns: true
      interval: 3600
      pid: "${config.services.oxidized.dataDir}/.config/oxidized/pid"
      debug: false
      run_once: false
      threads: 30
      use_max_threads: false
      timeout: 20
      timelimit: 300
      retries: 3
      prompt: !ruby/regexp /^([\w.@-]+[#>]\s?)$/
      next_adds_job: false
      groups: {}
      group_map: {}
      models: {}
      extensions:
        oxidized-web:
          load: true
          listen: "[::1]"
      crash:
        directory: "${config.services.oxidized.dataDir}/.config/oxidized/crashes"
        hostnames: false
      stats:
        history_size: 10
      input:
        default: ssh
        debug: false
        ssh:
          secure: false
        ftp:
          passive: true
        utf8_encoded: true
      output:
        default: git
        git:
          user: Oxidized
          email: oxi+noreply@xnee.net
          repo: "${config.services.oxidized.dataDir}/configs.git"
      source:
        default: csv
        csv:
          file: "${config.services.oxidized.dataDir}/.config/oxidized/router.db"
          delimiter: !ruby/regexp /,/
          map:
            name: 0
            ip: 1
            model: 2
          gpg: false
    '';
    routerDB = pkgs.writeText "oxidized-router.db" ''
      bbr00.nbg.de.as213422.net,2a01:4f8:1b7:730::5,vyos
      bbr01.nbg.de.as213422.net,2a01:4f8:1b7:730::c,vyos
      bbr01.dus.de.as213422.net,2a14:7c0:7000:3ff::14b,vyos
      router01.home01.xnee.net,,routeros
      r1.nbg01.xnee.net,,vyos
    '';
  };

  backup.paths = [ config.services.oxidized.dataDir ];
}
