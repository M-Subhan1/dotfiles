{
  description = "Zenful Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
    let
      configuration = { pkgs, config, ... }: {

        # Allow unfree packages to be installed.
        nixpkgs.config.allowUnfree = true;
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages =
          [
            pkgs.neovim
            pkgs.tmux
            pkgs.sesh
            pkgs.starship
            pkgs.git
            pkgs.eza
            pkgs.zoxide
            pkgs.ripgrep
            pkgs.fzf
            pkgs.lazygit
            pkgs.ranger
            pkgs.pnpm
            pkgs.yarn
            pkgs.supabase-cli
            pkgs.stripe-cli
            pkgs.nodejs_20
            pkgs.sqlite
          ];

        # Adding homebrew casks
        homebrew = {
          enable = true;

          brews = [
            "tpm"
            "stow"
          ];

          casks = [
            "wezterm@nightly"
            "arc"
            "zen-browser"
            "zoom"
            "spotify"
            "slack"
            "whatsapp"
            "raycast"
            "docker"
            "cloudflare-warp"
            "linear-linear"
            "iina"
            "the-unarchiver"
            "stats"
            "aldente"
            "git-credential-manager"
            "nikitabobko/tap/aerospace"
          ];

          onActivation.autoUpdate = true;
          onActivation.cleanup = "zap";
        };

        # Adding fonts to the environment
        fonts.packages = with pkgs; [
          (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];

        system.defaults = {
          dock.autohide = true;
        };

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true; # default shell on catalina
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Muhammads-MacBook-Pro-3
      darwinConfigurations."Muhammads-MacBook-Pro-3" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              # Apple Silicon Only
              enableRosetta = true;

              user = "subhan";
              autoMigrate = true;
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."Muhammads-MacBook-Pro-3".pkgs;
    };
}
