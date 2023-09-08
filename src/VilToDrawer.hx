package ;
import drawer.DrawerKeymap;
import haxe.DynamicAccess;
import haxe.Json;
import tools.ERegTools;
import vial.VialKeyNames;
import vial.VialKeymap;
import vial.VialKey;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class VilToDrawer {
	public static function run(opt:VilToDrawerOpt):DrawerKeymap {
		var vkm = opt.vil;
		var dkLayers:DynamicAccess<DrawerLayer> = new DynamicAccess();
		//
		inline function getLayerName(li:Int) {
			return opt.getLayerName(li, true);
		}
		
		// flatten layers and fix key positions:
		var vLayers:Array<Array<VialKey>> = [];
		for (i => layer in vkm.layout) {
			var rows = layer.copy();
			for (i => row in rows) rows[i] = row.copy();
			//
			for (def in opt.moveDefs) {
				var key = rows[def.srcRow].splice(def.srcCol, 1)[0];
				rows[def.dstRow].insert(def.dstCol, key);
			}
			//
			var rowCount = layer.length;
			var halfRowCount = rowCount >> 1;
			var newRows = [for (_ in 0 ... rowCount) null];
			for (rk => row in rows) {
				var dk = rk;
				if (opt.halfAfterHalf) {
					if (dk >= halfRowCount) {
						dk = (dk - halfRowCount) * 2 + 1;
						if (opt.mirrorRightHalf) row.reverse();
					} else {
						dk *= 2;
					}
				}
				newRows[dk] = row;
			}
			//
			var keys = [];
			for (row in newRows) for (key in row) keys.push(key);
			vLayers.push(keys);
		}
		//
		for (li => vkeys in vLayers) {
			var dkeys = [];
			for (k => kc in vkeys) {
				var dk = kc.toDrawerKey(opt);
				// is this a held key?
				var mo = "MO(" + li + ")";
				var lts = "LT" + li + "(";
				var held = false;
				for (vkeys2 in vLayers) {
					if (vkeys == vkeys2) continue;
					var kc2 = vkeys2[k];
					if (kc2 == null) continue;
					if (kc2 == mo || (kc2:String).startsWith(lts)) {
						held = true;
						break;
					}
				}
				if (held) {
					var dkx:DrawerKeyExt;
					if (dk is String) {
						dkx = { t: dk };
					} else dkx = dk;
					dkx.type = "held";
					if (dkx.t == VialKeyNames.map["KC_TRNS"]) dkx.t = "";
					dk = dkx;
				}
				dkeys.push(dk);
			}
			dkLayers[getLayerName(li)] = dkeys;
		}
		//
		var dCombos:Array<DrawerCombo> = [];
		for (vCombo in vkm.combo) {
			var iResult = vCombo.length - 1;
			var inKeys = [];
			for (i in 0 ... iResult) if (vCombo[i].isValid()) inKeys.push(vCombo[i]);
			if (inKeys.length < 2) continue;
			var cResult = vCombo[iResult];
			if (!cResult.isValid()) continue;
			
			for (li => vKeys in vLayers) {
				var keyPos = [];
				for (key in inKeys) {
					var kp = vKeys.indexOf(key);
					if (kp >= 0) keyPos.push(kp); else break;
				}
				if (keyPos.length < inKeys.length) continue;
				dCombos.push({
					p: keyPos,
					k: cResult.toDrawerKey(opt),
					l: [getLayerName(li)],
				});
			}
		}
		//
		var dkm:DrawerKeymap = {
			layout: {
				qmk_keyboard: opt.qmkKeyboard
			},
			layers: dkLayers,
			combos: dCombos,
		};
		if (opt.qmkLayout != null && opt.qmkLayout != "") dkm.layout.qmk_layout = opt.qmkLayout;
		return dkm;
	}
	public static function runTxt(opt:VilToDrawerOpt) {
		var dkm = run(opt);
		return Json.stringify(dkm, null, "  ");
	}
}
