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
typedef DrawerKey = EitherType<String, DrawerKeyExt>;
typedef DrawerLayer = EitherType<Array<DrawerKey>, Array<Array<DrawerKey>>>;
