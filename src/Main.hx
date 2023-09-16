package;

import haxe.DynamicAccess;
import haxe.Http;
import haxe.Json;
import js.Browser;
import js.Lib;
import js.html.Blob;
import js.html.DataListElement;
import js.html.Element;
import js.html.Event;
import js.html.FileReader;
import js.html.FormElement;
import js.html.InputElement;
import js.html.SelectElement;
import js.html.TextAreaElement;
import drawer.DrawerKeymap;
import tools.ERegTools;
import tools.JsonParserWithComments;
import vial.VialKeymap;
import VilToDrawer;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class Main {
	public static inline var buildDate:String = tools.BuildDate.asString();
	static inline function find<T:Element>(id:String, ?c:Class<T>):T {
		return cast Browser.document.getElementById(id);
	}
	static var fdVil:TextAreaElement = find("vil");
	static var fdOut:TextAreaElement = find("out");
	static var fdLog:TextAreaElement = find("log");
	
	static var fmVil:FormElement = find("vil-form");
	static var ffVil:InputElement = find("vil-picker");
	
	static var cbHalfAfterHalf:InputElement = find("half-after-half");
	static var cbMirrorRightHalf:InputElement = find("mirror-right-half");
	static var cbDebugKeyPos:InputElement = find("show-key-pos");
	static var ddOmitNonKeys:SelectElement = find("omit-non-keys");
	static var ddMarkNonKeysAs:SelectElement = find("mark-non-keys");
	static var cbOmitM1:InputElement = find("omit-m1");
	static var fdKeyboard:InputElement = find("keyboard");
	static var fdLayout:InputElement = find("layout");
	static var fdMoveDefs:TextAreaElement = find("move-defs");
	static var fdKeyRanges:TextAreaElement = find("key-ranges");
	
	static var fdLayerNames:TextAreaElement = find("layer-names");
	static var fdIncludeLayers:InputElement = find("include-layers");
	static var fdKeyOverrides:TextAreaElement = find("key-overrides");
	
	static var btConvert:InputElement = find("convert");
	static var cbCopyAfterConvert:InputElement = find("copy-after-convert");
	
	static var ddSample:SelectElement = find("sample");
	static var btLoad:InputElement = find("load-settings");
	static var btSave:InputElement = find("save-settings");
	static var btClear:InputElement = find("clear");
	
	static var fmLoad:FormElement = find("load-form");
	static var ffLoad:InputElement = find("load-picker");
	
	static var fields:Array<PageField> = [];
	
	static function convert() {
		var opt = new VilToDrawerOpt();
		fdLog.value = "";
		opt.log = (level:String, v:Any) -> {
			fdLog.value += (fdLog.value.length > 0 ? "\n" : "")
				+ '[$level] ' + v;
		};
		
		opt.qmkKeyboard = fdKeyboard.value.trim();
		opt.qmkLayout = fdLayout.value.trim();
		opt.parseVil(fdVil.value);
		
		opt.halfAfterHalf = cbHalfAfterHalf.checked;
		opt.mirrorRightHalf = cbMirrorRightHalf.checked;
		opt.omitNonKeys = Std.parseInt(ddOmitNonKeys.value);
		opt.omitM1 = cbOmitM1.checked;
		opt.parseMoveDefs(fdMoveDefs.value);
		opt.parseRangeDefs(fdKeyRanges.value);
		opt.showKeyPos = cbDebugKeyPos.checked;
		
		opt.parseLayerNames(fdLayerNames.value);
		opt.parseIncludeLayers(fdIncludeLayers.value);
		opt.parseKeyOverrides(fdKeyOverrides.value);
		opt.markNonKeysAs = ddMarkNonKeysAs.value;
		if (opt.markNonKeysAs == "") opt.markNonKeysAs = null;
		
		try {
			fdOut.value = VilToDrawer.runTxt(opt);
			opt.info("Done!");
		} catch (x:Dynamic) {
			Browser.console.error("Conversion error:", x);
			opt.error(x);
		}
	}
	static function clear() {
		for (fd in fields) fd.reset();
	}
	static function applySettings(root:WebSettings) {
		clear();
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
	static function loadSample(name:String = "yal-sofle") {
		var sfx = "?t=" + buildDate;
		var rs = new Http('examples/$name.json' + sfx);
		rs.onData = function(s) {
			applySettings(Json.parse(s));
			var rv = new Http('examples/$name.vil' + sfx);
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
		
		for (node in Browser.document.querySelectorAll([
			"main input[id]",
			"main textarea[id]",
			"main select[id]",
		].join(", "))) {
			var el:Element = cast node;
			if (el.classList.contains("transient")) continue;
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
			}
			else if (el.tagName == "SELECT") {
				var es:SelectElement = cast el;
				fields.push({
					id: el.id,
					get: function() return es.value,
					set: function(val) es.value = val,
					reset: function() es.selectedIndex = 0,
				});
			}
			else {
				var et:TextAreaElement = cast el;
				fields.push({
					id: el.id,
					get: function() {
						if (et.value.trim() == "") return [];
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
					applySettings(JsonParserWithComments.parse(fileReader.result));
				} catch (x:Dynamic) {
					Browser.alert("Error loading settings: " + x);
				}
			}
			fileReader.readAsText(file);
		}
		
		btConvert.onclick = function() {
			convert();
			if (cbCopyAfterConvert.checked) Browser.navigator.clipboard.writeText(fdOut.value);
		}
		btSave.onclick = function() saveSettings();
		btLoad.onclick = function() ffLoad.click();
		ddSample.onchange = function() {
			var name = ddSample.value;
			if (name == "") return;
			if (!Browser.window.confirm(
				"Are you sure that you want to replace your settings with the example? This cannot be undone!"
			)) {
				ddSample.selectedIndex = 0;
				return;
			}
			ddSample.selectedIndex = 0;
			loadSample(name);
		}
		
		var kbjs = Browser.document.createScriptElement();
		kbjs.onload = function() {
			var list:DataListElement = find("qmk_keyboard");
			for (kb in ((cast Browser.window).qmk_keyboards:Array<String>)) {
				var opt = Browser.document.createOptionElement();
				opt.value = kb;
				list.appendChild(opt);
			}
		};
		kbjs.async = true;
		kbjs.src = "qmk_keyboards.js";
		Browser.document.body.appendChild(kbjs);
		
		//if (local) loadSample("yal-cepstrum");
		Browser.console.info("Hello!");
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