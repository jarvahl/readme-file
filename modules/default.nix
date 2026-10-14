{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];
  systems = inputs.nixpkgs.lib.systems.flakeExposed;

  perSystem = {
    treefmt = {
      projectRootFile = "flake.nix";
      programs.nixfmt.enable = true;
    };
  };
}
