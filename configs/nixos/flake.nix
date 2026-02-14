{
  description = "My NixOS WSL system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
  };

  outputs = { self, nixpkgs, nixos-wsl, ... }:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        nixos-wsl.nixosModules.default

        ({ pkgs, ... }: {

          # Enable WSL
          wsl.enable = true;
          wsl.defaultUser = "nixos";

          # Enable flakes
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          # User
          users.users.nixos = {
            isNormalUser = true;
            extraGroups = [ "wheel" ];
            shell = pkgs.bash;
          };

          security.sudo.wheelNeedsPassword = false;

          # Packages
          environment.systemPackages = with pkgs; [
            git
            vim
            curl
            wget
            rustc
            cargo
            joshuto
            ranger
            go
            python3
            mpv
            cacert
            nodejs
          ];

          system.stateVersion = "25.05";
        })
      ];
    };
  };
}

