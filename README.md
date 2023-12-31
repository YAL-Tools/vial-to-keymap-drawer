# Vial layout to Keymap Drawer converter

**Quick links:** [web version](https://yal-tools.github.io/vial-to-keymap-drawer/)
· [itch](https://yellowafterlife.itch.io/vial-to-keymap-drawer) (for donations and pre-built binaries)

Takes your Vial `.vil` layouts and converts them to YAML that you can pass to
[keymap-drawer](https://github.com/caksoylar/keymap-drawer)
to render your layout to SVG/PNG images that you can show to people instead
of taking screenshots of Vial configurator.

Also lets you label your layers/keys to make the keymap easier to read
and displays combos/tap dances.

![](example.svg)

## Inevitable caveats

Apparently the order in which Vial stores keys in `.vil` files does not necessarily match up
with how keys are defined in QMK, therefore the keys may appear out of order, depending on the keyboard.

And if your keyboard has optional keys (like a wide LShift vs narrow LShift + extra key), the way those are represented is not standardized either - they could be set to `-1`, or just left as blanks in the layout file.

For this I'm giving you a bunch of tools to deal with common and uncommon mishaps -
from simple (get rid of extra blank/`-1` keys, auto-fix key order in split Vial keyboards)
to advanced (specify key order in a [visual editor](./docs/examples/key-range-editor.mp4) or hand-write key locations to swap or pick).

This makes this tool slightly less entry-level, but good news - you'll only need to do this once per keyboard.  
Perhaps contribute an example `.vil` + `.json` if it's a particularly quirky one?

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

- Written in [Haxe](https://haxe.org).
- Uses [FileSaver.js](https://github.com/eligrey/FileSaver.js/).

Display data comes from the following:

- Vial key labels: [Vial GUI](https://github.com/vial-kb/vial-gui)
- VIA key labels: [VIA GUI](https://github.com/the-via/app)
- QMK keyboard list: [QMK Configurator](https://config.qmk.fm/)  
	By which I mean not the _source code_ of QMK configurator, but taken straight from the web page.

As result of sourcing data from software licensed under GPLv2, this tool is probably also GPLv2.
