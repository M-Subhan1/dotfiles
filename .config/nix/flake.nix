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
            pkgs.wget
            pkgs.bun
            pkgs.valkey
            pkgs.graphicsmagick
            pkgs.direnv
            pkgs.karabiner-elements
          ];

        # Adding homebrew casks
        homebrew = {
          enable = true;
          taps = [
            "nikitabobko/tap"
            "supabase/tap"
          ];

          brews = [
            "neovim"
            "tpm"
            "stow"
            "sqlite"
            "nvm"
            "pnpm"
            "gh"
            "docker-compose"
            "supabase"
            "stripe-cli"
          ];

          casks = [
            "wezterm@nightly"
            "zen-browser"
            "zoom"
            "spotify"
            "slack"
            "whatsapp"
            "raycast"
            "linear-linear"
            "iina"
            "the-unarchiver"
            "stats"
            "aldente"
            "git-credential-manager"
            "google-chrome"
            "notion"
            "ghostty"
            "orbstack"
            "cursor"
            "obsidian"
          ];

          onActivation.autoUpdate = true;
        };

        # Adding fonts to the environment
        fonts.packages = with pkgs; [
          pkgs.nerd-fonts.jetbrains-mono
        ];


        system.defaults = {
          # Set the default theme to dark.
          NSGlobalDomain.AppleInterfaceStyle = "Dark";

          dock = {
            autohide = true;
            show-recents = false;
            persistent-apps = [
              "/Applications/Notion Calendar.app/"
              "/Applications/WezTerm.app/"
              "/Applications/Zen Browser.app/"
              "/Applications/Linear.app/"
              "/Applications/Slack.app/"
              "/Applications/Cursor.app/"
            ];
          };
        };

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
