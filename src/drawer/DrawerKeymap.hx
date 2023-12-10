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
	function postproc_1(s:String, opt:VilToDrawerOpt) {
		if (s == null) return null;
		var lqs = s.toLowerCase();
		return opt.keyNames.exists(lqs) ? opt.keyNames[lqs] : s;
	}
	public function postproc(opt:VilToDrawerOpt):DrawerKey {
		if (isFlat()) return postproc_1(this, opt);
		var ext:DrawerKeyExt = this;
		if (ext.s != null && StringTools.endsWith(ext.s, "+")) {
			var lqs = (ext.s + ext.t).toLowerCase();
			if (opt.keyNames.exists(lqs)) {
				ext.t = opt.keyNames[lqs];
				ext.s = "";
				return ext;
			}
		}
		if (ext.t != null) ext.t = postproc_1(ext.t, opt);
		if (ext.h != null) ext.h = postproc_1(ext.h, opt);
		if (ext.s != null) ext.s = postproc_1(ext.s, opt);
		return ext;
	}
}
enum abstract DrawerKeyAction(String) to String {
	var Tap = "t";
	var Hold = "h";
	var Shift = "s";
}
typedef DrawerLayer = Array<DrawerKey>;
