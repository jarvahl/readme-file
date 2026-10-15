{
  description = "Declarative README generator for Nix";

  inputs = {
    files = {
      url = "github:mightyiam/files";
      flake = false;
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:denful/import-tree";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ (inputs.import-tree ./modules) ];
      readmeFile = {
        title = "readme-file";
        description = "Declarative README generation for Nix flakes.";
        sections = [
          {
            title = "Use";
            text = ''
              Add the flake module to a flake-parts configuration:

              ```nix
              {
                inputs.readme-file.url = "github:jarvahl/readme-file";

                outputs = inputs:
                  inputs.flake-parts.lib.mkFlake { inherit inputs; } {
                    imports = [ inputs.readme-file.flakeModules.default ];

                    readmeFile = {
                      title = "My Nix Configuration";
                      description = "Declarative NixOS configuration";
                      sections = [
                        {
                          title = "Installation";
                          text = "Run `nixos-rebuild switch --flake .#hostname`.";
                        }
                        {
                          title = "Usage";
                          text = "Run `just --list`.";
                        }
                      ];
                    };
                  };
              }
              ```

              The module writes the configured content through `mightyiam/files`. Materialize
              and validate the tracked file with:

              ```sh
              nix run .#write-files
              nix flake check
              ```

              Sections can be contributed by independent modules and ordered with native Nix
              module operations:

              ```nix
              { lib, ... }:
              {
                readmeFile.sections = lib.mkBefore [
                  {
                    title = "Quick Start";
                    text = "Getting started.";
                  }
                ];
              }
              ```

              Use ordinary Nix expressions for dynamic content; no template language is
              required.
            '';
          }
        ];
      };
    };
}
