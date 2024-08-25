{ lib
, inputs
, modulesPath
, ...
}:
{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    # "${inputs.self}/modules/common/users.nix"
    # "${inputs.self}/modules/common/ssh.nix"
    # "${inputs.self}/modules/common/nix.nix"
  ];

  networking = {
    useNetworkd = true;
    useDHCP = false;
    hostName = "home-installer";
    usePredictableInterfaceNames = lib.mkDefault false;
    domain = "xnee.net";
    nameservers = [
      "192.168.10.10"
      "fde6:bbc7:8946:7387:6b4:feff:feca:b60b"
    ];
    timeServers = [ "fde6:bbc7:8946:7387:6b4:feff:feca:b60b" ];
    dhcpcd.enable = false;
  };
  systemd.network = {
    enable = true;
    networks."10-wan" = {
      networkConfig = {
        DHCP = "ipv6";
        IPv6AcceptRA = "yes";
      };
      matchConfig.Name = "eth0";
      address = [
        "192.168.10.255/23"
        "fde6:bbc7:8946:7387::10:ff/64"
      ];
      routes = [{ Gateway = "192.168.10.1"; }];
      linkConfig.RequiredForOnline = "routable";
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOh/i/DybAQVCtAL/q/f0yedGJNecelNEJFEWmezu/hV 2024-08-23-peter@sleipnir"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJRP8UDa+ZcEPZFYwUs0QxOn1e1dXIOP32wlMF8Nx42 2024-02-17-peter@kleeblatt"
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIufiw/wK2tMs2Kr2kZCkdJL0KNo1Ww2wJiS+c8I0QcBz9Ed+Wd6KixXPZK2XBZL3iv0bKXf/7U7mjj6bOetCz0ZI15pdNTYkk2nldvb5JkjXybgX+METJYNxAvoy5f5irDmRHPCG0RZayWCMLqu6uFMEkL6bV8Zn/Dr+PtzJTwgOyb36AWR1lscJ2CYc8tR7EmtxX1i9mexeF+WtG1fk3r3Qxqcxu1/kpncrZkYzvfb9MzuIhr0yWzgPaOd1jKPeAka/uNeQIozvz4VdT4rN8A2MzukAiLu5Cbs3DOQq/FW84Qk8q1me3SlTQ+MCskS0oJLYoxgxhWE85jtjYHU7woT6oehl448PJJk3L9dUX2wJclMbn/dM4YnhW9XN5OTLbhgl7pIzeuAmtV9G6uVafJkUov00/3id+iUrgrycMZrFFQJnKOChF+NVPJ17pCsGD7gycaNCVoXCvwF1GiFleKolfGQsPBShyT6Pop+JyDNQBNMHsGsrFYBQwHZaHhts7ngnt0CqS90/izrOS/kF1kserqZFErMeT9gpQCFjXPrwgSCUdA3c7A+DGpimFKARYUZitOTuZvBj6I2Aj3EX8VJ2tyRZvXQ11rpo33jqahCbUBCk6JOwu+OTvSjtMywqr6jYpcbIvRDaB9L7km/JfOMSFBUkO09JHxAfdwaqx9Q== cardno:20_158_828"
  ];

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      trusted-users = [
        "root"
        "@wheel"
      ];
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://cache.lix.systems"
      ];
      trusted-public-keys = [
        "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o="
      ];
    };
    nixPath = [ "nixpkgs=flake:nixpkgs" ];
  };
}
