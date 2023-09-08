package;

import haxe.DynamicAccess;
import haxe.Json;
import js.Browser;
import js.Lib;
import js.html.Element;
import js.html.Event;
import js.html.FileReader;
import js.html.FormElement;
import js.html.InputElement;
import js.html.TextAreaElement;
import drawer.DrawerKeymap;
import tools.ERegTools;
import vial.VialKeymap;
import VilToDrawer;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class Main {
	static inline function find<T:Element>(id:String, ?c:Class<T>):T {
		return cast Browser.document.getElementById(id);
	}
	static var fdVil:TextAreaElement = find("vil");
	static var fdOut:TextAreaElement = find("out");
	
	static var fmVil:FormElement = find("vil-form");
	static var ffVil:InputElement = find("vil-picker");
	
	static var cbHalfAfterHalf:InputElement = find("half-after-half");
	static var cbMirrorRightHalf:InputElement = find("mirror-right-half");
	static var fdKeyboard:InputElement = find("keyboard");
	static var fdLayout:InputElement = find("layout");
	static var fdMoveDefs:TextAreaElement = find("move-defs");
	static var fdLayerNames:TextAreaElement = find("layer-names");
	static var btConvert:InputElement = find("convert");
	
	static function convert() {
		var opt = new VilToDrawerOpt();
		opt.qmkKeyboard = fdKeyboard.value.trim();
		opt.qmkLayout = fdLayout.value.trim();
		opt.parseVil(fdVil.value);
		opt.halfAfterHalf = cbHalfAfterHalf.checked;
		opt.mirrorRightHalf = cbMirrorRightHalf.checked;
		opt.parseLayerNames(fdLayerNames.value);
		opt.parseMoveDefs(fdMoveDefs.value);
		fdOut.value = VilToDrawer.runTxt(opt);
	}
	static function main() {
		ffVil.onchange = function(e:Event) {
			var file = ffVil.files[0];
			if (file == null) return;
			
			var fileReader = new FileReader();
			fileReader.onloadend = function() fmVil.reset();
			fileReader.onload = function() {
				fdVil.value = fileReader.result;
			}
			fileReader.readAsText(file);
		}
		
		btConvert.onclick = function() convert();
		convert();
	}
	
}