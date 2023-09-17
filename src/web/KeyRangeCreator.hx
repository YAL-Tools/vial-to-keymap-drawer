package web;
import Main.find;
import js.Browser;
import js.html.DivElement;
import js.html.Element;
import js.html.FileReader;
import js.html.FormElement;
import js.html.InputElement;
import js.html.MouseEvent;
import js.html.TextAreaElement;
import VilToDrawer;

/**
 * ...
 * @author YellowAfterlife
 */
class KeyRangeCreator {
	public static var element:DivElement = find("key-range-editor");
	public static var svgCtr:DivElement = cast element.querySelector(".svg-ctr");
	public static var svgOld:DivElement = cast svgCtr.querySelector(".svg-old");
	public static var svgNew:DivElement = cast svgCtr.querySelector(".svg-new");
	
	public static var btOpen:InputElement = find("key-range-open");
	public static var btClose:InputElement = find("key-range-close");
	
	public static var btCopyYAML:InputElement = find("key-range-export");
	public static var btOpenSVG:InputElement = find("key-range-import");
	public static var fmOpenSVG:FormElement = find("key-range-svg-form");
	public static var fpOpenSVG:InputElement = find("key-range-svg-picker");
	
	public static var fdOut:TextAreaElement = find("key-range-preview");
	
	public static var btCopyYAML_text = btCopyYAML.value;
	static function btCopyYAML_show(next:String) {
		var orig = btCopyYAML.value;
		if (orig != next) {
			btCopyYAML.value = "Copied!";
			Browser.window.setTimeout(function() {
				btCopyYAML.value = btCopyYAML_text;
			}, 1000);
		}
	}
	
	static var keyInfo:Array<VialKeyInfo> = [];
	static var keyOrder:Array<Int> = [];
	static function update() {
		var newKeys = svgNew.querySelectorAll("g.key");
		var oldKeys = svgOld.querySelectorAll("g.key");
		for (i in 0 ... newKeys.length) {
			var ki = keyOrder[i];
			var okey:Element = ki != null ? cast oldKeys[ki] : null;
			var nkey:Element = cast newKeys[i];
			if (okey != null) {
				var rect = nkey.querySelector("rect").outerHTML;
				nkey.innerHTML = okey.innerHTML;
				nkey.querySelector("rect").outerHTML = rect;
			} else {
				var todo = [];
				for (c in nkey.children) if (c.tagName.toLowerCase() != "rect") todo.push(c);
				for (c in todo) nkey.removeChild(c);
			}
		}
		
		var ranges = [];
		var rangeStart:VialKeyInfo = null;
		var rangeEnd:VialKeyInfo = null;
		function flushRange() {
			var txt = rangeStart.row + "," + rangeStart.col;
			if (rangeEnd.col != rangeStart.col) txt += '-' + rangeEnd.col;
			ranges.push(txt);
		}
		for (i => ki in keyOrder) {
			var kp:VialKeyInfo = keyInfo[ki];
			if (rangeStart == null) {
				rangeStart = rangeEnd = kp;
			} else if (kp.row != rangeEnd.row || kp.col != rangeEnd.col + 1) {
				flushRange();
				rangeStart = rangeEnd = kp;
			} else rangeEnd = kp;
		}
		if (rangeStart != null) flushRange();
		//
		Main.fdKeyRanges.value = fdOut.value = ranges.join("\n");
	}
	
	static var svgMouseDown = false;
	static function svgReady(svg:String) {
		svgOld.innerHTML = svg;
		svgOld.onmousedown = function(e:MouseEvent) {
			svgMouseDown = true;
			var fn;
			fn = function(e:MouseEvent) {
				Browser.window.removeEventListener("mouseup", fn);
				svgMouseDown = false;
				Browser.console.log("up");
			}
			Browser.window.addEventListener("mouseup", fn);
			e.preventDefault();
			return false;
		}
		//
		var keyCount = 0;
		for (_key in svgOld.querySelectorAll("g.key")) {
			var key:Element = cast _key;
			var ki = keyCount++;
			key.onclick = function(_) {
				if (keyOrder.remove(ki)) {
					key.style.opacity = "1";
				} else {
					key.style.opacity = "0.3";
					keyOrder.push(ki);
				}
				update();
			}
			key.onmousemove = function(_) {
				if (svgMouseDown) {
					if (!keyOrder.contains(ki)) {
						keyOrder.push(ki);
						key.style.opacity = "0.3";
						update();
					}
				}
			}
		}
		//
		svgNew.innerHTML = svg;
		for (el in svgNew.querySelectorAll("g.key > text:not(.tap)")) {
			el.parentElement.removeChild(el);
		}
		//
		update();
	}
	public static function init() {
		btCopyYAML.onclick = function(_) {
			var yaml = Main.convert_impl(true);
			if (yaml != null) {
				keyInfo = Main.latestOpt.outKeys;
				Browser.navigator.clipboard.writeText(yaml).then(cast function() {
					btCopyYAML_show("Copied!");
				}).catchError(cast function() {
					btCopyYAML_show("Can't copy!");
				});
			} else {
				btCopyYAML_show("Error!");
			}
		}
		btOpenSVG.onclick = function() {
			fpOpenSVG.click();
		}
		fpOpenSVG.onchange = function() {
			var file = fpOpenSVG.files[0];
			if (file == null) return;
			
			var fileReader = new FileReader();
			fileReader.onloadend = function() {
				fmOpenSVG.reset();
			}
			fileReader.onload = function() {
				svgReady(fileReader.result);
			}
			fileReader.readAsText(file);
		}
		
		btOpen.onclick = function() {
			element.style.display = "";
		}
		btClose.onclick = function() {
			element.style.display = "none";
		}
	}
}
