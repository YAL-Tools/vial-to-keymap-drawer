neko VialToKeymapDrawer.n --keyboard sofle_rotated --half-after-half --mirror-right-half --move-defs yal-sofle/move-defs.txt --key-labels yal-sofle/key-labels.txt --layer-names yal-sofle/layer-names.txt --encoder-defs yal-sofle/encoder-defs.txt --vil yal-sofle/yal-sofle.vil --layer %1 yal-sofle-%1.yaml
keymap draw yal-sofle-%1.yaml>yal-sofle-%1.svg
cmd /C inkscape yal-sofle-%1.svg --export-filename="yal-sofle-%1.png"
cmd /C magick yal-sofle-%1.png -background #889EC5 -flatten yal-sofle-%1-blue.png
