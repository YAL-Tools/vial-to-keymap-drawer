package vial;

/**
 * Maps keys that are labelled like
 * "!\n1" (shift output goes first)
 * @author YellowAfterlife
 */
class VialKeysWithShiftState {
	public static var list:Array<String> = [
		// digits (of course)
		"KC_1",
		"KC_2",
		"KC_3",
		"KC_4",
		"KC_5",
		"KC_6",
		"KC_7",
		"KC_8",
		"KC_9",
		"KC_0",
		// common symbols:
		"KC_MINUS",
		"KC_EQUAL",
		"KC_LBRACKET",
		"KC_RBRACKET",
		"KC_BSLASH",
		"KC_SCOLON",
		"KC_QUOTE",
		"KC_GRAVE",
		"KC_COMMA",
		"KC_DOT",
		"KC_SLASH",
		// international:
		"KC_NONUS_HASH",
		"KC_NONUS_BSLASH",
		"KC_RO",
		"KC_KANA",
		"KC_JYEN",
		"KC_HENK",
		"KC_MHEN",
		"KC_LANG1",
		"KC_LANG2",
		// anything else..?
	];
	public static var map:Map<String, Bool> = (function() {
		var m = new Map();
		for (key in list) m[key] = true;
		return m;
	})();
}