# nix-config — agent notes

## Flake-parts: the whole tree is modules

The flake is built with [flake-parts](https://flake.parts/). Nix that defines system or user configuration should live in **flake-parts modules**—the `.nix` files under `modules/`, `users/`, `hosts/`, etc. that the flake imports and that each return module-shaped attributes (`flake`, `perSystem`, …).

- Prefer adding or extending a **fp module** over standalone `.nix` files that are not wired into `flake.nix` / the parts loader.
- Avoid one-off config outside the module pattern; it makes the config harder to compose and discover.

`flake.nix` itself stays thin; real definitions live in these imported parts.

## Inner modules: wrap settings in `config`

Leaf parts define `flake.{sharedModules,darwinModules,nixosModules,homeModules,nixvimModules}.*` and `flake.userConfig.<name>.module` (Home Manager user profiles). Those are **inner** NixOS-style submodules.

### Required shape

In the **inner** module (the body of `= { ... }:` for those definitions), keep only `imports`, `options`, and `meta` at the top level. Put every actual setting under an explicit `config` block.

Allowed at top level next to `imports` / `options`: `config = { ... }` (or `config = lib.mkMerge` / `lib.mkIf` as needed).

Do **not** use Nix’s shorthand that places `programs.*`, `services.*`, `home.*`, `nix.*`, nixvim `plugins` / `keymaps` / `globals`, etc. next to `imports` without a `config` wrapper.

### Example (inner home module)

```nix
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

### Example (nixvim plugin module)

```nix
{ ... }:
{
  flake.nixvimModules.plugins.foo = { ... }: {
    config = {
      plugins.some-plugin.enable = true;
    };
  };
}
```

### Cursor

The same conventions (everything as flake-parts modules, and inner `config` blocks) are in [`.cursor/rules/nix-modules-config.mdc`](.cursor/rules/nix-modules-config.mdc). Keep this file and that rule aligned when they change.
