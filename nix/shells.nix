{
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    devShells.default = pkgs.mkShellNoCC {
      name = "workstation-home-manager";

      packages = [
        # Take the CLI from the flake input so it can't drift from the modules.
        inputs'.home-manager.packages.home-manager
        pkgs.git
        pkgs.claude-code
        pkgs.nix-output-monitor
      ];

      shellHook = ''
        echo "workstation-home-manager: 'home-manager switch --impure --flake .' to apply"
      '';
    };
  };
}
