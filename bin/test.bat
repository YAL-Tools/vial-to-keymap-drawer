cd bin
neko VialToKeymapDrawer.n --keyboard sofle_rotated --half-after-half --mirror-right-half --move-defs yal-sofle/move-defs.txt --key-labels yal-sofle/key-labels.txt --layer-names yal-sofle/layer-names.txt --vil yal-sofle/yal-sofle.vil --layer 0 yal-sofle.yaml
keymap draw yal-sofle.yaml>yal-sofle.svg
pause