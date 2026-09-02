# nix-config — agent instructions

## Flake-parts modules

Everything in this repository that defines configuration should be a flake-parts
module: a Nix file imported by flake-parts (for example, under `modules/`,
`users/`, or `hosts/`) that returns module-shaped attributes such as `flake`,
`perSystem`, or `options`.

- Add new features to a new or existing flake-parts module and wire them into
  `flake.*` or `perSystem` consistently with the rest of the tree.
- Do not add ad hoc `.nix` files that are never imported by the flake or bypass
  the module system for one-off configuration.
- Keep `flake.nix` thin; put real definitions in imported modules.

## Inner modules require explicit `config`

Leaf modules define
`flake.{osModules,sharedModules,darwinModules,homeModules,nixvimModules}` and
`flake.userConfig.*.module`. These definitions contain inner NixOS-style module
functions.

In an inner module body, only module structure may appear at the top level:

- `imports`
- `options`
- `meta`
- `_module` or another module-system escape hatch
- `config`

Put all actual configuration under an explicit `config` attribute. This
includes `programs`, `services`, `home`, `environment`, `users`, `nix`,
`nixpkgs`, `home-manager`, and nixvim settings such as `plugins`, `globals`,
`keymaps`, and `opts`.

Use `config = lib.mkMerge [ ... ];` or `config = lib.mkIf condition { ... };`
when configuration needs merging or conditionals.

```nix
# Good
{ ... }:
{
  flake.homeModules.example = { ... }: {
    imports = [ ./other.nix ];
    config = {
      programs.git.enable = true;
    };
  };
}
```

```nix
# Bad: configuration uses shorthand at the inner module's top level
{ ... }:
{
  flake.homeModules.example = { ... }: {
    imports = [ ./other.nix ];
    programs.git.enable = true;
  };
}
```

```nix
# Good: nixvim inner module
{ ... }:
{
  flake.nixvimModules.plugins.foo = { ... }: {
    config = {
      plugins.foobar.enable = true;
    };
  };
}
```

This explicit `config` rule applies only to inner NixOS, Home Manager,
nix-darwin, and nixvim module bodies. It does not apply to an outer flake-parts
module that directly sets `flake.*` or `perSystem` and contains no inner module
function.
