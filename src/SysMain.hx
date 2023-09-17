package ;
import sys.io.File;
using StringTools;

/**
 * ...
 * @author YellowAfterlife
 */
class SysMain {
	static var config:VilToDrawerOpt = {
		var c = new VilToDrawerOpt();
		c.log = function(level, val) {
			Sys.print('[$level] ');
			Sys.print(val);
			Sys.println('');
		};
		c;
	};
	
	static function error(text:String) {
		Sys.println(text);
		Sys.exit(1);
	}
	static function getText(path:String) {
		try {
			var text = File.getContent(path);
			text = text.replace("\\r", "");
			return text;
		} catch (x:Dynamic) {
			error('Failed to read "$path":' + x);
			return null;
		}
	}
	static var cliOpts:Array<CommandLineOption> = [
		new CommandLineOption("help", [], function() {
			help();
		}, [
			"Shows this documentation and exits.",
		]),
		
		new CommandLineOption("vil", ["path"], function(path) {
			config.parseVil(getText(path));
		}, "Specifies a Vial .vil file to convert"),
		new CommandLineOption("via", ["path"], function(path) {
			config.parseVil(getText(path));
		}, "Specifies a VIA .json file to convert"),
		new CommandLineOption("force-json", [], function() {
			config.yamlLike = false;
		}, [
			"Outputs strict JSON instead of YAML"
		]),
		
		new CommandLineOption("keyboard", ["name"], function(val) {
			config.qmkKeyboard = val;
		}, [
			"Specifies a QMK keyboard name to use, such as",
			"corne_rotated",
			"splitkb/aurora/sofle_v2/rev1",
			"Find the name in configurator: https://config.qmk.fm/",
		]),
		new CommandLineOption("layout", ["name"], function(val) {
			config.qmkLayout = val;
		}, [
			"Specifies a physical layout to use, if keyboard has multiple.",
			"For example, corne_rotated has a LAYOUT_split_3x5_3.",
		]),
		new CommandLineOption("layer", ["index(es)"], function(val) {
			config.parseIncludeLayers(val);
		}, [
			"Only includes the specified layer (like `0`) or layers (like `0,1` in the output)."
		]),
		
		new CommandLineOption("layer-names", ["path"], function(path) {
			config.parseLayerNames(getText(path));
		}, [
			"Specifies a file to load layer names from (one per line)",
		], "Customization"),
		new CommandLineOption("key-labels", ["path"], function(path) {
			config.parseKeyOverrides(getText(path));
		}, [
			"Specifies a file to load key label overrides from. One per line, formatted as",
			"layer number, row, col => new key text",
			"For example,",
			"0,1,2 => COOL",
			"Would replace the label on third key in second row in first layer by COOL.",
			"Custom labels, KC_ names, and lean JSON objects {h:'Hold', t:'Tap'} are supported."
		]),
		new CommandLineOption("mark-unused", ["style"], function(cn) {
			config.markNonKeysAs = cn;
		}, [
			"Shows keys that are set to KC_NO or KC_TRNS on all layers in a different way.",
			"Supported options are:",
			"ghost : Default keymap-drawer style for layout-optional keys",
			"unused : Shows a dashed outline for the keys, without fill",
			"hidden : Hides the keys completely",
		]),
		
		new CommandLineOption("half-after-half", [], function() {
			config.halfAfterHalf = true;
		}, [
			"Specifies that keys are stored half-by-half and row-by-row",
			"(L1, L2, L3, R1, R2, R3 instead of L1, R1, L2, R2, L3, R3)",
		], "Tweaks"),
		new CommandLineOption("mirror-right-half", [], function() {
			config.mirrorRightHalf = true;
		}, [
			"Specifies that keys on the right half of keyboard are stored right-to-left",
			"Happens to keyboards where the PCB and software is identical for two halves",
		]),
		new CommandLineOption("move-defs", ["path"], function(path) {
			config.parseMoveDefs(getText(path));
		}, [
			"Specifies a file to load key move definitions from.",
			"One per line, formatted as one of the folllowing:",
			"old row, old col => new row, new col",
			"old row, old col[count] => new row, new col",
			"old row, old start col - old end col => new row, new col",
			"For example,",
			"1,2 => 0,5",
			"Would move third key from second row to sixth position in the first row.",
			"Rows and columns are counted as they appear in .vil",
		]),
		new CommandLineOption("key-ranges", ["path"], function(path) {
			config.parseRangeDefs(getText(path));
		}, [
			"Specifies a file to load key ranges from.",
			"One per line, formatted as one of the folllowing:",
			"row, start col - end col",
			"row, col",
			"This overrides all of the above tweaks and can be used if the exported layout",
			"is wildly different from the QMK layout.",
		]),
		new CommandLineOption("show-key-row-col", [], function(path) {
			config.parseRangeDefs(getText(path));
		}, [
			"Shows row,column for each key inside the 'Shift' state.",
			"Can make it easier to figure out key ranges.",
		]),
		new CommandLineOption("omit-m1", [], function() {
			config.omitM1 = true;
		}, [
			"Omits keys are set to -1 on all layers",
			"Occasionally used for optional keys in Vial builds.",
		]),
		new CommandLineOption("omit-no", ["layer-count"], function(ns) {
			var n = Std.parseInt(ns);
			if (n == null) throw '"$ns" is not a valid number.';
			config.omitNonKeys = n;
		}, [
			"Omit keys that are set to KC_NO on the given number of layers.",
			"Occasionally used for optional keys in VIA builds.",
			"Set to -1 to check all layers.",
		]),
	];
	
	static function help() {
		CommandLineOption.print(cliOpts);
		Sys.exit(0);
	}
	public static function main() {
		var args = Sys.args().copy();
		if (args.length == 0) help();
		
		try {
			CommandLineOption.run(args, cliOpts);
		} catch (x:Dynamic) {
			error("Error processing arguments: " + x);
		}
		
		if (args.length < 1) {
			error("Expected a .yaml path apart of the options");
		} else if (args.length > 1) {
			error('Multiple candidates for YAML path: ["' + args.join('","') + '"]');
		}
		var yamlPath = args[0];
		
		Sys.println("Converting...");
		var yamlTxt = VilToDrawer.runTxt(config);
		Sys.println('Writing to "$yamlPath"...');
		File.saveContent(args[0], yamlTxt);
		Sys.println("OK!");
	}
}