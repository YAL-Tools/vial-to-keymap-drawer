package ;
import drawer.DrawerKeymap;
import haxe.DynamicAccess;
import haxe.Json;
import tools.ERegTools;
import vial.VialKeymap;
import vial.VialKey;
import VilToDrawer;
using StringTools;
using tools.ERegTools;

/**
 * ...
 * @author YellowAfterlife
 */
class VilToDrawerOpt {
	public var root:VialKeymap;
	public var isVIA:Bool;
	public var qmkKeyboard:String = null;
	public var qmkLayout:String = null;
	public var halfAfterHalf = false;
	public var mirrorRightHalf = false;
	public var omitNonKeys = 0;
	public var markNonKeysAs:String = null;
	public var omitM1 = false;
	public var includeLayers:Array<Int> = [];
	public var layerNames:Array<VilToDrawerLayerName> = [];
	public var moveDefs:Array<VilToDrawerMoveDef> = [];
	public var rangeDefs:Array<VilToDrawerRangeDef> = [];
	public var keyOverrides:Array<VilToDrawerKeyOverride> = [];
	public var showKeyPos = false;
	public var yamlLike = true;
	
	public var combos = true;
	public var outKeys:Array<VialKeyInfo> = null;
	
	public function new() {}
	
	public dynamic function log(level:String, v:Any) {
		trace('[$level]', v);
	}
	public dynamic function info(v:Any) {
		log("info", v);
	}
	public dynamic function warn(v:Any) {
		log("warn", v);
	}
	public dynamic function error(v:Any) {
		log("error", v);
	}
	
	public function getLayerName(i:Int, long:Bool) {
		if (i < layerNames.length) {
			var l = layerNames[i];
			return long ? l.long : l.short;
		} else return "L" + i;
	}
	
	public function parseVil(txt:String) {
		root = Json.parse(txt);
		isVIA = root.layers != null;
	}
	
	static var rxLayerShortLong = ~/^(\S{1,6})(?::.*|\s+\(.*\))$/;
	public function parseLayerNames(txt:String) {
		txt = txt.replace("\r", "").trim();
		if (txt == "") return;
		var rx = rxLayerShortLong;
		for (line in txt.split("\n")) {
			line = line.trim();
			if (rx.match(line)) {
				layerNames.push({
					short: rx.matched(1),
					long: rx.matched(0),
				});
			} else if (line.length <= 6) {
				layerNames.push({
					short: line,
					long: line,
				});
			} else {
				var lis = "L" + layerNames.length;
				layerNames.push({
					short: lis,
					long: lis + ": " + line,
				});
			}
		}
	}
	
	static var rxMoveDef = new EReg("^\\s*"
		+ "(\\d+),\\s*"
		+ "(\\d+)\\s*"
		+ "(?:"
			+ "\\[\\s*" + "(\\d+)" + "\\s*\\]\\s*" + "|" // row,col[n]
			+ "\\-\\s*" + "(\\d+)" + "\\s*" // row,col-col2
		+ ")?"
		+ "=>\\s*"
		+ "(\\d+),\\s*"
		+ "(\\d+)"
	+ "\\s*$", "gm");
	public function parseMoveDefs(txt:String) {
		ERegTools.each(rxMoveDef, txt, function(rx:EReg) {
			var srcCol = Std.parseInt(rx.matched(2));
			var ns = rx.matched(3);
			var n:Int;
			if (ns != null) {
				n = Std.parseInt(ns);
			} else if ((ns = rx.matched(4)) != null) {
				n = Std.parseInt(ns) + 1 - srcCol;
			} else n = 1;
			var at = 5;
			moveDefs.push({
				srcRow: Std.parseInt(rx.matched(1)),
				srcCol: srcCol,
				count: n,
				dstRow: Std.parseInt(rx.matched(at)),
				dstCol: Std.parseInt(rx.matched(at + 1)),
				rule: rx.matched(0),
			});
		});
	}
	
	static var rxRangeDef = new EReg("^\\s*"
		+ "(\\d+),\\s*"
		+ "(\\d+)\\s*"
		+ "(?:" + "\\-\\s*" + "(\\d+)" + "\\s*" + ")?"
	+ "$", "gm");
	public function parseRangeDefs(txt:String) {
		ERegTools.each(rxRangeDef, txt, function(rx:EReg) {
			var col = Std.parseInt(rx.matched(2));
			var tillStr = rx.matched(3);
			var count:Int;
			if (tillStr != null) {
				var till = Std.parseInt(rx.matched(3));
				count = till + 1 - col;
			} else count = 1;
			rangeDefs.push({
				row: Std.parseInt(rx.matched(1)),
				col: col,
				count: count,
				rule: rx.matched(0),
			});
		});
	}
	
	public function parseIncludeLayers(txt:String) {
		~/\d+/g.each(txt, function(rx:EReg) {
			var s = rx.matched(0);
			var i = Std.parseInt(s);
			if (i == null) {
				error('"$s" is not a valid layer number');
			} else includeLayers.push(i);
		});
	}
	
	static var rxKeyOverride = ~/^\s*(\d+),\s*(\d+),\s*(\d+)\s*=>\s*(.+)/gm;
	public function parseKeyOverrides(txt:String) {
		ERegTools.each(rxKeyOverride, txt, function(rx:EReg) {
			keyOverrides.push({
				layer: Std.parseInt(rx.matched(1)),
				row: Std.parseInt(rx.matched(2)),
				col: Std.parseInt(rx.matched(3)),
				key: rx.matched(4),
				rule: rx.matched(0),
			});
		});
	}
}
typedef VilToDrawerKeyOverride = {
	var layer:Int;
	var row:Int;
	var col:Int;
	var key:String;
	var rule:String;
}
typedef VilToDrawerLayerName = {
	var short:String;
	var long:String;
};
typedef VilToDrawerMoveDef = {
	var srcRow:Int;
	var srcCol:Int;
	var dstRow:Int;
	var dstCol:Int;
	var count:Int;
	var rule:String;
};
typedef VilToDrawerRangeDef = {
	var row:Int;
	var col:Int;
	var count:Int;
	var rule:String;
};