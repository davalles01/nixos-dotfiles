{
  description = "NixOS Dani";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
	sysc-greet = {
	  url = "github:Nomadcxx/sysc-greet";
      inputs.nixpkgs.follows = "nixpkgs";
	};
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, sysc-greet, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
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
