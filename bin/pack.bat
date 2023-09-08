@echo off
del /Q VialToKeymapDrawer-Windows.zip
cmd /C nekotools boot VialToKeymapDrawer.n
cmd /C 7z a VialToKeymapDrawer-Windows.zip VialToKeymapDrawer.exe *.dll *.ndll ..\README.md yal-sofle VialToKeymapDrawer-example.bat

del /Q VialToKeymapDrawer-Unix.zip
cmd /C 7z a VialToKeymapDrawer-Unix.zip VialToKeymapDrawer.n VialToKeymapDrawer-example.sh yal-sofle ..\README.md

set /p ver="Version?: "
echo Uploading %ver%...

cmd /C itchio-butler push VialToKeymapDrawer-Windows.zip yellowafterlife/vial-to-keymap-drawer:windows --userversion=%ver%
cmd /C itchio-butler push VialToKeymapDrawer-Unix.zip yellowafterlife/vial-to-keymap-drawer:unix --userversion=%ver%
pause