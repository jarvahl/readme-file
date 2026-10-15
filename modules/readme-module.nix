{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.readme-file;

  trimTrailingNewlines =
    text: if lib.hasSuffix "\n" text then trimTrailingNewlines (lib.removeSuffix "\n" text) else text;

  generatedNotice = "<!-- DO-NOT-EDIT. This file was auto-generated using github:jarvahl/readme-file. Use nix run .#write-files to regenerate it. -->";

  renderSection =
    section:
    lib.concatStringsSep "\n\n" (
      [ "## ${section.title}" ] ++ lib.optional (section.text != "") (trimTrailingNewlines section.text)
    );

  render =
    lib.concatStringsSep "\n\n" (
      [
        generatedNotice
        "# ${cfg.title}"
      ]
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
