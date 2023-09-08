# Vial layout to Keymap Drawer converter

Takes your Vial `.vil` layouts and converts them to YAML that you can pass to
[keymap-drawer](https://github.com/caksoylar/keymap-drawer)
to render your layout to SVG/PNG images that you can show to people instead
of taking screenshots of Vial configurator.

## Inevitable caveats

Apparently the order in which Vial stores keys in `.vil` files does not necessarily match up
with how keys are defined in QMK, therefore the keys may appear out of order, depending on the keyboard.

For this I am giving you a couple checkboxes for common oddities and ability to move a key based on row-column.

Please accept my condolences in advance, but good news - you'll only need to do this once per keyboard.

## License and credits

Tool by YellowAfterlife

Written in [Haxe](https://haxe.org).

The displayed key names are based on parsing a file from
[Vial GUI](https://github.com/vial-kb/vial-gui),
so I guess this is now GPLv2, huh? Ah well
