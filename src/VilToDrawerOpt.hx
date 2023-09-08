package ;
import drawer.DrawerKeymap;
import haxe.DynamicAccess;
import haxe.Json;
import tools.ERegTools;
import vial.VialKeymap;
import vial.VialKey;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class VilToDrawerOpt {
	public var vil:VialKeymap;
	public var qmkKeyboard:String = null;
	public var qmkLayout:String = null;
	public var halfAfterHalf = false;
	public var mirrorRightHalf = false;
	public var layerNames:Array<VilToDrawerLayerName> = [];
	public var moveDefs:Array<VilToDrawerMoveDef> = [];
	public var keyOverrides:Array<VilToDrawerKeyOverride> = [];
	public function new() {}
	
	public function getLayerName(i:Int, long:Bool) {
		if (i < layerNames.length) {
			var l = layerNames[i];
			return long ? l.long : l.short;
		} else return "L" + i;
	}
	
	public function parseVil(txt:String) {
		vil = Json.parse(txt);
	}
	
	static var rxLayerShortLong = ~/^(\S{1,6})(?::.*|\s+\(.*\))$/;
	public function parseLayerNames(txt:String) {
		txt = txt.replace("\r", "").trim();
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
	
	static var rxMoveDef = ~/^\s*(\d+),\s*(\d+)\s*=>\s*(\d+),\s*(\d+)/gm;
	public function parseMoveDefs(txt:String) {
		ERegTools.each(rxMoveDef, txt, function(rx:EReg) {
			moveDefs.push({
				srcRow: Std.parseInt(rx.matched(1)),
				srcCol: Std.parseInt(rx.matched(2)),
				dstRow: Std.parseInt(rx.matched(3)),
				dstCol: Std.parseInt(rx.matched(4)),
			});
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
			});
		});
	}
}
typedef VilToDrawerKeyOverride = {
	layer:Int,
	row:Int,
	col:Int,
	key:String,
}
typedef VilToDrawerLayerName = {
	short:String,
	long:String,
};
typedef VilToDrawerMoveDef = {
	var srcRow:Int;
	var srcCol:Int;
	var dstRow:Int;
	var dstCol:Int;
};