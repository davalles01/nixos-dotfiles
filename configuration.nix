{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.blacklistedKernelModules = [ "ucsi_acpi" ];

  boot.kernelParams = [
    # 1. Desactiva Panel Self Refresh (PSR)
    "amdgpu.dcdebugmask=0x10"

    # 2. Desactiva ABM (Adaptive Backlight Management - culpable directo en fondos oscuros)
    "amdgpu.abmlevel=0"

    # 3. Desactiva la fluctuación dinámica del reloj de pantalla/VRAM al ahorrar energía
    "amdgpu.ppfeaturemask=0xfffd7fff"

	# Desactiva el ahorro de energía en el bus PCIe de la GPU AMD
	"pcie_aspm=off"
	"amdgpu.aspm=0"

	# Evita que la pantalla entre en estados deep-sleep de energía
	"amdgpu.runpm=0"
  ];

  nixpkgs.config.allowUnfree = true;

  # Battery

  services.upower.enable = true;


  # Networking 

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  
  # Bluetooth

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.dbus.enable = true;
  security.rtkit.enable = true;

  time.timeZone = "Europe/Madrid";

  console = {
	enable = true;
	font = "Lat2-Terminus16";
	keyMap = "es";
  };

  # Ly

  services.displayManager.ly.enable = true;

  # Hyprland setup

  programs.hyprland = {
	enable = true;
	xwayland.enable = true;
  };

  security.polkit.enable = true;

  xdg.portal.enable = true;
  xdg.portal.extraPortals = [
	pkgs.xdg-desktop-portal-hyprland
  ];

  services.gnome.gnome-keyring.enable = true;

  # Solaar Dependencies

  hardware.logitech.wireless.enable = true;
  boot.kernelModules = [ "uinput" ];

  # Audio setup

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;

	jack.enable = true;

	wireplumber.enable = true;  
  };

  services.libinput.enable = true;

  # Users

  users.users.dani = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      tree
    ];
  };

	programs.firefox = {
	  enable = true;
	  nativeMessagingHosts.packages = with pkgs; [
		firefoxpwa
	  ];
	};

  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # Fprintd
  services.fprintd.enable = true;

  security.pam.services.sudo.rules.auth.fprintd.order =
  config.security.pam.services.sudo.rules.auth.unix.order + 50;

  security.pam.services.ly.fprintAuth = false;

  environment.systemPackages = with pkgs; [
    vim
    wget
	kitty
	hyprpaper
	hyprlock 
	hypridle
	hyprshot
	fastfetch
	xfce.thunar
	solaar
    git
	wl-clipboard
	brightnessctl 
	playerctl 
	libnotify
	slurp 
	
	fprintd
	polkit_gnome

	alsa-utils

	matugen
	jq
  ];

  environment.pathsToLink = [ "/libexec" ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";

}

