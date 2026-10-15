{ inputs, ... }:
let
  testModule = import ./readme-options.nix;
  eval =
    modules:
    (inputs.nixpkgs.lib.evalModules {
      modules = [ testModule ] ++ modules;
    }).config;

  basic = eval [
    {
      readmeFile = {
        title = "Project";
        description = "Intro";
        sections = [
          {
            title = "One";
            text = "Line 1\nLine 2";
          }
          {
            title = "Two";
            text = "**Markdown**";
          }
        ];
      };
    }
  ];

  ordered = eval [
    ({ lib, ... }: {
      readmeFile.sections = lib.mkAfter [
        {
          title = "After";
          text = "a";
        }
      ];
    })
    ({ lib, ... }: {
      readmeFile.sections = lib.mkBefore [
        {
          title = "Before";
          text = "b";
        }
      ];
    })
    ({ lib, ... }: {
      readmeFile.sections = lib.mkOrder 500 [
        {
          title = "Middle";
          text = "m";
        }
      ];
    })
  ];

  composed = eval [
    ({ lib, ... }: {
      readmeFile.description = lib.mkDefault "default";
      readmeFile.sections = lib.mkMerge [
        [
          {
            title = "Merged";
            text = "merged";
          }
        ]
        (lib.mkIf true [
          {
            title = "Conditional";
            text = "conditional";
          }
        ])
      ];
    })
    ({ lib, ... }: {
      readmeFile.description = lib.mkForce "forced";
    })
  ];

  dynamic = eval [
    ({ config, ... }: {
      options.commands = inputs.nixpkgs.lib.mkOption {
        type = inputs.nixpkgs.lib.types.listOf inputs.nixpkgs.lib.types.str;
        default = [ ];
      };
      config = {
        commands = [
          "build"
          "test"
        ];
        readmeFile.sections = [
          {
            title = "Commands";
            text = inputs.nixpkgs.lib.concatMapStringsSep "\n" (name: "- `${name}`") config.commands;
          }
        ];
      };
    })
  ];

  assertions = [
    (basic.readmeFile.title == "Project")
    (basic.readmeFile.description == "Intro")
    (
      basic.readmeFile.sections == [
        {
          title = "One";
          text = "Line 1\nLine 2";
        }
        {
          title = "Two";
          text = "**Markdown**";
        }
      ]
    )
    (
      ordered.readmeFile.sections == [
        {
          title = "Middle";
          text = "m";
        }
        {
          title = "Before";
          text = "b";
        }
        {
          title = "After";
          text = "a";
        }
      ]
    )
    ((builtins.elemAt dynamic.readmeFile.sections 0).text == "- `build`\n- `test`")
    (composed.readmeFile.description == "forced")
    (
      composed.readmeFile.sections == [
        {
          title = "Merged";
          text = "merged";
        }
        {
          title = "Conditional";
          text = "conditional";
        }
      ]
    )
  ];
in
{
  perSystem = { pkgs, ... }: {
    checks.readme-module-tests = pkgs.runCommand "readme-module-tests" { } ''
      ${if builtins.all (x: x) assertions then "touch $out" else "exit 1"}
    '';
  };
}
