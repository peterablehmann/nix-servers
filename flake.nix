{
  description = "nix-servers";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

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

    # Attic
    attic.url = "github:zhaofengli/attic";

    # Nix-Topology
    nix-topology.url = "github:oddlama/nix-topology";

    # NixOS-DNS
    # peterablehmann/NixOS-DNS/tree/fix-cnames
    nixos-dns.url = "github:Janik-Haag/NixOS-DNS";
    nixos-dns.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self
    , nixpkgs
    , disko
    , sops-nix
    , flake-utils
    , colmena
    , attic
    , nix-topology
    , nixos-dns
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
      conf = self.nixosConfigurations;
    in
    (flake-utils.lib.eachDefaultSystem (system:
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
        ];
      };
    })) //
    {
      colmena = {
        # see for details:
        # https://github.com/zhaofengli/colmena/issues/60#issuecomment-1510496861
        meta = {
          nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
          nodeSpecialArgs = builtins.mapAttrs (name: value: value._module.specialArgs) conf;
        };
      } // builtins.mapAttrs (name: value: { imports = value._module.args.modules; }) conf;

      nixosConfigurations = {
        mns = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
          modules = [
            ./nodes/mns
            self.nixosModules.common
            nix-topology.nixosModules.default
          ];
        };
        sync = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
          modules = [
            ./nodes/sync
            self.nixosModules.common
            nix-topology.nixosModules.default
          ];
        };
        ymir = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
          modules = [
            ./nodes/ymir
            self.nixosModules.common
            nix-topology.nixosModules.default
          ];
        };
      };

      nixosModules = {
        common = ./modules/common;
        monitoring = ./modules/monitoring;
        kanidm = ./modules/kanidm.nix;
        paperless = ./modules/paperless.nix;
      };

      dns = (nixos-dns.utils.generate nixpkgs.legacyPackages.x86_64-linux).octodnsConfig {
        dnsConfig = {
          inherit (self) nixosConfigurations;
          extraConfig = import ./dns.nix;
        };
        config = {
          providers = {
            hetzner = {
              class = "octodns_hetzner.HetznerProvider";
              token = "env/HETZNER_DNS_API";
            };
          };
        };
        zones = {
          "bigdriver.net." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
          "lehmann.zone." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
          "uic-fahrzeugnummer.de." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
          "xnee.de." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
          "xnee.net." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    } // flake-utils.lib.eachDefaultSystem (system: rec {
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ nix-topology.overlays.default ];
      };

      topology = import nix-topology {
        inherit pkgs;
        modules = [
          # Your own file to define global topology. Works in principle like a nixos module but uses different options.
          # ./topology.nix
          # Inline module to inform topology of your existing NixOS hosts.
          ./topology.nix
          { inherit (self) nixosConfigurations; }
        ];
      };
    });
}
