# Vial layout to Keymap Drawer converter

**Quick links:** [web version](https://yal-tools.github.io/vial-to-keymap-drawer/)
· [pre-built binaries](https://yellowafterlife.itch.io/vial-to-keymap-drawer)

Takes your Vial `.vil` layouts and converts them to YAML that you can pass to
[keymap-drawer](https://github.com/caksoylar/keymap-drawer)
to render your layout to SVG/PNG images that you can show to people instead
of taking screenshots of Vial configurator.

Also lets you label your layers and keys to make the keymap easier to read.

## Inevitable caveats

Apparently the order in which Vial stores keys in `.vil` files does not necessarily match up
with how keys are defined in QMK, therefore the keys may appear out of order, depending on the keyboard.

For this I am giving you a couple checkboxes for common oddities and ability to move a key based on row-column.

Please accept my condolences in advance, but good news - you'll only need to do this once per keyboard.

## Using

For the web version, hopefully the use should be apparent enough,
and you can load an example configuration to see how to deal with keys being out of order.

The native version is invoked through command-line/terminal.

On Windows this is done as following:
```
.\VialToKeymapDrawer.exe <...options>
```

On Mac/Linux this is done as following (you'll need [Neko VM](https://nekovm.org/download/) installed):
```
neko ./VialToKeymapDrawer.n <...options>
```
For a full list of supported options, run without arguments or with `--help`;

Options might look like this, for instance (for a Sofle Choc):
```
--keyboard splitkb/aurora/sofle_v2/rev1 --half-after-half --mirror-right-half --move-defs yal-sofle/move-defs.txt --key-labels yal-sofle/key-labels.txt --layer-names yal-sofle/layer-names.txt --vil yal-sofle/yal-sofle.vil yal-sofle.yaml
```
Other keyboards may require less tinkering.

## Building

Web:
```text
haxe build-web.hxml
```
Native:
```text
haxe build-neko.hxml
nekotools boot bin/VialToKeymapDrawer.n
```

## License and credits

Tool by YellowAfterlife

Written in [Haxe](https://haxe.org).

Uses [FileSaver.js](https://github.com/eligrey/FileSaver.js/).

The displayed key names are based on parsing a file from
[Vial GUI](https://github.com/vial-kb/vial-gui),
so I guess this is now GPLv2, huh? Ah well
