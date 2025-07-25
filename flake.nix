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

    # Attic
    attic.url = "github:zhaofengli/attic";

    # NixOS-DNS
    # peterablehmann/NixOS-DNS/tree/fix-cnames
    nixos-dns.url = "github:Janik-Haag/NixOS-DNS";
    nixos-dns.inputs.nixpkgs.follows = "nixpkgs";

    fernglas = {
      type = "github";
      owner = "wobcom";
      repo = "fernglas";
    };
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
      attic,
      nixos-dns,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      # let's filter the installer configuration since we don't want to deploy it with colmena
      conf = builtins.removeAttrs self.nixosConfigurations [ "home-installer" ];
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
          ];
        };
      }
    ))
    // {
      colmena = {
        # see for details:
        # https://github.com/zhaofengli/colmena/issues/60#issuecomment-1510496861
        meta = {
          nixpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
          nodeSpecialArgs = builtins.mapAttrs (name: value: value._module.specialArgs) conf;
        };
      } // builtins.mapAttrs (name: value: { imports = value._module.args.modules; }) conf;

      nixosConfigurations = {
        bjorn = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
          modules = [
            ./nodes/bjorn
            self.nixosModules.common
          ];
        };
        heptifili = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
          modules = [
            ./nodes/heptifili
            self.nixosModules.common
          ];
        };
        mns = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
          modules = [
            ./nodes/mns
            self.nixosModules.common
          ];
        };
        ymir = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
          modules = [
            ./nodes/ymir
            self.nixosModules.common
          ];
        };
      };

      nixosModules = {
        common = ./modules/common;
        dyndns = ./modules/dyndns;
        immich = ./modules/immich.nix;
        monitoring = ./modules/monitoring;
        lidarr = ./modules/lidarr.nix;
        pathvector = ./modules/pathvector.nix;
        netbox = ./modules/netbox.nix;
        kanidm = ./modules/kanidm.nix;
        keycloak = ./modules/keycloak.nix;
        paperless = ./modules/paperless.nix;
        pdns-recursor = ./modules/pdns-recursor.nix;
        syncthing = ./modules/syncthing.nix;
        uptime-kuma = ./modules/uptime-kuma.nix;
        unbound = ./modules/unbound.nix;
        restic-server = ./modules/restic-server;
        nextcloud = ./modules/nextcloud.nix;
        radicale = ./modules/radicale;
        routinator = ./modules/routinator.nix;
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
          "hainsacker.de." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
          "hetzner-offline.de." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
          "lehmann.ing." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
          "lehmann.zone." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
          "uic-fahrzeugnummer.de." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
          "xnee.de." = nixos-dns.utils.octodns.generateZoneAttrs [ "hetzner" ];
          "xnee.net." = nixos-dns.utils.octodns.generateZoneAttrs [
            "hetzner"
          ];
        };
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;
    };
}
