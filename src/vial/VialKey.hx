package vial;
import vial.VialKeyNames;
import drawer.DrawerKeymap;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
abstract VialKey(String) from String to String {
	static var rx_modTap = new EReg("^"
		+ "(\\w+)_T"
		+ "\\(" + "(.+)" + "\\)",
	"");
	static var rx_lt = new EReg("^LT(\\d)" + "\\(" + "(.+)" + "\\)$", "");
	static var rx_layer = new EReg("^(MO|DF|TG|TT|OSL|TO)" + "\\(" + "(\\d+)" + "\\)$", "");
	static var rx_pair = new EReg("^(\\w+)" + "\\(" + "(.+)" + "\\)$", "");
	public function toDrawerKey(opt:VilToDrawerOpt):DrawerKey {
		var kc:String = this;
		if (kc == null || kc == "" || kc == "KC_NO") return null;
		if (rx_modTap.match(kc)) {
			var key = rx_modTap.matched(1);
			var t:VialKey = rx_modTap.matched(2);
			return {
				t: t.toDrawerKey(opt),
				h: key,
			}
		}
		
		if (rx_layer.match(kc)) {
			var li = Std.parseInt(rx_layer.matched(2));
			return rx_layer.matched(1) + " " + opt.getLayerName(li, false);
		}
		
		if (rx_lt.match(kc)) {
			var h:VialKey = "MO(" + rx_lt.matched(1) + ")";
			var t:VialKey = rx_lt.matched(2);
			return {
				t: t.toDrawerKey(opt),
				h: h.toDrawerKey(opt),
			}
		}
		
		if (rx_pair.match(kc)) {
			var f:VialKey = rx_pair.matched(1);
			var k:VialKey = rx_pair.matched(2);
			return {
				t: k.toDrawerKey(opt),
				s: f.toDrawerKey(opt),
			};
		}
		
		var fullName = VialKeyNames.map[kc];
		if (fullName != null) return fullName;
		
		if (kc.startsWith("KC_")) return kc.substr(3);
		return kc;
	}
	
	public function isValid() {
		return switch (this) {
			case null, "", "KC_NO": false;
			default: true;
		}
	}
}
