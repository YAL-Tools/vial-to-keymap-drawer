package drawer;
import haxe.extern.EitherType;
import haxe.DynamicAccess;

/**
 * @author YellowAfterlife
 */
typedef DrawerKeymap = {
	var layout:DrawerKeymapLayout;
	var layers:DynamicAccess<DrawerLayer>;
	var?combos:Array<DrawerCombo>;
	var?draw_config:DrawerConfig;
}
typedef DrawerKeymapLayout = {
	var qmk_keyboard:String;
	var?qmk_layout:String;
};
typedef DrawerConfig = {
	var svg_extra_style:String;
}
typedef DrawerCombo = {
	var p:Array<Int>;
	var k:DrawerKey;
	var l:Array<String>;
};
typedef DrawerKeyExt = {
	var?t:String;
	var?h:String;
	var?s:String;
	var?type:String;
};
typedef DrawerKeyFlat = String;
abstract DrawerKey(Dynamic)
	from DrawerKeyFlat from DrawerKeyExt
	to DrawerKeyFlat to DrawerKeyExt
{
	public function isFlat():Bool {
		return this == null || (this is String);
	}
	public function toExt():DrawerKeyExt {
		if (this == null) return { t: "" };
		return isFlat() ? { t: this } : this;
	}
	public function toFlat(a:DrawerKeyAction):DrawerKeyFlat {
		if (isFlat()) return this;
		return Reflect.field(this, a);
	}
}
enum abstract DrawerKeyAction(String) to String {
	var Tap = "t";
	var Hold = "h";
	var Shift = "s";
}
typedef DrawerLayer = Array<DrawerKey>;
