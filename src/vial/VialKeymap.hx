package vial;
import haxe.extern.EitherType;
import drawer.DrawerKeymap;
using StringTools;

/**
 * @author YellowAfterlife
 */
typedef VialKeymap = {
	var version:Int;
	var uid:Int;
	var layout:Array<Array<Array<VialKey>>>;
	var encoder_layout:Array<Array<Array<String>>>;
	var layout_options:Int;
	var vial_protocol:Int;
	var via_protocol:Int;
	var tap_dance:Array<VialKeymapTapDance>;
	var combo:Array<Array<VialKey>>;
	var key_override:Array<Any>;
	var settings:Any;
};
abstract VialKeymapTapDance(Array<Any>) {
	public var tap(get, set):VialKey;
	inline function get_tap()  return this[0];
	inline function set_tap(k) return this[0] = k;
	
	public var hold(get, set):VialKey;
	inline function get_hold()  return this[1];
	inline function set_hold(k) return this[1] = k;
	
	public var doubleTap(get, set):VialKey;
	inline function get_doubleTap()  return this[2];
	inline function set_doubleTap(k) return this[2] = k;
	
	public var tapHold(get, set):VialKey;
	inline function get_tapHold()  return this[3];
	inline function set_tapHold(k) return this[3] = k;
	
	public var tapTerm(get, set):Float;
	inline function get_tapTerm()  return this[4];
	inline function set_tapTerm(t) return this[4] = t;
}