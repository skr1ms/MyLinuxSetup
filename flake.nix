{
  description = "NixOS + Caelestia-dots + meowrch themes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-cli = {
      url = "github:caelestia-dots/cli";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    antigravity = {       
      url = "github:jacopone/antigravity-nix";     
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let system = "x86_64-linux"; in {
    nixosConfigurations.NixOS = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs system; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.takuya = import ./home.nix;
            extraSpecialArgs = { inherit inputs system; };
          };
        }
      ];
    };
  };
}

