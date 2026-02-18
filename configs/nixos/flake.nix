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
            wsl.enable = true;
            wsl.defaultUser = "nixos";

            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            users.users.nixos = {
              isNormalUser = true;
              extraGroups = [ "wheel" ];
              shell = pkgs.bash;
            };

security.sudo.wheelNeedsPassword = false;

            environment.systemPackages = with pkgs; [
              git git-filter-repo vim neovim curl wget rustc cargo go nodejs ollama
              python3 python311 python3Packages.pip python3Packages.httpx
              python3Packages.jinja2 python3Packages.requests python3Packages.tkinter
              pipx black mypy bash-completion fzf tmux tree btop jq joshuto ranger
              mpv cmake ninja gcc docker docker-compose docker-buildx kubectl
              openssh cacert
            ];

virtualisation.docker.enable = true;
            virtualisation.docker.liveRestore = false;

            system.stateVersion = "25.05";
          })
        ];
      };
    };
}
