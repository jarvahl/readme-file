{ lib, ... }:
{
  options.readme = {
    title = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The main README heading.";
    };

    description = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Optional Markdown immediately following the title.";
    };

    sections = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            title = lib.mkOption {
              type = lib.types.str;
              description = "The section heading.";
            };
            text = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "The section Markdown content.";
            };
          };
        }
      );
      default = [ ];
      description = "Ordered README sections.";
    };
  };
}
