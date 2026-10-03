{
  description = "nix-servers";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Lix
    # lix-module = {
    #   url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    # Disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # SOPS Nix
    sops-nix.url = "github:Mic92/sops-nix";

    # Flake-Utils
    flake-utils.url = "github:numtide/flake-utils";

    # Colmena
    colmena.url = "github:zhaofengli/colmena/main";
    colmena.inputs.nixpkgs.follows = "nixpkgs";

    # NixOS-DNS
    # peterablehmann/NixOS-DNS/tree/fix-cnames
    nixos-dns.url = "github:Janik-Haag/NixOS-DNS";
    nixos-dns.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      # lix-module,
      disko,
      sops-nix,
      flake-utils,
      colmena,
      nixos-dns,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    (flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # pkgs is needed here because colmena would otherwise be in the scope two times
            pkgs.colmena
            sops
            jq
            octodns
            octodns-providers.bind
            octodns-providers.hetzner
            nixfmt-tree
            nixos-anywhere
          ];
        };
      }
    ))
    // {
      colmenaHive = colmena.lib.makeHive {
        meta = {
          specialArgs = { inherit inputs outputs; };
          nixpkgs = import nixpkgs {
            system = "x86_64-linux";
          };
        };

        defaults = {
          imports = [
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            nixos-dns.nixosModules.dns
            self.nixosModules.common
          ];
        };
        
        immich = {
          imports = [ ./nodes/immich ];
        };
        miniflux = {
          imports = [ ./nodes/miniflux ];
        };
        netbird01-nbg01 = {
          imports = [ ./nodes/netbird01-nbg01 ];
        };
        netbird02-nbg01 = {
          imports = [ ./nodes/netbird02-nbg01 ];
        };
        netbox = {
          imports = [ ./nodes/netbox ];
        };
        oxidized = {
          imports = [ ./nodes/oxidized ];
        };
        paperless = {
          imports = [ ./nodes/paperless ];
        };
        radicale = {
          imports = [ ./nodes/storage1 ];
        };
        storage1 = {
          imports = [ ./nodes/storage1 ];
        };
        syncthing = {
          imports = [ ./nodes/syncthing ];
        };
        workstation-server = {
          imports = [ ./nodes/workstation-server ];
        };
        ymir = {
          imports = [ ./nodes/ymir ];
        };
      };

      nixosConfigurations = self.colmenaHive.nodes;

      nixosModules = {
        common = ./modules/common;
        monitoring = ./modules/monitoring;
        paperless = ./modules/paperless.nix;
        restic-server = ./modules/restic-server;
        pocket-id = ./modules/pocket-id.nix;
        routinator = ./modules/routinator.nix;
      };

      dns = (nixos-dns.utils.generate nixpkgs.legacyPackages.x86_64-linux).octodnsConfig {
        dnsConfig = {
          inherit (self) nixosConfigurations;
          extraConfig = import ./dns.nix;
        };
        config = {
          processors = {
            acme.class = "octodns.processor.acme.AcmeMangingProcessor";
          };
          providers = {
            hetzner = {
              class = "octodns_hetzner.HetznerProvider";
              token = "env/HETZNER_DNS_API";
              backend = "hcloud";
            };
          };
        };
        zones = {
          "as213422.net." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ] // {
            processors = [ "acme" ];
          };
          "bigdriver.net." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ] // {
            processors = [ "acme" ];
          };
          "hainsacker.de." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ] // {
            processors = [ "acme" ];
          };
          "lehmann.ing." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ] // {
            processors = [ "acme" ];
          };
          "lehmann.zone." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ] // {
            processors = [ "acme" ];
          };
          # "uic-fahrzeugnummer.de." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ] // {
          #   processors = [ "acme" ];
          # };
          "xnee.net." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ] // {
            processors = [ "acme" ];
          };
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
