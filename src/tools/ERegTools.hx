package tools;

/**
 * ...
 * @author YellowAfterlife
 */
class ERegTools {
	private static var escapeRx_1:EReg = new EReg("([.*+?^${}()|[\\]\\/\\\\])", 'g');
	public static function escapeRx(s:String):String {
		return escapeRx_1.replace(s, "\\$1");
	}
	
	public static function each(r:EReg, s:String, f:EReg->Void) {
		var i:Int = 0;
		while (r.matchSub(s, i)) {
			var p = r.matchedPos();
			//if (p.pos < i) break; // bug on --run..?
			//trace(p, i);
			f(r);
			i = p.pos + p.len;
		}
	}
}
