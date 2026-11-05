{
  description = "NixOS Dani";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    
    # Flake oficial de Hyprland
    hyprland.url = "github:hyprwm/Hyprland";

	hyprpaper.url = "github:hyprwm/hyprpaper";

    sysc-greet = {
      url = "github:Nomadcxx/sysc-greet";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sysc-greet, hyprland, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      # Pasar los inputs a todos los módulos (permite usar 'inputs.hyprland' en configuration.nix)
      specialArgs = { inherit inputs; };

      modules = [
        ./configuration.nix
        sysc-greet.nixosModules.default
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.dani = import ./home.nix;
            backupFileExtension = "backup";
          };
        }
      ];
    };  
  };
}
