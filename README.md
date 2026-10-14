<!-- DO-NOT-EDIT. This file was auto-generated using github:jarvahl/readme-file. Use nix run .#write-files to regenerate it. -->

# readme-file

Declarative README generation for Nix flakes.

## Use

Add the flake module to a flake-parts configuration:

```nix
{
  inputs.readme-file.url = "github:jarvahl/readme-file";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.readme-file.flakeModules.default ];

      readme = {
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
  readme.sections = lib.mkBefore [
    {
      title = "Quick Start";
      text = "Getting started.";
    }
  ];
}
```

Use ordinary Nix expressions for dynamic content; no template language is
required.
