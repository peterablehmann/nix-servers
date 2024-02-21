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
  };

  outputs =
    { self
    , nixpkgs
    , sops-nix
    , ...
    } @ inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations = {
        mns = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          modules = [
            ./nodes/mns
            self.nixosModules.common
          ];
        };
        sync = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          modules = [
            ./nodes/sync
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
