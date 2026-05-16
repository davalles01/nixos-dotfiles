{ config, pkgs, ... }:

let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config";
  create_symlink = path: config.lib.file.mkOutOfStoreSymlink path;
  configs = {
	hypr = "hypr";
    nvim = "nvim"; 
	kitty = "kitty"; 
	fastfetch = "fastfetch";
	rofi = "rofi";
	quickshell = "quickshell";
  };
in 

{
  home.username = "dani";
  home.homeDirectory = "/home/dani";
  programs.git.enable = true;
  home.stateVersion = "25.11";

  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Mocha-Standard-Blue-Dark";
      package = pkgs.catppuccin-gtk;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    font = {
      name = "Noto Sans";
      size = 11;
    };
  };

  programs.bash = {
    enable = true;

    shellAliases = {
      v = "nvim";
	  nrs = "sudo nixos-rebuild switch --flake ~/nixos-dotfiles#nixos";
    }; 

	initExtra = '' 
		if [[ $- == *i* ]]; then
		  fastfetch
		fi
	'';
  };

  xdg.configFile = builtins.mapAttrs 
    (name: subpath: {
		source = create_symlink "${dotfiles}/${subpath}";
		recursive = true;
	})
	configs;

	home.packages = with pkgs; [
	neovim
	zip
	unzip
	ripgrep
	nil
	nixpkgs-fmt
	nodejs
	gcc

	bibata-cursors

	papirus-icon-theme
	catppuccin-gtk

	quickshell
    qt6Packages.qtdeclarative

	xfce.exo

	blueman
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  home.sessionVariables = {
	GTK_THEME = "Catppuccin-Mocha-Standard-Blue-Dark";
	QML_IMPORT_PATH = "${pkgs.quickshell}/lib/qt-6/qml";

	TERMINAL = "kitty";
	XDG_TERMINAL = "kitty";
    XDG_TERMINAL_EMULATOR = "kitty";
  };
}
