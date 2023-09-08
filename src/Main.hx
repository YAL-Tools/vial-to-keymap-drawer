package;

import haxe.DynamicAccess;
import haxe.Http;
import haxe.Json;
import js.Browser;
import js.Lib;
import js.html.Blob;
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
	static var fdKeyOverrides:TextAreaElement = find("key-overrides");
	static var btConvert:InputElement = find("convert");
	
	static var btSample:InputElement = find("sample");
	static var btLoad:InputElement = find("load-settings");
	static var btSave:InputElement = find("save-settings");
	static var btClear:InputElement = find("clear");
	
	static var fmLoad:FormElement = find("load-form");
	static var ffLoad:InputElement = find("load-picker");
	
	static var fields:Array<PageField> = [];
	
	static function convert() {
		var opt = new VilToDrawerOpt();
		opt.qmkKeyboard = fdKeyboard.value.trim();
		opt.qmkLayout = fdLayout.value.trim();
		opt.parseVil(fdVil.value);
		opt.halfAfterHalf = cbHalfAfterHalf.checked;
		opt.mirrorRightHalf = cbMirrorRightHalf.checked;
		opt.parseLayerNames(fdLayerNames.value);
		opt.parseMoveDefs(fdMoveDefs.value);
		opt.parseKeyOverrides(fdKeyOverrides.value);
		fdOut.value = VilToDrawer.runTxt(opt);
	}
	static function clear() {
		for (fd in fields) fd.reset();
	}
	static function applySettings(root:WebSettings) {
		for (id => val in root.fields) {
			var fd = fields.filter(f -> f.id == id)[0];
			if (fd == null) continue;
			fd.set(val);
		}
	}
	static function saveSettings() {
		var root:WebSettings = {
			resourceType: "https://yal-tools.github.io/vial-to-keymap-drawer/",
			fields: {},
		};
		for (fd in fields) {
			root.fields[fd.id] = fd.get();
		}
		var blob = new Blob([Json.stringify(root, null, "\t")]);
		(cast Browser.window).saveAs(blob, "settings.json", "application/json");
	}
	static function loadSample() {
		var rs = new Http("yal-sofle.json");
		rs.onData = function(s) {
			applySettings(Json.parse(s));
			var rv = new Http("yal-sofle.vil");
			rv.onData = function(s) {
				fdVil.value = s;
				convert();
			}
			rv.request();
		};
		rs.request();
	}
	static function main() {
		var local = Browser.document.location.hostname == "localhost";
		
		for (node in Browser.document.querySelectorAll("main input[id], main textarea[id]")) {
			var el:Element = cast node;
			if (el == fdOut || el == fdVil) continue;
			if (el.tagName == "INPUT") {
				var ei:InputElement = cast el;
				switch (ei.type) {
					case "text": fields.push({
						id: el.id,
						get: function() return ei.value,
						set: function(val) ei.value = val,
						reset: function() ei.value = "",
					});
					case "checkbox": fields.push({
						id: el.id,
						get: function() return ei.checked,
						set: function(val) ei.checked = val,
						reset: function() ei.checked = false,
					});
				}
			} else {
				var et:TextAreaElement = cast el;
				fields.push({
					id: el.id,
					get: function() {
						return et.value.split("\n");
					},
					set: function(val) {
						if (val is Array) {
							et.value = (val:Array<String>).join("\n");
						} else et.value = val;
					},
					reset: function() et.value = "",
				});
			}
		}
		
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
		
		btClear.onclick = function() {
			if (!Browser.window.confirm(
				"Are you sure that you want to clear settings? This cannot be undone!"
			)) return;
			clear();
		}
		
		ffLoad.onchange = function() {
			var file = ffLoad.files[0];
			if (file == null) return;
			
			var fileReader = new FileReader();
			fileReader.onloadend = function() fmLoad.reset();
			fileReader.onload = function() {
				try {
					applySettings(Json.parse(fileReader.result));
				} catch (x:Dynamic) {
					Browser.alert("Error loading settings: " + x);
				}
			}
			fileReader.readAsText(file);
		}
		
		btConvert.onclick = function() convert();
		btSave.onclick = function() saveSettings();
		btLoad.onclick = function() ffLoad.click();
		btSample.onclick = function() {
			if (!Browser.window.confirm(
				"Are you sure that you want to replace your settings with the example? This cannot be undone!"
			)) return;
			loadSample();
		}
		if (local) loadSample();
	}
	
}
typedef PageField = {
	id: String,
	reset: Void->Void,
	get: Void->Any,
	set: Any->Void,
}
typedef WebSettings = {
	resourceType:String,
	fields:DynamicAccess<Any>,
}