package ;
import vial.VialKeyNames;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class KcToKeyName {
	public static var map:Map<String, String> = [
		"KC_TRNS" => "▽",
		"KC_NO" => "",
	];
	public static function get(kc:String) {
		var s = map[kc];
		if (s != null) return s;
		s = VialKeyNames.map[kc];
		if (s != null) return s;
		if (kc.startsWith("KC_")) return kc.substr(3);
		return kc;
	}
}