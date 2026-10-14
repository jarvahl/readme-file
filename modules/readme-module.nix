{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.readme;

  trimTrailingNewlines =
    text: if lib.hasSuffix "\n" text then trimTrailingNewlines (lib.removeSuffix "\n" text) else text;

  renderSection =
    section:
    lib.concatStringsSep "\n\n" (
      [ "## ${section.title}" ] ++ lib.optional (section.text != "") (trimTrailingNewlines section.text)
    );

  render =
    lib.concatStringsSep "\n\n" (
      [ "# ${cfg.title}" ]
      ++ lib.optional (cfg.description != "") (trimTrailingNewlines cfg.description)
      ++ map renderSection cfg.sections
    )
    + "\n";
in
{
  imports = [
    ./readme-options.nix
    "${inputs.files}/flake-module.nix"
  ];

  config.perSystem =
    { ... }:
    {
      files = {
        file."README.md".text = render;
        writer.app = true;
      };
    };
}
