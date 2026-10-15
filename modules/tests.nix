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
      readme-file = {
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
      readme-file.sections = lib.mkAfter [
        {
          title = "After";
          text = "a";
        }
      ];
    })
    ({ lib, ... }: {
      readme-file.sections = lib.mkBefore [
        {
          title = "Before";
          text = "b";
        }
      ];
    })
    ({ lib, ... }: {
      readme-file.sections = lib.mkOrder 500 [
        {
          title = "Middle";
          text = "m";
        }
      ];
    })
  ];

  composed = eval [
    ({ lib, ... }: {
      readme-file.description = lib.mkDefault "default";
      readme-file.sections = lib.mkMerge [
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
      readme-file.description = lib.mkForce "forced";
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
        readme-file.sections = [
          {
            title = "Commands";
            text = inputs.nixpkgs.lib.concatMapStringsSep "\n" (name: "- `${name}`") config.commands;
          }
        ];
      };
    })
  ];

  assertions = [
    (basic.readme-file.title == "Project")
    (basic.readme-file.description == "Intro")
    (
      basic.readme-file.sections == [
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
      ordered.readme-file.sections == [
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
    ((builtins.elemAt dynamic.readme-file.sections 0).text == "- `build`\n- `test`")
    (composed.readme-file.description == "forced")
    (
      composed.readme-file.sections == [
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
