{
  description = "FZ NixOS WSL";

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
            # Development tools
            git
            git-filter-repo
            vim
            neovim
            curl
            wget
            rustc
            cargo
            go
            nodejs
            python3
            python311
            python3Packages.pip
            python3Packages.httpx
            python3Packages.jinja2
            python3Packages.requests
            python3Packages.tkinter
            pipx
            black
            mypy

            # System utilities
            bash-completion
            fzf
            tmux
            tree
            btop
            jq

            # File managers
            joshuto
            ranger

            # Media
            mpv

            # Build tools
            cmake
            ninja
            gcc

            # Docker
            docker
            docker-compose
            docker-buildx

            # Kubernetes
            kubectl

            # SSH
            openssh

            # Security
            cacert
          ];

          system.stateVersion = "25.05";
        })
      ];
    };
  };
}
