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
  };

  outputs =
    { self
    , nixpkgs
    , disko
    , sops-nix
    , flake-utils
    , colmena
    , attic
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
          ];
        };
        monitoring = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
          modules = [
            ./nodes/monitoring
            self.nixosModules.common
          ];
        };
        sync = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
          modules = [
            ./nodes/sync
            self.nixosModules.common
          ];
        };
        cache = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          extraModules = [ inputs.colmena.nixosModules.deploymentOptions ];
          modules = [
            ./nodes/cache
            self.nixosModules.common
          ];
        };
      };

      nixosModules = {
        common = ./modules/common;
      };

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    };
}
