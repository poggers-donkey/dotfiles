{
  description = "Your new nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    emacs.url = "github:nix-community/emacs-overlay";
    emacs.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    impermanence.url = "github:nix-community/impermanence";
#    hyprland.url = "github:hyprwm/Hyprland";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    stylix.url = "github:danth/stylix";
#     base16.url = github:SenchoPens/base16.nix;

base16-schemes = { url = github:TotalChaos05/base16-schemes; flake = false; };
  };

  outputs =
    { self, nixpkgs, home-manager, impermanence,# hyprland, 
    emacs, nur,
      nixos-hardware, stylix,# base16-schemes,
      ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in rec {
      nixosConfigurations = {
        t480 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
	  nixos-hardware.nixosModules.lenovo-thinkpad-t480
            ./configuration.nix
	    ./hardware-configuration.nix
          ];
        };
	poggers = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
	  nixos-hardware.nixosModules.lenovo-thinkpad-t480
            ./configuration.nix
	    ./poggers-hw.nix
          ];
        };

      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      #homeConfigurations = {
      # FIXME replace with your username@hostname
      #"your-username@your-hostname" = home-manager.lib.homeManagerConfiguration {
      #pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
      #extraSpecialArgs = { inherit inputs outputs; };
      #modules = [
      ## > Our main home-manager configuration file <
      #./home-manager/home.nix
      #];
      #};
      #};
    };
}
