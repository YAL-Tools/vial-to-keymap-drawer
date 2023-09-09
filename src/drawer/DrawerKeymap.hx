package drawer;
import haxe.extern.EitherType;
import haxe.DynamicAccess;

/**
 * @author YellowAfterlife
 */
typedef DrawerKeymap = {
	var layout:{
		var qmk_keyboard:String;
		var?qmk_layout:String;
	};
	var layers:DynamicAccess<DrawerLayer>;
	var?combos:Array<DrawerCombo>;
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
	public inline function isFlat():Bool {
		return (this is String);
	}
	public function toExt():DrawerKeyExt {
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
typedef DrawerLayer = EitherType<Array<DrawerKey>, Array<Array<DrawerKey>>>;
