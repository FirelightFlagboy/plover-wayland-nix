# Plover for Wayland

Try to provide a nix derivation for plover that work on Wayland.

By following the discussion [openstenoproject/plover#1050 - Not working [...] on Wayland [...]](https://github.com/openstenoproject/plover/issues/1050).
I've tried to provide plover with 2 proposed flavor `wtype` and `dotool` with the latest version of plover v4 (currently `v4.0.0-rc.2`).

For both flavor you will need to enable manually the plugin (navigate to `Settings -> Plugin`) or by editing the field `Plugins.enabled_extensions` in `~/.config/plover/plover.cfg`.

In the end only the `dotool` flavor work on my system (`nixos`).

## With dotool

```shell
nix run .#plover-dotool
```

## With wtype

```shell
nix run .#plover-wtype
```

## Testing both flavor

I've provided a nix dev shell that provide both flavor with `plover` to try them out.

First you will need to enter in the development shell with:

```shell
nix develop
```

Then execute `plover`, at that point, you will need to enable one of the plugins.

## Sources

- [lgcl/nuv plover derivation](https://git.sr.ht/~lgcl/nuv/tree/5160a21c675506cee7872d0b7a269daadd6c9eb6/item/hmModules/plover.nix) providing the building block for this flake.
- [halbGefressen/plover-output-dotool](https://github.com/halbGefressen/plover-output-dotool) providing the plugin `plover-output-dotool`.
- [svenkeidel/plover-wtype-output](https://github.com/svenkeidel/plover-wtype-output) providing the plugin `plover-wtype-output`.
