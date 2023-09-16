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
	#if js
	public static inline var needsHxOrder:Bool = false;
	#else
	public static inline var needsHxOrder:Bool = true;
	#end
	static function procViaLayers(opt:VilToDrawerOpt) {
		var vLayers:Array<Array<VialKey>> = [];
		for (l => layer in opt.root.layers) {
			var keys = layer.copy();
			function checkPos(row:Int, col:Int, rule:String) {
				if (row != 0) {
					opt.warn('Row should be 0 is VIA layouts (found $row in "$rule")');
				}
				if (col < 0 || col >= keys.length) {
					opt.error('Column $col out of bounds for "$rule"');
					return true;
				}
				return false;
			}
			if (opt.rangeDefs.length > 0) {
				var nkeys = [];
				for (rdef in opt.rangeDefs) {
					if (checkPos(rdef.row, rdef.col, rdef.rule)) continue;
					nkeys = nkeys.concat(keys.slice(rdef.col, rdef.col + rdef.count));
				}
				keys = nkeys;
			}
			else for (def in opt.moveDefs) {
				if (checkPos(def.srcRow, def.srcCol, def.rule)) continue;
				var sub = keys.splice(def.srcCol, def.count);
				sub.reverse();
				for (key in sub) keys.insert(def.dstCol, key);
			}
			vLayers.push(keys);
		}
		return vLayers;
	}
	static function procVialLayers(opt:VilToDrawerOpt) {
		var vLayers:Array<Array<VialKey>> = [];
		for (i => layer in opt.root.layout) { // Vial
			var rows = layer.copy();
			for (i => row in rows) rows[i] = row.copy();
			function checkPos(row:Int, col:Int, rule:String) {
				if (row < 0 || row >= rows.length) {
					opt.error('Row $row out of bounds for "$rule"');
					return true;
				}
				if (col < 0 || col >= rows[row].length) {
					opt.error('Column $col out of bounds for "$rule"');
					return true;
				}
				return false;
			}
			//
			for (ko in opt.keyOverrides) if (ko.layer == i) {
				if (checkPos(ko.row, ko.col, ko.rule)) continue;
				rows[ko.row][ko.col] = ko.key;
			}
			//
			var keys = [];
			if (opt.rangeDefs.length > 0) for (rd in opt.rangeDefs) {
				if (checkPos(rd.row, rd.col, rd.rule)) continue;
				keys = keys.concat(rows[rd.row].slice(rd.col, rd.count));
			}
			else {
				//
				for (moveDef in opt.moveDefs) {
					if (checkPos(moveDef.srcRow, moveDef.srcCol, moveDef.rule)) continue;
					var sub = rows[moveDef.srcRow].splice(moveDef.srcCol, moveDef.count);
					sub.reverse();
					for (key in sub) rows[moveDef.dstRow].insert(moveDef.dstCol, key);
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
				for (row in newRows) for (key in row) keys.push(key);
			}
			vLayers.push(keys);
		}
		return vLayers;
	}
	static function postProcLayers(vLayers:Array<Array<VialKey>>, opt:VilToDrawerOpt) {
		var omitNonKeys = opt.omitNonKeys;
		if (omitNonKeys != 0) {
			var k = vLayers[0].length;
			while (--k >= 0) {
				if (vLayers[0][k] != "KC_NO") continue;
				var isNon = true;
				for (l2 in 1 ... vLayers.length) {
					if (omitNonKeys > 0 && l2 >= omitNonKeys) continue;
					if (vLayers[l2][k] == "KC_NO") continue;
					isNon = false;
					break;
				}
				if (isNon) for (vkeys in vLayers) vkeys.splice(k, 1);
			}
		}
		if (opt.omitM1) {
			var k = vLayers[0].length;
			while (--k >= 0) {
				if (!vLayers[0][k].isM1()) continue;
				var isM1 = true;
				for (l in 0 ... vLayers.length) {
					if (vLayers[l][k].isM1()) continue;
					isM1 = false;
					break;
				}
				if (!isM1) continue;
				for (l in 0 ... vLayers.length) {
					vLayers[l].splice(k, 1);
				}
			}
		}
	}
	public static function run(opt:VilToDrawerOpt):DrawerKeymap {
		var vkm = opt.root;
		//
		inline function getLayerName(li:Int) {
			return opt.getLayerName(li, true);
		}
		var isVial = !opt.isVIA;
		
		// layer -> keys[]
		var vLayers:Array<Array<VialKey>> = isVial ? procVialLayers(opt) : procViaLayers(opt);
		postProcLayers(vLayers, opt);
		
		//
		var dkLayers:DynamicAccess<DrawerLayer> = new DynamicAccess();
		var dkLayerList:Array<DrawerLayer> = [];
		var layerNames = [];
		for (li => vkeys in vLayers) {
			if (opt.includeLayers.length > 0 && !opt.includeLayers.contains(li)) continue;
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
			var ln = getLayerName(li);
			dkLayers[ln] = dkeys;
			dkLayerList.push(dkeys);
			layerNames.push(ln);
		}
		if (needsHxOrder) dkLayers["__hxOrder__"] = cast layerNames;
		//
		var extraStyle:Array<String> = [];
		if (opt.markNonKeysAs != null) {
			var found = false;
			var trns = VialKeyNames.map["KC_TRNS"];
			function isNon(dk:DrawerKey) {
				return dk == null || dk == trns;
			}
			for (k in 0 ... dkLayerList[0].length) {
				if (!isNon(dkLayerList[0][k])) continue;
				if (dkLayerList.filter(dkeys -> !isNon(dkeys[k])).length != 0) continue;
				for (dkeys in dkLayerList) {
					var dk = dkeys[k].toExt();
					dk.t = "";
					dk.type = opt.markNonKeysAs;
					dkeys[k] = dk;
					found = true;
				}
			}
			if (found) switch (opt.markNonKeysAs) {
				case "unused": extraStyle = extraStyle.concat([
					"rect.unused, rect.combo.unused {",
					"\t" + "fill: transparent;",
					"\t" + "stroke-dasharray: 4, 6;",
					"\t" + "stroke-width: 2;",
					"}",
				]);
				case "hidden": extraStyle = extraStyle.concat([
					"rect.hidden, rect.combo.hidden {",
					"\t" + "fill: transparent;",
					"\t" + "stroke-width: 0;",
					"}",
				]);
			}
		}
		//
		var dCombos:Array<DrawerCombo> = [];
		if (vkm.combo != null) for (vCombo in vkm.combo) {
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
		if (extraStyle.length > 0) {
			dkm.draw_config = {
				svg_extra_style: extraStyle.join("\n"),
			};
		}
		if (opt.qmkLayout != null && opt.qmkLayout != "") dkm.layout.qmk_layout = opt.qmkLayout;
		return dkm;
	}
	public static function runTxt(opt:VilToDrawerOpt) {
		var dkm = run(opt);
		if (needsHxOrder) {
			return tools.JsonPrinterWithOrder.print(dkm, null, "  ");
		}
		return Json.stringify(dkm, null, "  ");
	}
}
