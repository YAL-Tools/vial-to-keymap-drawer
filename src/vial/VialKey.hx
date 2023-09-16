package vial;
import haxe.Json;
import tools.JsonParserWithComments;
import via.ViaKeyNames;
import vial.VialKeyNames;
import drawer.DrawerKeymap;
import vial.VialKeysWithShiftState;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
abstract VialKey(String) from String to String {
	public function toDrawerKey(opt:VilToDrawerOpt, oneLine:Bool = false):DrawerKey {
		var kc:String = this;
		if (kc == null || kc == "" || kc == "KC_NO") return null;
		
		// `LSft_T(kc)` and alike
		static var rx_modTap = new EReg("^"
			+ "(\\w+)_T"
			+ "\\(" + "(.+)" + "\\)",
		"");
		if (rx_modTap.match(kc)) {
			var key = rx_modTap.matched(1);
			var t:VialKey = rx_modTap.matched(2);
			var dk = t.toDrawerKey(opt).toExt();
			dk.h = key;
			return dk;
		}
		
		// show "MO <layer tag>" if appropriate
		static var rx_layer = new EReg("^(MO|DF|TG|TT|OSL|TO)" + "\\(" + "(\\d+)" + "\\)$", "");
		if (rx_layer.match(kc)) {
			var li = Std.parseInt(rx_layer.matched(2));
			return rx_layer.matched(1) + " " + opt.getLayerName(li, false);
		}
		
		// `TD(x)`
		static var rx_td = new EReg("^TD" + "\\(" + "(\\d+)" + "\\)$", "");
		if (rx_td.match(kc)) {
			var ti = Std.parseInt(rx_td.matched(1));
			var td = opt.root.tap_dance[ti];
			if (td != null) {
				return {
					s: kc,
					t: td.tap.toDrawerKey(opt, true).toFlat(Tap),
					h: td.hold.toDrawerKey(opt, true).toFlat(Tap),
				};
			}
		}
		
		// `LT2(kc)` -> { t: kc, h: MO(2) }
		static var rx_lt = new EReg("^"
			+ "(?:"
				+ "LT(\\d)\\(" + "|"
				+ "LT\\((\\d+),\\s*"
			+ ")" + "(.+)" + "\\)"
		+ "$", "");
		if (rx_lt.match(kc)) {
			var t:VialKey = rx_lt.matched(3);
			var lts = rx_lt.matched(1) ?? rx_lt.matched(2);
			var h:VialKey = "MO(" + lts + ")";
			var dk = t.toDrawerKey(opt).toExt();
			dk.h = h.toDrawerKey(opt).toFlat(Tap);
			return dk;
		}
		
		// `LSFT(kc)` (special handling - replaces tap-state by shift-state)
		static var rx_shift = new EReg("^([LR]SFT)" + "\\(" + "(.+)" + "\\)$", "");
		if (rx_shift.match(kc)) {
			var shift = rx_shift.matched(1) + "+";
			var key:VialKey = rx_shift.matched(2);
			var dk = key.toDrawerKey(opt).toExt();
			if (dk.s != null) {
				dk.t = dk.s;
			}
			dk.s = shift;
			return dk;
		}
		
		// other `MOD(kc)` keys
		static var rx_pair = new EReg("^(\\w+)" + "\\(" + "(.+)" + "\\)$", "");
		if (rx_pair.match(kc)) {
			var f:String = rx_pair.matched(1);
			switch (f) {
				case "C": f = "Ctrl";
				case "S": f = "Shift";
				case "A": f = "Alt";
				case "G": f = "Gui";
			}
			var k:VialKey = rx_pair.matched(2);
			var dk = k.toDrawerKey(opt).toExt();
			if (dk.s != null) {
				dk.t = dk.s + "\n" + dk.t;
			}
			dk.s = f + "+";
			return dk;
		}
		
		// {"t":"A", "s":"B"} or "key"
		static var rx_json = new EReg("^(?:" + [
			"\\{" + ".+" + "\\}",
			"\""  + ".+" + "\"",
		].join("|") + ")\\s*$", "");
		if (rx_json.match(kc)) {
			try {
				return JsonParserWithComments.parse(kc);
			} catch (x:Dynamic) {
				trace('Error parsing JSON "$kc":', x);
				return kc;
			}
		}
		
		var fullName = opt.isVIA ? ViaKeyNames.map[kc] : VialKeyNames.map[kc];
		if (fullName != null) {
			if (oneLine) {
				return fullName.replace("\n", "  ");
			}
			if (VialKeysWithShiftState.map.exists(kc)) {
				var parts = fullName.split("\n");
				if (parts.length > 1) {
					return { s: parts[0], t: parts[1] };
				}
			}
			return fullName;
		}
		
		if (kc.startsWith("KC_")) return kc.substr(3);
		return kc;
	}
	
	public function isValid() {
		if (this is Float && (cast this:Float) == -1) return false;
		return switch (this) {
			case null, "", "KC_NO": false;
			default: true;
		}
	}
	public function isM1() {
		return (this is Float) && (cast this:Float) == -1;
	}
}
