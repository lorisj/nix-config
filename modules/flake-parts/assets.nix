{ lib, self, ... }:
{
  options.flake.assets = lib.mkOption {
    type = lib.types.submodule {
      options = {
        images = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.path;
          default = { };
          description = "Static image assets shipped with this flake.";
        };

        directories = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.path;
          default = { };
          description = "Asset directories shipped with this flake.";
        };

        sources = lib.mkOption {
          type = lib.types.lazyAttrsOf lib.types.path;
          default = { };
          description = "Source files used by asset generators.";
        };

      };
    };
    default = { };
  };

  config.flake.assets = {
    images = {
      roundHill = builtins.toPath "${self.outPath}/.assets/round-hill.jpg";
      vanSickle = builtins.toPath "${self.outPath}/.assets/van-sickle.jpg";
    };
    directories.programIcons = builtins.toPath "${self.outPath}/.assets/sketchybar-icons";
    sources = {
      sketchybarTexture = builtins.toPath "${self.outPath}/.assets/sketchybar/texture.py";
      starSpecks = builtins.toPath "${self.outPath}/.assets/kitty/star-specks.py";
    };
  };
}
